import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/team_screen_controller.dart';
import 'add_team_screen.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TeamProfileController.to;

    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050810),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        centerTitle: false,
        title: Text(
          'Team',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Tabs Pill Selector ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
              child: Row(
                children: [
                  Obx(() {
                    final isSelected = controller.selectedTab.value == 0;
                    return GestureDetector(
                      onTap: () => controller.selectedTab.value = 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2F7CF6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'My Teams',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF8B95A5),
                            fontSize: 14.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(width: 8.w),
                  Obx(() {
                    final isSelected = controller.selectedTab.value == 1;
                    return GestureDetector(
                      onTap: () => controller.selectedTab.value = 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2F7CF6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "Team's Request",
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF8B95A5),
                            fontSize: 14.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // ─── Content List ───────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.selectedTab.value == 0) {
                  return _buildMyTeamsList(context, controller);
                } else {
                  return _buildTeamRequestsList(context, controller);
                }
              }),
            ),

            // ─── Sticky Bottom Button (Join New Team >) ──────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const AddTeamScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F7CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Join New Team',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── My Teams Tab ───────────────────────────────────────────────────
  Widget _buildMyTeamsList(
    BuildContext context,
    TeamProfileController controller,
  ) {
    if (controller.myTeams.isEmpty) {
      return Center(
        child: Text(
          'No teams joined yet',
          style: TextStyle(color: const Color(0xFF8B95A5), fontSize: 14.sp),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      itemCount: controller.myTeams.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = controller.myTeams[index];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1424),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFF1E2B45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                item.email,
                style: TextStyle(
                  color: const Color(0xFF8B95A5),
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Team's Request Tab ─────────────────────────────────────────────
  Widget _buildTeamRequestsList(
    BuildContext context,
    TeamProfileController controller,
  ) {
    if (controller.requests.isEmpty) {
      return Center(
        child: Text(
          'No team requests',
          style: TextStyle(color: const Color(0xFF8B95A5), fontSize: 14.sp),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      itemCount: controller.requests.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = controller.requests[index];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1424),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFF1E2B45)),
          ),
          child: Row(
            children: [
              // Name and Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      item.email,
                      style: TextStyle(
                        color: const Color(0xFF8B95A5),
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),

              // Action Buttons or Pending Badge
              if (item.isActionable)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => controller.approveRequest(item.id),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F7CF6),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Approve',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => controller.declineRequest(item.id),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: const Color(0xFF374151)),
                        ),
                        child: Text(
                          'Decline',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFF374151)),
                  ),
                  child: Text(
                    'Pending Request',
                    style: TextStyle(
                      color: const Color(0xFF8B95A5),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
