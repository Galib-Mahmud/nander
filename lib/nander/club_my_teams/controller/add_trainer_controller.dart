import 'package:flutter/material.dart';
import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';

class AvailableTrainerModel {
  final String id;
  final String name;
  final String email;
  final String? profile;

  AvailableTrainerModel({
    required this.id,
    required this.name,
    required this.email,
    this.profile,
  });

  factory AvailableTrainerModel.fromJson(Map<String, dynamic> json) {
    return AvailableTrainerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profile: json['profile'],
    );
  }
}

class ClubAddTrainerController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  List<AvailableTrainerModel> _availableTrainers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  bool _hasFetched = false;

  List<AvailableTrainerModel> get availableTrainers => _availableTrainers.where((t) =>
  t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      t.email.toLowerCase().contains(_searchQuery.toLowerCase())
  ).toList();

  bool get isLoading => _isLoading;
  bool get hasSearched => _searchQuery.isNotEmpty || _hasFetched; // ✅ Show results even if search box is empty after fetch

  /// ✅ NEW: Call this in initState to fetch data immediately
  Future<void> initSearch(String teamId) async {
    if (_hasFetched) return;

    _isLoading = true;
    notifyListeners();
    debugPrint("🚀 Auto-fetching trainers for team: $teamId");

    try {
      final res = await _apiClient.get(ApiEndpoint.findMembers(teamId));
      debugPrint("📩 Response: $res");

      if (res is Map && res['success'] == true) {
        final List<dynamic> list = res['data'] ?? [];
        _availableTrainers = list.map((e) => AvailableTrainerModel.fromJson(e)).toList();
        _hasFetched = true;
        debugPrint("✅ Loaded ${_availableTrainers.length} trainers");
      }
    } catch (e) {
      debugPrint("💥 Init Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search filter (only filters local list now)
  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Send request to an EXISTING trainer
  Future<bool> sendRequest({
    required String teamId,
    required String trainerId,
    required String trainerName,
    required String email,
  }) async {
    try {
      debugPrint("📨 Requesting: $trainerName ($trainerId)");
      await _apiClient.post(
        ApiEndpoint.addMember,
        body: {
          'teamId': teamId,
          'trainerId': trainerId,
          'sendEmail': email,
          'trainerName': trainerName,
        },
      );
      return true;
    } catch (e) {
      debugPrint("❌ Request Failed: $e");
      rethrow;
    }
  }

  /// Invite a NEW trainer via email
  Future<bool> inviteNewTrainer({
    required String teamId,
    required String trainerName,
    required String email,
  }) async {
    try {
      debugPrint("📨 Inviting: $trainerName ($email)");
      await _apiClient.post(
        ApiEndpoint.addMember,
        body: {
          'teamId': teamId,
          'sendEmail': email,
          'trainerName': trainerName,
        },
      );
      return true;
    } catch (e) {
      debugPrint("❌ Invite Failed: $e");
      rethrow;
    }
  }
}