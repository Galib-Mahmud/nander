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

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TeamController controller = TeamController.to;
    final notificationCtrl = NotificationController.to;

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
              controller.isClubAdmin.value ? 'Manage Club Teams' : 'Assigned Teams',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF8B95A5),
                fontWeight: FontWeight.normal,
              ),
            )),
          ],
        ),
        actions: [
          _buildNotificationBell(notificationCtrl),
          SizedBox(width: 12.w),
          _buildMoreOptions(),
          SizedBox(width: 16.w),
        ],
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.teams.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4D94FF)));
        }

        if (controller.teams.isEmpty) {
          return RefreshIndicator(
            color: const Color(0xFF4D94FF),
            backgroundColor: const Color(0xFF111827),
            onRefresh: controller.fetchTeams,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 140.h),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.groups_outlined, size: 64.w, color: Colors.white24),
                      SizedBox(height: 16.h),
                      Text(
                        'No teams found',
                        style: TextStyle(color: Colors.white70, fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        controller.isClubAdmin.value
                            ? 'Tap below to add your first team.'
                            : 'You have not been assigned to any teams yet.',
                        style: TextStyle(color: Colors.white38, fontSize: 13.sp),
                      ),
                      if (controller.isClubAdmin.value) ...[
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
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 110.h),
            itemCount: controller.teams.length,
            itemBuilder: (context, index) {
              final team = controller.teams[index];
              return _buildTeamCard(context, team, controller);
            },
          ),
        );
      }),
      floatingActionButton: Obx(() => controller.isClubAdmin.value
          ? Padding(
              padding: EdgeInsets.only(bottom: 70.h),
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

              // Admin Actions (Edit & Delete)
              if (controller.isClubAdmin.value)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                  color: const Color(0xFF161E30),
                  onSelected: (value) {
                    if (value == 'edit') {
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
                ),
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

          // Trainer Info & Status Badge
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
                        (team.trainerName != null && team.trainerName!.isNotEmpty)
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

              // Status chip
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
                  team.isTrainerAccepted ? 'Accepted' : 'Pending',
                  style: TextStyle(
                    color: team.isTrainerAccepted ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
        Get.find<AppDrawerController>().open();
      },
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Icon(Icons.more_vert, color: Colors.white, size: 22.w),
      ),
    );
  }
}