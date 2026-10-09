import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/endpoint/api_endpoint.dart';
import '../../routes/route_name.dart';
import '../controller/top_club_controller.dart';
import '../controller/top_club_model.dart';

class TopClubsScreen extends StatefulWidget {
  const TopClubsScreen({super.key});

  @override
  State<TopClubsScreen> createState() => _TopClubsScreenState();
}

class _TopClubsScreenState extends State<TopClubsScreen> {
  bool isFindClubsActive = true;
  final TextEditingController _searchController = TextEditingController();
  late final TopClubController controller;

  @override
  void initState() {
    super.initState();
    controller = TopClubController.to;

    // The controller's onInit() only runs the first time it is created, so
    // re-fetch whenever this screen opens. If onInit() just started a fetch
    // the loading flag is already true and we skip the duplicate call.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isNetworkLoading.value) controller.fetchMyNetwork();
      if (!controller.isFindClubsLoading.value) controller.fetchFindClubs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050810),
        foregroundColor: Colors.white,
        title: const Text(
          'Top Clubs',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _buildNotificationBell(),
          SizedBox(width: 12.w),
          _buildMoreOptions(),
          SizedBox(width: 20.w),
        ],
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'Keep up with your rewards and rankings.',
              style: TextStyle(color: const Color(0xFF8B95A5), fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 20.h),

          // Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => isFindClubsActive = false);
                        _searchController.clear();
                        controller.fetchMyNetwork();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: !isFindClubsActive
                              ? const Color(0xFF1F2937)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Text(
                            'My Network',
                            style: TextStyle(
                              color: !isFindClubsActive
                                  ? Colors.white
                                  : const Color(0xFF8B95A5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => isFindClubsActive = true);
                        _searchController.clear();
                        controller.fetchFindClubs();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isFindClubsActive
                              ? const Color(0xFF1F2937)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Text(
                            'Find Clubs',
                            style: TextStyle(
                              color: isFindClubsActive
                                  ? Colors.white
                                  : const Color(0xFF8B95A5),
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

          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  Icon(Icons.search,
                      color: const Color(0xFF8B95A5), size: 20.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search clubs...',
                        hintStyle: TextStyle(color: Color(0xFF8B95A5)),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        if (isFindClubsActive) {
                          controller.onSearchChanged(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Club List
          Expanded(
            child: isFindClubsActive
                ? _buildFindClubsList()
                : _buildMyNetworkList(),
          ),
        ],
      ),
    );
  }

  // ─── Find Clubs List ───────────────────────────────────────────────
  Widget _buildFindClubsList() {
    return Obx(() {
      if (controller.isFindClubsLoading.value &&
          controller.findClubs.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF4D94FF)),
        );
      }

      if (controller.findClubs.isEmpty) {
        return Center(
          child: Text(
            'No clubs found',
            style: TextStyle(color: const Color(0xFF8B95A5), fontSize: 14.sp),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchFindClubs(
            search: controller.searchQuery.value),
        color: const Color(0xFF4D94FF),
        backgroundColor: const Color(0xFF111827),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: controller.findClubs.length,
          itemBuilder: (context, index) {
            final club = controller.findClubs[index];
            return _buildFindClubCard(club);
          },
        ),
      );
    });
  }

  // ─── My Network List ───────────────────────────────────────────────
  Widget _buildMyNetworkList() {
    return Obx(() {
      if (controller.isNetworkLoading.value &&
          controller.networkClubs.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF4D94FF)),
        );
      }

      if (controller.networkClubs.isEmpty) {
        return Center(
          child: Text(
            'No clubs in your network',
            style: TextStyle(color: const Color(0xFF8B95A5), fontSize: 14.sp),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchMyNetwork,
        color: const Color(0xFF4D94FF),
        backgroundColor: const Color(0xFF111827),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: controller.networkClubs.length,
          itemBuilder: (context, index) {
            final networkClub = controller.networkClubs[index];
            return _buildNetworkClubCard(networkClub);
          },
        ),
      );
    });
  }

  // ─── Find Club Card (with Invite button) ───────────────────────────
  Widget _buildFindClubCard(FindClubModel club) {
    return Obx(() {
      final isInvited = controller.invitedClubIds.contains(club.id);
      return GestureDetector(
        onTap: () {
          Get.toNamed(RouteName.clubProfile);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFF1F2937)),
          ),
          child: Row(
            children: [
              // Profile image
              _buildClubAvatar(club.profile, club.name),
              SizedBox(width: 12.w),
              // Club info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      club.email,
                      style: TextStyle(
                          color: const Color(0xFF8B95A5), fontSize: 14.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              // Invite button
              GestureDetector(
                onTap: isInvited
                    ? null
                    : () => controller.sendInvite(club.id),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 24.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isInvited
                        ? const Color(0xFF1F2937)
                        : const Color(0xFF4D94FF),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    isInvited ? 'Sent' : 'Invite',
                    style: TextStyle(
                      color: isInvited
                          ? const Color(0xFF8B95A5)
                          : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─── Network Club Card (with Chat icon) ────────────────────────────
  Widget _buildNetworkClubCard(NetworkClubModel networkClub) {
    final club = networkClub.club;
    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteName.chat);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Row(
          children: [
            // Profile image
            _buildClubAvatar(club.profile, club.name),
            SizedBox(width: 12.w),
            // Club info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    club.email,
                    style: TextStyle(
                        color: const Color(0xFF8B95A5), fontSize: 14.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Chat icon
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2A3550)),
              ),
              child: Icon(Icons.chat_bubble_outline,
                  color: Colors.white.withValues(alpha: 0.7), size: 20.w),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Club Avatar ───────────────────────────────────────────────────
  Widget _buildClubAvatar(String? profile, String name) {
    final imageUrl = ApiEndpoint.resolveImageUrl(profile);
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2A3550)),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: 44.w,
          height: 44.w,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: const Color(0xFF4D94FF),
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
            : Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: const Color(0xFF4D94FF),
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBell() {
    return Stack(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF1F2937)),
          ),
          child: Icon(Icons.notifications_outlined,
              color: Colors.white.withValues(alpha: 0.7), size: 22.w),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            width: 18.w,
            height: 18.w,
            decoration: const BoxDecoration(
                color: Color(0xFFEF4444), shape: BoxShape.circle),
            child: Center(
              child: Text('3',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreOptions() {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Icon(Icons.more_vert, color: Colors.white, size: 22.w),
    );
  }
}