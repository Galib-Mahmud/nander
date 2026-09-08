import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:nander/club/routes/route_name.dart';

import '../../widget/controller/app_drawer_controller.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool isUpcomingSelected = true;
  String selectedTeam = 'All teams';
  final List<String> teams = ['All teams', 'U18 Elite', 'U14', 'U16', 'U18'];

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
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Bell Icon with Badge
          Stack(
            children: [
              GestureDetector(
                onTap: (){
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
                    color: Colors.white.withOpacity(0.7),
                    size: 22.w,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5252),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
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
            onTap: (){
              Get.find<AppDrawerController>().open();
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
                Icons.more_vert,
                color: Colors.white,
                size: 22.w,
              ),
            ),
          ),
          SizedBox(width: 20.w),
        ],
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              '2 sessions · week 35',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 15.sp,
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
                      onTap: () => setState(() => isUpcomingSelected = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isUpcomingSelected ? const Color(0xFF0A0E1A) : Colors.transparent,
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
                                  : Colors.white.withOpacity(0.5),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isUpcomingSelected = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !isUpcomingSelected ? const Color(0xFF0A0E1A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          border: !isUpcomingSelected
                              ? Border.all(color: const Color(0xFF2A3550))
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Past',
                            style: TextStyle(
                              color: !isUpcomingSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              fontSize: 15.sp,
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
          SizedBox(
            height: 40.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              scrollDirection: Axis.horizontal,
              itemCount: teams.length,
              separatorBuilder: (context, index) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final team = teams[index];
                final isSelected = selectedTeam == team;
                return GestureDetector(
                  onTap: () => setState(() => selectedTeam = team),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4D94FF) : const Color(0xFF1A2236),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF4D94FF) : const Color(0xFF2A3550),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        team,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white,
                          fontSize: 14.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24.h),
          // Schedule List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildScheduleItem();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildScheduleItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Text(
            'Tue 25 Aug',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GestureDetector(
          onTap: (){
            Get.toNamed(RouteName.scheduler);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 20.h),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2236),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFF2A3550),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '17:00',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        'Edge work & tight turns',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  '75\'',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Nordkap U14 · Skating',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E1A),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: const Color(0xFF2A3550),
                    ),
                  ),
                  child: const Text(
                    'medium',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white.withOpacity(0.5),
                      size: 16.w,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Nordkap U14 · Skating',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1424),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF2A3550),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', false),
          _buildNavItem(Icons.calendar_today, 'Schedule', true),
          SizedBox(width: 40.w), // Space for FAB
          _buildNavItem(Icons.bar_chart, 'Team', false),
          _buildNavItem(Icons.layers_outlined, 'More', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF4D94FF) : Colors.white.withOpacity(0.5),
          size: 24.w,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF4D94FF) : Colors.white.withOpacity(0.5),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}