import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../chat/screen/add_new_team_screen.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../home/controller/notification_controller.dart';
import '../../routes/route_name.dart';
import '../../team/controller/team_controller.dart';
import '../../team/controller/team_model.dart';
import '../../widget/controller/app_drawer_controller.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final TeamController controller = TeamController.to;
  final TextEditingController searchCtrl = TextEditingController();
  final RxString searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    controller.fetchTeams();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  List<TeamModel> get filteredTeams {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return controller.teams;
    return controller.teams.where((team) {
      final nameMatches = team.name.toLowerCase().contains(q);
      final addressMatches = (team.address ?? '').toLowerCase().contains(q);
      final bioMatches = (team.bio ?? '').toLowerCase().contains(q);
      final trainerMatches = (team.trainerName ?? '').toLowerCase().contains(q);
      return nameMatches || addressMatches || bioMatches || trainerMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    NotificationController? notificationCtrl;
    try {
      notificationCtrl = NotificationController.to;
    } catch (_) {}

    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050810),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Teams',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.h),
            Obx(() => Text(
              controller.isClubAdmin.value ? 'Manage Club Teams' : 'Explore & Assigned Teams',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF8B95A5),
                fontWeight: FontWeight.normal,
              ),
            )),
          ],
        ),
        actions: [
          if (notificationCtrl != null) _buildNotificationBell(notificationCtrl),
          SizedBox(width: 12.w),
          _buildMoreOptions(),
          SizedBox(width: 16.w),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: TextField(
                  controller: searchCtrl,
                  onChanged: (val) => searchQuery.value = val,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search teams...',
                    hintStyle: TextStyle(color: const Color(0xFF8B95A5), fontSize: 14.sp),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF8B95A5), size: 20),
                    suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                            onPressed: () {
                              searchCtrl.clear();
                              searchQuery.value = '';
                            },
                          )
                        : const SizedBox.shrink()),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ),

            // Content List / Empty State
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.teams.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF4D94FF)));
                }

                final teamsList = filteredTeams;

                if (teamsList.isEmpty) {
                  return RefreshIndicator(
                    color: const Color(0xFF4D94FF),
                    backgroundColor: const Color(0xFF111827),
                    onRefresh: controller.fetchTeams,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 120.h),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.groups_outlined, size: 64.w, color: Colors.white24),
                              SizedBox(height: 16.h),
                              Text(
                                searchQuery.value.isNotEmpty ? 'No matching teams' : 'No teams found',
                                style: TextStyle(color: Colors.white70, fontSize: 16.sp, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                searchQuery.value.isNotEmpty
                                    ? 'Try searching with different keywords.'
                                    : (controller.isClubAdmin.value
                                        ? 'Tap below to add your first team.'
                                        : 'No teams available to display.'),
                                style: TextStyle(color: Colors.white38, fontSize: 13.sp),
                              ),
                              if (controller.isClubAdmin.value && searchQuery.value.isEmpty) ...[
                                SizedBox(height: 24.h),
                                ElevatedButton.icon(
                                  onPressed: () => Get.to(() => const AddNewTeamScreen()),
                                  icon: const Icon(Icons.add, color: Colors.white),
                                  label: const Text('Add Team', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4D94FF),
                                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFF4D94FF),
                  backgroundColor: const Color(0xFF111827),
                  onRefresh: controller.fetchTeams,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, controller.isClubAdmin.value ? 90.h : 20.h),
                    itemCount: teamsList.length,
                    itemBuilder: (context, index) {
                      final team = teamsList[index];
                      return _buildTeamCard(context, team, controller);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() => controller.isClubAdmin.value
          ? Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: FloatingActionButton.extended(
                onPressed: () => Get.to(() => const AddNewTeamScreen()),
                backgroundColor: const Color(0xFF4D94FF),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('New Team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          : const SizedBox.shrink()),
    );
  }

  Widget _buildTeamCard(BuildContext context, TeamModel team, TeamController controller) {
    final isClubAdmin = controller.isClubAdmin.value;
    final isJoined = team.isTrainerJoined(controller.currentUserId.value);
    final isPending = team.isTrainerPending(controller.currentUserId.value) ||
        controller.pendingJoinTeamIds.contains(team.id);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 54.w,
                  height: 54.w,
                  color: const Color(0xFF050810),
                  child: (team.image != null && team.image!.isNotEmpty)
                      ? Image.network(
                          ApiEndpoint.resolveImageUrl(team.image) ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.shield, color: Color(0xFF4D94FF), size: 28)),
                        )
                      : const Center(child: Icon(Icons.shield, color: Color(0xFF4D94FF), size: 28)),
                ),
              ),
              SizedBox(width: 14.w),

              // Team Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (team.address != null && team.address!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.white54),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              team.address!,
                              style: TextStyle(color: const Color(0xFF8B95A5), fontSize: 12.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Admin Popup Menu or Trainer Join Button
              if (isClubAdmin)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                  color: const Color(0xFF161E30),
                  onSelected: (value) {
                    if (value == 'add_member') {
                      _showAddMemberBottomSheet(context, team, controller);
                    } else if (value == 'edit') {
                      Get.to(() => AddNewTeamScreen(team: team));
                    } else if (value == 'delete') {
                      Get.dialog(
                        AlertDialog(
                          backgroundColor: const Color(0xFF161E30),
                          title: const Text('Delete Team', style: TextStyle(color: Colors.white)),
                          content: Text(
                            'Are you sure you want to delete "${team.name}"?',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                controller.deleteTeam(team.id);
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'add_member',
                      child: Row(
                        children: [
                          Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF4D94FF), size: 18),
                          SizedBox(width: 8),
                          Text('Add Member', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                // Trainer Action: Joined / Pending / Join Team button
                if (isJoined)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, size: 13.sp, color: const Color(0xFF10B981)),
                        SizedBox(width: 4.w),
                        Text(
                          'Joined',
                          style: TextStyle(
                            color: const Color(0xFF10B981),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isPending)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'Request Pending',
                      style: TextStyle(
                        color: const Color(0xFFF59E0B),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => controller.joinTeamAsTrainer(team.id),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D94FF),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        'Join Team',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),

          if (team.bio != null && team.bio!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              team.bio!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13.sp,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          SizedBox(height: 14.h),
          Divider(color: Colors.white.withValues(alpha: 0.08)),
          SizedBox(height: 10.h),

          // Members list or Lead Trainer info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12.r,
                      backgroundColor: const Color(0xFF2A3550),
                      child: Icon(Icons.person, size: 14.r, color: Colors.white70),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        (team.members.isNotEmpty)
                            ? '${team.members.length} Trainer${team.members.length > 1 ? 's' : ''} assigned'
                            : (team.trainerName != null && team.trainerName!.isNotEmpty)
                                ? team.trainerName!
                                : (team.sendEmail ?? 'No trainer assigned'),
                        style: TextStyle(color: Colors.white70, fontSize: 12.sp, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Status chip (Club Admin)
              if (isClubAdmin)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: team.isTrainerAccepted
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: team.isTrainerAccepted
                          ? const Color(0xFF10B981).withValues(alpha: 0.4)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    team.isTrainerAccepted ? 'Active' : 'Pending',
                    style: TextStyle(
                      color: team.isTrainerAccepted ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          // If members exist, show quick preview pills
          if (team.members.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              children: team.members.take(3).map((m) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    m.displayName,
                    style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddMemberBottomSheet(BuildContext context, TeamModel team, TeamController controller) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161E30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Member to Team',
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                'Team: ${team.name}',
                style: TextStyle(color: const Color(0xFF4D94FF), fontSize: 13.sp),
              ),
              SizedBox(height: 16.h),

              Text('Trainer Name', style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
              SizedBox(height: 6.h),
              Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    hintStyle: TextStyle(color: const Color(0xFF8B95A5), fontSize: 14.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              Text('Trainer Email', style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
              SizedBox(height: 6.h),
              Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter Trainer Email',
                    hintStyle: TextStyle(color: const Color(0xFF8B95A5), fontSize: 14.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () async {
                    if (emailCtrl.text.trim().isEmpty) {
                      Get.snackbar('Error', 'Please enter trainer email');
                      return;
                    }
                    Navigator.pop(ctx);
                    await controller.addTeamMember(
                      teamId: team.id,
                      trainerName: nameCtrl.text.trim(),
                      sendEmail: emailCtrl.text.trim(),
                      isSendByEmail: true,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D94FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: const Text('Add Member', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationBell(NotificationController notificationCtrl) {
    return GestureDetector(
      onTap: () => Get.toNamed(RouteName.notifications),
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.notifications_outlined, color: Colors.white.withValues(alpha: 0.7), size: 22.w),
            Obx(() {
              if (notificationCtrl.unreadCount > 0) {
                return Positioned(
                  right: 4.w,
                  top: 4.w,
                  child: Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        '${notificationCtrl.unreadCount}',
                        style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOptions() {
    return GestureDetector(
      onTap: () {
        try {
          Get.find<AppDrawerController>().open();
        } catch (_) {}
      },
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: const Icon(Icons.more_vert, color: Colors.white, size: 22),
      ),
    );
  }
}