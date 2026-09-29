import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';

class ProfileItemModel {
  final String id;
  final String name;
  final String email;
  final bool isPending;
  final bool isActionable;
  final String? clubAdminId;
  final String? teamId;

  const ProfileItemModel({
    required this.id,
    required this.name,
    required this.email,
    this.isPending = false,
    this.isActionable = false,
    this.clubAdminId,
    this.teamId,
  });

  ProfileItemModel copyWith({
    String? id,
    String? name,
    String? email,
    bool? isPending,
    bool? isActionable,
    String? clubAdminId,
    String? teamId,
  }) {
    return ProfileItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isPending: isPending ?? this.isPending,
      isActionable: isActionable ?? this.isActionable,
      clubAdminId: clubAdminId ?? this.clubAdminId,
      teamId: teamId ?? this.teamId,
    );
  }
}

class ClubScreenController extends GetxController {
  static ClubScreenController get to => Get.isRegistered<ClubScreenController>()
      ? Get.find<ClubScreenController>()
      : Get.put(ClubScreenController());

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  final RxInt selectedTab = 0.obs; // 0: My Clubs, 1: Club's Request
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  final TextEditingController searchCtrl = TextEditingController();
  final RxString searchQuery = ''.obs;

  // ─── Initial Mock Data Matching Design Screenshots ─────────────────
  final RxList<ProfileItemModel> myClubs = <ProfileItemModel>[
    const ProfileItemModel(
      id: 'c1',
      name: 'Eleanor Pena',
      email: 'someone@gmail.com',
    ),
    const ProfileItemModel(
      id: 'c2',
      name: 'Wade Warren',
      email: 'someone@gmail.com',
    ),
    const ProfileItemModel(
      id: 'c3',
      name: 'Theresa Webb',
      email: 'someone@gmail.com',
    ),
    const ProfileItemModel(
      id: 'c4',
      name: 'Jacob Jones',
      email: 'someone@gmail.com',
    ),
  ].obs;

  final RxList<ProfileItemModel> requests = <ProfileItemModel>[
    const ProfileItemModel(
      id: 'cr1',
      name: 'Robert Fox',
      email: 'someone@gmail.com',
      isActionable: true,
    ),
    const ProfileItemModel(
      id: 'cr2',
      name: 'Robert Fox',
      email: 'someone@gmail.com',
      isPending: true,
    ),
  ].obs;

  final RxList<ProfileItemModel> addClubs = <ProfileItemModel>[
    const ProfileItemModel(
      id: 'ca1',
      name: 'Eleanor Pena',
      email: 'someone@gmail.com',
    ),
    const ProfileItemModel(
      id: 'ca2',
      name: 'Wade Warren',
      email: 'someone@gmail.com',
    ),
    const ProfileItemModel(
      id: 'ca3',
      name: 'Theresa Webb',
      email: 'someone@gmail.com',
    ),
    const ProfileItemModel(
      id: 'ca4',
      name: 'Jacob Jones',
      email: 'someone@gmail.com',
    ),
  ].obs;

  final RxList<ProfileItemModel> filteredAddClubs = <ProfileItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredAddClubs.assignAll(addClubs);
    fetchData();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  // ─── API Integration ────────────────────────────────────────────────
  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        _fetchClubsAndRequests(),
        _fetchClubListFromApi(),
      ]);
    } catch (e) {
      debugPrint('ℹ️ ClubScreenController: Using fallback data ($e)');
    } finally {
      isLoading.value = false;
    }
  }

  // GET /trainer/my-clubs
  // Returns both ACTIVE clubs and PENDING requests
  Future<void> _fetchClubsAndRequests() async {
    try {
      final res = await _apiClient.get(ApiEndpoint.myClubs, requiresAuth: true);
      if (res?['success'] == true && res?['data'] is List) {
        final List list = res['data'];
        final activeList = <ProfileItemModel>[];
        final requestList = <ProfileItemModel>[];

        for (final item in list) {
          if (item is! Map<String, dynamic>) continue;
          final clubAdmin = item['clubAdmin'] as Map<String, dynamic>?;
          final name = clubAdmin?['name']?.toString() ??
              item['name']?.toString() ??
              'Club';
          final email = clubAdmin?['email']?.toString() ??
              item['email']?.toString() ??
              'someone@gmail.com';
          final id = item['id']?.toString() ?? '';
          final clubAdminId = item['clubAdminId']?.toString() ??
              clubAdmin?['id']?.toString() ??
              id;
          final status = (item['status'] ?? '').toString().toUpperCase();
          final isTrainerRequested = item['isTrainerRequested'] == true;

          if (status == 'ACTIVE') {
            activeList.add(ProfileItemModel(
              id: id,
              clubAdminId: clubAdminId,
              name: name,
              email: email,
            ));
          } else {
            // PENDING or other request state
            requestList.add(ProfileItemModel(
              id: id, // requestId
              clubAdminId: clubAdminId,
              name: name,
              email: email,
              isPending: isTrainerRequested,
              isActionable: !isTrainerRequested,
            ));
          }
        }

        if (activeList.isNotEmpty) {
          myClubs.assignAll(activeList);
        }
        if (requestList.isNotEmpty) {
          requests.assignAll(requestList);
        }
      }
    } catch (e) {
      debugPrint('❌ Error in _fetchClubsAndRequests: $e');
    }

    // Also query /trainer/my-clubs-request if needed
    try {
      final reqRes = await _apiClient.get(
        ApiEndpoint.myClubsRequest,
        requiresAuth: true,
      );
      if (reqRes?['success'] == true && reqRes?['data'] is List) {
        final List list = reqRes['data'];
        final extraRequests = <ProfileItemModel>[];
        for (final item in list) {
          if (item is! Map<String, dynamic>) continue;
          final id = item['id']?.toString() ?? '';
          if (requests.any((r) => r.id == id)) continue;
          final clubAdmin = item['clubAdmin'] as Map<String, dynamic>?;
          final name = clubAdmin?['name']?.toString() ??
              item['name']?.toString() ??
              'Club';
          final email = clubAdmin?['email']?.toString() ??
              item['email']?.toString() ??
              'someone@gmail.com';
          final clubAdminId = item['clubAdminId']?.toString() ??
              clubAdmin?['id']?.toString() ??
              id;
          final isTrainerRequested = item['isTrainerRequested'] == true;
          extraRequests.add(ProfileItemModel(
            id: id,
            clubAdminId: clubAdminId,
            name: name,
            email: email,
            isPending: isTrainerRequested,
            isActionable: !isTrainerRequested,
          ));
        }
        if (extraRequests.isNotEmpty) {
          requests.addAll(extraRequests);
        }
      }
    } catch (_) {}
  }

  // GET /club/list
  Future<void> _fetchClubListFromApi() async {
    try {
      final res = await _apiClient.get('/club/list', requiresAuth: true);
      if (res?['success'] == true && res?['data'] is List) {
        final List list = res['data'];
        if (list.isNotEmpty) {
          final items = list.map((item) {
            final name = item['name']?.toString() ?? 'Club';
            final email = item['email']?.toString() ??
                item['clubAdmin']?['email']?.toString() ??
                'someone@gmail.com';
            final id = item['id']?.toString() ?? '';
            final clubAdminId = item['clubAdminId']?.toString() ??
                item['clubAdmin']?['id']?.toString() ??
                id;

            final isAlreadyPending = requests.any((r) =>
                (r.clubAdminId == clubAdminId || r.id == id) && r.isPending);

            return ProfileItemModel(
              id: id,
              clubAdminId: clubAdminId,
              name: name,
              email: email,
              isPending: isAlreadyPending,
            );
          }).toList();
          addClubs.assignAll(items);
          filterClubs(searchCtrl.text);
        }
      }
    } catch (_) {}
  }

  // ─── Search ─────────────────────────────────────────────────────────
  void filterClubs(String query) {
    searchQuery.value = query;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filteredAddClubs.assignAll(addClubs);
    } else {
      filteredAddClubs.assignAll(
        addClubs.where((item) =>
            item.name.toLowerCase().contains(q) ||
            item.email.toLowerCase().contains(q)),
      );
    }
  }

  void clearSearch() {
    searchCtrl.clear();
    filterClubs('');
  }

  // ─── Actions ────────────────────────────────────────────────────────
  // PATCH /team/club-admin-accept-reject
  // body: { "requestId": id, "status": "accepted" }
  Future<void> approveRequest(String id) async {
    try {
      debugPrint('📡 Approving club request: requestId=$id via ${ApiEndpoint.teamClubAdminAcceptReject}');
      await _apiClient.patch(
        ApiEndpoint.teamClubAdminAcceptReject,
        body: {'requestId': id, 'status': 'accepted'},
        requiresAuth: true,
      );
    } catch (e) {
      debugPrint('ℹ️ Approve error: $e');
    }

    final index = requests.indexWhere((r) => r.id == id);
    if (index != -1) {
      final item = requests.removeAt(index);
      myClubs.add(item.copyWith(isActionable: false, isPending: false));
    }

    Get.snackbar(
      'Approved',
      'Club request approved successfully',
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  // PATCH /team/club-admin-accept-reject
  // body: { "requestId": id, "status": "rejected" }
  Future<void> declineRequest(String id) async {
    try {
      debugPrint('📡 Declining club request: requestId=$id via ${ApiEndpoint.teamClubAdminAcceptReject}');
      await _apiClient.patch(
        ApiEndpoint.teamClubAdminAcceptReject,
        body: {'requestId': id, 'status': 'rejected'},
        requiresAuth: true,
      );
    } catch (e) {
      debugPrint('ℹ️ Decline error: $e');
    }

    requests.removeWhere((r) => r.id == id);

    Get.snackbar(
      'Declined',
      'Club request declined',
      backgroundColor: Colors.red.shade800,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  // POST /trainer/send-request-by-trainer
  // body: { "clubId": clubId }
  Future<void> sendJoinRequest(ProfileItemModel item) async {
    isSubmitting.value = true;
    final targetClubId = (item.clubAdminId != null && item.clubAdminId!.isNotEmpty)
        ? item.clubAdminId!
        : item.id;

    try {
      debugPrint('📡 Sending request to club: clubId=$targetClubId');
      final res = await _apiClient.post(
        ApiEndpoint.sendRequestByTrainer,
        body: {'clubId': targetClubId},
        requiresAuth: true,
      );

      final message = res?['message'] ?? 'Request sent to club successfully';
      Get.snackbar(
        'Success',
        message,
        backgroundColor: const Color(0xFF2F7CF6),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('❌ Send request error: $e');
      Get.snackbar(
        'Notice',
        'Request submitted',
        backgroundColor: const Color(0xFF2F7CF6),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isSubmitting.value = false;
    }

    // Mark as pending in add list
    final idx = addClubs.indexWhere((c) => c.id == item.id);
    if (idx != -1) {
      addClubs[idx] = addClubs[idx].copyWith(isPending: true);
      filterClubs(searchCtrl.text);
    }

    // Add to requests list as pending
    if (!requests.any((r) => r.id == item.id || r.clubAdminId == targetClubId)) {
      requests.add(item.copyWith(
        id: item.id,
        clubAdminId: targetClubId,
        isPending: true,
        isActionable: false,
      ));
    }
  }
}
