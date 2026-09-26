import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../routes/route_name.dart';
import '../controller/trainer_controller.dart';
import '../model/trainer_model.dart';

class TrainersScreen extends StatelessWidget {
  const TrainersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TrainerController.to;

    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050810),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trainers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),

              // Tab Pill Selector
              Obx(() {
                final isMyTrainers = controller.selectedTab.value == 0;
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.selectedTab.value = 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isMyTrainers ? const Color(0xFF4D94FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'My Trainers',
                          style: TextStyle(
                            color: isMyTrainers ? Colors.white : const Color(0xFF8B95A5),
                            fontSize: 15.sp,
                            fontWeight: isMyTrainers ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: () => controller.selectedTab.value = 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: !isMyTrainers ? const Color(0xFF4D94FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "Trainer's Request",
                          style: TextStyle(
                            color: !isMyTrainers ? Colors.white : const Color(0xFF8B95A5),
                            fontSize: 15.sp,
                            fontWeight: !isMyTrainers ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              SizedBox(height: 16.h),

              // Search Bar
              Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: TextField(
                  controller: controller.searchMainCtrl,
                  onChanged: controller.applyMainSearch,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search trainer...',
                    hintStyle: TextStyle(color: const Color(0xFF8B95A5), fontSize: 14.sp),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF8B95A5), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Main List
              Expanded(
                child: Obx(() {
                  final isMyTrainers = controller.selectedTab.value == 0;
                  final isLoading = isMyTrainers
                      ? controller.isLoadingMyTrainers.value
                      : controller.isLoadingRequests.value;

                  if (isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4D94FF)),
                    );
                  }

                  final list = isMyTrainers
                      ? controller.filteredMyTrainers
                      : controller.filteredRequests;

                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, color: const Color(0xFF8B95A5), size: 48.w),
                          SizedBox(height: 12.h),
                          Text(
                            isMyTrainers ? 'No trainers yet' : 'No pending requests',
                            style: TextStyle(color: Colors.white70, fontSize: 16.sp, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            isMyTrainers
                                ? 'Add your first trainer to your club'
                                : 'Incoming and sent requests will appear here',
                            style: TextStyle(color: const Color(0xFF8B95A5), fontSize: 13.sp),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF4D94FF),
                    backgroundColor: const Color(0xFF111827),
                    onRefresh: () => isMyTrainers
                        ? controller.fetchMyTrainers()
                        : controller.fetchTrainerRequests(),
                    child: ListView.builder(
                      itemCount: list.length,
                      padding: EdgeInsets.only(bottom: 20.h),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        if (isMyTrainers) {
                          return _buildMyTrainerCard(item);
                        } else {
                          return _buildRequestCard(controller, item);
                        }
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () {
                controller.searchAddCtrl.clear();
                controller.applyAddSearch('');
                Get.toNamed(RouteName.addTrainer);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D94FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.r)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Add New Trainer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyTrainerCard(ClubTrainerItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.displayName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            item.displayEmail,
            style: TextStyle(
              color: const Color(0xFF8B95A5),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(TrainerController controller, ClubTrainerItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  item.displayEmail,
                  style: TextStyle(
                    color: const Color(0xFF8B95A5),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          if (item.isTrainerRequested)
            Row(
              children: [
                GestureDetector(
                  onTap: () => controller.respondToRequest(requestId: item.id, isAccept: true),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4D94FF),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Approve',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => controller.respondToRequest(requestId: item.id, isAccept: false),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFF334155)),
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
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Text(
                'Pending Request',
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
