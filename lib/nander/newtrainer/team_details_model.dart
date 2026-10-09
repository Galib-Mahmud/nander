class TeamChartPoint {
  final String name;
  final int total;
  final int completed;

  const TeamChartPoint({
    required this.name,
    required this.total,
    required this.completed,
  });

  factory TeamChartPoint.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

    return TeamChartPoint(
      name: (json['name'] ?? '').toString(),
      total: toInt(json['total']),
      completed: toInt(json['completed']),
    );
  }
}

class TrainerTeamDetailModel {
  final String id;
  final String name;
  final String? bio;
  final String? address;
  final String? image;
  final String? clubId;
  final int totalSessions;
  final int completedSessions;
  final int progressPercentage;
  final List<TeamChartPoint> chartData;

  const TrainerTeamDetailModel({
    required this.id,
    required this.name,
    this.bio,
    this.address,
    this.image,
    this.clubId,
    this.totalSessions = 0,
    this.completedSessions = 0,
    this.progressPercentage = 0,
    this.chartData = const [],
  });

  int get remainingSessions =>
      (totalSessions - completedSessions).clamp(0, totalSessions);

  factory TrainerTeamDetailModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

    final rawChart = json['chartData'];

    return TrainerTeamDetailModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      bio: json['bio']?.toString(),
      address: json['address']?.toString(),
      image: json['image']?.toString(),
      clubId: json['clubId']?.toString(),
      totalSessions: toInt(json['totalSessions']),
      completedSessions: toInt(json['completedSessions']),
      progressPercentage: toInt(json['progressPercentage']),
      chartData: rawChart is List
          ? rawChart
          .whereType<Map>()
          .map((e) => TeamChartPoint.fromJson(Map<String, dynamic>.from(e)))
          .toList()
          : const [],
    );
  }
}