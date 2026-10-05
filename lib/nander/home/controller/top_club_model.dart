/// Model for a club in the "My Network" response
class NetworkClubModel {
  final String id;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ClubInfo club;

  NetworkClubModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.club,
  });

  factory NetworkClubModel.fromJson(Map<String, dynamic> json) {
    return NetworkClubModel(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      club: ClubInfo.fromJson(json['club'] ?? {}),
    );
  }
}

/// Detailed club info from the network response
class ClubInfo {
  final String id;
  final String email;
  final String name;
  final String? profile;
  final String? bio;
  final String? address;
  final String role;
  final bool isOnline;
  final bool isVerified;
  final String status;

  ClubInfo({
    required this.id,
    required this.email,
    required this.name,
    this.profile,
    this.bio,
    this.address,
    required this.role,
    required this.isOnline,
    required this.isVerified,
    required this.status,
  });

  factory ClubInfo.fromJson(Map<String, dynamic> json) {
    return ClubInfo(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      profile: json['profile'],
      bio: json['bio'],
      address: json['address'],
      role: json['role'] ?? '',
      isOnline: json['isOnline'] ?? false,
      isVerified: json['isVerified'] ?? false,
      status: json['status'] ?? '',
    );
  }
}

/// Model for a club in the "Find Clubs" response
class FindClubModel {
  final String id;
  final String name;
  final String email;
  final String? profile;
  final String role;
  final bool isOnline;

  FindClubModel({
    required this.id,
    required this.name,
    required this.email,
    this.profile,
    required this.role,
    required this.isOnline,
  });

  factory FindClubModel.fromJson(Map<String, dynamic> json) {
    return FindClubModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profile: json['profile'],
      role: json['role'] ?? '',
      isOnline: json['isOnline'] ?? false,
    );
  }
}
