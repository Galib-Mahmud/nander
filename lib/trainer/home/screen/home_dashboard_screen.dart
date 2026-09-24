import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../announcement/controller/announcement_controller.dart';
import '../../routes/route_name.dart';
import '../../widget/controller/app_drawer_controller.dart';
// ✅ Import the announcement controller

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller to ensure data fetching starts
    final announcementController = AnnouncementController.to;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 20.h),
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
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Text('TU', style: TextStyle(color: Color(0xFF4D94FF), fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Today', style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2.h),
                          Text('Nordkap Hockey Club', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13.sp)),
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
                            decoration: BoxDecoration(color: const Color(0xFF1A2236), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF2A3550))),
                            child: GestureDetector(
                              onTap: () => Get.toNamed(RouteName.notifications),
                              child: Icon(Icons.notifications_outlined, color: Colors.white, size: 20.w),
                            ),
                          ),
                          Positioned(right: 0, top: 0, child: Container(width: 18.w, height: 18.w, decoration: const BoxDecoration(color: Color(0xFFFF5252), shape: BoxShape.circle), child: Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold))))),
                        ],
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: () => Get.find<AppDrawerController>().open(),
                        child: Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(color: const Color(0xFF1A2236), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF2A3550))),
                          child: Icon(Icons.more_vert, color: Colors.white, size: 20.w),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Next on the ice Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                height: 280.h,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r), image: const DecorationImage(image: AssetImage('assets/images/b.jpg'), fit: BoxFit.cover)),
                child: Stack(
                  children: [
                    Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.7), Colors.black.withOpacity(0.85)]))),
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Next on the Field Hockey', style: TextStyle(color: const Color(0xFF4D94FF), fontSize: 15.sp, fontWeight: FontWeight.w500)), Text('16:30', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold))]),
                          SizedBox(height: 12.h),
                          const Text('Power play entries & net front', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.h),
                          Text('Nordkap U18 Elite • Tue 25 Aug', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14.sp)),
                          SizedBox(height: 12.h),
                          Row(children: [Icon(Icons.access_time, color: Colors.white.withOpacity(0.7), size: 16.w), SizedBox(width: 6.w), Text('75 min', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14.sp)), SizedBox(width: 20.w), Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.7), size: 16.w), SizedBox(width: 6.w), Text('Nordkap Arena • Main', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14.sp))]),
                          SizedBox(height: 16.h),
                          GestureDetector(onTap: () {}, child: Container(padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h), decoration: BoxDecoration(color: const Color(0xFF4D94FF), borderRadius: BorderRadius.circular(10.r)), child: const Text('View Session', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Stats Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Expanded(child: _buildStatCard(title: 'Session Overview', value: '84', change: '+13 vs last', isPositive: true)),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildStatCard(title: 'Weekly Progress', value: '84', change: '-13 vs last', isPositive: false)),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Top Clubs Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Top Clubs', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600)), Text('All', style: TextStyle(color: const Color(0xFF4D94FF), fontSize: 14.sp, fontWeight: FontWeight.w500))]),
                  SizedBox(height: 12.h),
                  Container(padding: EdgeInsets.symmetric(horizontal: 16.w), decoration: BoxDecoration(color: const Color(0xFF1A2236), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: const Color(0xFF2A3550))), child: Row(children: [Icon(Icons.search, color: Colors.white.withOpacity(0.4), size: 20.w), SizedBox(width: 12.w), Expanded(child: TextField(style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Search clubs...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14.sp), border: InputBorder.none)))])),
                  SizedBox(height: 12.h),
                  _buildClubItem('Manchester United', 'Best Club of United States'),
                  _buildClubItem('Manchester United', 'Best Club of United States'),
                  _buildClubItem('Manchester United', 'Best Club of United States'),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ✅ FIXED ANNOUNCEMENT SECTION WITH NAVIGATION & LIMIT 3
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Announcement', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600)),
                      // ✅ Navigate to full announcement list
                      GestureDetector(
                        onTap: () => Get.toNamed(RouteName.announcements),
                        child: Text('All', style: TextStyle(color: const Color(0xFF4D94FF), fontSize: 14.sp, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // ✅ Reactive Obx to show live data
                  Obx(() {
                    if (announcementController.isLoading.value && announcementController.announcements.isEmpty) {
                      return SizedBox(height: 60.h, child: Center(child: CircularProgressIndicator(color: Color(0xFF4D94FF))));
                    }

                    if (announcementController.announcements.isEmpty) {
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(color: Color(0xFF1A2236), borderRadius: BorderRadius.circular(12.r)),
                        child: Center(child: Text('No announcements yet', style: TextStyle(color: Colors.white54, fontSize: 13.sp))),
                      );
                    }

                    // ✅ Take only first 3 items for dashboard
                    final recentItems = announcementController.announcements.take(3).toList();

                    return Column(
                      children: recentItems.map((item) => _buildAnnouncementItem(item.title, item.description)).toList(),
                    );
                  }),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Club Readiness Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Club readiness', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600)), Text('All', style: TextStyle(color: const Color(0xFF4D94FF), fontSize: 14.sp, fontWeight: FontWeight.w500))]),
                  SizedBox(height: 12.h),
                  _buildReadinessItem('Nordkap U18 Elite', '22/24 sessions', 81, 92),
                  _buildReadinessItem('Nordkap U18 Elite', '22/24 sessions', 81, 92),
                  _buildReadinessItem('Nordkap U18 Elite', '22/24 sessions', 81, 92),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Coming Up Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Coming up', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600)), Text('All', style: TextStyle(color: const Color(0xFF4D94FF), fontSize: 14.sp, fontWeight: FontWeight.w500))]),
                  SizedBox(height: 12.h),
                  _buildComingUpItem('Edge work & tight turns', 'Nordkap U14 • Skating'),
                  _buildComingUpItem('Edge work & tight turns', 'Nordkap U14 • Skating'),
                  _buildComingUpItem('Edge work & tight turns', 'Nordkap U14 • Skating'),
                ],
              ),
            ),

            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required String change, required bool isPositive}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: const Color(0xFF1A2236), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: const Color(0xFF2A3550))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12.sp)),
        SizedBox(height: 8.h),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        Text(change, style: TextStyle(color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFFF5252), fontSize: 12.sp, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildClubItem(String name, String subtitle) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: const Color(0xFF1A2236), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: const Color(0xFF2A3550))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)), SizedBox(height: 4.h), Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12.sp))])),
        Container(padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h), decoration: BoxDecoration(color: const Color(0xFF4D94FF), borderRadius: BorderRadius.circular(8.r)), child: const Text('Invite', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _buildAnnouncementItem(String title, String subtitle) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: const Color(0xFF1A2236), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: const Color(0xFF2A3550))),
      child: Row(children: [
        Container(width: 8.w, height: 8.w, decoration: const BoxDecoration(color: Color(0xFFFFB800), shape: BoxShape.circle)),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)), SizedBox(height: 4.h), Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13.sp))])),
      ]),
    );
  }

  Widget _buildReadinessItem(String title, String subtitle, int score, int percentage) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: const Color(0xFF1A2236), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: const Color(0xFF2A3550))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)), Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), decoration: BoxDecoration(color: const Color(0xFF0A0E1A), borderRadius: BorderRadius.circular(6.r)), child: Text(score.toString(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)))]),
        SizedBox(height: 8.h),
        Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13.sp)),
        SizedBox(height: 8.h),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4.r), child: LinearProgressIndicator(value: percentage / 100, backgroundColor: const Color(0xFF2A3550), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4D94FF)), minHeight: 6.h))), SizedBox(width: 12.w), Text('$percentage%', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600))]),
      ]),
    );
  }

  Widget _buildComingUpItem(String title, String subtitle) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: const Color(0xFF1A2236), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: const Color(0xFF2A3550))),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tue 25', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12.sp)), SizedBox(height: 4.h), Text('17:00', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold))]),
        SizedBox(width: 16.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)), SizedBox(height: 4.h), Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13.sp))])),
        Container(padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h), decoration: BoxDecoration(color: const Color(0xFF0A0E1A), borderRadius: BorderRadius.circular(6.r), border: Border.all(color: const Color(0xFF2A3550))), child: const Text('medium', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500))),
        SizedBox(width: 12.w),
        Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.4), size: 20.w),
      ]),
    );
  }
}