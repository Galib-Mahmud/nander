import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../trainer/routes/route_name.dart';
import '../../../trainer/widget/controller/app_drawer_controller.dart';
import '../../../trainer/profile/controller/profile_controller.dart';
import '../../../trainer/core/endpoint/api_endpoint.dart';
import '../../../trainer/core/local_storage/user_info.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = ProfileController.to;
    return Scaffold(
      backgroundColor: const Color(0xFF050810), // Very dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF050810),
        elevation: 0,
        title: Row(
          children: [
            // ✅ Logo Image Asset
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo.png', // ✅ Your logo image path
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to text if image not found
                    return const Center(
                      child: Text(
                        'TU',
                        style: TextStyle(
                          color: Color(0xFF4D94FF),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Title and Subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'More',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Nordkap U18 Elite',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Notification Bell
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
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(RouteName.notifications);
                  },
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 20.w,
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
                  child: Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
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
                size: 20.w,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: Column(
                  children: [
                    // Logo / Avatar
                    Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: controller.profileImageUrl.value.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                ApiEndpoint.resolveImageUrl(controller.profileImageUrl.value) ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.shield, color: Color(0xFF050810), size: 40),
                              ),
                            )
                          : const Icon(Icons.shield, color: Color(0xFF050810), size: 40),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      controller.name.value.isNotEmpty
                          ? controller.name.value
                          : 'Club Admin',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (controller.email.value.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        controller.email.value,
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                      ),
                    ],
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF050810),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFF1F2937)),
                      ),
                      child: Text(
                        '${controller.role.value.isNotEmpty ? controller.role.value : "CLUB_ADMIN"} · ${controller.status.value.isNotEmpty ? controller.status.value : "Active"}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // Section 1: MY DEVICE · ACCOUNT
              const Text(
                'MY DEVICE · ACCOUNT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 16.h),
              _buildMenuItem('Profile Update', Icons.chevron_right, onTap: () {
                Get.toNamed(RouteName.updateprofile);
              }),
              SizedBox(height: 12.h),
              _buildMenuItem('Change Password', Icons.chevron_right, onTap: () {
                Get.toNamed(RouteName.forgotPassword);
              }),
              SizedBox(height: 12.h),
              _buildMenuItem('Language', Icons.chevron_right, onTap: () {}),
              SizedBox(height: 12.h),
              _buildMenuItem('Trainer', Icons.chevron_right, onTap: () {
                Get.toNamed(RouteName.trainers);
              }),

              SizedBox(height: 30.h),

              // Section 2: PRIVACY
              const Text(
                'PRIVACY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 16.h),
              _buildMenuItem('Terms & Conditions', Icons.chevron_right, onTap: () {
                Get.toNamed(RouteName.terms);
              }),
              SizedBox(height: 12.h),
              _buildMenuItem('Privacy Policy', Icons.chevron_right, onTap: () {
                Get.toNamed(RouteName.privacy);
              }),
              SizedBox(height: 12.h),
              _buildMenuItem("FAQ's", Icons.chevron_right, onTap: () {
                Get.toNamed(RouteName.faq);
              }),
              SizedBox(height: 12.h),
              // Delete Account (Red Text)
              _buildMenuItem(
                'Delete Account',
                Icons.chevron_right,
                isDestructive: true,
                onTap: () {
                  controller.requestDeleteAccount();
                },
              ),

              SizedBox(height: 30.h),

              // Log Out Button
              GestureDetector(
                onTap: () async {
                  await UserInfo.logout();
                  Get.offAllNamed(RouteName.wellcome1);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 18.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF451A1A), // Dark red background
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFEF4444)), // Red border
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20.w),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 20.w),
                        child: Icon(Icons.logout, color: const Color(0xFFEF4444), size: 22.w),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 100.h),
            ],
          ),
        );
      }),
    );
  }

  // Reusable Menu Item Widget
  Widget _buildMenuItem(
      String title,
      IconData icon, {
        bool isDestructive = false,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isDestructive ? const Color(0xFFEF4444) : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              icon,
              color: isDestructive ? const Color(0xFFEF4444) : Colors.white.withOpacity(0.7),
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}
