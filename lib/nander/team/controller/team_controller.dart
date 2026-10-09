import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/controller/club_model.dart';
import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../core/local_storage/user_info.dart';
import '../../trainers/model/trainer_model.dart';
import 'team_model.dart';

class TeamController extends GetxController {
  static TeamController get to => Get.isRegistered<TeamController>()
      ? Get.find<TeamController>()
      : Get.put(TeamController());

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);
  final ImagePicker _picker = ImagePicker();

  // ─── General & Role State ─────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isClubAdmin = false.obs;
  final RxString currentUserId = ''.obs;

  // Selected image for adding/editing team (form-data)
  final Rx<File?> selectedImage = Rx<File?>(null);

  // ─── Club Admin Teams State (GET /team/my-team) ───────────────────
  final RxList<TeamModel> teams = <TeamModel>[].obs;

  // Team Members for Selected Team (Admin management)
  final RxList<TeamMemberModel> activeTeamMembers = <TeamMemberModel>[].obs;
  final RxList<TeamMemberModel> requestTeamMembers = <TeamMemberModel>[].obs;
  final RxBool isLoadingMembers = false.obs;

  // ─── Trainer Teams State (Role: TRAINER) ──────────────────────────
  final RxInt trainerTab = 0.obs; // 0: My Teams, 1: Browse Teams, 2: Requests
  final RxList<TeamModel> myTeams = <TeamModel>[].obs; // Joined/Active Teams
  final RxList<TeamModel> allTeams = <TeamModel>[].obs; // All teams to browse
  final RxList<TeamModel> filteredAllTeams = <TeamModel>[].obs;
  final RxList<TeamModel> requestedTeams = <TeamModel>[].obs; // Requests/Invites
  final RxSet<String> pendingJoinTeamIds = <String>{}.obs;
  final TextEditingController teamSearchCtrl = TextEditingController();

  // ─── Legacy Trainer Clubs State (for backward compatibility) ──────
  final RxList<ClubTrainerItem> myClubs = <ClubTrainerItem>[].obs;
  final RxList<ClubModel> allClubs = <ClubModel>[].obs;
  final RxList<ClubModel> filteredAllClubs = <ClubModel>[].obs;
  final RxSet<String> pendingClubIds = <String>{}.obs;
  final RxBool isLoadingClubs = false.obs;
  final TextEditingController clubSearchCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initController();
  }

  @override
  void onClose() {
    teamSearchCtrl.dispose();
    clubSearchCtrl.dispose();
    super.onClose();
  }

  // ─── Helper for extracting dynamic lists ──────────────────────────
  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['teams'] is List) return data['teams'] as List;
      if (data['activeTeams'] is List) return data['activeTeams'] as List;
      if (data['requestTeams'] is List) return data['requestTeams'] as List;
      if (data['members'] is List) return data['members'] as List;
      if (data['data'] is List) return data['data'] as List;
      if (data['items'] is List) return data['items'] as List;
      if (data['results'] is List) return data['results'] as List;
      if (data['data'] is Map) return _extractList(data['data']);
    }
    return [];
  }

  // ─── Lifecycle & Role Detection ───────────────────────────────────
  Future<void> initController() async {
    await checkUserRole();
    if (isClubAdmin.value) {
      await fetchTeams();
    } else {
      await Future.wait([
        fetchTrainerData(),
        fetchMyClubs(),
        fetchAllClubs(),
      ]);
    }
  }

  Future<void> refreshData() async {
    await checkUserRole();
    if (isClubAdmin.value) {
      await fetchTeams();
    } else {
      await Future.wait([
        fetchTrainerData(),
        fetchMyClubs(),
        fetchAllClubs(),
      ]);
    }
  }

  Future<void> checkUserRole() async {
    final role = await UserInfo.getUserRole();
    isClubAdmin.value = (role == 'CLUB_ADMIN');
    final uid = await UserInfo.getUserId();
    if (uid != null) currentUserId.value = uid;
    debugPrint(
        '👥 TeamController - User role: $role, isClubAdmin: ${isClubAdmin.value}, userId: ${currentUserId.value}');
  }

  // ─── Pick Image for Team (form-data) ──────────────────────────────
  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        selectedImage.value = File(picked.path);
      }
    } catch (e) {
      debugPrint('❌ Pick image error: $e');
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  void clearSelectedImage() {
    selectedImage.value = null;
  }

  // ─────────────────────────────────────────────────────────────────
  // 3. GET My Teams (Club Admin: GET /team/my-team)
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchTeams() async {
    if (!isClubAdmin.value) {
      await fetchTrainerData();
      return;
    }

    isLoading.value = true;
    try {
      debugPrint('📡 [Club Admin] Fetching my teams: ${ApiEndpoint.myTeam}');
      final response = await _apiClient.get(ApiEndpoint.myTeam, requiresAuth: true);

      if (response?['success'] == true && response?['data'] != null) {
        final rawList = _extractList(response['data']);
        final parsed = <TeamModel>[];
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            try {
              parsed.add(TeamModel.fromJson(item));
            } catch (e) {
              debugPrint('⚠️ Error parsing admin team item: $e');
            }
          }
        }
        teams.assignAll(parsed);
        debugPrint('✅ Loaded ${teams.length} teams for club admin');
      }
    } catch (e) {
      debugPrint('❌ Fetch admin teams error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // TRAINER FLOW: Fetch all trainer data
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchTrainerData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchMyTeamsWithProgress(),
        fetchTrainerActiveTeams(),
        fetchAllTeamsForTrainer(),
        fetchTrainerRequestTeams(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 7. GET My Team With Progress (GET /team/my-team-with-progress)
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchMyTeamsWithProgress() async {
    try {
      debugPrint('📡 [Trainer] Fetching my teams with progress: ${ApiEndpoint.myTeamWithProgress}');
      final response = await _apiClient.get(ApiEndpoint.myTeamWithProgress, requiresAuth: true);

      List<TeamModel> loadedTeams = [];

      if (response?['success'] == true && response?['data'] != null) {
        final rawList = _extractList(response['data']);
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            try {
              loadedTeams.add(TeamModel.fromJson(item));
            } catch (e) {
              debugPrint('⚠️ Error parsing myTeamWithProgress item: $e');
            }
          }
        }
      }

      if (loadedTeams.isNotEmpty) {
        myTeams.assignAll(loadedTeams);
        teams.assignAll(loadedTeams);
        debugPrint('✅ [Trainer] Loaded ${myTeams.length} teams with progress');
      }
    } catch (e) {
      debugPrint('❌ Fetch trainer my teams with progress error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 15. GET Active Teams by Trainer (GET /team/active-teams)
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchTrainerActiveTeams() async {
    try {
      debugPrint('📡 [Trainer] Fetching active teams: ${ApiEndpoint.activeTeams}');
      final activeResp = await _apiClient.get(ApiEndpoint.activeTeams, requiresAuth: true);
      if (activeResp?['success'] == true && activeResp?['data'] != null) {
        final rawList = _extractList(activeResp['data']);
        final List<TeamModel> activeList = [];
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            try {
              activeList.add(TeamModel.fromJson(item));
            } catch (e) {
              debugPrint('⚠️ Error parsing activeTeams item: $e');
            }
          }
        }
        for (final t in activeList) {
          final existingIdx = myTeams.indexWhere((existing) => existing.id == t.id);
          if (existingIdx == -1) {
            myTeams.add(t);
          }
        }
        teams.assignAll(myTeams);
        debugPrint('✅ [Trainer] Total active/joined teams: ${myTeams.length}');
      }
    } catch (e) {
      debugPrint('❌ Fetch trainer active teams error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 4. GET All Team by Trainer (GET /team)
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchAllTeamsForTrainer({String? query}) async {
    try {
      final endpoint = (query != null && query.trim().isNotEmpty)
          ? '${ApiEndpoint.team}?search=${Uri.encodeComponent(query.trim())}'
          : ApiEndpoint.team;
      debugPrint('📡 [Trainer] Fetching all teams: $endpoint');

      final response = await _apiClient.get(endpoint, requiresAuth: true);
      if (response?['success'] == true && response?['data'] != null) {
        final rawList = _extractList(response['data']);
        final parsed = <TeamModel>[];
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            try {
              parsed.add(TeamModel.fromJson(item));
            } catch (e) {
              debugPrint('⚠️ Error parsing all team item: $e');
            }
          }
        }
        allTeams.assignAll(parsed);
        filterAllTeams(teamSearchCtrl.text);
        debugPrint('✅ [Trainer] Loaded ${allTeams.length} total teams');
      }
    } catch (e) {
      debugPrint('❌ Fetch all teams error: $e');
    }
  }

  void filterAllTeams(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filteredAllTeams.assignAll(allTeams);
    } else {
      filteredAllTeams.assignAll(allTeams.where((t) =>
      t.name.toLowerCase().contains(q) ||
          (t.address ?? '').toLowerCase().contains(q) ||
          (t.bio ?? '').toLowerCase().contains(q) ||
          (t.trainerName ?? '').toLowerCase().contains(q) ||
          (t.club?.name ?? '').toLowerCase().contains(q)));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 16. GET Request Team Member by Trainer (GET /team/request-teams)
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchTrainerRequestTeams() async {
    try {
      debugPrint('📡 [Trainer] Fetching requested teams: ${ApiEndpoint.requestTeams}');
      final response = await _apiClient.get(ApiEndpoint.requestTeams, requiresAuth: true);

      if (response?['success'] == true && response?['data'] != null) {
        final rawList = _extractList(response['data']);
        final parsed = <TeamModel>[];
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            try {
              parsed.add(TeamModel.fromJson(item));
            } catch (e) {
              debugPrint('⚠️ Error parsing request team item: $e');
            }
          }
        }
        requestedTeams.assignAll(parsed);
        debugPrint('✅ [Trainer] Loaded ${requestedTeams.length} pending team requests');
      }
    } catch (e) {
      debugPrint('❌ Fetch trainer request teams error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 10. POST Join Request by Trainer (POST /team/join-request-by-trainer)
  // ─────────────────────────────────────────────────────────────────
  Future<bool> joinTeamAsTrainer(String teamId) async {
    isSubmitting.value = true;
    try {
      final body = {'teamId': teamId};
      debugPrint('📤 [Trainer] Sending join request: $body to ${ApiEndpoint.teamJoinRequestByTrainer}');

      final response = await _apiClient.post(
        ApiEndpoint.teamJoinRequestByTrainer,
        body: body,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        pendingJoinTeamIds.add(teamId);
        Get.snackbar(
          'Success',
          response?['message'] ?? 'Join request sent successfully',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        await Future.wait([
          fetchAllTeamsForTrainer(),
          fetchTrainerRequestTeams(),
        ]);
        return true;
      } else {
        Get.snackbar(
          'Notice',
          response?['message'] ?? 'Failed to send join request',
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
        );
        return false;
      }
    } on HttpException catch (e) {
      debugPrint('❌ Join team error: $e');
      Get.snackbar('Error', e.message,
          backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } catch (e) {
      debugPrint('❌ Join team error: $e');
      Get.snackbar('Error', 'Failed to send join request',
          backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 12. Accept / Reject Joining Request by Trainer (PATCH /trainer/trainer-accept-reject)
  // ─────────────────────────────────────────────────────────────────
  Future<bool> respondToTrainerInvitation({
    required String requestId,
    required bool isAccept,
    String? teamId,
  }) async {
    isSubmitting.value = true;
    try {
      final status = isAccept ? 'accepted' : 'rejected';
      final body = {
        'requestId': requestId,
        'status': status,
      };
      debugPrint('📤 [Trainer] Responding to request: $body');

      // Try primary endpoint: /trainer/trainer-accept-reject
      dynamic response = await _apiClient.patch(
        ApiEndpoint.trainerAcceptReject,
        body: body,
        requiresAuth: true,
      );

      // Fallback if not accepted on /trainer/...
      if (response == null || response['success'] != true) {
        try {
          response = await _apiClient.patch(
            ApiEndpoint.teamTrainerAcceptReject,
            body: body,
            requiresAuth: true,
          );
        } catch (_) {}
      }

      if (response?['success'] == true) {
        Get.snackbar(
          isAccept ? 'Accepted' : 'Declined',
          response?['message'] ??
              (isAccept ? 'Invitation accepted successfully' : 'Invitation declined'),
          backgroundColor: isAccept ? Colors.green.shade700 : Colors.red.shade800,
          colorText: Colors.white,
        );
        await fetchTrainerData();
        return true;
      } else {
        Get.snackbar(
          'Error',
          response?['message'] ?? 'Failed to update invitation status',
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Trainer accept/reject invitation error: $e');
      Get.snackbar('Error', 'Failed to update invitation',
          backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 1. POST Create Team (Club Admin: POST /team/create)
  // ─────────────────────────────────────────────────────────────────
  Future<bool> createTeam({
    required String name,
    required String bio,
    required String address,
    required String sendEmail,
    required String trainerName,
    String? trainerId,
    bool isSendByEmail = false,
    File? imageFile,
  }) async {
    if (name.trim().isEmpty) {
      Get.snackbar('Error', 'Team name is required');
      return false;
    }

    isSubmitting.value = true;
    try {
      final fields = {
        'name': name.trim(),
        'bio': bio.trim(),
        'address': address.trim(),
        'sendEmail': sendEmail.trim(),
        'trainerName': trainerName.trim(),
        'trainerId': trainerId ?? '',
        'isSendByEmail': isSendByEmail ? 'true' : 'false',
      };

      final fileToUpload = imageFile ?? selectedImage.value;
      final Map<String, File> files = {};
      if (fileToUpload != null) {
        files['image'] = fileToUpload;
      }

      debugPrint('📤 [Club Admin] Creating team: $fields, files: ${files.keys}');

      final response = await _apiClient.multipart(
        ApiEndpoint.teamCreate,
        method: 'POST',
        fields: fields,
        files: files.isNotEmpty ? files : null,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        selectedImage.value = null;
        Get.back(); // close screen
        Get.snackbar(
          'Success',
          response?['message'] ?? 'Team created successfully',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );
        await fetchTeams();
        return true;
      }
      return false;
    } on HttpException catch (e) {
      debugPrint('❌ Create team error: $e');
      Get.snackbar('Error', e.message,
          backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } catch (e) {
      debugPrint('❌ Create team error: $e');
      Get.snackbar('Error', 'Failed to create team',
          backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 2. PATCH Update Team (Club Admin: PATCH /team/update)
  // ─────────────────────────────────────────────────────────────────
  Future<bool> updateTeam({
    required String id,
    required String name,
    required String bio,
    required String address,
    String? sendEmail,
    String? trainerName,
    File? imageFile,
  }) async {
    if (name.trim().isEmpty) {
      Get.snackbar('Error', 'Team name is required');
      return false;
    }

    isSubmitting.value = true;
    try {
      final fields = {
        'id': id,
        'name': name.trim(),
        'bio': bio.trim(),
        'address': address.trim(),
        if (sendEmail != null) 'sendEmail': sendEmail.trim(),
        if (trainerName != null) 'trainerName': trainerName.trim(),
      };

      final fileToUpload = imageFile ?? selectedImage.value;
      final Map<String, File> files = {};
      if (fileToUpload != null) {
        files['image'] = fileToUpload;
      }

      debugPrint('📤 [Club Admin] Updating team: $fields, files: ${files.keys}');

      final response = await _apiClient.multipart(
        ApiEndpoint.teamUpdate,
        method: 'PATCH',
        fields: fields,
        files: files.isNotEmpty ? files : null,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        selectedImage.value = null;
        Get.back();
        Get.snackbar(
          'Success',
          response?['message'] ?? 'Team updated successfully',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );
        await fetchTeams();
        return true;
      }
      return false;
    } on HttpException catch (e) {
      debugPrint('❌ Update team error: $e');
      Get.snackbar('Error', e.message,
          backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } catch (e) {
      debugPrint('❌ Update team error: $e');
      Get.snackbar('Error', 'Failed to update team',
          backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 5. GET Single Team (GET /team/:teamId)
  // ─────────────────────────────────────────────────────────────────
  Future<TeamModel?> fetchSingleTeam(String id) async {
    try {
      final response =
      await _apiClient.get(ApiEndpoint.teamDetail(id), requiresAuth: true);
      if (response?['success'] == true &&
          response['data'] is Map<String, dynamic>) {
        return TeamModel.fromJson(response['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('❌ Fetch single team error: $e');
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────
  // 8. GET Single Team With Progress (GET /team/single-team-with-progress/:teamId)
  // ─────────────────────────────────────────────────────────────────
  Future<TeamModel?> fetchSingleTeamWithProgress(String teamId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoint.singleTeamWithProgress(teamId),
        requiresAuth: true,
      );
      if (response?['success'] == true && response?['data'] is Map<String, dynamic>) {
        return TeamModel.fromJson(response['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('❌ Fetch single team with progress error: $e');
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────
  // 6. DELETE Team (DELETE /team/:teamId)
  // ─────────────────────────────────────────────────────────────────
  Future<bool> deleteTeam(String id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoint.teamDelete(id),
          requiresAuth: true);
      if (response?['success'] == true) {
        teams.removeWhere((t) => t.id == id);
        myTeams.removeWhere((t) => t.id == id);
        allTeams.removeWhere((t) => t.id == id);
        filteredAllTeams.removeWhere((t) => t.id == id);
        Get.snackbar(
          'Deleted',
          response?['message'] ?? 'Team deleted successfully',
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Delete team error: $e');
      Get.snackbar('Error', 'Failed to delete team');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 9. POST Add Team Member by Admin (POST /team/add-member)
  // ─────────────────────────────────────────────────────────────────
  Future<bool> addTeamMember({
    required String teamId,
    String? trainerId,
    String? trainerName,
    String? sendEmail,
    bool isSendByEmail = false,
  }) async {
    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'teamId': teamId,
        'trainerId': trainerId ?? '',
        'sendEmail': sendEmail ?? '',
        'trainerName': trainerName ?? '',
        'isSendByEmail': isSendByEmail,
      };

      debugPrint('📤 [Club Admin] Adding team member: $body to ${ApiEndpoint.teamAddMember}');
      final response = await _apiClient.post(
        ApiEndpoint.teamAddMember,
        body: body,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        Get.snackbar(
          'Success',
          response?['message'] ?? 'Team member added / invitation sent successfully',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );
        await Future.wait([
          fetchActiveTeamMembers(teamId),
          fetchRequestTeamMembers(teamId),
          fetchTeams(),
        ]);
        return true;
      } else {
        Get.snackbar(
          'Error',
          response?['message'] ?? 'Failed to add team member',
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
        );
        return false;
      }
    } on HttpException catch (e) {
      debugPrint('❌ Add member error: $e');
      Get.snackbar('Error', e.message,
          backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } catch (e) {
      debugPrint('❌ Add member error: $e');
      Get.snackbar('Error', 'Failed to add member',
          backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 13. GET Active Team Member by Admin (GET /team/active-team-members/:teamId)
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchActiveTeamMembers(String teamId) async {
    isLoadingMembers.value = true;
    try {
      final response = await _apiClient.get(
        ApiEndpoint.activeTeamMembers(teamId),
        requiresAuth: true,
      );
      if (response?['success'] == true && response?['data'] != null) {
        final rawList = _extractList(response['data']);
        activeTeamMembers.assignAll(
          rawList
              .whereType<Map<String, dynamic>>()
              .map(TeamMemberModel.fromJson)
              .toList(),
        );
        debugPrint(
            '👥 Loaded ${activeTeamMembers.length} active members for team $teamId');
      }
    } catch (e) {
      debugPrint('❌ Fetch active team members error: $e');
    } finally {
      isLoadingMembers.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 14. GET Request Team Member by Admin (GET /team/request-team-members/:teamId)
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchRequestTeamMembers(String teamId) async {
    isLoadingMembers.value = true;
    try {
      final response = await _apiClient.get(
        ApiEndpoint.requestTeamMembers(teamId),
        requiresAuth: true,
      );
      if (response?['success'] == true && response?['data'] != null) {
        final rawList = _extractList(response['data']);
        requestTeamMembers.assignAll(
          rawList
              .whereType<Map<String, dynamic>>()
              .map(TeamMemberModel.fromJson)
              .toList(),
        );
        debugPrint(
            '👥 Loaded ${requestTeamMembers.length} request members for team $teamId');
      }
    } catch (e) {
      debugPrint('❌ Fetch request team members error: $e');
    } finally {
      isLoadingMembers.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 11 & 17. Trainer Accept or Reject by Admin (PATCH /team/trainer-accept-reject)
  // ─────────────────────────────────────────────────────────────────
  Future<bool> respondToTeamRequestByAdmin({
    required String teamId,
    required String requestId,
    required bool isAccept,
  }) async {
    try {
      final status = isAccept ? 'accepted' : 'rejected';
      final body = {
        'requestId': requestId,
        'status': status,
      };
      debugPrint('📤 [Club Admin] Responding to trainer request: $body');

      // Primary endpoint 17: /team/trainer-accept-reject
      dynamic response = await _apiClient.patch(
        ApiEndpoint.teamTrainerAcceptReject,
        body: body,
        requiresAuth: true,
      );

      // Fallback endpoint 11: /trainer/trainer-accept-reject if needed
      if (response == null || response['success'] != true) {
        try {
          response = await _apiClient.patch(
            ApiEndpoint.trainerAcceptReject,
            body: body,
            requiresAuth: true,
          );
        } catch (_) {}
      }

      if (response?['success'] == true) {
        Get.snackbar(
          isAccept ? 'Approved' : 'Declined',
          response?['message'] ?? (isAccept ? 'Trainer approved' : 'Request declined'),
          backgroundColor:
          isAccept ? Colors.green.shade700 : Colors.red.shade800,
          colorText: Colors.white,
        );
        await Future.wait([
          fetchActiveTeamMembers(teamId),
          fetchRequestTeamMembers(teamId),
          fetchTeams(),
        ]);
        return true;
      } else {
        Get.snackbar(
          'Error',
          response?['message'] ?? 'Failed to process request',
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Admin respond to team member request error: $e');
      Get.snackbar('Error', 'Failed to process request',
          backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Compatibility methods for Trainer Clubs (keeps existing screens functional)
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchMyClubs() async {
    isLoadingClubs.value = true;
    try {
      final response =
      await _apiClient.get(ApiEndpoint.myClubs, requiresAuth: true);
      if (response?['success'] == true && response?['data'] is List) {
        final list = (response['data'] as List)
            .map((item) =>
            ClubTrainerItem.fromJson(item as Map<String, dynamic>))
            .toList();
        myClubs.assignAll(list);
        for (final item in list) {
          if (item.clubAdmin?.id != null && item.clubAdmin!.id.isNotEmpty) {
            pendingClubIds.add(item.clubAdmin!.id);
          }
          if (item.clubAdminId != null && item.clubAdminId!.isNotEmpty) {
            pendingClubIds.add(item.clubAdminId!);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Fetch my clubs error: $e');
    } finally {
      isLoadingClubs.value = false;
    }
  }

  Future<void> fetchAllClubs({String? query}) async {
    try {
      final endpoint = (query != null && query.trim().isNotEmpty)
          ? '/club/list?search=${Uri.encodeComponent(query.trim())}'
          : '/club/list';
      final response = await _apiClient.get(endpoint, requiresAuth: true);
      if (response?['success'] == true && response?['data'] is List) {
        final raw = response['data'] as List;
        final list = <ClubModel>[];
        for (final item in raw) {
          try {
            list.add(ClubModel.fromJson(item as Map<String, dynamic>));
          } catch (e) {
            debugPrint('⚠️ Error parsing club item: $e');
          }
        }
        allClubs.assignAll(list);
        filterAllClubs(clubSearchCtrl.text);
      }
    } catch (e) {
      debugPrint('❌ Fetch all clubs error: $e');
    }
  }

  void filterAllClubs(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filteredAllClubs.assignAll(allClubs);
    } else {
      filteredAllClubs.assignAll(allClubs.where((c) =>
      c.name.toLowerCase().contains(q) ||
          (c.address ?? '').toLowerCase().contains(q) ||
          (c.bio ?? '').toLowerCase().contains(q)));
    }
  }

  Future<bool> sendRequestToClub(String clubId) async {
    isSubmitting.value = true;
    try {
      final response = await _apiClient.post(
        ApiEndpoint.sendRequestByTrainer,
        body: {"clubAdminId": clubId},
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        pendingClubIds.add(clubId);
        Get.snackbar(
          'Success',
          response?['message'] ?? 'Request sent to club successfully.',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        await fetchMyClubs();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Send request to club error: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
