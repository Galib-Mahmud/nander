import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../core/local_storage/user_info.dart';
import '../model/trainer_model.dart';

class TrainerController extends GetxController {
  static TrainerController get to => Get.isRegistered<TrainerController>()
      ? Get.find<TrainerController>()
      : Get.put(TrainerController());

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  // Tabs: 0 -> My Trainers, 1 -> Trainer's Request
  final RxInt selectedTab = 0.obs;

  final RxBool isLoadingMyTrainers = false.obs;
  final RxBool isLoadingRequests = false.obs;
  final RxBool isLoadingAllTrainers = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString userRole = 'CLUB_ADMIN'.obs;

  // Lists
  final RxList<ClubTrainerItem> myTrainers = <ClubTrainerItem>[].obs;
  final RxList<ClubTrainerItem> filteredMyTrainers = <ClubTrainerItem>[].obs;

  final RxList<ClubTrainerItem> requests = <ClubTrainerItem>[].obs;
  final RxList<ClubTrainerItem> filteredRequests = <ClubTrainerItem>[].obs;

  final RxList<TrainerModel> allTrainers = <TrainerModel>[].obs;
  final RxList<TrainerModel> searchResults = <TrainerModel>[].obs;

  // Track sent requests
  final RxSet<String> requestedTrainerIds = <String>{}.obs;

  // Search controllers
  final TextEditingController searchMainCtrl = TextEditingController();
  final TextEditingController searchAddCtrl = TextEditingController();

  // Invite controllers
  final TextEditingController inviteNameCtrl = TextEditingController();
  final TextEditingController inviteEmailCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkRoleAndFetch();
  }

  @override
  void onClose() {
    searchMainCtrl.dispose();
    searchAddCtrl.dispose();
    inviteNameCtrl.dispose();
    inviteEmailCtrl.dispose();
    super.onClose();
  }

  Future<void> checkRoleAndFetch() async {
    final role = await UserInfo.getUserRole();
    if (role != null && role.isNotEmpty) {
      userRole.value = role;
    }
    await Future.wait([
      fetchMyTrainers(),
      fetchTrainerRequests(),
      fetchAllTrainers(),
    ]);
  }

  // ─── 1. Fetch My Trainers / Clubs ────────────────────────────────
  Future<void> fetchMyTrainers() async {
    isLoadingMyTrainers.value = true;
    try {
      final endpoint = (userRole.value == 'TRAINER')
          ? ApiEndpoint.myClubs
          : ApiEndpoint.myClubTrainers;

      final response = await _apiClient.get(endpoint, requiresAuth: true);
      if (response?['success'] == true && response?['data'] is List) {
        final list = (response['data'] as List)
            .map((item) => ClubTrainerItem.fromJson(item as Map<String, dynamic>))
            .toList();
        myTrainers.assignAll(list);
        applyMainSearch(searchMainCtrl.text);
      }
    } catch (e) {
      debugPrint('❌ Fetch my trainers error: $e');
    } finally {
      isLoadingMyTrainers.value = false;
    }
  }

  // ─── 2. Fetch Trainer Requests ──────────────────────────────────
  Future<void> fetchTrainerRequests() async {
    isLoadingRequests.value = true;
    try {
      final endpoint = (userRole.value == 'TRAINER')
          ? ApiEndpoint.myClubsRequest
          : ApiEndpoint.myClubTrainersRequest;

      final response = await _apiClient.get(endpoint, requiresAuth: true);
      if (response?['success'] == true && response?['data'] is List) {
        final list = (response['data'] as List)
            .map((item) => ClubTrainerItem.fromJson(item as Map<String, dynamic>))
            .toList();
        requests.assignAll(list);

        for (final req in list) {
          if (req.trainerId != null && req.trainerId!.isNotEmpty) {
            requestedTrainerIds.add(req.trainerId!);
          }
        }
        applyMainSearch(searchMainCtrl.text);
      }
    } catch (e) {
      debugPrint('❌ Fetch trainer requests error: $e');
    } finally {
      isLoadingRequests.value = false;
    }
  }

  // ─── 3. Fetch All Trainers (for Add Trainer screen) ──────────────
  Future<void> fetchAllTrainers() async {
    isLoadingAllTrainers.value = true;
    try {
      final response = await _apiClient.get(ApiEndpoint.trainerList, requiresAuth: true);
      if (response?['success'] == true && response?['data'] is List) {
        final list = (response['data'] as List)
            .map((item) => TrainerModel.fromJson(item as Map<String, dynamic>))
            .toList();
        allTrainers.assignAll(list);
        applyAddSearch(searchAddCtrl.text);
      }
    } catch (e) {
      debugPrint('❌ Fetch all trainers error: $e');
    } finally {
      isLoadingAllTrainers.value = false;
    }
  }

  // ─── 4. Search Filter for Main Screen ────────────────────────────
  void applyMainSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filteredMyTrainers.assignAll(myTrainers);
      filteredRequests.assignAll(requests);
    } else {
      filteredMyTrainers.assignAll(
        myTrainers.where((item) =>
            item.displayName.toLowerCase().contains(q) ||
            item.displayEmail.toLowerCase().contains(q)),
      );
      filteredRequests.assignAll(
        requests.where((item) =>
            item.displayName.toLowerCase().contains(q) ||
            item.displayEmail.toLowerCase().contains(q)),
      );
    }
  }

  // ─── 5. Search Filter for Add Trainer Screen ─────────────────────
  void applyAddSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      searchResults.assignAll(allTrainers);
    } else {
      searchResults.assignAll(
        allTrainers.where((t) =>
            t.name.toLowerCase().contains(q) ||
            t.email.toLowerCase().contains(q)),
      );
    }
  }

  // ─── 6. Send Request To Existing Trainer ─────────────────────────
  Future<bool> sendRequestToTrainer(String trainerId) async {
    isSubmitting.value = true;
    try {
      final endpoint = (userRole.value == 'TRAINER')
          ? ApiEndpoint.sendRequestByTrainer
          : ApiEndpoint.sendRequestByClubAdmin;

      final body = (userRole.value == 'TRAINER')
          ? {"clubId": trainerId}
          : {"trainerId": trainerId};

      final response = await _apiClient.post(
        endpoint,
        body: body,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        requestedTrainerIds.add(trainerId);
        Get.snackbar(
          'Success',
          response?['message'] ?? 'Request sent successfully',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );
        await fetchTrainerRequests();
        return true;
      }
      return false;
    } on HttpException catch (e) {
      Get.snackbar('Error', e.message, backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } catch (e) {
      debugPrint('❌ Send request error: $e');
      Get.snackbar('Error', 'Failed to send request', backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── 7. Invite Trainer By Email ───────────────────────────────────
  Future<bool> inviteTrainer({required String name, required String email}) async {
    if (name.trim().isEmpty) {
      Get.snackbar('Error', 'Trainer name is required', backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      Get.snackbar('Error', 'Please enter a valid email address', backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    }

    isSubmitting.value = true;
    try {
      final body = {
        "trainerName": name.trim(),
        "sendEmail": email.trim(),
        "isSendByEmail": true,
      };

      final response = await _apiClient.post(
        ApiEndpoint.sendRequestByClubAdmin,
        body: body,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        inviteNameCtrl.clear();
        inviteEmailCtrl.clear();
        Get.back(); // close Invite Trainer screen
        Get.snackbar(
          'Success',
          response?['message'] ?? 'Trainer invited successfully',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );
        await fetchTrainerRequests();
        return true;
      }
      return false;
    } on HttpException catch (e) {
      Get.snackbar('Error', e.message, backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } catch (e) {
      debugPrint('❌ Invite trainer error: $e');
      Get.snackbar('Error', 'Failed to invite trainer', backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── 8. Respond to Request (Approve / Decline) ───────────────────
  Future<bool> respondToRequest({required String requestId, required bool isAccept}) async {
    isSubmitting.value = true;
    try {
      final endpoint = (userRole.value == 'TRAINER')
          ? ApiEndpoint.clubAdminAcceptReject
          : ApiEndpoint.trainerAcceptReject;

      // Backend expects 'ACTIVE' or 'REJECTED'
      final statusVal = isAccept ? 'ACTIVE' : 'REJECTED';
      final body = {
        "id": requestId,
        "requestId": requestId,
        "status": statusVal,
      };

      final response = await _apiClient.patch(
        endpoint,
        body: body,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        Get.snackbar(
          isAccept ? 'Approved' : 'Declined',
          response?['message'] ?? (isAccept ? 'Request accepted successfully.' : 'Request declined.'),
          backgroundColor: isAccept ? Colors.green.shade700 : Colors.red.shade800,
          colorText: Colors.white,
        );
        await Future.wait([
          fetchMyTrainers(),
          fetchTrainerRequests(),
        ]);
        return true;
      }
      return false;
    } on HttpException catch (e) {
      Get.snackbar('Error', e.message, backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } catch (e) {
      debugPrint('❌ Respond request error: $e');
      Get.snackbar('Error', 'Failed to process request', backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
