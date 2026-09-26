import '../../announcement/controller/announcement_model.dart';

class TeamModel {
  final String id;
  final String name;
  final String? bio;
  final String? address;
  final String? image;
  final String clubId;
  final String? trainerId;
  final String? sendEmail;
  final String? trainerName;
  final bool isSendByEmail;
  final bool isTrainerAccepted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ClubInfo? club;
  final dynamic trainer;

  TeamModel({
    required this.id,
    required this.name,
    this.bio,
    this.address,
    this.image,
    required this.clubId,
    this.trainerId,
    this.sendEmail,
    this.trainerName,
    required this.isSendByEmail,
    required this.isTrainerAccepted,
    this.createdAt,
    this.updatedAt,
    this.club,
    this.trainer,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      bio: json['bio']?.toString(),
      address: json['address']?.toString(),
      image: json['image']?.toString(),
      clubId: json['clubId']?.toString() ?? '',
      trainerId: json['trainerId']?.toString(),
      sendEmail: json['sendEmail']?.toString(),
      trainerName: json['trainerName']?.toString(),
      isSendByEmail: json['isSendByEmail'] == true,
      // Note: Backend JSON keys include 'isTainerAccepted' or 'isTrainerAccepted'
      isTrainerAccepted: (json['isTainerAccepted'] == true || json['isTrainerAccepted'] == true),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      club: (json['club'] != null && json['club'] is Map<String, dynamic>)
          ? ClubInfo.fromJson(json['club'] as Map<String, dynamic>)
          : null,
      trainer: json['trainer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'address': address,
      'image': image,
      'clubId': clubId,
      'trainerId': trainerId,
      'sendEmail': sendEmail,
      'trainerName': trainerName,
      'isSendByEmail': isSendByEmail,
      'isTainerAccepted': isTrainerAccepted,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
