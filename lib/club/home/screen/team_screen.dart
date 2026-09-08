import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import '../../routes/route_name.dart';
import '../../widget/controller/app_drawer_controller.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050810),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Nordkap U18 Elite',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8B95A5),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _buildNotificationBell(),
          SizedBox(width: 12.w),
          _buildMoreOptions(),
          SizedBox(width: 20.w),
        ],
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildTeamCard();
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTeamCard() {
    return GestureDetector(
      onTap: (){
        Get.toNamed(RouteName.topClubs);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF111827), // Slightly lighter than bg
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nordkap U18 Elite',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF050810),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFF374151)),
                  ),
                  child: const Text(
                    '81',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '22/24 sessions',
                  style: TextStyle(color: const Color(0xFF8B95A5), fontSize: 14.sp),
                ),
                const Text(
                  '92%',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: 0.92,
                backgroundColor: const Color(0xFF374151),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4D94FF)),
                minHeight: 8.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBell() {
    return Stack(
      children: [
        GestureDetector(
          onTap: (){
            Get.toNamed(RouteName.notifications);
          },
          child: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Icon(Icons.notifications_outlined, color: Colors.white.withOpacity(0.7), size: 22.w),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            width: 18.w,
            height: 18.w,
            decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
            child: Center(
              child: Text('3', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreOptions() {
    return GestureDetector(
      onTap: (){
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

  Widget _buildBottomNav() {
    return Container(
      height: 80.h,
      decoration: const BoxDecoration(
        color: Color(0xFF0B1120),
        border: Border(top: BorderSide(color: Color(0xFF1F2937))),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home', false),
              _navItem(Icons.calendar_today_outlined, 'Schedule', false),
              SizedBox(width: 40.w), // Space for FAB
              _navItem(Icons.bar_chart, 'Team', true), // Active
              _navItem(Icons.layers_outlined, 'More', false),
            ],
          ),
          Positioned(
            top: -25.h,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // Handle FAB tap
                },
                child: Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4D94FF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4D94FF).withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF4D94FF) : const Color(0xFF8B95A5), size: 24.w),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(color: isActive ? const Color(0xFF4D94FF) : const Color(0xFF8B95A5), fontSize: 12.sp)),
      ],
    );
  }
}