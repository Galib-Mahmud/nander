import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../team/controller/team_model.dart';


class ClubMyTeamsController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  List<TeamModel> _teams = [];
  bool _isLoading = false;
  String? _error;

  List<TeamModel> get teams => _teams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all teams belonging to the logged-in user
  Future<void> fetchTeams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoint.myTeams);
      if (response is Map<String, dynamic> && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        _teams = data.map((e) => TeamModel.fromJson(e)).toList();
      } else {
        _error = "Failed to load teams";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new team via POST /team/create
  Future<bool> createTeam({
    required String name,
    required String bio,
    required String address,
    File? imageFile,
  }) async {
    try {
      final fields = {'name': name, 'bio': bio, 'address': address};
      final files = <String, File>{};
      if (imageFile != null) files['image'] = imageFile;

      await _apiClient.multipart(
        ApiEndpoint.teamCreate,
        method: 'POST',
        fields: fields,
        files: files.isNotEmpty ? files : null,
      );

      await fetchTeams(); // Refresh list after creation
      return true;
    } catch (e) {
      debugPrint("Create Error: $e");
      rethrow;
    }
  }

  /// Update an existing team via PATCH /team/update
  Future<bool> updateTeam({
    required String id,
    required String name,
    required String bio,
    required String address,
    File? imageFile,
  }) async {
    try {
      final fields = {
        'id': id, // CRITICAL: Backend requires ID in body for /team/update
        'name': name,
        'bio': bio,
        'address': address,
      };

      final files = <String, File>{};
      if (imageFile != null) files['image'] = imageFile;

      await _apiClient.multipart(
        ApiEndpoint.teamUpdate,
        method: 'PATCH',
        fields: fields,
        files: files.isNotEmpty ? files : null,
      );

      await fetchTeams(); // Refresh list after update
      return true;
    } catch (e) {
      debugPrint("Update Error: $e");
      rethrow;
    }
  }

  /// Delete a team via DELETE /team/{id}
  Future<bool> deleteTeam(String teamId) async {
    try {
      await _apiClient.delete(ApiEndpoint.teamDelete(teamId));
      _teams.removeWhere((t) => t.id == teamId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Delete Error: $e");
      rethrow;
    }
  }
}