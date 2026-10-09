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

  String? get displayImage {
    if (trainer is Map && trainer['profile'] != null && trainer['profile'].toString().isNotEmpty) {
      return trainer['profile'].toString();
    }
    if (trainer is Map && trainer['image'] != null && trainer['image'].toString().isNotEmpty) {
      return trainer['image'].toString();
    }
    return null;
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
  final String? requestId;
  final String? requestStatus;
  final int totalSessions;
  final int completedSessions;
  final int progressPercentage;

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
    this.requestId,
    this.requestStatus,
    this.totalSessions = 0,
    this.completedSessions = 0,
    this.progressPercentage = 0,
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
    Map<String, dynamic> data = json;
    String? reqId = json['requestId']?.toString();
    String? reqStatus = json['requestStatus']?.toString() ?? json['status']?.toString();

    if (json.containsKey('team') && json['team'] is Map<String, dynamic>) {
      reqId ??= json['id']?.toString() ?? json['_id']?.toString();
      reqStatus ??= json['status']?.toString();
      data = Map<String, dynamic>.from(json['team'] as Map);
    }

    final rawMembers = data['members'] ?? json['members'];
    List<TeamMemberModel> parsedMembers = [];
    if (rawMembers is List) {
      for (final m in rawMembers) {
        if (m is Map<String, dynamic>) {
          parsedMembers.add(TeamMemberModel.fromJson(m));
        }
      }
    }

    int toInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

    return TeamModel(
      id: data['id']?.toString() ?? data['_id']?.toString() ?? json['teamId']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      bio: data['bio']?.toString(),
      address: data['address']?.toString(),
      image: data['image']?.toString(),
      clubId: data['clubId']?.toString() ?? '',
      trainerId: data['trainerId']?.toString(),
      sendEmail: data['sendEmail']?.toString(),
      trainerName: data['trainerName']?.toString(),
      isSendByEmail: data['isSendByEmail'] == true,
      isTrainerAccepted: (data['isTainerAccepted'] == true ||
          data['isTrainerAccepted'] == true ||
          data['status'] == 'accepted' ||
          data['status'] == 'ACTIVE'),
      createdAt: data['createdAt'] != null ? DateTime.tryParse(data['createdAt'].toString()) : null,
      updatedAt: data['updatedAt'] != null ? DateTime.tryParse(data['updatedAt'].toString()) : null,
      club: (data['club'] != null && data['club'] is Map<String, dynamic>)
          ? ClubInfo.fromJson(data['club'] as Map<String, dynamic>)
          : null,
      trainer: data['trainer'],
      members: parsedMembers,
      requestId: reqId,
      requestStatus: reqStatus,
      totalSessions: toInt(data['totalSessions'] ?? json['totalSessions']),
      completedSessions: toInt(data['completedSessions'] ?? json['completedSessions']),
      progressPercentage: toInt(data['progressPercentage'] ?? json['progressPercentage']),
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
      if (requestId != null) 'requestId': requestId,
      if (requestStatus != null) 'requestStatus': requestStatus,
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'progressPercentage': progressPercentage,
    };
  }
}
