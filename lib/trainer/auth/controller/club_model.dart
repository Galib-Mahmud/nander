class ClubModel {
  final String id;
  final String name;
  final String? profile;
  final String? bio;
  final String? address;
  final bool isOnline;

  ClubModel({
    required this.id,
    required this.name,
    this.profile,
    this.bio,
    this.address,
    required this.isOnline,
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) {
    return ClubModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      profile: json['profile'] as String?,   // null থাকলে null-ই থাকে, crash করে না
      bio: json['bio'] as String?,
      address: json['address'] as String?,
      isOnline: json['isOnline'] == true,     // strictly bool check, non-bool/null হলে false
    );
  }
}