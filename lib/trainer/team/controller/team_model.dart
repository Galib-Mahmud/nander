import '../../announcement/controller/announcement_model.dart';

class TeamMemberModel {
  final String id;
  final String? trainerId;
  final String? teamId;
  final String? trainerName;
  final String? sendEmail;
  final bool isSendByEmail;
  final bool isTrainerRequested;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic trainer;

  TeamMemberModel({
    required this.id,
    this.trainerId,
    this.teamId,
    this.trainerName,
    this.sendEmail,
    this.isSendByEmail = false,
    this.isTrainerRequested = false,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.trainer,
  });

  String get displayName {
    if (trainer is Map && trainer['name'] != null && trainer['name'].toString().isNotEmpty) {
      return trainer['name'].toString();
    }
    if (trainerName != null && trainerName!.isNotEmpty) {
      return trainerName!;
    }
    return 'Trainer';
  }

  String get displayEmail {
    if (trainer is Map && trainer['email'] != null && trainer['email'].toString().isNotEmpty) {
      return trainer['email'].toString();
    }
    if (sendEmail != null && sendEmail!.isNotEmpty) {
      return sendEmail!;
    }
    return '';
  }

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      trainerId: json['trainerId']?.toString(),
      teamId: json['teamId']?.toString(),
      trainerName: json['trainerName']?.toString() ?? json['name']?.toString(),
      sendEmail: json['sendEmail']?.toString() ?? json['email']?.toString(),
      isSendByEmail: json['isSendByEmail'] == true,
      isTrainerRequested: json['isTrainerRequested'] == true,
      status: json['status']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      trainer: json['trainer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainerId': trainerId,
      'teamId': teamId,
      'trainerName': trainerName,
      'sendEmail': sendEmail,
      'isSendByEmail': isSendByEmail,
      'isTrainerRequested': isTrainerRequested,
      'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'trainer': trainer,
    };
  }
}

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
  final List<TeamMemberModel> members;

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
    this.members = const [],
  });

  bool isTrainerJoined(String? currentUserId) {
    if (currentUserId == null || currentUserId.isEmpty) return false;
    if (trainerId == currentUserId) return true;
    return members.any((m) =>
        m.trainerId == currentUserId &&
        (m.status == 'ACTIVE' || m.status == 'accepted'));
  }

  bool isTrainerPending(String? currentUserId) {
    if (currentUserId == null || currentUserId.isEmpty) return false;
    return members.any((m) =>
        m.trainerId == currentUserId &&
        (m.status == 'PENDING' || m.status == 'pending'));
  }

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'];
    List<TeamMemberModel> parsedMembers = [];
    if (rawMembers is List) {
      for (final m in rawMembers) {
        if (m is Map<String, dynamic>) {
          parsedMembers.add(TeamMemberModel.fromJson(m));
        }
      }
    }

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
      members: parsedMembers,
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
      'members': members.map((m) => m.toJson()).toList(),
    };
  }
}
