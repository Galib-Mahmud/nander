import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/club_screen_controller.dart';

class AddClubScreen extends StatefulWidget {
  const AddClubScreen({super.key});

  @override
  State<AddClubScreen> createState() => _AddClubScreenState();
}

class _AddClubScreenState extends State<AddClubScreen> {
  late final ClubScreenController controller = ClubScreenController.to;

  @override
  void initState() {
    super.initState();
    // Refresh find-club every time the screen opens, so pending state is
    // current. Skip if the controller's own first load is already running.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isLoading.value && !controller.isLoadingFindClubs.value) {
        controller.fetchFindClubs(showLoader: controller.addClubs.isEmpty);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

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
          'Add Club',
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
            // ─── Search Bar ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: TextField(
                  controller: controller.searchCtrl,
                  onChanged: controller.filterClubs,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF8B95A5),
                      size: 20,
                    ),
                    hintText: 'Search Club...',
                    hintStyle: TextStyle(
                      color: const Color(0xFF8B95A5),
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    suffixIcon: Obx(() {
                      if (controller.searchQuery.value.isNotEmpty) {
                        return IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF8B95A5),
                            size: 18,
                          ),
                          onPressed: controller.clearSearch,
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ),
                ),
              ),
            ),

            // ─── Club List or Empty State ────────────────────────────────
            Expanded(
              child: Obx(() {
                final list = controller.filteredAddClubs;
                final isLoading = controller.isLoading.value ||
                    controller.isLoadingFindClubs.value;

                if (isLoading && list.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2F7CF6)),
                  );
                }

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Club not found!',
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
                            fontSize: 13.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _buildClubCard(context, item, controller);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubCard(
      BuildContext context,
      ProfileItemModel item,
      ClubScreenController controller,
      ) {
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
          SizedBox(width: 12.w),

          // Request Button or Pending Badge
          if (item.isPending)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
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
            )
          else
            Obx(() {
              final isSending =
              controller.sendingClubIds.contains(item.targetId);
              return GestureDetector(
                onTap: isSending ? null : () => controller.sendJoinRequest(item),
                child: Container(
                  constraints: BoxConstraints(minWidth: 84.w),
                  alignment: Alignment.center,
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F7CF6),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: isSending
                      ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    'Request',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
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