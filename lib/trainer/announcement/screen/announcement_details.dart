import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../controller/announcement_controller.dart';
import '../controller/announcement_model.dart';
import 'announcement_create.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final AnnouncementModel announcement;
  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final controller = AnnouncementController.to;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        foregroundColor: Colors.white,
        title: const Text('Announcement Detail', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Show Edit/Delete only if Admin
          Obx(() => controller.isAdmin.value
              ? PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  color: const Color(0xFF1A2236),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Get.to(() => AnnouncementCreateScreen(announcement: announcement));
                    } else if (value == 'delete') {
                      Get.dialog(AlertDialog(
                        backgroundColor: const Color(0xFF1A2236),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        title: const Text('Delete Announcement', style: TextStyle(color: Colors.white)),
                        content: const Text(
                          'Are you sure you want to delete this announcement?',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                          ),
                          TextButton(
                            onPressed: () async {
                              Get.back(); // Close dialog first
                              final ok = await controller.deleteAnnouncement(announcement.id);
                              if (ok) {
                                Get.back(); // Go back to list screen
                              }
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ));
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink()),
          SizedBox(width: 10.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2236),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFF2A3550)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Club Info Header (if available in Postman response)
              if (announcement.club != null) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22.r,
                      backgroundColor: const Color(0xFF2A3550),
                      backgroundImage: (announcement.club!.profile != null && announcement.club!.profile!.isNotEmpty)
                          ? NetworkImage(ApiEndpoint.resolveImageUrl(announcement.club!.profile)!)
                          : null,
                      child: (announcement.club!.profile == null || announcement.club!.profile!.isEmpty)
                          ? Icon(Icons.shield_outlined, color: const Color(0xFF4D94FF), size: 22.r)
                          : null,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            announcement.club!.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (announcement.club!.address != null && announcement.club!.address!.isNotEmpty)
                            Text(
                              announcement.club!.address!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12.sp,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Divider(color: Colors.white.withValues(alpha: 0.1)),
                SizedBox(height: 16.h),
              ],

              // Title
              Text(
                announcement.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),

              // Description
              Text(
                announcement.description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 15.sp,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 24.h),

              Divider(color: Colors.white.withValues(alpha: 0.1)),
              SizedBox(height: 12.h),

              // Created Date
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14.sp, color: Colors.white54),
                  SizedBox(width: 6.w),
                  Text(
                    '${announcement.createdAt.day} ${_getMonth(announcement.createdAt.month)} ${announcement.createdAt.year}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}