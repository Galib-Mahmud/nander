import 'package:flutter/material.dart';
import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';

class TrainerModel {
  final String id;
  final String name;
  final String email;
  final String? profile;
  final String status; // ACTIVE, PENDING, REJECTED
  final bool isTrainerRequested;

  TrainerModel({
    required this.id,
    required this.name,
    required this.email,
    this.profile,
    required this.status,
    this.isTrainerRequested = false,
  });

  factory TrainerModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> userData =
    (json['trainer'] is Map<String, dynamic>) ? json['trainer'] : json;

    return TrainerModel(
      id: json['id']?.toString() ?? '',
      // trainer null hole (email diye invite) trainerName / sendEmail theke nibe
      name: userData['name']?.toString() ??
          json['trainerName']?.toString() ??
          'Unknown',
      email: userData['email']?.toString() ??
          json['sendEmail']?.toString() ??
          'Unknown',
      profile: userData['profile']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      isTrainerRequested: json['isTrainerRequested'] == true,
    );
  }
}

class TeamTrainersController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  List<TrainerModel> _activeTrainers = [];
  List<TrainerModel> _requestedTrainers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // Getters
  List<TrainerModel> get activeTrainers => _activeTrainers
      .where((t) =>
  t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      t.email.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  List<TrainerModel> get requestedTrainers => _requestedTrainers
      .where((t) =>
  t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      t.email.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  bool get isLoading => _isLoading;

  /// Fetch both Active and Requested trainers for a specific team
  Future<void> fetchAllData(String teamId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Active Members
      final membersRes = await _apiClient.get(ApiEndpoint.teamMembers(teamId));
      if (membersRes is Map && membersRes['success'] == true) {
        final data = membersRes['data'];
        // API returns nested structure: { id, name..., members: [...] }
        final List<dynamic> membersList = data['members'] ?? [];
        _activeTrainers =
            membersList.map((e) => TrainerModel.fromJson(e)).toList();
      }

      // 2. Fetch Requests
      final reqRes =
      await _apiClient.get(ApiEndpoint.requestTeamMembers(teamId));
      if (reqRes is Map && reqRes['success'] == true) {
        final List<dynamic> reqList = reqRes['data'] ?? [];
        _requestedTrainers =
            reqList.map((e) => TrainerModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve or Reject a trainer request
  Future<bool> handleRequest(String trainerId, String action) async {
    try {
      // action should be "ACTIVE" or "REJECTED" based on your API enum
      final status = action == 'approve' ? 'ACTIVE' : 'REJECTED';

      await _apiClient.patch(
        ApiEndpoint.trainerAcceptReject,
        body: {'id': trainerId, 'status': status},
      );

      // Move from requests to active (or remove if rejected)
      final trainer = _requestedTrainers.firstWhere((t) => t.id == trainerId);
      _requestedTrainers.remove(trainer);

      if (action == 'approve') {
        _activeTrainers.add(TrainerModel(
          id: trainer.id,
          name: trainer.name,
          email: trainer.email,
          profile: trainer.profile,
          status: 'ACTIVE',
          isTrainerRequested: trainer.isTrainerRequested,
        ));
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Action Error: $e");
      return false;
    }
  }

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}