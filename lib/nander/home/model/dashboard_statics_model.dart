import 'training_session_model.dart';

class AnnouncementDashItem {
  final String id;
  final String title;
  final String description;

  AnnouncementDashItem({
    required this.id,
    required this.title,
    required this.description,
  });

  factory AnnouncementDashItem.fromJson(Map<String, dynamic> json) {
    return AnnouncementDashItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

class ReadinessItem {
  final String id;
  final String name;
  final String? image;
  final int progress;

  ReadinessItem({
    required this.id,
    required this.name,
    this.image,
    this.progress = 0,
  });

  factory ReadinessItem.fromJson(Map<String, dynamic> json) {
    return ReadinessItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      progress: json['progress'] is int
          ? json['progress'] as int
          : int.tryParse(json['progress']?.toString() ?? '0') ?? 0,
    );
  }
}

class DashboardStaticsModel {
  final int totalSession;
  final num weeklyProgress;
  final int? totalTrainer;
  final TrainingSessionModel? mostNewSessionToday;
  final List<TrainingSessionModel> last5Session;
  final List<AnnouncementDashItem> announcements;
  final List<ReadinessItem> readinessItems;
  final Map<String, dynamic>? rawJson;

  DashboardStaticsModel({
    this.totalSession = 0,
    this.weeklyProgress = 0,
    this.totalTrainer,
    this.mostNewSessionToday,
    this.last5Session = const [],
    this.announcements = const [],
    this.readinessItems = const [],
    this.rawJson,
  });

  factory DashboardStaticsModel.fromJson(Map<String, dynamic> json) {
    TrainingSessionModel? session;
    if (json['mostNewSessionToday'] != null &&
        json['mostNewSessionToday'] is Map<String, dynamic>) {
      try {
        session = TrainingSessionModel.fromJson(
            json['mostNewSessionToday'] as Map<String, dynamic>);
      } catch (_) {}
    }

    final parsedLast5 = <TrainingSessionModel>[];
    if (json['last5Session'] is List) {
      for (final item in json['last5Session'] as List) {
        if (item is Map<String, dynamic>) {
          try {
            parsedLast5.add(TrainingSessionModel.fromJson(item));
          } catch (_) {}
        }
      }
    }

    // Parse announcements (key is 'announcement' in API response)
    final parsedAnnouncements = <AnnouncementDashItem>[];
    final announcementRaw = json['announcement'] ?? json['announcements'];
    if (announcementRaw is List) {
      for (final item in announcementRaw) {
        if (item is Map<String, dynamic>) {
          try {
            parsedAnnouncements.add(AnnouncementDashItem.fromJson(item));
          } catch (_) {}
        }
      }
    }

    // Parse readiness — club admin uses 'clubReadiness', trainer uses 'teamReadiness'
    final parsedReadiness = <ReadinessItem>[];
    final readinessRaw = json['clubReadiness'] ?? json['teamReadiness'];
    if (readinessRaw is List) {
      for (final item in readinessRaw) {
        if (item is Map<String, dynamic>) {
          try {
            parsedReadiness.add(ReadinessItem.fromJson(item));
          } catch (_) {}
        }
      }
    }

    return DashboardStaticsModel(
      totalSession: int.tryParse(json['totalSession']?.toString() ?? '') ?? 0,
      weeklyProgress:
          num.tryParse(json['weeklyProgress']?.toString() ?? '') ?? 0,
      totalTrainer: int.tryParse(json['totalTrainer']?.toString() ?? ''),
      mostNewSessionToday: session,
      last5Session: parsedLast5,
      announcements: parsedAnnouncements,
      readinessItems: parsedReadiness,
      rawJson: json,
    );
  }
}
