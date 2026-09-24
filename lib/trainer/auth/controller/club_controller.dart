import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../core/endpoint/api_endpoint.dart';
import 'club_model.dart';

class ClubController extends GetxController {
  static ClubController get to => Get.put(ClubController());

  final RxList<ClubModel> clubs = <ClubModel>[].obs;
  final RxBool isLoading = false.obs;

  final RxString selectedClubId   = ''.obs;
  final RxString selectedClubName = ''.obs;

  Future<void> fetchClubs({String? search}) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse(ApiEndpoint.clubList).replace(
        queryParameters: (search != null && search.trim().isNotEmpty)
            ? {'search': search.trim()}
            : null,
      );
      final response = await http.get(uri, headers: {'Accept': 'application/json'});

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final rawList = (decoded['data'] as List?) ?? [];

        // ✅ Parse each club individually — one bad/incomplete record
        // (e.g. null profile, missing field) no longer wipes out the
        // whole list.
        final parsed = <ClubModel>[];
        for (final item in rawList) {
          try {
            parsed.add(ClubModel.fromJson(item as Map<String, dynamic>));
          } catch (e) {
            debugPrint('⚠️ Skipped malformed club entry: $item — $e');
          }
        }

        clubs.assignAll(parsed);
      } else {
        debugPrint('❌ Fetch clubs failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Fetch clubs error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleClub(String id, String name) {
    if (selectedClubId.value == id) {
      selectedClubId.value = '';
      selectedClubName.value = '';
    } else {
      selectedClubId.value = id;
      selectedClubName.value = name;
    }
  }

  void reset() {
    selectedClubId.value = '';
    selectedClubName.value = '';
    clubs.clear();
  }
}