import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../routes/route_name.dart';

class TopClubsScreen extends StatefulWidget {
  const TopClubsScreen({super.key});

  @override
  State<TopClubsScreen> createState() => _TopClubsScreenState();
}

class _TopClubsScreenState extends State<TopClubsScreen> {
  bool isFindClubsActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050810),
        foregroundColor: Colors.white,
        title: const Text(
          'Top Clubs',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'Keep up with your rewards and rankings.',
              style: TextStyle(color: const Color(0xFF8B95A5), fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 20.h),

          // Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isFindClubsActive = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !isFindClubsActive ? const Color(0xFF1F2937) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Text(
                            'My Network',
                            style: TextStyle(
                              color: !isFindClubsActive ? Colors.white : const Color(0xFF8B95A5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isFindClubsActive = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isFindClubsActive ? const Color(0xFF1F2937) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Text(
                            'Find Clubs',
                            style: TextStyle(
                              color: isFindClubsActive ? Colors.white : const Color(0xFF8B95A5),
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
          SizedBox(height: 20.h),

          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  Icon(Icons.search, color: const Color(0xFF8B95A5), size: 20.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search clubs...',
                        hintStyle: TextStyle(color: Color(0xFF8B95A5)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Club List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildClubCard();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard() {
    return GestureDetector(
      onTap: (){
Get.toNamed(RouteName.clubProfile);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manchester United',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Best Club of United States',
                  style: TextStyle(color: const Color(0xFF8B95A5), fontSize: 14.sp),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFF4D94FF),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: const Text(
                'Invite',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF1F2937)),
          ),
          child: Icon(Icons.notifications_outlined, color: Colors.white.withOpacity(0.7), size: 22.w),
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
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Icon(Icons.more_vert, color: Colors.white, size: 22.w),
    );
  }
}