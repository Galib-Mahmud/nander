import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nander/nander/trainers/screen/add_trainer_screen.dart';

import '../../auth/controller/club_model.dart';
import '../../chat/screen/add_new_team_screen.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../team/controller/team_controller.dart';
import '../../team/controller/team_model.dart';
import '../../trainers/model/trainer_model.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final TeamController controller = TeamController.to;

  @override
  void initState() {
    super.initState();
    controller.refreshData();
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
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            }
          },
        ),
        titleSpacing: 0,
        title: Obx(() {
          if (controller.isClubAdmin.value) {
            return Text(
              'My Teams',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            );
          }
          return Text(
            controller.trainerTab.value == 0 ? 'My Clubs' : 'Find Clubs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ),
      body: Obx(() {
        if (!controller.isClubAdmin.value) {
          return _buildTrainerBody(context);
        }
        return _buildClubAdminBody(context);
      }),
    );
  }

  Widget _buildClubAdminBody(BuildContext context) {
    if (controller.isLoading.value && controller.teams.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4D94FF)),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF4D94FF),
      backgroundColor: const Color(0xFF111827),
      onRefresh: controller.refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            if (controller.teams.isEmpty) ...[
              SizedBox(height: 120.h),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      color: const Color(0xFF8B95A5),
                      size: 56.w,
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'No teams found',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Tap below to add your first team',
                      style: TextStyle(
                        color: const Color(0xFF8B95A5),
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
            ] else ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 0.74,
                ),
                itemCount: controller.teams.length,
                itemBuilder: (context, index) {
                  final team = controller.teams[index];
                  return _buildTeamCard(context, team);
                },
              ),
              SizedBox(height: 20.h),
            ],

            // Add New Team Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const AddNewTeamScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D94FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Add New Team',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // 120px spacing so button stays above bottom bar
            SizedBox(height: 120.h),
          ],
        ),
      ),
    );
  }

  // ─── Trainer Body (Tabs: My Clubs & Club List) ───────────────────
  Widget _buildTrainerBody(BuildContext context) {
    return Column(
      children: [
        // Tab selector: My Clubs & Club List
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 12.h),
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.trainerTab.value = 0,
                    child: Obx(() => Container(
                          decoration: BoxDecoration(
                            color: controller.trainerTab.value == 0
                                ? const Color(0xFF4D94FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              'My Clubs (${controller.myClubs.length})',
                              style: TextStyle(
                                color: controller.trainerTab.value == 0
                                    ? Colors.white
                                    : const Color(0xFF8B95A5),
                                fontSize: 13.sp,
                                fontWeight: controller.trainerTab.value == 0
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        )),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.trainerTab.value = 1,
                    child: Obx(() => Container(
                          decoration: BoxDecoration(
                            color: controller.trainerTab.value == 1
                                ? const Color(0xFF4D94FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              'Club List (${controller.allClubs.length})',
                              style: TextStyle(
                                color: controller.trainerTab.value == 1
                                    ? Colors.white
                                    : const Color(0xFF8B95A5),
                                fontSize: 13.sp,
                                fontWeight: controller.trainerTab.value == 1
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Body content
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFF4D94FF),
            backgroundColor: const Color(0xFF111827),
            onRefresh: controller.refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Obx(() {
                if (controller.trainerTab.value == 0) {
                  return _buildMyClubsView(context);
                } else {
                  return _buildClubListView(context);
                }
              }),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Trainer: My Clubs View (from GET /trainer/my-clubs) ───────────
  Widget _buildMyClubsView(BuildContext context) {
    if (controller.isLoadingClubs.value && controller.myClubs.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 80.h),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF4D94FF)),
        ),
      );
    }

    if (controller.myClubs.isEmpty) {
      return Column(
        children: [
          SizedBox(height: 100.h),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: const Color(0xFF8B95A5),
                  size: 56.w,
                ),
                SizedBox(height: 14.h),
                Text(
                  'No clubs joined yet',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Explore clubs and send an invitation to join',
                  style: TextStyle(
                    color: const Color(0xFF8B95A5),
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 30.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () => controller.trainerTab.value = 1,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D94FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                      child: const Text(
                        'Find Clubs',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 120.h),
        ],
      );
    }

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.74,
          ),
          itemCount: controller.myClubs.length,
          itemBuilder: (context, index) {
            final club = controller.myClubs[index];
            return _buildClubCard(context, club);
          },
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () => controller.trainerTab.value = 1,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D94FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Send Invitation to Club',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 120.h),
      ],
    );
  }

  // ─── Trainer: Club List View (from GET /club/list) ─────────────────
  Widget _buildClubListView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Search Bar
          Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: TextField(
              controller: controller.clubSearchCtrl,
              onChanged: controller.filterAllClubs,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search clubs by name or location...',
                hintStyle: TextStyle(
                  color: const Color(0xFF8B95A5),
                  fontSize: 14.sp,
                ),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF8B95A5), size: 20),
                suffixIcon: controller.clubSearchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Colors.white54, size: 18),
                        onPressed: () {
                          controller.clubSearchCtrl.clear();
                          controller.filterAllClubs('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          if (controller.filteredAllClubs.isEmpty) ...[
            SizedBox(height: 80.h),
            Center(
              child: Column(
                children: [
                  Icon(Icons.search_off,
                      color: const Color(0xFF8B95A5), size: 48.w),
                  SizedBox(height: 10.h),
                  Text(
                    'No clubs found',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 120.h),
          ] else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.filteredAllClubs.length,
              itemBuilder: (context, index) {
                final club = controller.filteredAllClubs[index];
                return _buildClubListItem(context, club);
              },
            ),
            SizedBox(height: 120.h),
          ],
        ],
      ),
    );
  }

  // ─── Trainer: Joined/Pending Club Card ────────────────────────────
  Widget _buildClubCard(BuildContext context, ClubTrainerItem club) {
    const defaultBio =
        'A community-focused hockey club dedicated to developing players, building strong teams, and creating opportunities for athletes of all skill levels.';
    final isActive = club.status?.toUpperCase() == 'ACTIVE';

    return GestureDetector(
      onTap: () => _showClubDetailsBottomSheet(context, club),
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Column(
          children: [
            // Circular Avatar (Top-center, 58.w)
            ClipRRect(
              borderRadius: BorderRadius.circular(30.r),
              child: Container(
                width: 58.w,
                height: 58.w,
                color: const Color(0xFF050810),
                child: (club.displayProfile != null &&
                        club.displayProfile!.isNotEmpty)
                    ? Image.network(
                        ApiEndpoint.resolveImageUrl(club.displayProfile) ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.shield,
                            color: Color(0xFF4D94FF),
                            size: 30,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.shield,
                          color: Color(0xFF4D94FF),
                          size: 30,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 10.h),

            // Club Name
            Text(
              club.displayName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),

            // Status Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                isActive ? 'Active' : 'Pending',
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 6.h),

            // Bio / Address
            Expanded(
              child: Text(
                (club.clubAdmin?.bio != null &&
                        club.clubAdmin!.bio!.trim().isNotEmpty)
                    ? club.clubAdmin!.bio!
                    : (club.clubAdmin?.address != null &&
                            club.clubAdmin!.address!.trim().isNotEmpty)
                        ? club.clubAdmin!.address!
                        : defaultBio,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11.sp,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Trainer: Club List Item with Invite Action ───────────────────
  Widget _buildClubListItem(BuildContext context, ClubModel club) {
    return Obx(() {
      final isAlreadyJoined = controller.myClubs.any((c) =>
          (c.clubAdmin?.id == club.id || c.clubAdminId == club.id) &&
          c.status?.toUpperCase() == 'ACTIVE');
      final isPending = controller.pendingClubIds.contains(club.id) ||
          controller.myClubs.any((c) =>
              (c.clubAdmin?.id == club.id || c.clubAdminId == club.id) &&
              c.status?.toUpperCase() == 'PENDING');

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Container(
                width: 48.w,
                height: 48.w,
                color: const Color(0xFF050810),
                child: (club.profile != null && club.profile!.isNotEmpty)
                    ? Image.network(
                        ApiEndpoint.resolveImageUrl(club.profile) ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.shield,
                              color: Color(0xFF4D94FF), size: 24),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.shield,
                            color: Color(0xFF4D94FF), size: 24),
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    (club.address != null && club.address!.isNotEmpty)
                        ? club.address!
                        : (club.bio != null && club.bio!.isNotEmpty)
                            ? club.bio!
                            : 'Hockey Club',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF8B95A5),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            if (isAlreadyJoined)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: const Text(
                  'Joined',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (isPending)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.sendRequestToClub(club.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D94FF),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Invite',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  // ─── Trainer: Club Details BottomSheet ───────────────────────────
  void _showClubDetailsBottomSheet(BuildContext context, ClubTrainerItem club) {
    final isActive = club.status?.toUpperCase() == 'ACTIVE';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.displayName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (club.clubAdmin?.email != null &&
                            club.clubAdmin!.email!.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            club.clubAdmin!.email!,
                            style: TextStyle(
                              color: const Color(0xFF8B95A5),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Pending Request',
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if (club.clubAdmin?.address != null &&
                  club.clubAdmin!.address!.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: Color(0xFF8B95A5), size: 16),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        club.clubAdmin!.address!,
                        style: TextStyle(
                          color: const Color(0xFF8B95A5),
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
              ],
              Text(
                'About Club',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                (club.clubAdmin?.bio != null &&
                        club.clubAdmin!.bio!.trim().isNotEmpty)
                    ? club.clubAdmin!.bio!
                    : 'A community-focused hockey club dedicated to developing players, building strong teams, and creating opportunities for athletes of all skill levels.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13.sp,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Exact Card Design from Figma Screenshot 1 ─────────────────────
  Widget _buildTeamCard(BuildContext context, TeamModel team) {
    const defaultBio =
        'A community-focused hockey club dedicated to developing players, building strong teams, and creating opportunities for athletes of all skill levels.';

    return GestureDetector(
      onTap: () => _showTeamDetailsBottomSheet(context, team),
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Column(
          children: [
            // Circular Avatar (Top-center, 58.w)
            ClipRRect(
              borderRadius: BorderRadius.circular(30.r),
              child: Container(
                width: 58.w,
                height: 58.w,
                color: const Color(0xFF050810),
                child: (team.image != null && team.image!.isNotEmpty)
                    ? Image.network(
                        ApiEndpoint.resolveImageUrl(team.image) ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.shield,
                            color: Color(0xFF4D94FF),
                            size: 30,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.shield,
                          color: Color(0xFF4D94FF),
                          size: 30,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 12.h),

            // Team Name (Centered, bold white, 16.sp)
            Text(
              team.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),

            // Bio (Centered, 11.sp, max 4 lines, elegant grey)
            Expanded(
              child: Text(
                (team.bio != null && team.bio!.trim().isNotEmpty)
                    ? team.bio!
                    : defaultBio,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11.sp,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Team Members & Details BottomSheet ───────────────────────────
  void _showTeamDetailsBottomSheet(BuildContext context, TeamModel team) {
    controller.fetchActiveTeamMembers(team.id);
    controller.fetchRequestTeamMembers(team.id);

    int activeTabIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.92,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Header with Team Name & Edit/Delete
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  team.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (team.address != null &&
                                    team.address!.isNotEmpty) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    team.address!,
                                    style: TextStyle(
                                      color: const Color(0xFF8B95A5),
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: Color(0xFF4D94FF), size: 22),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  Get.to(() => AddNewTeamScreen(team: team));
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white54, size: 22),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // Tab selector: Active Members & Join Requests
                      Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1522),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFF1F2937)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setModalState(() => activeTabIndex = 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: activeTabIndex == 0
                                        ? const Color(0xFF4D94FF)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: Obx(() => Text(
                                          'Active Members (${controller.activeTeamMembers.length})',
                                          style: TextStyle(
                                            color: activeTabIndex == 0
                                                ? Colors.white
                                                : const Color(0xFF8B95A5),
                                            fontSize: 13.sp,
                                            fontWeight: activeTabIndex == 0
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                          ),
                                        )),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setModalState(() => activeTabIndex = 1),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: activeTabIndex == 1
                                        ? const Color(0xFF4D94FF)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: Obx(() => Text(
                                          'Requests (${controller.requestTeamMembers.length})',
                                          style: TextStyle(
                                            color: activeTabIndex == 1
                                                ? Colors.white
                                                : const Color(0xFF8B95A5),
                                            fontSize: 13.sp,
                                            fontWeight: activeTabIndex == 1
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                          ),
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Tab Content
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoadingMembers.value) {
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF4D94FF)),
                            );
                          }

                          if (activeTabIndex == 0) {
                            // Active Members
                            if (controller.activeTeamMembers.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.people_outline,
                                        color: Colors.white24, size: 40.sp),
                                    SizedBox(height: 8.h),
                                    Text('No active team members yet',
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 13.sp)),
                                  ],
                                ),
                              );
                            }
                            return ListView.separated(
                              controller: scrollController,
                              itemCount: controller.activeTeamMembers.length,
                              separatorBuilder: (_, __) => Divider(
                                  color: Colors.white.withValues(alpha: 0.06)),
                              itemBuilder: (context, idx) {
                                final member =
                                    controller.activeTeamMembers[idx];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF050810),
                                    child: Text(
                                      member.displayName.isNotEmpty
                                          ? member.displayName[0].toUpperCase()
                                          : 'T',
                                      style: const TextStyle(
                                        color: Color(0xFF4D94FF),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    member.displayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    member.displayEmail,
                                    style: const TextStyle(
                                      color: Color(0xFF8B95A5),
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: const Text(
                                      'Active',
                                      style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            // Requests (Approve / Decline)
                            if (controller.requestTeamMembers.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inbox_outlined,
                                        color: Colors.white24, size: 40.sp),
                                    SizedBox(height: 8.h),
                                    Text('No pending join requests',
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 13.sp)),
                                  ],
                                ),
                              );
                            }
                            return ListView.separated(
                              controller: scrollController,
                              itemCount: controller.requestTeamMembers.length,
                              separatorBuilder: (_, __) => Divider(
                                  color: Colors.white.withValues(alpha: 0.06)),
                              itemBuilder: (context, idx) {
                                final member =
                                    controller.requestTeamMembers[idx];
                                return Container(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFF050810),
                                        child: Text(
                                          member.displayName.isNotEmpty
                                              ? member.displayName[0]
                                                  .toUpperCase()
                                              : 'T',
                                          style: const TextStyle(
                                            color: Color(0xFF4D94FF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              member.displayName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              member.displayEmail,
                                              style: const TextStyle(
                                                color: Color(0xFF8B95A5),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Approve Button
                                          GestureDetector(
                                            onTap: () => controller
                                                .respondToTeamRequestByAdmin(
                                              teamId: team.id,
                                              requestId: member.id,
                                              isAccept: true,
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 14.w,
                                                  vertical: 6.h),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4D94FF),
                                                borderRadius:
                                                    BorderRadius.circular(20.r),
                                              ),
                                              child: Text(
                                                'Approve',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          // Decline Button
                                          GestureDetector(
                                            onTap: () => controller
                                                .respondToTeamRequestByAdmin(
                                              teamId: team.id,
                                              requestId: member.id,
                                              isAccept: false,
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 14.w,
                                                  vertical: 6.h),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF111827),
                                                borderRadius:
                                                    BorderRadius.circular(20.r),
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFF334155)),
                                              ),
                                              child: Text(
                                                'Decline',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        }),
                      ),
                      SizedBox(height: 12.h),
                      // Add Member Button
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Get.to(() => const AddTrainerScreen());
                          },
                          icon: const Icon(Icons.person_add_alt_1,
                              color: Color(0xFF4D94FF), size: 18),
                          label: const Text(
                            'Invite / Add Trainer',
                            style: TextStyle(
                              color: Color(0xFF4D94FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF4D94FF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ─── Invite / Add Trainer Dialog ──────────────────────────────────
  void _showAddMemberDialog(BuildContext context, TeamModel team) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Member to Team',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                'Team: ${team.name}',
                style:
                    TextStyle(color: const Color(0xFF4D94FF), fontSize: 13.sp),
              ),
              SizedBox(height: 16.h),
              Text('Trainer Name',
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
              SizedBox(height: 6.h),
              Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF050810),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    hintStyle: TextStyle(
                        color: const Color(0xFF8B95A5), fontSize: 14.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text('Trainer Email',
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
              SizedBox(height: 6.h),
              Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF050810),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter Trainer Email',
                    hintStyle: TextStyle(
                        color: const Color(0xFF8B95A5), fontSize: 14.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () async {
                    if (emailCtrl.text.trim().isEmpty) {
                      Get.snackbar('Error', 'Please enter trainer email');
                      return;
                    }
                    Navigator.pop(ctx);
                    await controller.addTeamMember(
                      teamId: team.id,
                      trainerName: nameCtrl.text.trim(),
                      sendEmail: emailCtrl.text.trim(),
                      isSendByEmail: true,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D94FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text(
                    'Add Member',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
