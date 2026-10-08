import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nander/nander/core/endpoint/api_endpoint.dart';
import 'package:nander/nander/core/local_storage/user_info.dart';
import 'package:nander/nander/newtrainer/trainer_model.dart';

class TrainerTeamController extends GetxController {
  static TrainerTeamController get to => Get.find();

  final RxList<TrainerTeamModel> teams = <TrainerTeamModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyTeams();
  }

  Future<void> fetchMyTeams() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final body = await _get(ApiEndpoint.myTeamWithProgress);

      if (body['success'] == true) {
        final list = (body['data'] as List? ?? []);
        teams.assignAll(
          list
              .map((e) =>
                  TrainerTeamModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
      } else {
        errorMessage.value =
            (body['message'] ?? 'Failed to load teams').toString();
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Pull down to retry.';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── HTTP ───────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _get(String path) async {
    final token = await UserInfo.getAccessToken();

    final res = await http.get(
      Uri.parse('${ApiEndpoint.baseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
