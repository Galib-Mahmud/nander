class AnnouncementModel {
  final String id;
  final String title;
  final String description;
  final String clubId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ClubInfo? club; // Optional, as it might not be in list view

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.clubId,
    required this.createdAt,
    required this.updatedAt,
    this.club,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      club: json['club'] != null ? ClubInfo.fromJson(json['club']) : null,
    );
  }
}

class ClubInfo {
  final String id;
  final String name;
  final String profile;
  final String role;

  ClubInfo({
    required this.id,
    required this.name,
    required this.profile,
    required this.role,
  });

  factory ClubInfo.fromJson(Map<String, dynamic> json) {
    return ClubInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      profile: json['profile']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}