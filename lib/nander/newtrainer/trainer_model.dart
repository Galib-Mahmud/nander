class TrainerTeamModel {
  final String id;
  final String name;
  final String? bio;
  final String? address;
  final String? image;
  final String? clubId;
  final int totalSessions;
  final int completedSessions;
  final int progressPercentage;

  const TrainerTeamModel({
    required this.id,
    required this.name,
    this.bio,
    this.address,
    this.image,
    this.clubId,
    this.totalSessions = 0,
    this.completedSessions = 0,
    this.progressPercentage = 0,
  });

  factory TrainerTeamModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

    return TrainerTeamModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      bio: json['bio']?.toString(),
      address: json['address']?.toString(),
      image: json['image']?.toString(),
      clubId: json['clubId']?.toString(),
      totalSessions: toInt(json['totalSessions']),
      completedSessions: toInt(json['completedSessions']),
      progressPercentage: toInt(json['progressPercentage']),
    );
  }
}
