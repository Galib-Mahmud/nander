class TrainerModel {
  final String id;
  final String email;
  final String name;
  final String? profile;
  final String? bio;
  final String? address;
  final String? role;
  final bool isOnline;
  final bool isVerified;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TrainerModel({
    required this.id,
    required this.email,
    required this.name,
    this.profile,
    this.bio,
    this.address,
    this.role,
    this.isOnline = false,
    this.isVerified = false,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory TrainerModel.fromJson(Map<String, dynamic> json) {
    return TrainerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      profile: json['profile']?.toString(),
      bio: json['bio']?.toString(),
      address: json['address']?.toString(),
      role: json['role']?.toString(),
      isOnline: json['isOnline'] == true,
      isVerified: json['isVerified'] == true,
      status: json['status']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }
}

class ClubTrainerItem {
  final String id;
  final String? trainerId;
  final String? clubAdminId;
  final String? status;
  final String? trainerName;
  final String? sendEmail;
  final bool isSendByEmail;
  final bool isTrainerRequested;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final TrainerModel? trainer;
  final dynamic clubAdmin;

  ClubTrainerItem({
    required this.id,
    this.trainerId,
    this.clubAdminId,
    this.status,
    this.trainerName,
    this.sendEmail,
    this.isSendByEmail = false,
    this.isTrainerRequested = false,
    this.createdAt,
    this.updatedAt,
    this.trainer,
    this.clubAdmin,
  });

  String get displayName {
    if (trainer != null && trainer!.name.isNotEmpty) {
      return trainer!.name;
    }
    if (trainerName != null && trainerName!.isNotEmpty) {
      return trainerName!;
    }
    if (clubAdmin is Map && clubAdmin['name'] != null) {
      return clubAdmin['name'].toString();
    }
    return 'Trainer';
  }

  String get displayEmail {
    if (trainer != null && trainer!.email.isNotEmpty) {
      return trainer!.email;
    }
    if (sendEmail != null && sendEmail!.isNotEmpty) {
      return sendEmail!;
    }
    if (clubAdmin is Map && clubAdmin['email'] != null) {
      return clubAdmin['email'].toString();
    }
    return '';
  }

  factory ClubTrainerItem.fromJson(Map<String, dynamic> json) {
    TrainerModel? trainerObj;
    if (json['trainer'] != null && json['trainer'] is Map<String, dynamic>) {
      trainerObj = TrainerModel.fromJson(json['trainer'] as Map<String, dynamic>);
    } else if (json['role'] == 'TRAINER' || (json['email'] != null && json['trainerId'] == null)) {
      trainerObj = TrainerModel.fromJson(json);
    }

    return ClubTrainerItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      trainerId: json['trainerId']?.toString(),
      clubAdminId: json['clubAdminId']?.toString() ?? json['clubId']?.toString(),
      status: json['status']?.toString(),
      trainerName: json['trainerName']?.toString() ?? json['name']?.toString(),
      sendEmail: json['sendEmail']?.toString() ?? json['email']?.toString(),
      isSendByEmail: json['isSendByEmail'] == true,
      isTrainerRequested: json['isTrainerRequested'] == true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      trainer: trainerObj,
      clubAdmin: json['clubAdmin'] ?? json['club'],
    );
  }
}
