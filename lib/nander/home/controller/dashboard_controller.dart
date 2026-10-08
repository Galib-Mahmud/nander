import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../core/local_storage/user_info.dart';
import '../model/dashboard_statics_model.dart';

class DashboardController extends GetxController {
  static DashboardController get to {
    if (!Get.isRegistered<DashboardController>()) {
      return Get.put(DashboardController());
    }
    return Get.find<DashboardController>();
  }

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  final Rx<DashboardStaticsModel?> dashboardData =
      Rx<DashboardStaticsModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString userRole = ''.obs; // 'CLUB_ADMIN' or 'TRAINER'

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStatics();
  }

  Future<void> fetchDashboardStatics() async {
    isLoading.value = true;
    try {
      final role = await UserInfo.getUserRole();
      userRole.value = role ?? '';
      final endpoint = (role == 'CLUB_ADMIN')
          ? ApiEndpoint.dashboardStaticsClubAdmin
          : ApiEndpoint.dashboardStaticsTrainer;

      final response = await _apiClient.get(endpoint, requiresAuth: true);
      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          dashboardData.value = DashboardStaticsModel.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('Error fetching dashboard statics: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

