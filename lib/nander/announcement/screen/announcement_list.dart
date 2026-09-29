import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/route_name.dart';
import '../controller/announcement_controller.dart';
import 'announcement_create.dart';
import 'announcement_details.dart';

class AnnouncementListScreen extends StatelessWidget {
  const AnnouncementListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AnnouncementController.to;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        foregroundColor: Colors.white,
        title: const Text('Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Notification Bell
          GestureDetector(
            onTap: () => Get.toNamed(RouteName.notifications),
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(color: Color(0xFF1A2236), shape: BoxShape.circle),
              child: Stack(
                children: [
                  Center(child: Icon(Icons.notifications_outlined, size: 20.w, color: Colors.white70)),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // More Menu
          Container(
            margin: EdgeInsets.only(right: 20.w),
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(color: Color(0xFF1A2236), shape: BoxShape.circle),
            child: Icon(Icons.more_vert, size: 20.w, color: Colors.white70),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Text(
              'Keep up with your rewards and rankings.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14.sp),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.announcements.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF4D94FF)));
              }

              if (controller.announcements.isEmpty) {
                return RefreshIndicator(
                  color: const Color(0xFF4D94FF),
                  backgroundColor: const Color(0xFF1A2236),
                  onRefresh: controller.fetchAnnouncements,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 150.h),
                      Center(
                        child: Text(
                          'No announcements yet',
                          style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF4D94FF),
                backgroundColor: const Color(0xFF1A2236),
                onRefresh: controller.fetchAnnouncements,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  itemCount: controller.announcements.length,
                  itemBuilder: (context, index) {
                    final item = controller.announcements[index];
                    return GestureDetector(
                      onTap: () => Get.to(() => AnnouncementDetailScreen(announcement: item)),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2236),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFF2A3550)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Yellow Dot
                            Container(
                              margin: EdgeInsets.only(top: 6.h, right: 12.w),
                              width: 8.w,
                              height: 8.w,
                              decoration: const BoxDecoration(color: Color(0xFFFFC107), shape: BoxShape.circle),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    item.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                  if (item.club != null) ...[
                                    SizedBox(height: 6.h),
                                    Text(
                                      item.club!.name,
                                      style: TextStyle(
                                        color: const Color(0xFF4D94FF),
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),

          // Add Button (Only for Admin)
          Obx(() => controller.isAdmin.value
              ? Padding(
                  padding: EdgeInsets.all(20.w),
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => const AnnouncementCreateScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D94FF),
                      minimumSize: Size(double.infinity, 50.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: const Text(
                      'Add New Announcement',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}