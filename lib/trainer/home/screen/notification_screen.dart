import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool isAllSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        foregroundColor: Colors.white,
        title: const Text(
          'Notifications',
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
              Container(
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
          Container(
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
              'Keep up with your rewards and rankings.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 15.sp,
              ),
            ),
          ),
          SizedBox(height: 20.h),
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
                      onTap: () => setState(() => isAllSelected = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isAllSelected ? const Color(0xFF0A0E1A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          border: isAllSelected
                              ? Border.all(color: const Color(0xFF2A3550))
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'All',
                            style: TextStyle(
                              color: isAllSelected
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
                      onTap: () => setState(() => isAllSelected = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !isAllSelected ? const Color(0xFF0A0E1A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          border: !isAllSelected
                              ? Border.all(color: const Color(0xFF2A3550))
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Unread',
                            style: TextStyle(
                              color: !isAllSelected
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
          SizedBox(height: 20.h),
          // Notification List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildNotificationItem();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
          Text(
            '2 plans awaiting approval',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'U12 first development · Women squad onboarding',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '1h ago',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}