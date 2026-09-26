import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../routes/route_name.dart';
import '../controller/trainer_controller.dart';
import '../model/trainer_model.dart';

class AddTrainerScreen extends StatelessWidget {
  const AddTrainerScreen({super.key});

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
        title: Text(
          'Add Trainer',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),

              // Search Input
              Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: TextField(
                  controller: controller.searchAddCtrl,
                  onChanged: controller.applyAddSearch,
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
              SizedBox(height: 20.h),

              // Results or Empty State
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingAllTrainers.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4D94FF)),
                    );
                  }

                  final list = controller.searchResults;

                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Trainer not found!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Search again with correct name or email',
                            style: TextStyle(
                              color: const Color(0xFF8B95A5),
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: list.length,
                    padding: EdgeInsets.only(bottom: 16.h),
                    itemBuilder: (context, index) {
                      final trainer = list[index];
                      return _buildTrainerResultCard(controller, trainer);
                    },
                  );
                }),
              ),

              // Bottom Section: "Can't Find Your Trainer?" or Invite Button
              Obx(() {
                final hasResults = controller.searchResults.isNotEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasResults) ...[
                      Text(
                        "Can't Find Your Trainer?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Search again with correct name or email',
                        style: TextStyle(
                          color: const Color(0xFF8B95A5),
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.inviteNameCtrl.clear();
                          controller.inviteEmailCtrl.clear();
                          Get.toNamed(RouteName.inviteTrainer);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4D94FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.r)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Invite the Trainer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainerResultCard(TrainerController controller, TrainerModel trainer) {
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
                  trainer.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  trainer.email,
                  style: TextStyle(
                    color: const Color(0xFF8B95A5),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Obx(() {
            final isRequested = controller.requestedTrainerIds.contains(trainer.id);

            if (isRequested) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Text(
                  'Pending',
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            return GestureDetector(
              onTap: () => controller.sendRequestToTrainer(trainer.id),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D94FF),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
