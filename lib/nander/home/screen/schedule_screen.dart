import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../routes/route_name.dart';
import '../../widget/controller/app_drawer_controller.dart';
import '../controller/training_session_controller.dart';
import '../model/training_session_model.dart';
import 'training_session_detail_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final int activeTabIndex;
  const ScheduleScreen({super.key, this.activeTabIndex = 0});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final TrainingSessionController _controller = TrainingSessionController.to;
  bool isUpcomingSelected = true;
  String selectedTeamFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _controller.fetchSessionsByTrainer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        foregroundColor: Colors.white,
        title: const Text(
          'Schedule',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        //   onPressed: () => Navigator.pop(context),
        // ),
        actions: [
          // Bell Icon with Badge
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Get.toNamed(RouteName.notifications);
                },
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2236),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2A3550),
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 22.w,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5252),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          // More Options
          GestureDetector(
            onTap: () {
              try {
                Get.find<AppDrawerController>().open();
              } catch (_) {}
            },
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2236),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2A3550),
                ),
              ),
              child: const Icon(
                Icons.more_vert,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          SizedBox(width: 20.w),
        ],
        elevation: 0,
      ),
      body: Obx(() {
        final sessions = _controller.trainingSessions;
        final filteredSessions = sessions.where((s) {
          if (isUpcomingSelected && s.isCompleted) return false;
          if (!isUpcomingSelected && !s.isCompleted) return false;
          if (selectedTeamFilter != 'ALL' && s.teamId != selectedTeamFilter) {
            return false;
          }
          return true;
        }).toList();

        return RefreshIndicator(
          color: const Color(0xFF4D94FF),
          backgroundColor: const Color(0xFF1A2236),
          onRefresh: () async {
            await _controller.fetchSessionsByTrainer();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  '${filteredSessions.length} session${filteredSessions.length == 1 ? "" : "s"} scheduled',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Tabs
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2236),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFF2A3550),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => isUpcomingSelected = true),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isUpcomingSelected
                                  ? const Color(0xFF0A0E1A)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.r),
                              border: isUpcomingSelected
                                  ? Border.all(color: const Color(0xFF2A3550))
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Upcoming',
                                style: TextStyle(
                                  color: isUpcomingSelected
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => isUpcomingSelected = false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: !isUpcomingSelected
                                  ? const Color(0xFF0A0E1A)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.r),
                              border: !isUpcomingSelected
                                  ? Border.all(color: const Color(0xFF2A3550))
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Completed',
                                style: TextStyle(
                                  color: !isUpcomingSelected
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Team Filters
              if (_controller.activeTeams.isNotEmpty) ...[
                SizedBox(
                  height: 38.h,
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildTeamChip('ALL', 'All teams'),
                      ..._controller.activeTeams.map((team) {
                        return Padding(
                          padding: EdgeInsets.only(left: 10.w),
                          child: _buildTeamChip(team.teamId, team.name),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // Schedule List
              Expanded(
                child: _controller.isLoadingSessions.value
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF4D94FF)))
                    : filteredSessions.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            itemCount: filteredSessions.length,
                            itemBuilder: (context, index) {
                              final session = filteredSessions[index];
                              return _buildScheduleCard(session);
                            },
                          ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(RouteName.scheduler),
        backgroundColor: const Color(0xFF4D94FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Plan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTeamChip(String id, String name) {
    final isSelected = selectedTeamFilter == id;
    return GestureDetector(
      onTap: () => setState(() => selectedTeamFilter = id),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4D94FF) : const Color(0xFF1A2236),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF4D94FF) : const Color(0xFF2A3550),
          ),
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2236),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2A3550)),
              ),
              child: Icon(Icons.event_note,
                  color: Colors.white.withValues(alpha: 0.4), size: 36.w),
            ),
            SizedBox(height: 16.h),
            Text(
              isUpcomingSelected
                  ? 'No upcoming training sessions'
                  : 'No completed sessions yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isUpcomingSelected
                  ? 'Create a training plan with AI to schedule your next session.'
                  : 'Completed training sessions will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13.sp,
              ),
            ),
            if (isUpcomingSelected) ...[
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(RouteName.scheduler),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Create Training Plan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D94FF),
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(TrainingSessionModel session) {
    final dateStr = session.createdAt != null
        ? '${session.createdAt!.day}/${session.createdAt!.month}/${session.createdAt!.year}'
        : 'Session';

    return GestureDetector(
      onTap: () {
        Get.to(() => TrainingSessionDetailScreen(session: session));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2236),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: const Color(0xFF2A3550),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4D94FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    session.displayFocus.toUpperCase(),
                    style: TextStyle(
                      color: const Color(0xFF4D94FF),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              session.displayTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.access_time,
                    color: Colors.white.withValues(alpha: 0.5), size: 14.w),
                SizedBox(width: 4.w),
                Text(
                  '${session.durationMinutes} min',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(Icons.shield_outlined,
                    color: Colors.white.withValues(alpha: 0.5), size: 14.w),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    session.teamName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.fitness_center_outlined,
                    color: Colors.white.withValues(alpha: 0.5), size: 14.w),
                SizedBox(width: 4.w),
                Text(
                  '${session.exercises.length} exercises',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(Icons.speed,
                    color: Colors.white.withValues(alpha: 0.5), size: 14.w),
                SizedBox(width: 4.w),
                Text(
                  session.displayDifficulty,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
