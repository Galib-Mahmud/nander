import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/route_name.dart';
import '../../widget/controller/app_drawer_controller.dart';
import '../../auth/controller/auth_controller.dart';
import '../../profile/controller/profile_controller.dart';
import '../../core/local_storage/user_info.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../profile/screen/club_screen.dart';
import '../../profile/screen/team_screen.dart';
import '../../core/localization/localization_service.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = ProfileController.to;

    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050810),
        elevation: 0,
        titleSpacing: 16.w,
        title: Row(
          children: [
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
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
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
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'More'.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 2.h),
                  Obx(() => Text(
                        controller.name.value.isNotEmpty
                            ? controller.name.value
                            : (controller.isLoading.value
                                ? 'Loading...'.tr
                                : 'Profile'.tr),
                        style: TextStyle(
                            color: const Color(0xFF8B95A5), fontSize: 13.sp),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2236),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2A3550)),
                ),
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(RouteName.notifications);
                  },
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
                      color: Color(0xFFFF5252), shape: BoxShape.circle),
                  child: Center(
                    child: Text('N',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
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
                border: Border.all(color: const Color(0xFF2A3550)),
              ),
              child: Icon(Icons.more_vert, color: Colors.white, size: 20.w),
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: controller.fetchProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                  child: controller.isLoading.value &&
                          controller.nameController.text.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF4D94FF))),
                        )
                      : Column(
                          children: [
                            Container(
                              width: 70.w,
                              height: 70.w,
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: controller.profileImageUrl.value.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        ApiEndpoint.resolveImageUrl(controller
                                                .profileImageUrl.value) ??
                                            '',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.shield,
                                                color: Color(0xFF050810),
                                                size: 40),
                                      ),
                                    )
                                  : const Icon(Icons.shield,
                                      color: Color(0xFF050810), size: 40),
                            ),
                            SizedBox(height: 12.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: Text(
                                controller.name.value.isNotEmpty
                                    ? controller.name.value
                                    : '—',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: Text(
                                controller.email.value,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 13),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF050810),
                                borderRadius: BorderRadius.circular(20.r),
                                border:
                                    Border.all(color: const Color(0xFF1F2937)),
                              ),
                              child: Text(
                                '${controller.role.value} · ${controller.status.value}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12.sp),
                              ),
                            ),
                          ],
                        ),
                ),

                SizedBox(height: 30.h),

                Text(
                  'MY DEVICE · ACCOUNT'.tr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
                SizedBox(height: 16.h),
                _buildMenuItem('Profile Update'.tr, Icons.chevron_right,
                    onTap: () {
                  Get.toNamed(RouteName.updateprofile);
                }),
                SizedBox(height: 12.h),
                _buildMenuItem('Reset Password'.tr, Icons.chevron_right,
                    onTap: () {
                  final auth = AuthController.to;
                  auth.resetOtpVerified.value = false;
                  auth.forgotEmailController.clear();
                  auth.newPasswordController.clear();
                  auth.confirmNewPasswordController.clear();
                  Get.toNamed(RouteName.forgotPassword);
                }),
                SizedBox(height: 12.h),
                _buildMenuItem(
                  'Language'.tr,
                  Icons.chevron_right,
                  trailingText: LocalizationService.currentLanguageName,
                  onTap: () => _showLanguageBottomSheet(context),
                ),
                SizedBox(height: 12.h),

                // Club and Team logic for TRAINER
                if (controller.role.value == 'TRAINER') ...[
                  _buildMenuItem('Club'.tr, Icons.chevron_right, onTap: () {
                    Get.to(() => const ClubScreen());
                  }),
                  SizedBox(height: 12.h),
                  _buildMenuItem('Team'.tr, Icons.chevron_right, onTap: () {
                    Get.to(() => const TeamScreen());
                  }),
                  SizedBox(height: 12.h),
                ],

                // Trainers list for CLUB_ADMIN
                if (controller.role.value == 'CLUB_ADMIN') ...[
                  _buildMenuItem('Trainers'.tr, Icons.chevron_right, onTap: () {
                    Get.toNamed(RouteName.trainers);
                  }),
                  SizedBox(height: 12.h),
                ],

                SizedBox(height: 30.h),

                Text(
                  'PRIVACY'.tr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
                SizedBox(height: 16.h),
                _buildMenuItem('Terms & Conditions'.tr, Icons.chevron_right,
                    onTap: () {
                  Get.toNamed(RouteName.terms);
                }),
                SizedBox(height: 12.h),
                _buildMenuItem('Privacy Policy'.tr, Icons.chevron_right,
                    onTap: () {
                  Get.toNamed(RouteName.privacy);
                }),
                SizedBox(height: 12.h),
                _buildMenuItem("FAQ's".tr, Icons.chevron_right, onTap: () {
                  Get.toNamed(RouteName.faq);
                }),
                SizedBox(height: 12.h),
                _buildMenuItem('Delete Account'.tr, Icons.chevron_right,
                    isDestructive: true, onTap: () {
                  controller.requestDeleteAccount();
                }),

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
                      color: const Color(0xFF451A1A),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFEF4444)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20.w),
                          child: Text(
                            'Log Out'.tr,
                            style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 20.w),
                          child: Icon(Icons.logout,
                              color: const Color(0xFFEF4444), size: 22.w),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 100.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Language'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildLanguageOption(
                  title: 'English',
                  subtitle: 'English',
                  isSelected: !LocalizationService.isDutch,
                  onTap: () async {
                    await LocalizationService.changeLanguage(
                        LocalizationService.englishCode);
                    Get.back();
                  },
                ),
                SizedBox(height: 12.h),
                _buildLanguageOption(
                  title: 'Nederlands',
                  subtitle: 'Dutch',
                  isSelected: LocalizationService.isDutch,
                  onTap: () async {
                    await LocalizationService.changeLanguage(
                        LocalizationService.dutchCode);
                    Get.back();
                  },
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4D94FF).withValues(alpha: 0.12)
              : const Color(0xFF1A2236),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF4D94FF) : const Color(0xFF2A3550),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF8B95A5),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4D94FF),
              )
            else
              const Icon(
                Icons.radio_button_unchecked,
                color: Color(0xFF8B95A5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon, {
    bool isDestructive = false,
    String? trailingText,
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailingText != null) ...[
                  Text(
                    trailingText,
                    style: TextStyle(
                      color: const Color(0xFF8B95A5),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                Icon(
                  icon,
                  color: isDestructive
                      ? const Color(0xFFEF4444)
                      : Colors.white.withValues(alpha: 0.7),
                  size: 20.w,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
