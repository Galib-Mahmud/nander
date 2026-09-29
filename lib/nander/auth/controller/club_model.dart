class ClubModel {
  final String id;
  final String name;
  final String? email;
  final String? profile;
  final String? bio;
  final String? address;
  final String? role;
  final bool isOnline;
  final bool isVerified;
  final String? status;

  ClubModel({
    required this.id,
    required this.name,
    this.email,
    this.profile,
    this.bio,
    this.address,
    this.role,
    this.isOnline = false,
    this.isVerified = false,
    this.status,
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) {
    return ClubModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      profile: json['profile'] as String?,
      bio: json['bio'] as String?,
      address: json['address'] as String?,
      role: json['role']?.toString(),
      isOnline: json['isOnline'] == true,
      isVerified: json['isVerified'] == true,
      status: json['status']?.toString(),
    );
  }
}
