import '../../core/endpoint/api_endpoint.dart';

class ActiveTeamItem {
  final String id;
  final String teamId;
  final String name;
  final String? bio;
  final String? address;
  final String? image;
  final String? clubId;
  final String? clubName;

  ActiveTeamItem({
    required this.id,
    required this.teamId,
    required this.name,
    this.bio,
    this.address,
    this.image,
    this.clubId,
    this.clubName,
  });

  String? get resolvedImageUrl => ApiEndpoint.resolveImageUrl(image);

  factory ActiveTeamItem.fromJson(Map<String, dynamic> json) {
    // Active teams API: team info is nested in json['team']
    final teamObj = json['team'] as Map<String, dynamic>?;
    return ActiveTeamItem(
      id: json['id']?.toString() ?? '',
      teamId: teamObj?['id']?.toString() ??
          json['teamId']?.toString() ??
          json['id']?.toString() ??
          '',
      name: teamObj?['name']?.toString() ??
          json['name']?.toString() ??
          json['teamName']?.toString() ??
          'Team',
      bio: teamObj?['bio']?.toString(),
      address: teamObj?['address']?.toString(),
      image: teamObj?['image']?.toString() ?? json['image']?.toString(),
      clubId: teamObj?['clubId']?.toString() ?? json['clubId']?.toString(),
      clubName: json['clubName']?.toString(),
    );
  }
}

class ExerciseModel {
  final String? id;
  final int order;
  final String? slotName;
  final String exerciseName;
  final String? allocatedDuration;
  final String? keyCoachingCue;
  final String? imageUrl;
  final int exerciseNumber;
  final String title;
  final int durationMinutes;
  final String? category;
  final String? difficulty;
  final String? fieldsize;
  final String? description;
  final List<String> coachingPoints;
  final List<String> keyFactors;
  final String? setup;
  final List<String> variations;

  ExerciseModel({
    this.id,
    int? order,
    this.slotName,
    String? exerciseName,
    this.allocatedDuration,
    this.keyCoachingCue,
    this.imageUrl,
    this.exerciseNumber = 1,
    String? title,
    this.durationMinutes = 15,
    this.category,
    this.difficulty,
    this.fieldsize,
    this.description,
    this.coachingPoints = const [],
    this.keyFactors = const [],
    this.setup,
    this.variations = const [],
  })  : order = order ?? exerciseNumber,
        exerciseName = exerciseName ?? title ?? 'Exercise',
        title = title ?? exerciseName ?? 'Exercise';

  String? get resolvedImageUrl => ApiEndpoint.resolveImageUrl(imageUrl);

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    final num = json['order'] is int
        ? json['order'] as int
        : (json['exerciseNumber'] is int
            ? json['exerciseNumber'] as int
            : int.tryParse(json['order']?.toString() ??
                    json['exerciseNumber']?.toString() ??
                    '1') ??
                1);

    final name = json['exerciseName']?.toString() ??
        json['title']?.toString() ??
        json['name']?.toString() ??
        'Exercise';

    final durMin = json['durationMinutes'] is int
        ? json['durationMinutes'] as int
        : int.tryParse(json['durationMinutes']?.toString() ?? '15') ?? 15;

    final durStr = json['allocatedDuration']?.toString() ?? '$durMin min';

    return ExerciseModel(
      id: json['id']?.toString() ?? json['exerciseId']?.toString(),
      order: num,
      exerciseNumber: num,
      slotName: json['slotName']?.toString() ?? json['slot']?.toString(),
      exerciseName: name,
      title: name,
      allocatedDuration: durStr,
      durationMinutes: durMin,
      keyCoachingCue: json['keyCoachingCue']?.toString(),
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
      category: json['category']?.toString(),
      difficulty: json['difficulty']?.toString(),
      fieldsize: json['fieldsize']?.toString(),
      description: json['description']?.toString(),
      coachingPoints: parseList(json['coachingPoints']),
      keyFactors: parseList(json['keyFactors']),
      setup: json['setup']?.toString(),
      variations: parseList(json['variations']),
    );
  }
}

class SessionReportModel {
  final String? id;
  final String? topic;
  final String? notes;
  final int? attendanceCount;

  SessionReportModel({this.id, this.topic, this.notes, this.attendanceCount});

  factory SessionReportModel.fromJson(Map<String, dynamic> json) {
    return SessionReportModel(
      id: json['id']?.toString(),
      topic: json['topic']?.toString() ?? json['reportTopic']?.toString(),
      notes: json['notes']?.toString() ?? json['reportNotes']?.toString(),
      attendanceCount: json['attendanceCount'] is int
          ? json['attendanceCount']
          : int.tryParse(json['attendanceCount']?.toString() ?? '0'),
    );
  }
}

class TrainingSessionModel {
  final String id;
  final String? teamId;
  final String teamName;
  final String? period;
  final dynamic perWeek;
  final String? focus;
  final String? title;
  final String? category;
  final String? difficulty;
  final String? fieldsize;
  final int totalDurationMinutes;
  final String? sessionOverview;
  final String? coachingRationale;
  final bool isCompleted;
  final DateTime? createdAt;
  final List<ExerciseModel> exercises;
  final List<SessionReportModel> sessionReports;

  TrainingSessionModel({
    required this.id,
    this.teamId,
    this.teamName = 'Team',
    this.period,
    this.perWeek,
    this.focus,
    this.title,
    this.category,
    this.difficulty,
    this.fieldsize,
    this.totalDurationMinutes = 90,
    this.sessionOverview,
    this.coachingRationale,
    this.isCompleted = false,
    this.createdAt,
    this.exercises = const [],
    this.sessionReports = const [],
  });

  int get durationMinutes => totalDurationMinutes;

  String get displayTitle =>
      (title != null && title!.isNotEmpty) ? title! : 'Training Session';

  String get displayFocus =>
      (focus != null && focus!.isNotEmpty) ? focus! : (category ?? 'ATTACK');

  String get displayDifficulty =>
      (difficulty != null && difficulty!.isNotEmpty) ? difficulty! : 'EASY';

  String get displayFieldsize =>
      (fieldsize != null && fieldsize!.isNotEmpty) ? fieldsize! : 'FULL_FIELD';

  factory TrainingSessionModel.fromJson(Map<String, dynamic> json) {
    var exList = <ExerciseModel>[];
    if (json['exercises'] is List) {
      exList = (json['exercises'] as List)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    var repList = <SessionReportModel>[];
    if (json['sessionReports'] is List) {
      repList = (json['sessionReports'] as List)
          .map((e) => SessionReportModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    DateTime? created;
    if (json['createdAt'] != null) {
      created = DateTime.tryParse(json['createdAt'].toString());
    }

    final titleVal = json['sessionTitle']?.toString() ??
        json['title']?.toString() ??
        json['name']?.toString();

    final focusVal =
        json['focus']?.toString() ?? json['category']?.toString();

    final totalDur = json['totalDurationMinutes'] is int
        ? json['totalDurationMinutes'] as int
        : (json['targetDurationMinutes'] is int
            ? json['targetDurationMinutes'] as int
            : int.tryParse(json['totalDurationMinutes']?.toString() ??
                    json['targetDurationMinutes']?.toString() ??
                    '90') ??
                90);

    return TrainingSessionModel(
      id: json['id']?.toString() ?? '',
      teamId: json['teamId']?.toString() ?? json['team']?['id']?.toString(),
      teamName: json['team']?['name']?.toString() ??
          json['teamName']?.toString() ??
          'Team',
      period: json['period']?.toString(),
      perWeek: json['perWeek'],
      focus: focusVal,
      title: titleVal,
      category: json['category']?.toString() ?? focusVal,
      difficulty: json['difficulty']?.toString(),
      fieldsize: json['fieldsize']?.toString(),
      totalDurationMinutes: totalDur,
      sessionOverview: json['sessionOverview']?.toString(),
      coachingRationale: json['coachingRationale']?.toString(),
      isCompleted: json['isCompleted'] == true,
      createdAt: created,
      exercises: exList,
      sessionReports: repList,
    );
  }
}
