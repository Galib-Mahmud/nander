import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';
import 'top_club_model.dart';

class TopClubController extends GetxController {
  static TopClubController get to => Get.put(TopClubController());

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  // ─── Observable State ──────────────────────────────────────────────
  final RxList<NetworkClubModel> networkClubs = <NetworkClubModel>[].obs;
  final RxList<FindClubModel> findClubs = <FindClubModel>[].obs;

  final RxBool isNetworkLoading = false.obs;
  final RxBool isFindClubsLoading = false.obs;
  final RxBool isSendingInvite = false.obs;

  /// Tracks which club IDs have a pending/sent invite so we can update UI
  final RxSet<String> invitedClubIds = <String>{}.obs;

  /// Search query for Find Clubs
  final RxString searchQuery = ''.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchMyNetwork();
    fetchFindClubs();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  // ─── Search with debounce ──────────────────────────────────────────
  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchFindClubs(search: query);
    });
  }

  // ─── GET /network (My Network) ─────────────────────────────────────
  Future<void> fetchMyNetwork() async {
    isNetworkLoading.value = true;
    try {
      final response = await _apiClient.get(
        ApiEndpoint.network,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final parsed = <NetworkClubModel>[];
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            try {
              parsed.add(NetworkClubModel.fromJson(item));
            } catch (e) {
              debugPrint('⚠️ Error parsing network club: $e');
            }
          }
        }
        networkClubs.assignAll(parsed);
        debugPrint('✅ My Network loaded: ${networkClubs.length} clubs');
      }
    } catch (e) {
      debugPrint('❌ Fetch My Network error: $e');
      Get.snackbar(
        'Error',
        'Failed to load network',
        backgroundColor: const Color(0xFF1A2236),
        colorText: Colors.white,
      );
    } finally {
      isNetworkLoading.value = false;
    }
  }

  // ─── GET /network/find-clubs?search= ───────────────────────────────
  Future<void> fetchFindClubs({String? search}) async {
    isFindClubsLoading.value = true;
    try {
      String endpoint = ApiEndpoint.findClubs;
      if (search != null && search.trim().isNotEmpty) {
        endpoint += '?search=${Uri.encodeComponent(search.trim())}';
      }

      final response = await _apiClient.get(
        endpoint,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final parsed = <FindClubModel>[];
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            try {
              parsed.add(FindClubModel.fromJson(item));
            } catch (e) {
              debugPrint('⚠️ Error parsing find club: $e');
            }
          }
        }
        findClubs.assignAll(parsed);
        debugPrint('✅ Find Clubs loaded: ${findClubs.length} clubs');
      }
    } catch (e) {
      debugPrint('❌ Fetch Find Clubs error: $e');
      Get.snackbar(
        'Error',
        'Failed to load clubs',
        backgroundColor: const Color(0xFF1A2236),
        colorText: Colors.white,
      );
    } finally {
      isFindClubsLoading.value = false;
    }
  }

  // ─── POST /network/send-request ────────────────────────────────────
  Future<void> sendInvite(String clubId) async {
    if (invitedClubIds.contains(clubId)) return; // Already invited
    isSendingInvite.value = true;
    try {
      final response = await _apiClient.post(
        ApiEndpoint.sendNetworkRequest,
        body: {"id": clubId},
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        invitedClubIds.add(clubId);
        Get.snackbar(
          'Success',
          response?['message'] ?? 'Invite sent successfully',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );
        // Refresh both lists
        fetchMyNetwork();
        fetchFindClubs(search: searchQuery.value);
      }
    } catch (e) {
      debugPrint('❌ Send invite error: $e');
      Get.snackbar(
        'Error',
        'Failed to send invite',
        backgroundColor: const Color(0xFF1A2236),
        colorText: Colors.white,
      );
    } finally {
      isSendingInvite.value = false;
    }
  }
}
