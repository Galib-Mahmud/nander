import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context)),
        actions: [
          // Show Edit/Delete only if Admin
          Obx(() => controller.isAdmin.value
              ? PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'edit') {
                Get.to(() => AnnouncementCreateScreen(announcement: announcement));
              } else if (value == 'delete') {
                Get.dialog(AlertDialog(
                  backgroundColor: const Color(0xFF1A2236),
                  title: const Text('Delete Announcement', style: TextStyle(color: Colors.white)),
                  content: const Text('Are you sure you want to delete this?', style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                    TextButton(
                        onPressed: () {
                          controller.deleteAnnouncement(announcement.id);
                          Get.back(); // Close dialog
                          Get.back(); // Go back to list
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red))
                    ),
                  ],
                ));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          )
              : const SizedBox.shrink()
          ),
          SizedBox(width: 10.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2236),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFF2A3550)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(announcement.title,
                  style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              Text(announcement.description,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15.sp, height: 1.5)),
              SizedBox(height: 24.h),
              Divider(color: Colors.white.withOpacity(0.1)),
              SizedBox(height: 12.h),
              Text(
                '${announcement.createdAt.day} ${_getMonth(announcement.createdAt.month)} ${announcement.createdAt.year}',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}