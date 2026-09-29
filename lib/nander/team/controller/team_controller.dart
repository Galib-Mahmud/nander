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

  final RxList<TeamModel> teams = <TeamModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isClubAdmin = false.obs;
  final RxString currentUserId = ''.obs;

  // Track pending join requests sent in current session
  final RxSet<String> pendingJoinTeamIds = <String>{}.obs;

  // Selected image for adding/editing team
  final Rx<File?> selectedImage = Rx<File?>(null);

  // ─── Trainer Clubs State (Role: TRAINER) ─────────────────────────
  final RxList<ClubTrainerItem> myClubs = <ClubTrainerItem>[].obs;
  final RxList<ClubModel> allClubs = <ClubModel>[].obs;
  final RxList<ClubModel> filteredAllClubs = <ClubModel>[].obs;
  final RxSet<String> pendingClubIds = <String>{}.obs;
  final RxBool isLoadingClubs = false.obs;
  final RxInt trainerTab = 0.obs;
  final TextEditingController clubSearchCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initController();
  }

  @override
  void onClose() {
    clubSearchCtrl.dispose();
    super.onClose();
  }

  Future<void> initController() async {
    await checkUserRole();
    if (isClubAdmin.value) {
      await fetchTeams();
    } else {
      await Future.wait([
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

  // ─── Pick Image for Team ──────────────────────────────────────────
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

  // ─── GET Teams (Role-based) ──────────────────────────────────────
  // Club Admin: /team/my-team
  // Trainer: /team
  Future<void> fetchTeams() async {
    isLoading.value = true;
    try {
      final endpoint =
          isClubAdmin.value ? ApiEndpoint.myTeam : ApiEndpoint.team;
      debugPrint(
          '📡 Fetching teams from: $endpoint (role: ${isClubAdmin.value ? "CLUB_ADMIN" : "TRAINER"})');

      final response = await _apiClient.get(endpoint, requiresAuth: true);

      if (response?['success'] == true) {
        final dynamic raw = response['data'];
        final List<dynamic> list = (raw is List)
            ? raw
            : (raw is Map && raw['teams'] is List)
                ? raw['teams']
                : [];

        final parsed = <TeamModel>[];
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            try {
              parsed.add(TeamModel.fromJson(item));
            } catch (e) {
              debugPrint('⚠️ Error parsing team item: $e');
            }
          }
        }

        teams.assignAll(parsed);
        debugPrint('✅ Loaded ${teams.length} teams from $endpoint');
      }
    } catch (e) {
      debugPrint('❌ Fetch teams error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── GET Trainer Clubs (GET /trainer/my-clubs) ────────────────────
  Future<void> fetchMyClubs() async {
    isLoadingClubs.value = true;
    try {
      debugPrint('📡 Fetching trainer clubs from: ${ApiEndpoint.myClubs}');
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
        debugPrint(
            '✅ Loaded ${myClubs.length} clubs from ${ApiEndpoint.myClubs}');
      }
    } catch (e) {
      debugPrint('❌ Fetch my clubs error: $e');
    } finally {
      isLoadingClubs.value = false;
    }
  }

  // ─── GET All Clubs (GET /club/list) ───────────────────────────────
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

  // ─── POST Send Request to Club (POST /trainer/send-request-by-trainer) ──
  Future<bool> sendRequestToClub(String clubId) async {
    isSubmitting.value = true;
    try {
      debugPrint(
          '📡 Sending request to club $clubId via ${ApiEndpoint.sendRequestByTrainer}');
      final response = await _apiClient.post(
        ApiEndpoint.sendRequestByTrainer,
        body: {"clubId": clubId},
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
      } else {
        Get.snackbar(
          'Notice',
          response?['message'] ?? 'Failed to send request.',
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
        );
        return false;
      }
    } on HttpException catch (e) {
      Get.snackbar('Error', e.message,
          backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } catch (e) {
      debugPrint('❌ Send request to club error: $e');
      Get.snackbar('Error', 'Failed to send request to club',
          backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── GET Single Team ──────────────────────────────────────────────
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

  // ─── POST Create Team (form-data) ─────────────────────────────────
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

      debugPrint('📤 Creating team: $fields, files: ${files.keys}');

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

  // ─── PATCH Update Team (form-data) ────────────────────────────────
  Future<bool> updateTeam({
    required String id,
    required String name,
    required String bio,
    required String address,
    required String sendEmail,
    required String trainerName,
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
        'sendEmail': sendEmail.trim(),
        'trainerName': trainerName.trim(),
      };

      final fileToUpload = imageFile ?? selectedImage.value;
      final Map<String, File> files = {};
      if (fileToUpload != null) {
        files['image'] = fileToUpload;
      }

      debugPrint('📤 Updating team: $fields, files: ${files.keys}');

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

  // ─── DELETE Team ──────────────────────────────────────────────────
  Future<bool> deleteTeam(String id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoint.teamDelete(id),
          requiresAuth: true);
      if (response?['success'] == true) {
        teams.removeWhere((t) => t.id == id);
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

  // ─── POST Add Team Member (Club Admin only) ───────────────────────
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
        if (trainerId != null && trainerId.isNotEmpty) 'trainerId': trainerId,
        if (trainerName != null && trainerName.isNotEmpty)
          'trainerName': trainerName,
        if (sendEmail != null && sendEmail.isNotEmpty) 'sendEmail': sendEmail,
        if (isSendByEmail) 'isSendByEmail': true,
      };

      debugPrint('📤 Adding team member: $body');
      final response = await _apiClient.post(
        ApiEndpoint.teamAddMember,
        body: body,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        Get.snackbar(
          'Success',
          response?['message'] ?? 'Team member added successfully',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );
        await fetchTeams();
        return true;
      }
      return false;
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

  // ─── POST Join Request By Trainer (Trainer only) ──────────────────
  Future<bool> joinTeamAsTrainer(String teamId) async {
    isSubmitting.value = true;
    try {
      final body = {'teamId': teamId};
      debugPrint('📤 Sending join request: $body');

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
        );
        await fetchTeams();
        return true;
      }
      return false;
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

  // ─── 11 & 12. Team Members Management ──────────────────────────────
  final RxList<TeamMemberModel> activeTeamMembers = <TeamMemberModel>[].obs;
  final RxList<TeamMemberModel> requestTeamMembers = <TeamMemberModel>[].obs;
  final RxBool isLoadingMembers = false.obs;

  Future<void> fetchActiveTeamMembers(String teamId) async {
    isLoadingMembers.value = true;
    try {
      final response = await _apiClient.get(
        ApiEndpoint.activeTeamMembers(teamId),
        requiresAuth: true,
      );
      if (response?['success'] == true) {
        final dynamic raw = response['data'];
        final List<dynamic> list = (raw is List) ? raw : [];
        activeTeamMembers.assignAll(
          list
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

  Future<void> fetchRequestTeamMembers(String teamId) async {
    isLoadingMembers.value = true;
    try {
      final response = await _apiClient.get(
        ApiEndpoint.requestTeamMembers(teamId),
        requiresAuth: true,
      );
      if (response?['success'] == true) {
        final dynamic raw = response['data'];
        final List<dynamic> list = (raw is List) ? raw : [];
        requestTeamMembers.assignAll(
          list
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

  // 13. Trainer Accept/Reject by Admin
  Future<bool> respondToTeamRequestByAdmin({
    required String teamId,
    required String requestId,
    required bool isAccept,
  }) async {
    try {
      final body = {
        'id': requestId,
        'requestId': requestId,
        'status': isAccept ? 'ACTIVE' : 'REJECTED',
      };
      debugPrint('📤 Admin responding to team member request: $body');
      final response = await _apiClient.patch(
        ApiEndpoint.teamTrainerAcceptReject,
        body: body,
        requiresAuth: true,
      );
      if (response?['success'] == true) {
        Get.snackbar(
          isAccept ? 'Approved' : 'Declined',
          response?['message'] ?? 'Request processed successfully',
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
      }
      return false;
    } catch (e) {
      debugPrint('❌ Admin respond to team member request error: $e');
      Get.snackbar('Error', 'Failed to process request',
          backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    }
  }

  // 14. Trainer Accept/Reject by Trainer
  Future<bool> respondToTeamRequestByTrainer({
    required String teamId,
    required String requestId,
    required bool isAccept,
  }) async {
    try {
      final body = {
        'id': requestId,
        'requestId': requestId,
        'status': isAccept ? 'ACTIVE' : 'REJECTED',
      };
      debugPrint('📤 Trainer responding to team invitation: $body');
      final response = await _apiClient.patch(
        ApiEndpoint.teamClubAdminAcceptReject,
        body: body,
        requiresAuth: true,
      );
      if (response?['success'] == true) {
        Get.snackbar(
          isAccept ? 'Approved' : 'Declined',
          response?['message'] ?? 'Request processed successfully',
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
      }
      return false;
    } catch (e) {
      debugPrint('❌ Trainer respond to team invitation error: $e');
      Get.snackbar('Error', 'Failed to process request',
          backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    }
  }
}
