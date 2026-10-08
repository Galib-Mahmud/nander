import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nander/nander/home/screen/schedule_screen.dart';

import '../../core/endpoint/api_endpoint.dart';
import '../../routes/route_name.dart';
import '../../widget/controller/app_drawer_controller.dart';
import '../controller/dashboard_controller.dart';
import '../model/dashboard_statics_model.dart';
import '../model/training_session_model.dart';
import 'training_session_detail_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DashboardController.to;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.dashboardData.value == null) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4D94FF)));
        }
        final data = controller.dashboardData.value;
        final isAdmin = controller.userRole.value == 'CLUB_ADMIN';

        return RefreshIndicator(
          color: const Color(0xFF4D94FF),
          backgroundColor: const Color(0xFF1A2236),
          onRefresh: controller.fetchDashboardStatics,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 52.h, 20.w, 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A1628),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Text('TU',
                                      style: TextStyle(
                                          color: Color(0xFF4D94FF),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Today',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 2.h),
                              Text(
                                  isAdmin
                                      ? 'Club Admin Dashboard'
                                      : 'Trainer Dashboard',
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.6),
                                      fontSize: 13.sp)),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 44.w,
                                height: 44.w,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF1A2236),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFF2A3550))),
                                child: GestureDetector(
                                  onTap: () =>
                                      Get.toNamed(RouteName.notifications),
                                  child: Icon(Icons.notifications_outlined,
                                      color: Colors.white, size: 20.w),
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
                                          shape: BoxShape.circle),
                                      child: Center(
                                          child: Text('3',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10.sp,
                                                  fontWeight:
                                                      FontWeight.bold))))),
                            ],
                          ),
                          SizedBox(width: 12.w),
                          GestureDetector(
                            onTap: () => Get.find<AppDrawerController>().open(),
                            child: Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF1A2236),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: const Color(0xFF2A3550))),
                              child: Icon(Icons.more_vert,
                                  color: Colors.white, size: 20.w),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Most New Session Today Card ───────────────────
                if (data?.mostNewSessionToday != null)
                  _buildHeroSessionCard(data!.mostNewSessionToday!, context)
                else
                  _buildEmptySessionBanner(context),

                SizedBox(height: 20.h),

                // ── Stats Cards ──────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Expanded(
                          child: _buildStatCard(
                              title: 'Total Sessions',
                              value: data?.totalSession.toString() ?? '0',
                              sub: isAdmin && data?.totalTrainer != null
                                  ? '${data!.totalTrainer} trainers'
                                  : 'All time')),
                      SizedBox(width: 12.w),
                      Expanded(
                          child: _buildStatCard(
                              title: 'Weekly Progress',
                              value: '${data?.weeklyProgress.toInt() ?? 0}%',
                              sub: 'This week',
                              isProgress: true,
                              progressValue:
                                  (data?.weeklyProgress.toDouble() ?? 0) /
                                      100)),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // ── Announcements Section ────────────────────────
                if (data != null && data.announcements.isNotEmpty)
                  _buildAnnouncementsSection(data.announcements),

                // ── Readiness Section ─────────────────────────────
                if (data != null && data.readinessItems.isNotEmpty)
                  _buildReadinessSection(data.readinessItems, isAdmin),

                // ── Last 5 Sessions ───────────────────────────────
                if (data != null && data.last5Session.isNotEmpty)
                  _buildLast5SessionsSection(data.last5Session, context),

                SizedBox(height: 100.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Hero "Most New Session Today" Card ─────────────────────────────────
  Widget _buildHeroSessionCard(
      TrainingSessionModel session, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onTap: () =>
            Get.to(() => TrainingSessionDetailScreen(session: session)),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              image: const DecorationImage(
                  image: AssetImage('assets/images/b.jpg'),
                  fit: BoxFit.cover,
                  onError: null)),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0A1628).withValues(alpha: 0.95),
                      const Color(0xFF050D1A).withValues(alpha: 0.98),
                    ])),
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBadge(
                          session.displayFocus, const Color(0xFF4D94FF)),
                      if (session.isCompleted)
                        _buildBadge('Completed', const Color(0xFF10B981))
                      else
                        _buildBadge('Active', const Color(0xFFFFB800)),
                    ]),
                SizedBox(height: 12.h),
                Text(
                  session.displayTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Row(children: [
                  Icon(Icons.access_time,
                      color: Colors.white.withValues(alpha: 0.7), size: 16.w),
                  SizedBox(width: 6.w),
                  Text('${session.durationMinutes} min',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14.sp)),
                  SizedBox(width: 20.w),
                  Icon(Icons.group_outlined,
                      color: Colors.white.withValues(alpha: 0.7), size: 16.w),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(session.teamName,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14.sp),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
                SizedBox(height: 8.h),
                Row(children: [
                  Icon(Icons.fitness_center_outlined,
                      color: Colors.white.withValues(alpha: 0.7), size: 16.w),
                  SizedBox(width: 6.w),
                  Text('${session.exercises.length} exercises',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14.sp)),
                  SizedBox(width: 20.w),
                  Icon(Icons.bar_chart_outlined,
                      color: Colors.white.withValues(alpha: 0.7), size: 16.w),
                  SizedBox(width: 6.w),
                  Text(session.displayDifficulty,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14.sp)),
                ]),
                SizedBox(height: 16.h),
                Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    decoration: BoxDecoration(
                        color: const Color(0xFF4D94FF),
                        borderRadius: BorderRadius.circular(10.r)),
                    child: const Text('View Session',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12.sp, fontWeight: FontWeight.w600)),
    );
  }

  // ── Stats Card ─────────────────────────────────────────────────────────
  Widget _buildStatCard({
    required String title,
    required String value,
    required String sub,
    bool isProgress = false,
    double progressValue = 0,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          color: const Color(0xFF1A2236),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFF2A3550))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 12.sp)),
        SizedBox(height: 8.h),
        Text(value,
            style: TextStyle(
                color: Colors.white,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        if (isProgress) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progressValue.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFF2A3550),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF4D94FF)),
              minHeight: 4.h,
            ),
          ),
          SizedBox(height: 4.h),
        ],
        Text(sub,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }

  // ── Announcements Section ─────────────────────────────────────────────
  Widget _buildAnnouncementsSection(List<AnnouncementDashItem> items) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Announcements',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: () => Get.toNamed(RouteName.announcements),
              child: Text('All',
                  style: TextStyle(
                      color: const Color(0xFF4D94FF),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500)),
            ),
          ]),
          SizedBox(height: 12.h),
          ...items.take(3).map((a) => _buildAnnouncementItem(a)),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(AnnouncementDashItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          color: const Color(0xFF1A2236),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFF2A3550))),
      child: Row(children: [
        Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
                color: Color(0xFFFFB800), shape: BoxShape.circle)),
        SizedBox(width: 12.w),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 4.h),
          Text(item.description,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 13.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ])),
        Icon(Icons.chevron_right,
            color: Colors.white.withValues(alpha: 0.4), size: 20.w),
      ]),
    );
  }

  // ── Readiness Section ────────────────────────────────────────────────
  Widget _buildReadinessSection(List<ReadinessItem> items, bool isAdmin) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(isAdmin ? 'Club Readiness' : 'Team Readiness',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600)),
            Text('All',
                style: TextStyle(
                    color: const Color(0xFF4D94FF),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500)),
          ]),
          SizedBox(height: 12.h),
          ...items.map((r) => _buildReadinessItem(r)),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildReadinessItem(ReadinessItem item) {
    final imageUrl = ApiEndpoint.resolveImageUrl(item.image);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          color: const Color(0xFF1A2236),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFF2A3550))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                  color: const Color(0xFF0A0E1A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2A3550))),
              child: ClipOval(
                child: imageUrl != null
                    ? Image.network(imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                item.name.isNotEmpty
                                    ? item.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                    color: const Color(0xFF4D94FF),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ))
                    : Center(
                        child: Text(
                          item.name.isNotEmpty
                              ? item.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                              color: const Color(0xFF4D94FF),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(item.name,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600)),
          ]),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                  color: const Color(0xFF0A0E1A),
                  borderRadius: BorderRadius.circular(6.r)),
              child: Text('${item.progress}%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600))),
        ]),
        SizedBox(height: 10.h),
        ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
                value: (item.progress / 100).clamp(0.0, 1.0),
                backgroundColor: const Color(0xFF2A3550),
                valueColor: AlwaysStoppedAnimation<Color>(
                  item.progress >= 75
                      ? const Color(0xFF10B981)
                      : item.progress >= 40
                          ? const Color(0xFF4D94FF)
                          : const Color(0xFFFFB800),
                ),
                minHeight: 6.h)),
      ]),
    );
  }

  // ── Last 5 Sessions Section ───────────────────────────────────────────
  Widget _buildLast5SessionsSection(
      List<TrainingSessionModel> sessions, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Recent Sessions',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: () =>
                  Get.to(() => const ScheduleScreen(activeTabIndex: 0)),
              child: Text(
                'View All',
              ),
            ),
          ]),
          SizedBox(height: 12.h),
          ...sessions.map((s) => _buildSessionListItem(s, context)),
        ],
      ),
    );
  }

  Widget _buildSessionListItem(
      TrainingSessionModel session, BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => TrainingSessionDetailScreen(session: session)),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
            color: const Color(0xFF1A2236),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFF2A3550))),
        child: Row(children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: session.isCompleted
                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                  : const Color(0xFF4D94FF).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              session.isCompleted
                  ? Icons.check_circle_outline
                  : Icons.sports_hockey,
              color: session.isCompleted
                  ? const Color(0xFF10B981)
                  : const Color(0xFF4D94FF),
              size: 22.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(session.displayTitle,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.h),
                Row(children: [
                  Text('${session.durationMinutes} min',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12.sp)),
                  SizedBox(width: 8.w),
                  Text('•',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 12.sp)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(session.teamName,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12.sp),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _buildMiniTag(session.displayFocus),
            SizedBox(height: 4.h),
            if (session.isCompleted)
              Text('Done',
                  style: TextStyle(
                      color: const Color(0xFF10B981), fontSize: 11.sp))
            else
              Text('Pending',
                  style: TextStyle(
                      color: const Color(0xFFFFB800), fontSize: 11.sp)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildMiniTag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
          color: const Color(0xFF4D94FF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
              color: const Color(0xFF4D94FF).withValues(alpha: 0.3))),
      child: Text(label,
          style: TextStyle(
              color: const Color(0xFF4D94FF),
              fontSize: 10.sp,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildEmptySessionBanner(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2236),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF2A3550)),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: const Color(0xFF4D94FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.auto_awesome,
                  color: const Color(0xFF4D94FF), size: 24.w),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Training Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Generate AI training sessions for your team',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => Get.toNamed(RouteName.scheduler),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D94FF),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Start',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
