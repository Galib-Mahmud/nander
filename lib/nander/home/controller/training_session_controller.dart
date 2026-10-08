
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';
import 'dashboard_controller.dart';
import '../model/training_session_model.dart';

/// Team item returned in `data.teams` of
/// GET /training-session/training-sessions-by-trainer
class SessionTeamItem {
  final String id;
  final String name;
  final String? image;

  const SessionTeamItem({required this.id, required this.name, this.image});

  factory SessionTeamItem.fromJson(Map<String, dynamic> json) {
    return SessionTeamItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      image: json['image']?.toString(),
    );
  }
}

class TrainingSessionController extends GetxController {
  static TrainingSessionController get to {
    if (!Get.isRegistered<TrainingSessionController>()) {
      return Get.put(TrainingSessionController());
    }
    return Get.find<TrainingSessionController>();
  }

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  // Active Teams
  final RxList<ActiveTeamItem> activeTeams = <ActiveTeamItem>[].obs;
  final Rx<ActiveTeamItem?> selectedTeam = Rx<ActiveTeamItem?>(null);
  final RxString selectedTeamId = ''.obs;
  final RxBool isLoadingTeams = false.obs;

  // Training Sessions List
  final RxList<TrainingSessionModel> trainingSessions =
      <TrainingSessionModel>[].obs;
  final RxBool isLoadingSessions = false.obs;

  // Teams row on top of the schedule list (from `data.teams`)
  final RxList<SessionTeamItem> sessionTeams = <SessionTeamItem>[].obs;
  // 'ALL' = no teamId param, otherwise ?teamId=<id>
  final RxString sessionFilterTeamId = 'ALL'.obs;
  int _sessionReqSeq = 0;

  // Wizard state for creating a plan
  final RxString selectedPeriod = '2 weeks'.obs;
  final RxString selectedSessionsPerWeek = '1× per week'.obs;
  final RxString selectedFocus = 'ATTACK'.obs; // ATTACK, DEFENCE, TRANSITION, TECHNIQUE
  final RxString selectedDifficulty = 'EASY'.obs; // EASY, MEDIUM, HARD
  final RxString selectedFieldsize = 'FULL_FIELD'.obs; // FULL_FIELD, HALF_FIELD, CAROUSEL
  final RxInt targetDurationMinutes = 160.obs;
  final TextEditingController trainingTypeCtrl = TextEditingController(text: 'Circle entry');

  // Active/Created Session for overview & details
  final Rx<TrainingSessionModel?> currentSession =
  Rx<TrainingSessionModel?>(null);
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isSubmittingReport = false.obs;
  final RxBool isLoadingSingleSession = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActiveTeams();
  }

  @override
  void onClose() {
    trainingTypeCtrl.dispose();
    super.onClose();
  }

  void selectTeam(ActiveTeamItem? team) {
    selectedTeam.value = team;
    selectedTeamId.value = team?.teamId ?? '';
    if (selectedTeamId.value.isNotEmpty) {
      // Uses the schedule filter (default ALL) so picking a team for plan
      // creation does not narrow the schedule list.
      fetchSessionsByTrainer();
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map) {
      if (data['teams'] is List) return data['teams'] as List;
      if (data['activeTeams'] is List) return data['activeTeams'] as List;
      if (data['data'] is List) return data['data'] as List;
      if (data['result'] is List) return data['result'] as List;
      if (data['rows'] is List) return data['rows'] as List;
    }
    return [];
  }

  Future<void> fetchActiveTeams() async {
    isLoadingTeams.value = true;
    try {
      var list = <ActiveTeamItem>[];
      final response =
      await _apiClient.get(ApiEndpoint.activeTeams, requiresAuth: true);
      if (response != null && response['success'] == true && response['data'] != null) {
        final rawList = _extractList(response['data']);
        list = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => ActiveTeamItem.fromJson(e))
            .where((t) => t.teamId.isNotEmpty)
            .toList();
      }

      // Fallback 1: /team/my-team (for club admins or assigned teams)
      if (list.isEmpty) {
        try {
          final myTeamResp =
          await _apiClient.get(ApiEndpoint.myTeam, requiresAuth: true);
          if (myTeamResp != null &&
              myTeamResp['success'] == true &&
              myTeamResp['data'] != null) {
            final rawList = _extractList(myTeamResp['data']);
            list = rawList
                .whereType<Map<String, dynamic>>()
                .map((e) => ActiveTeamItem.fromJson(e))
                .where((t) => t.teamId.isNotEmpty)
                .toList();
          }
        } catch (_) {}
      }

      // Fallback 2: /team (all teams)
      if (list.isEmpty) {
        try {
          final teamResp =
          await _apiClient.get(ApiEndpoint.team, requiresAuth: true);
          if (teamResp != null &&
              teamResp['success'] == true &&
              teamResp['data'] != null) {
            final rawList = _extractList(teamResp['data']);
            list = rawList
                .whereType<Map<String, dynamic>>()
                .map((e) => ActiveTeamItem.fromJson(e))
                .where((t) => t.teamId.isNotEmpty)
                .toList();
          }
        } catch (_) {}
      }

      activeTeams.value = list;
      if (activeTeams.isNotEmpty) {
        if (selectedTeam.value == null ||
            selectedTeamId.value.isEmpty ||
            !activeTeams.any((t) => t.teamId == selectedTeamId.value)) {
          selectTeam(activeTeams.first);
        }
      }
    } catch (e) {
      debugPrint('Error fetching active teams: $e');
    } finally {
      isLoadingTeams.value = false;
    }
  }

  /// GET /training-session/training-sessions-by-trainer[?teamId=...]
  /// Response: data = { teams: [...], sessions: [...] }
  Future<void> fetchSessionsByTrainer({String? teamId}) async {
    if (teamId != null && teamId.isNotEmpty) {
      sessionFilterTeamId.value = teamId;
    }
    final tId = sessionFilterTeamId.value;
    final isAll = tId.isEmpty || tId == 'ALL';

    // Ignore stale responses if a newer request was fired meanwhile.
    final seq = ++_sessionReqSeq;
    isLoadingSessions.value = true;

    try {
      final endpoint = isAll
          ? '/training-session/training-sessions-by-trainer'
          : ApiEndpoint.trainingSessionsByTrainer(tId);

      final response = await _apiClient.get(endpoint, requiresAuth: true);
      if (seq != _sessionReqSeq) return;

      if (response != null && response['success'] == true) {
        final data = response['data'];

        // `sessions` must be read explicitly: _extractList() would pick
        // data['teams'] first and return the teams instead of the sessions.
        final List<dynamic> rawSessions = data is Map
            ? (data['sessions'] is List ? data['sessions'] as List : <dynamic>[])
            : _extractList(data);

        trainingSessions.value = rawSessions
            .whereType<Map<String, dynamic>>()
            .map((e) => TrainingSessionModel.fromJson(e))
            .toList();

        if (data is Map && data['teams'] is List) {
          final teams = (data['teams'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => SessionTeamItem.fromJson(e))
              .where((t) => t.id.isNotEmpty)
              .toList();
          // Only refresh the teams row on an ALL fetch, so the row does not
          // collapse to a single team after tapping a team chip.
          if (isAll || sessionTeams.isEmpty) {
            sessionTeams.value = teams;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching training sessions: $e');
    } finally {
      if (seq == _sessionReqSeq) {
        isLoadingSessions.value = false;
      }
    }
  }

  Future<TrainingSessionModel?> fetchSingleSession(String id) async {
    isLoadingSingleSession.value = true;
    try {
      final endpoint = ApiEndpoint.singleTrainingSession(id);
      final response = await _apiClient.get(endpoint, requiresAuth: true);
      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final s = TrainingSessionModel.fromJson(data);
          currentSession.value = s;
          return s;
        }
      }
    } catch (e) {
      debugPrint('Error fetching single session: $e');
    } finally {
      isLoadingSingleSession.value = false;
    }
    return null;
  }

  Future<TrainingSessionModel?> createTrainingSession() async {
    // If team is unselected or teams list is empty, fetch teams now
    if (selectedTeamId.value.isEmpty || activeTeams.isEmpty) {
      await fetchActiveTeams();
    }

    if (selectedTeamId.value.isEmpty && activeTeams.isNotEmpty) {
      selectTeam(activeTeams.first);
    }

    if (selectedTeamId.value.isEmpty) {
      Get.snackbar(
        'Select Team',
        'Please select or join an active team first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return null;
    }

    isCreating.value = true;
    try {
      final body = {
        'focus': selectedFocus.value,
        'difficulty': selectedDifficulty.value,
        'fieldsize': selectedFieldsize.value,
        'teamId': selectedTeamId.value,
        if (targetDurationMinutes.value > 0)
          'targetDurationMinutes': targetDurationMinutes.value,
        if (trainingTypeCtrl.text.trim().isNotEmpty)
          'trainingType': trainingTypeCtrl.text.trim(),
      };

      final response = await _apiClient.post(
        ApiEndpoint.createTrainingSession,
        body: body,
        requiresAuth: true,
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data != null && data is Map<String, dynamic>) {
          final session = TrainingSessionModel.fromJson(data);
          currentSession.value = session;
          // Refresh sessions list and dashboard
          fetchSessionsByTrainer();
          try {
            DashboardController.to.fetchDashboardStatics();
          } catch (_) {}

          Get.snackbar(
            'Success',
            response['message']?.toString() ??
                'Training session created successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
          );
          return session;
        }
      } else {
        Get.snackbar(
          'Error',
          response?['message']?.toString() ?? 'Failed to create plan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error creating training session: $e');
      Get.snackbar(
        'Error',
        'Something went wrong while generating session.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isCreating.value = false;
    }
    return null;
  }

  Future<bool> updateTrainingSession(
      String sessionId, Map<String, dynamic> body) async {
    isUpdating.value = true;
    try {
      final endpoint = ApiEndpoint.updateTrainingSession(sessionId);
      dynamic response;
      try {
        response = await _apiClient.put(endpoint, body: body, requiresAuth: true);
      } catch (_) {
        response = await _apiClient.patch(endpoint, body: body, requiresAuth: true);
      }

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final updated = TrainingSessionModel.fromJson(data);
          currentSession.value = updated;
        }
        fetchSessionsByTrainer();
        try {
          DashboardController.to.fetchDashboardStatics();
        } catch (_) {}
        return true;
      }
    } catch (e) {
      debugPrint('Error updating session: $e');
    } finally {
      isUpdating.value = false;
    }
    return false;
  }

  Future<bool> toggleSessionComplete(String sessionId, bool isCompleted) async {
    final ok = await updateTrainingSession(sessionId, {'isCompleted': isCompleted});
    if (ok) {
      Get.snackbar(
        'Session Updated',
        isCompleted ? 'Marked session as completed' : 'Marked session as active',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isCompleted ? const Color(0xFF10B981) : const Color(0xFF4D94FF),
        colorText: Colors.white,
      );
    }
    return ok;
  }

  Future<bool> submitSessionReport(
      String sessionId,
      String topic,
      String notes,
      ) async {
    isSubmittingReport.value = true;
    try {
      final ok = await updateTrainingSession(
        sessionId,
        {
          'reportTopic': topic,
          'reportNotes': notes,
        },
      );
      if (ok) {
        Get.snackbar(
          'Success',
          'Report submitted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        return true;
      }
    } catch (e) {
      debugPrint('Error submitting session report: $e');
    } finally {
      isSubmittingReport.value = false;
    }
    return false;
  }
}




























// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../core/endpoint/api_client.dart';
// import '../../core/endpoint/api_endpoint.dart';
// import 'dashboard_controller.dart';
// import '../model/training_session_model.dart';
//
// class TrainingSessionController extends GetxController {
//   static TrainingSessionController get to {
//     if (!Get.isRegistered<TrainingSessionController>()) {
//       return Get.put(TrainingSessionController());
//     }
//     return Get.find<TrainingSessionController>();
//   }
//
//   final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);
//
//   // Active Teams
//   final RxList<ActiveTeamItem> activeTeams = <ActiveTeamItem>[].obs;
//   final Rx<ActiveTeamItem?> selectedTeam = Rx<ActiveTeamItem?>(null);
//   final RxString selectedTeamId = ''.obs;
//   final RxBool isLoadingTeams = false.obs;
//
//   // Training Sessions List
//   final RxList<TrainingSessionModel> trainingSessions =
//       <TrainingSessionModel>[].obs;
//   final RxBool isLoadingSessions = false.obs;
//
//   // Wizard state for creating a plan
//   final RxString selectedPeriod = '2 weeks'.obs;
//   final RxString selectedSessionsPerWeek = '1× per week'.obs;
//   final RxString selectedFocus = 'ATTACK'.obs; // ATTACK, DEFENCE, TRANSITION, TECHNIQUE
//   final RxString selectedDifficulty = 'EASY'.obs; // EASY, MEDIUM, HARD
//   final RxString selectedFieldsize = 'FULL_FIELD'.obs; // FULL_FIELD, HALF_FIELD, CAROUSEL
//   final RxInt targetDurationMinutes = 160.obs;
//   final TextEditingController trainingTypeCtrl = TextEditingController(text: 'Circle entry');
//
//   // Active/Created Session for overview & details
//   final Rx<TrainingSessionModel?> currentSession =
//       Rx<TrainingSessionModel?>(null);
//   final RxBool isCreating = false.obs;
//   final RxBool isUpdating = false.obs;
//   final RxBool isSubmittingReport = false.obs;
//   final RxBool isLoadingSingleSession = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchActiveTeams();
//   }
//
//   @override
//   void onClose() {
//     trainingTypeCtrl.dispose();
//     super.onClose();
//   }
//
//   void selectTeam(ActiveTeamItem? team) {
//     selectedTeam.value = team;
//     selectedTeamId.value = team?.teamId ?? '';
//     if (selectedTeamId.value.isNotEmpty) {
//       fetchSessionsByTrainer(teamId: selectedTeamId.value);
//     }
//   }
//
//   List<dynamic> _extractList(dynamic data) {
//     if (data == null) return [];
//     if (data is List) return data;
//     if (data is Map) {
//       if (data['teams'] is List) return data['teams'] as List;
//       if (data['activeTeams'] is List) return data['activeTeams'] as List;
//       if (data['data'] is List) return data['data'] as List;
//       if (data['result'] is List) return data['result'] as List;
//       if (data['rows'] is List) return data['rows'] as List;
//     }
//     return [];
//   }
//
//   Future<void> fetchActiveTeams() async {
//     isLoadingTeams.value = true;
//     try {
//       var list = <ActiveTeamItem>[];
//       final response =
//           await _apiClient.get(ApiEndpoint.activeTeams, requiresAuth: true);
//       if (response != null && response['success'] == true && response['data'] != null) {
//         final rawList = _extractList(response['data']);
//         list = rawList
//             .whereType<Map<String, dynamic>>()
//             .map((e) => ActiveTeamItem.fromJson(e))
//             .where((t) => t.teamId.isNotEmpty)
//             .toList();
//       }
//
//       // Fallback 1: /team/my-team (for club admins or assigned teams)
//       if (list.isEmpty) {
//         try {
//           final myTeamResp =
//               await _apiClient.get(ApiEndpoint.myTeam, requiresAuth: true);
//           if (myTeamResp != null &&
//               myTeamResp['success'] == true &&
//               myTeamResp['data'] != null) {
//             final rawList = _extractList(myTeamResp['data']);
//             list = rawList
//                 .whereType<Map<String, dynamic>>()
//                 .map((e) => ActiveTeamItem.fromJson(e))
//                 .where((t) => t.teamId.isNotEmpty)
//                 .toList();
//           }
//         } catch (_) {}
//       }
//
//       // Fallback 2: /team (all teams)
//       if (list.isEmpty) {
//         try {
//           final teamResp =
//               await _apiClient.get(ApiEndpoint.team, requiresAuth: true);
//           if (teamResp != null &&
//               teamResp['success'] == true &&
//               teamResp['data'] != null) {
//             final rawList = _extractList(teamResp['data']);
//             list = rawList
//                 .whereType<Map<String, dynamic>>()
//                 .map((e) => ActiveTeamItem.fromJson(e))
//                 .where((t) => t.teamId.isNotEmpty)
//                 .toList();
//           }
//         } catch (_) {}
//       }
//
//       activeTeams.value = list;
//       if (activeTeams.isNotEmpty) {
//         if (selectedTeam.value == null ||
//             selectedTeamId.value.isEmpty ||
//             !activeTeams.any((t) => t.teamId == selectedTeamId.value)) {
//           selectTeam(activeTeams.first);
//         }
//       }
//     } catch (e) {
//       debugPrint('Error fetching active teams: $e');
//     } finally {
//       isLoadingTeams.value = false;
//     }
//   }
//
//   Future<void> fetchSessionsByTrainer({String? teamId}) async {
//     isLoadingSessions.value = true;
//     final tId = teamId ?? selectedTeamId.value;
//     try {
//       final endpoint = (tId.isNotEmpty && tId != 'ALL')
//           ? ApiEndpoint.trainingSessionsByTrainer(tId)
//           : '/training-session/training-sessions-by-trainer';
//
//       final response = await _apiClient.get(endpoint, requiresAuth: true);
//       if (response != null && response['success'] == true) {
//         final data = response['data'];
//         final rawList = _extractList(data);
//         trainingSessions.value = rawList
//             .whereType<Map<String, dynamic>>()
//             .map((e) => TrainingSessionModel.fromJson(e))
//             .toList();
//       }
//     } catch (e) {
//       debugPrint('Error fetching training sessions: $e');
//     } finally {
//       isLoadingSessions.value = false;
//     }
//   }
//
//   Future<TrainingSessionModel?> fetchSingleSession(String id) async {
//     isLoadingSingleSession.value = true;
//     try {
//       final endpoint = ApiEndpoint.singleTrainingSession(id);
//       final response = await _apiClient.get(endpoint, requiresAuth: true);
//       if (response != null && response['success'] == true) {
//         final data = response['data'];
//         if (data is Map<String, dynamic>) {
//           final s = TrainingSessionModel.fromJson(data);
//           currentSession.value = s;
//           return s;
//         }
//       }
//     } catch (e) {
//       debugPrint('Error fetching single session: $e');
//     } finally {
//       isLoadingSingleSession.value = false;
//     }
//     return null;
//   }
//
//   Future<TrainingSessionModel?> createTrainingSession() async {
//     // If team is unselected or teams list is empty, fetch teams now
//     if (selectedTeamId.value.isEmpty || activeTeams.isEmpty) {
//       await fetchActiveTeams();
//     }
//
//     if (selectedTeamId.value.isEmpty && activeTeams.isNotEmpty) {
//       selectTeam(activeTeams.first);
//     }
//
//     if (selectedTeamId.value.isEmpty) {
//       Get.snackbar(
//         'Select Team',
//         'Please select or join an active team first',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withValues(alpha: 0.8),
//         colorText: Colors.white,
//       );
//       return null;
//     }
//
//     isCreating.value = true;
//     try {
//       final body = {
//         'focus': selectedFocus.value,
//         'difficulty': selectedDifficulty.value,
//         'fieldsize': selectedFieldsize.value,
//         'teamId': selectedTeamId.value,
//         if (targetDurationMinutes.value > 0)
//           'targetDurationMinutes': targetDurationMinutes.value,
//         if (trainingTypeCtrl.text.trim().isNotEmpty)
//           'trainingType': trainingTypeCtrl.text.trim(),
//       };
//
//       final response = await _apiClient.post(
//         ApiEndpoint.createTrainingSession,
//         body: body,
//         requiresAuth: true,
//       );
//
//       if (response != null && response['success'] == true) {
//         final data = response['data'];
//         if (data != null && data is Map<String, dynamic>) {
//           final session = TrainingSessionModel.fromJson(data);
//           currentSession.value = session;
//           // Refresh sessions list and dashboard
//           fetchSessionsByTrainer();
//           try {
//             DashboardController.to.fetchDashboardStatics();
//           } catch (_) {}
//
//           Get.snackbar(
//             'Success',
//             response['message']?.toString() ??
//                 'Training session created successfully',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: const Color(0xFF10B981),
//             colorText: Colors.white,
//           );
//           return session;
//         }
//       } else {
//         Get.snackbar(
//           'Error',
//           response?['message']?.toString() ?? 'Failed to create plan',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red.withValues(alpha: 0.8),
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       debugPrint('Error creating training session: $e');
//       Get.snackbar(
//         'Error',
//         'Something went wrong while generating session.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withValues(alpha: 0.8),
//         colorText: Colors.white,
//       );
//     } finally {
//       isCreating.value = false;
//     }
//     return null;
//   }
//
//   Future<bool> updateTrainingSession(
//       String sessionId, Map<String, dynamic> body) async {
//     isUpdating.value = true;
//     try {
//       final endpoint = ApiEndpoint.updateTrainingSession(sessionId);
//       dynamic response;
//       try {
//         response = await _apiClient.put(endpoint, body: body, requiresAuth: true);
//       } catch (_) {
//         response = await _apiClient.patch(endpoint, body: body, requiresAuth: true);
//       }
//
//       if (response != null && response['success'] == true) {
//         final data = response['data'];
//         if (data is Map<String, dynamic>) {
//           final updated = TrainingSessionModel.fromJson(data);
//           currentSession.value = updated;
//         }
//         fetchSessionsByTrainer();
//         try {
//           DashboardController.to.fetchDashboardStatics();
//         } catch (_) {}
//         return true;
//       }
//     } catch (e) {
//       debugPrint('Error updating session: $e');
//     } finally {
//       isUpdating.value = false;
//     }
//     return false;
//   }
//
//   Future<bool> toggleSessionComplete(String sessionId, bool isCompleted) async {
//     final ok = await updateTrainingSession(sessionId, {'isCompleted': isCompleted});
//     if (ok) {
//       Get.snackbar(
//         'Session Updated',
//         isCompleted ? 'Marked session as completed' : 'Marked session as active',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: isCompleted ? const Color(0xFF10B981) : const Color(0xFF4D94FF),
//         colorText: Colors.white,
//       );
//     }
//     return ok;
//   }
//
//   Future<bool> submitSessionReport(
//     String sessionId,
//     String topic,
//     String notes,
//   ) async {
//     isSubmittingReport.value = true;
//     try {
//       final ok = await updateTrainingSession(
//         sessionId,
//         {
//           'reportTopic': topic,
//           'reportNotes': notes,
//         },
//       );
//       if (ok) {
//         Get.snackbar(
//           'Success',
//           'Report submitted successfully',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: const Color(0xFF10B981),
//           colorText: Colors.white,
//         );
//         return true;
//       }
//     } catch (e) {
//       debugPrint('Error submitting session report: $e');
//     } finally {
//       isSubmittingReport.value = false;
//     }
//     return false;
//   }
// }
