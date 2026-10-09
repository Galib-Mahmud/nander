import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nander/nander/newtrainer/trainer_controller.dart';
import 'package:nander/nander/newtrainer/trainer_model.dart';
import 'package:nander/nander/newtrainer/trainner_team_details_screen.dart';


/// Trainer's team list with training progress.
/// No bottom nav bar here - it is meant to be placed inside the app shell
/// that already owns the nav bar.
class TrainerTeam extends StatelessWidget {
  const TrainerTeam({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrainerTeamController());

    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.teams.isEmpty) {
                  return const Center(
                    child:
                    CircularProgressIndicator(color: Color(0xFF4D94FF)),
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFF4D94FF),
                  backgroundColor: const Color(0xFF111827),
                  onRefresh: controller.fetchMyTeams,
                  child: _buildBody(controller),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header: "Team" + first team name ───────────────────────────────
  Widget _buildHeader(TrainerTeamController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final subtitle = controller.teams.isNotEmpty
                  ? controller.teams.first.name
                  : '';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF8B95A5),
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Body states: error / empty / list ──────────────────────────────
  Widget _buildBody(TrainerTeamController controller) {
    if (controller.errorMessage.value.isNotEmpty &&
        controller.teams.isEmpty) {
      return _scrollableMessage(
        icon: Icons.error_outline,
        title: controller.errorMessage.value,
      );
    }

    if (controller.teams.isEmpty) {
      return _scrollableMessage(
        icon: Icons.groups_outlined,
        title: 'No teams found',
        subtitle: 'Teams you are part of will appear here',
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
      itemCount: controller.teams.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final team = controller.teams[index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Get.to(
                () => TrainerTeamDetailScreen(
              teamId: team.id,
              initialName: team.name,
            ),
          ),
          child: _buildTeamProgressCard(team),
        );
      },
    );
  }

  Widget _scrollableMessage({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 120.h),
        Icon(icon, color: const Color(0xFF8B95A5), size: 56.w),
        SizedBox(height: 14.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 6.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF8B95A5),
              fontSize: 13.sp,
            ),
          ),
        ],
      ],
    );
  }

  // ─── Team card with progress bar ────────────────────────────────────
  Widget _buildTeamProgressCard(TrainerTeamModel team) {
    final percent = team.progressPercentage.clamp(0, 100);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            team.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  color: const Color(0xFF8B95A5),
                  fontSize: 14.sp,
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6.h,
              backgroundColor: Colors.white,
              valueColor:
              const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }
}