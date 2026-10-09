import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nander/nander/newtrainer/team_details_model.dart';

import '../core/endpoint/api_client.dart';
import '../core/endpoint/api_endpoint.dart';


/// GET /team/single-team-with-progress/{teamId}
class TrainerTeamDetailController extends GetxController {
  final String teamId;
  TrainerTeamDetailController(this.teamId);

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  final Rx<TrainerTeamDetailModel?> team = Rx<TrainerTeamDetailModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTeam();
  }

  Future<void> fetchTeam() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _apiClient.get(
        ApiEndpoint.singleTeamWithProgress(teamId),
        requiresAuth: true,
      );

      if (response != null &&
          response['success'] == true &&
          response['data'] is Map) {
        team.value = TrainerTeamDetailModel.fromJson(
          Map<String, dynamic>.from(response['data'] as Map),
        );
      } else {
        errorMessage.value =
            (response?['message'] ?? 'Failed to load team').toString();
        debugPrint('❌ Team detail not loaded. Response: $response');
      }
    } catch (e) {
      debugPrint('❌ Fetch team detail error: $e');
      errorMessage.value = 'Something went wrong. Pull down to retry.';
    } finally {
      isLoading.value = false;
    }
  }
}