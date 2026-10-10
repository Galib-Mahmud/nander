import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../chat/screen/add_new_team_screen.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../newtrainer/trainner_team_details_screen.dart';
import '../../team/controller/team_controller.dart';
import '../../team/controller/team_model.dart';
import '../../trainers/screen/add_trainer_screen.dart';

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
              'My Teams'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            );
          }
          final tabIndex = controller.trainerTab.value;
          final tabTitle = tabIndex == 0
              ? 'My Teams'.tr
              : tabIndex == 1
              ? 'Find Teams'.tr
              : 'Team Requests'.tr;
          return Text(
            tabTitle,
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

  // ═══════════════════════════════════════════════════════════════════
  // ─── CLUB ADMIN BODY (GET /team/my-team) ───────────────────────────
  // ═══════════════════════════════════════════════════════════════════
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

            // Add New Team Button (POST /team/create)
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

            SizedBox(height: 120.h),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ─── TRAINER BODY (My Teams, Find Teams, Requests) ─────────────────
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildTrainerBody(BuildContext context) {
    return Column(
      children: [
        // Tab selector: My Teams, Find Teams, Requests
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 12.h),
          child: Container(
            height: 44.h,
            padding: EdgeInsets.all(4.w),
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
                          '${'My Teams'.tr} (${controller.myTeams.length})',
                          style: TextStyle(
                            color: controller.trainerTab.value == 0
                                ? Colors.white
                                : const Color(0xFF8B95A5),
                            fontSize: 12.sp,
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
                          '${'Find Teams'.tr} (${controller.findableTeams.length})',
                          style: TextStyle(
                            color: controller.trainerTab.value == 1
                                ? Colors.white
                                : const Color(0xFF8B95A5),
                            fontSize: 12.sp,
                            fontWeight: controller.trainerTab.value == 1
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
                    onTap: () => controller.trainerTab.value = 2,
                    child: Obx(() => Container(
                      decoration: BoxDecoration(
                        color: controller.trainerTab.value == 2
                            ? const Color(0xFF4D94FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          '${'Requests'.tr} (${controller.requestedTeams.length})',
                          style: TextStyle(
                            color: controller.trainerTab.value == 2
                                ? Colors.white
                                : const Color(0xFF8B95A5),
                            fontSize: 12.sp,
                            fontWeight: controller.trainerTab.value == 2
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
                  return _buildTrainerMyTeamsView(context);
                } else if (controller.trainerTab.value == 1) {
                  return _buildTrainerFindTeamsView(context);
                } else {
                  return _buildTrainerRequestsView(context);
                }
              }),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Trainer: Tab 0 - My Teams View (GET /team/my-team-with-progress & /team/active-teams)
  Widget _buildTrainerMyTeamsView(BuildContext context) {
    if (controller.isLoading.value && controller.myTeams.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 80.h),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF4D94FF)),
        ),
      );
    }

    if (controller.myTeams.isEmpty) {
      return Column(
        children: [
          SizedBox(height: 100.h),
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
                  'No teams joined yet',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Explore teams and send a request to join',
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
                        'Join New Teams',
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
            childAspectRatio: 0.72,
          ),
          itemCount: controller.myTeams.length,
          itemBuilder: (context, index) {
            final team = controller.myTeams[index];
            return _buildTrainerTeamCard(context, team);
          },
        ),
        SizedBox(height: 20.h),

      ],
    );
  }

  // ─── Trainer: Tab 1 - Find Teams View (GET /team) ─────────────────
  Widget _buildTrainerFindTeamsView(BuildContext context) {
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
              controller: controller.teamSearchCtrl,
              onChanged: controller.filterAllTeams,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search teams by name, location...',
                hintStyle: TextStyle(
                  color: const Color(0xFF8B95A5),
                  fontSize: 14.sp,
                ),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF8B95A5), size: 20),
                suffixIcon: controller.teamSearchCtrl.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear,
                      color: Colors.white54, size: 18),
                  onPressed: () {
                    controller.teamSearchCtrl.clear();
                    controller.filterAllTeams('');
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          if (controller.findableTeams.isEmpty) ...[
            SizedBox(height: 80.h),
            Center(
              child: Column(
                children: [
                  Icon(Icons.search_off,
                      color: const Color(0xFF8B95A5), size: 48.w),
                  SizedBox(height: 10.h),
                  Text(
                    'No teams to join',
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
              itemCount: controller.findableTeams.length,
              itemBuilder: (context, index) {
                final team = controller.findableTeams[index];
                return _buildTrainerFindTeamListItem(context, team);
              },
            ),
            SizedBox(height: 120.h),
          ],
        ],
      ),
    );
  }

  // ─── Trainer: Tab 2 - Requests View (GET /team/request-teams) ──────
  Widget _buildTrainerRequestsView(BuildContext context) {
    if (controller.isLoading.value && controller.requestedTeams.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 80.h),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF4D94FF)),
        ),
      );
    }

    if (controller.requestedTeams.isEmpty) {
      return Column(
        children: [
          SizedBox(height: 100.h),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  color: const Color(0xFF8B95A5),
                  size: 56.w,
                ),
                SizedBox(height: 14.h),
                Text(
                  'No pending team requests',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Invitations from clubs will appear here',
                  style: TextStyle(
                    color: const Color(0xFF8B95A5),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 120.h),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.requestedTeams.length,
            itemBuilder: (context, index) {
              final team = controller.requestedTeams[index];
              return _buildTrainerRequestListItem(context, team);
            },
          ),
          SizedBox(height: 120.h),
        ],
      ),
    );
  }

  // ─── Trainer: Team Card with Progress ─────────────────────────────
  Widget _buildTrainerTeamCard(BuildContext context, TeamModel team) {
    const defaultBio =
        'A community-focused hockey team dedicated to developing players and building strong teams.';

    return GestureDetector(
      onTap: () {
        // Navigate to Single Team With Progress details screen (GET /team/single-team-with-progress/:teamId)
        Get.to(() => TrainerTeamDetailScreen(
          teamId: team.id,
          initialName: team.name,
        ));
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Column(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(26.r),
              child: Container(
                width: 52.w,
                height: 52.w,
                color: const Color(0xFF050810),
                child: (team.image != null && team.image!.isNotEmpty)
                    ? Image.network(
                  ApiEndpoint.resolveImageUrl(team.image) ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.shield,
                      color: Color(0xFF4D94FF),
                      size: 26,
                    ),
                  ),
                )
                    : const Center(
                  child: Icon(
                    Icons.shield,
                    color: Color(0xFF4D94FF),
                    size: 26,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // Team Name
            Text(
              team.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),

            // Active Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 6.h),

            // Progress or Bio
            if (team.totalSessions > 0 || team.progressPercentage > 0) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${team.completedSessions}/${team.totalSessions} Sessions',
                          style: TextStyle(
                            color: const Color(0xFF8B95A5),
                            fontSize: 10.sp,
                          ),
                        ),
                        Text(
                          '${team.progressPercentage}%',
                          style: TextStyle(
                            color: const Color(0xFF4D94FF),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: (team.progressPercentage / 100.0).clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFF1F2937),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF4D94FF)),
                        minHeight: 5.h,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Expanded(
                child: Text(
                  (team.bio != null && team.bio!.trim().isNotEmpty)
                      ? team.bio!
                      : (team.address != null && team.address!.trim().isNotEmpty)
                      ? team.address!
                      : defaultBio,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11.sp,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Trainer: Find Team List Item with Join Action (POST /team/join-request-by-trainer)
  Widget _buildTrainerFindTeamListItem(BuildContext context, TeamModel team) {
    return Obx(() {
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
                child: (team.image != null && team.image!.isNotEmpty)
                    ? Image.network(
                  ApiEndpoint.resolveImageUrl(team.image) ?? '',
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
                    team.name,
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
                    (team.club != null && team.club!.name.isNotEmpty)
                        ? team.club!.name
                        : (team.address != null && team.address!.isNotEmpty)
                        ? team.address!
                        : (team.bio != null && team.bio!.isNotEmpty)
                        ? team.bio!
                        : 'Hockey Team',
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
            ElevatedButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : () => controller.joinTeamAsTrainer(team.id),
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
                'Join',
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

  // ─── Trainer: Request List Item (Accept / Reject: PATCH /trainer/trainer-accept-reject)
  Widget _buildTrainerRequestListItem(BuildContext context, TeamModel team) {
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
              child: (team.image != null && team.image!.isNotEmpty)
                  ? Image.network(
                ApiEndpoint.resolveImageUrl(team.image) ?? '',
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
                  team.name,
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
                  (team.club?.name != null && team.club!.name.isNotEmpty)
                      ? team.club!.name
                      : (team.address != null && team.address!.isNotEmpty)
                      ? team.address!
                      : 'Team Request',
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
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ─── CLUB ADMIN: Exact Card Design from Figma ───────────────────────
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildTeamCard(BuildContext context, TeamModel team) {
    const defaultBio =
        'A community-focused hockey team dedicated to developing players, building strong teams, and creating opportunities for athletes of all skill levels.';

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

            // Team Name
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

            // Bio / Address
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

  // ═══════════════════════════════════════════════════════════════════
  // ─── CLUB ADMIN: Team Details & Members BottomSheet ────────────────
  // ═══════════════════════════════════════════════════════════════════
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
                              // Edit Team (PATCH /team/update)
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: Color(0xFF4D94FF), size: 22),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  Get.to(() => AddNewTeamScreen(team: team));
                                },
                              ),
                              // Delete Team (DELETE /team/:teamId)
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent, size: 22),
                                onPressed: () {
                                  _confirmDeleteTeam(ctx, team);
                                },
                              ),
                              // Close Sheet
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

                      // Tab selector: Active Members & Requests
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
                            // Active Members (GET /team/active-team-members/:teamId)
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
                                    backgroundImage: member.displayImage != null
                                        ? NetworkImage(
                                        ApiEndpoint.resolveImageUrl(
                                            member.displayImage) ??
                                            '')
                                        : null,
                                    child: member.displayImage == null
                                        ? Text(
                                      member.displayName.isNotEmpty
                                          ? member.displayName[0]
                                          .toUpperCase()
                                          : 'T',
                                      style: const TextStyle(
                                        color: Color(0xFF4D94FF),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                        : null,
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
                            // Requests (GET /team/request-team-members/:teamId)
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
                                        backgroundImage:
                                        member.displayImage != null
                                            ? NetworkImage(
                                            ApiEndpoint.resolveImageUrl(
                                                member
                                                    .displayImage) ??
                                                '')
                                            : null,
                                        child: member.displayImage == null
                                            ? Text(
                                          member.displayName.isNotEmpty
                                              ? member.displayName[0]
                                              .toUpperCase()
                                              : 'T',
                                          style: const TextStyle(
                                            color: Color(0xFF4D94FF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                            : null,
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
                                          // Approve Button (PATCH /team/trainer-accept-reject)
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

                      // Add Member Button (POST /team/add-member)
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showAddMemberDialog(context, team);
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

  // ─── Delete Confirmation Dialog (DELETE /team/:teamId) ────────────
  void _confirmDeleteTeam(BuildContext parentContext, TeamModel team) {
    showDialog(
      context: parentContext,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Delete Team',
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to delete "${team.name}"? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF8B95A5))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(parentContext); // Close bottom sheet
              await controller.deleteTeam(team.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Invite / Add Trainer Dialog (POST /team/add-member) ───────────
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
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Get.to(() => const AddTrainerScreen());
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF334155)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        'Browse Trainers',
                        style: TextStyle(
                          color: const Color(0xFF8B95A5),
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
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
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        'Add Member',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
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
}





























// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
// import '../../chat/screen/add_new_team_screen.dart';
// import '../../core/endpoint/api_endpoint.dart';
// import '../../newtrainer/trainner_team_details_screen.dart';
// import '../../team/controller/team_controller.dart';
// import '../../team/controller/team_model.dart';
// import '../../trainers/screen/add_trainer_screen.dart';
//
// class TeamScreen extends StatefulWidget {
//   const TeamScreen({super.key});
//
//   @override
//   State<TeamScreen> createState() => _TeamScreenState();
// }
//
// class _TeamScreenState extends State<TeamScreen> {
//   final TeamController controller = TeamController.to;
//
//   @override
//   void initState() {
//     super.initState();
//     controller.refreshData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF050810),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF050810),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new,
//             color: Colors.white,
//             size: 20,
//           ),
//           onPressed: () {
//             if (Navigator.canPop(context)) {
//               Get.back();
//             }
//           },
//         ),
//         titleSpacing: 0,
//         title: Obx(() {
//           if (controller.isClubAdmin.value) {
//             return Text(
//               'My Teams',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 22.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             );
//           }
//           final tabIndex = controller.trainerTab.value;
//           final tabTitle = tabIndex == 0
//               ? 'My Teams'
//               : tabIndex == 1
//               ? 'Find Teams'
//               : 'Team Requests';
//           return Text(
//             tabTitle,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 22.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           );
//         }),
//       ),
//       body: Obx(() {
//         if (!controller.isClubAdmin.value) {
//           return _buildTrainerBody(context);
//         }
//         return _buildClubAdminBody(context);
//       }),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════════
//   // ─── CLUB ADMIN BODY (GET /team/my-team) ───────────────────────────
//   // ═══════════════════════════════════════════════════════════════════
//   Widget _buildClubAdminBody(BuildContext context) {
//     if (controller.isLoading.value && controller.teams.isEmpty) {
//       return const Center(
//         child: CircularProgressIndicator(color: Color(0xFF4D94FF)),
//       );
//     }
//
//     return RefreshIndicator(
//       color: const Color(0xFF4D94FF),
//       backgroundColor: const Color(0xFF111827),
//       onRefresh: controller.refreshData,
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: Column(
//           children: [
//             if (controller.teams.isEmpty) ...[
//               SizedBox(height: 120.h),
//               Center(
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.groups_outlined,
//                       color: const Color(0xFF8B95A5),
//                       size: 56.w,
//                     ),
//                     SizedBox(height: 14.h),
//                     Text(
//                       'No teams found',
//                       style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     SizedBox(height: 6.h),
//                     Text(
//                       'Tap below to add your first team',
//                       style: TextStyle(
//                         color: const Color(0xFF8B95A5),
//                         fontSize: 13.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 40.h),
//             ] else ...[
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 16.w,
//                   mainAxisSpacing: 16.h,
//                   childAspectRatio: 0.74,
//                 ),
//                 itemCount: controller.teams.length,
//                 itemBuilder: (context, index) {
//                   final team = controller.teams[index];
//                   return _buildTeamCard(context, team);
//                 },
//               ),
//               SizedBox(height: 20.h),
//             ],
//
//             // Add New Team Button (POST /team/create)
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20.w),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 52.h,
//                 child: ElevatedButton(
//                   onPressed: () => Get.to(() => const AddNewTeamScreen()),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF4D94FF),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(26.r),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: Text(
//                     'Add New Team',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 120.h),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════════
//   // ─── TRAINER BODY (My Teams, Find Teams, Requests) ─────────────────
//   // ═══════════════════════════════════════════════════════════════════
//   Widget _buildTrainerBody(BuildContext context) {
//     return Column(
//       children: [
//         // Tab selector: My Teams, Find Teams, Requests
//         Padding(
//           padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 12.h),
//           child: Container(
//             height: 44.h,
//             padding: EdgeInsets.all(4.w),
//             decoration: BoxDecoration(
//               color: const Color(0xFF111827),
//               borderRadius: BorderRadius.circular(10.r),
//               border: Border.all(color: const Color(0xFF1F2937)),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => controller.trainerTab.value = 0,
//                     child: Obx(() => Container(
//                       decoration: BoxDecoration(
//                         color: controller.trainerTab.value == 0
//                             ? const Color(0xFF4D94FF)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(8.r),
//                       ),
//                       child: Center(
//                         child: Text(
//                           'My Teams (${controller.myTeams.length})',
//                           style: TextStyle(
//                             color: controller.trainerTab.value == 0
//                                 ? Colors.white
//                                 : const Color(0xFF8B95A5),
//                             fontSize: 12.sp,
//                             fontWeight: controller.trainerTab.value == 0
//                                 ? FontWeight.bold
//                                 : FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     )),
//                   ),
//                 ),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => controller.trainerTab.value = 1,
//                     child: Obx(() => Container(
//                       decoration: BoxDecoration(
//                         color: controller.trainerTab.value == 1
//                             ? const Color(0xFF4D94FF)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(8.r),
//                       ),
//                       child: Center(
//                         child: Text(
//                           'Find Teams (${controller.filteredAllTeams.length})',
//                           style: TextStyle(
//                             color: controller.trainerTab.value == 1
//                                 ? Colors.white
//                                 : const Color(0xFF8B95A5),
//                             fontSize: 12.sp,
//                             fontWeight: controller.trainerTab.value == 1
//                                 ? FontWeight.bold
//                                 : FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     )),
//                   ),
//                 ),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => controller.trainerTab.value = 2,
//                     child: Obx(() => Container(
//                       decoration: BoxDecoration(
//                         color: controller.trainerTab.value == 2
//                             ? const Color(0xFF4D94FF)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(8.r),
//                       ),
//                       child: Center(
//                         child: Text(
//                           'Requests (${controller.requestedTeams.length})',
//                           style: TextStyle(
//                             color: controller.trainerTab.value == 2
//                                 ? Colors.white
//                                 : const Color(0xFF8B95A5),
//                             fontSize: 12.sp,
//                             fontWeight: controller.trainerTab.value == 2
//                                 ? FontWeight.bold
//                                 : FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     )),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//
//         // Body content
//         Expanded(
//           child: RefreshIndicator(
//             color: const Color(0xFF4D94FF),
//             backgroundColor: const Color(0xFF111827),
//             onRefresh: controller.refreshData,
//             child: SingleChildScrollView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               child: Obx(() {
//                 if (controller.trainerTab.value == 0) {
//                   return _buildTrainerMyTeamsView(context);
//                 } else if (controller.trainerTab.value == 1) {
//                   return _buildTrainerFindTeamsView(context);
//                 } else {
//                   return _buildTrainerRequestsView(context);
//                 }
//               }),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ─── Trainer: Tab 0 - My Teams View (GET /team/my-team-with-progress & /team/active-teams)
//   Widget _buildTrainerMyTeamsView(BuildContext context) {
//     if (controller.isLoading.value && controller.myTeams.isEmpty) {
//       return Padding(
//         padding: EdgeInsets.only(top: 80.h),
//         child: const Center(
//           child: CircularProgressIndicator(color: Color(0xFF4D94FF)),
//         ),
//       );
//     }
//
//     if (controller.myTeams.isEmpty) {
//       return Column(
//         children: [
//           SizedBox(height: 100.h),
//           Center(
//             child: Column(
//               children: [
//                 Icon(
//                   Icons.groups_outlined,
//                   color: const Color(0xFF8B95A5),
//                   size: 56.w,
//                 ),
//                 SizedBox(height: 14.h),
//                 Text(
//                   'No teams joined yet',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 SizedBox(height: 6.h),
//                 Text(
//                   'Explore teams and send a request to join',
//                   style: TextStyle(
//                     color: const Color(0xFF8B95A5),
//                     fontSize: 13.sp,
//                   ),
//                 ),
//                 SizedBox(height: 30.h),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 40.w),
//                   child: SizedBox(
//                     width: double.infinity,
//                     height: 48.h,
//                     child: ElevatedButton(
//                       onPressed: () => controller.trainerTab.value = 1,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF4D94FF),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(24.r),
//                         ),
//                       ),
//                       child: const Text(
//                         'Find Teams',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 120.h),
//         ],
//       );
//     }
//
//     return Column(
//       children: [
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 16.w,
//             mainAxisSpacing: 16.h,
//             childAspectRatio: 0.72,
//           ),
//           itemCount: controller.myTeams.length,
//           itemBuilder: (context, index) {
//             final team = controller.myTeams[index];
//             return _buildTrainerTeamCard(context, team);
//           },
//         ),
//         SizedBox(height: 20.h),
//
//       ],
//     );
//   }
//
//   // ─── Trainer: Tab 1 - Find Teams View (GET /team) ─────────────────
//   Widget _buildTrainerFindTeamsView(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w),
//       child: Column(
//         children: [
//           // Search Bar
//           Container(
//             height: 48.h,
//             decoration: BoxDecoration(
//               color: const Color(0xFF111827),
//               borderRadius: BorderRadius.circular(10.r),
//               border: Border.all(color: const Color(0xFF1F2937)),
//             ),
//             child: TextField(
//               controller: controller.teamSearchCtrl,
//               onChanged: controller.filterAllTeams,
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: 'Search teams by name, location...',
//                 hintStyle: TextStyle(
//                   color: const Color(0xFF8B95A5),
//                   fontSize: 14.sp,
//                 ),
//                 prefixIcon: const Icon(Icons.search,
//                     color: Color(0xFF8B95A5), size: 20),
//                 suffixIcon: controller.teamSearchCtrl.text.isNotEmpty
//                     ? IconButton(
//                   icon: const Icon(Icons.clear,
//                       color: Colors.white54, size: 18),
//                   onPressed: () {
//                     controller.teamSearchCtrl.clear();
//                     controller.filterAllTeams('');
//                   },
//                 )
//                     : null,
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.symmetric(vertical: 12.h),
//               ),
//             ),
//           ),
//           SizedBox(height: 16.h),
//
//           if (controller.filteredAllTeams.isEmpty) ...[
//             SizedBox(height: 80.h),
//             Center(
//               child: Column(
//                 children: [
//                   Icon(Icons.search_off,
//                       color: const Color(0xFF8B95A5), size: 48.w),
//                   SizedBox(height: 10.h),
//                   Text(
//                     'No teams found',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 15.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 120.h),
//           ] else ...[
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: controller.filteredAllTeams.length,
//               itemBuilder: (context, index) {
//                 final team = controller.filteredAllTeams[index];
//                 return _buildTrainerFindTeamListItem(context, team);
//               },
//             ),
//             SizedBox(height: 120.h),
//           ],
//         ],
//       ),
//     );
//   }
//
//   // ─── Trainer: Tab 2 - Requests View (GET /team/request-teams) ──────
//   Widget _buildTrainerRequestsView(BuildContext context) {
//     if (controller.isLoading.value && controller.requestedTeams.isEmpty) {
//       return Padding(
//         padding: EdgeInsets.only(top: 80.h),
//         child: const Center(
//           child: CircularProgressIndicator(color: Color(0xFF4D94FF)),
//         ),
//       );
//     }
//
//     if (controller.requestedTeams.isEmpty) {
//       return Column(
//         children: [
//           SizedBox(height: 100.h),
//           Center(
//             child: Column(
//               children: [
//                 Icon(
//                   Icons.inbox_outlined,
//                   color: const Color(0xFF8B95A5),
//                   size: 56.w,
//                 ),
//                 SizedBox(height: 14.h),
//                 Text(
//                   'No pending team requests',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 SizedBox(height: 6.h),
//                 Text(
//                   'Invitations from clubs will appear here',
//                   style: TextStyle(
//                     color: const Color(0xFF8B95A5),
//                     fontSize: 13.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 120.h),
//         ],
//       );
//     }
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w),
//       child: Column(
//         children: [
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: controller.requestedTeams.length,
//             itemBuilder: (context, index) {
//               final team = controller.requestedTeams[index];
//               return _buildTrainerRequestListItem(context, team);
//             },
//           ),
//           SizedBox(height: 120.h),
//         ],
//       ),
//     );
//   }
//
//   // ─── Trainer: Team Card with Progress ─────────────────────────────
//   Widget _buildTrainerTeamCard(BuildContext context, TeamModel team) {
//     const defaultBio =
//         'A community-focused hockey team dedicated to developing players and building strong teams.';
//
//     return GestureDetector(
//       onTap: () {
//         // Navigate to Single Team With Progress details screen (GET /team/single-team-with-progress/:teamId)
//         Get.to(() => TrainerTeamDetailScreen(
//           teamId: team.id,
//           initialName: team.name,
//         ));
//       },
//       child: Container(
//         padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
//         decoration: BoxDecoration(
//           color: const Color(0xFF111827),
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(color: const Color(0xFF1F2937)),
//         ),
//         child: Column(
//           children: [
//             // Avatar
//             ClipRRect(
//               borderRadius: BorderRadius.circular(26.r),
//               child: Container(
//                 width: 52.w,
//                 height: 52.w,
//                 color: const Color(0xFF050810),
//                 child: (team.image != null && team.image!.isNotEmpty)
//                     ? Image.network(
//                   ApiEndpoint.resolveImageUrl(team.image) ?? '',
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => const Center(
//                     child: Icon(
//                       Icons.shield,
//                       color: Color(0xFF4D94FF),
//                       size: 26,
//                     ),
//                   ),
//                 )
//                     : const Center(
//                   child: Icon(
//                     Icons.shield,
//                     color: Color(0xFF4D94FF),
//                     size: 26,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 8.h),
//
//             // Team Name
//             Text(
//               team.name,
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 15.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 4.h),
//
//             // Active Badge
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF10B981).withValues(alpha: 0.15),
//                 borderRadius: BorderRadius.circular(10.r),
//               ),
//               child: const Text(
//                 'Active',
//                 style: TextStyle(
//                   color: Color(0xFF10B981),
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             SizedBox(height: 6.h),
//
//             // Progress or Bio
//             if (team.totalSessions > 0 || team.progressPercentage > 0) ...[
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 4.w),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           '${team.completedSessions}/${team.totalSessions} Sessions',
//                           style: TextStyle(
//                             color: const Color(0xFF8B95A5),
//                             fontSize: 10.sp,
//                           ),
//                         ),
//                         Text(
//                           '${team.progressPercentage}%',
//                           style: TextStyle(
//                             color: const Color(0xFF4D94FF),
//                             fontSize: 10.sp,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 4.h),
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(4.r),
//                       child: LinearProgressIndicator(
//                         value: (team.progressPercentage / 100.0).clamp(0.0, 1.0),
//                         backgroundColor: const Color(0xFF1F2937),
//                         valueColor: const AlwaysStoppedAnimation<Color>(
//                             Color(0xFF4D94FF)),
//                         minHeight: 5.h,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ] else ...[
//               Expanded(
//                 child: Text(
//                   (team.bio != null && team.bio!.trim().isNotEmpty)
//                       ? team.bio!
//                       : (team.address != null && team.address!.trim().isNotEmpty)
//                       ? team.address!
//                       : defaultBio,
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: Colors.white.withValues(alpha: 0.7),
//                     fontSize: 11.sp,
//                     height: 1.3,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ─── Trainer: Find Team List Item with Join Action (POST /team/join-request-by-trainer)
//   Widget _buildTrainerFindTeamListItem(BuildContext context, TeamModel team) {
//     return Obx(() {
//       final isJoined = controller.myTeams.any((t) => t.id == team.id);
//       final isPending = controller.pendingJoinTeamIds.contains(team.id) ||
//           controller.requestedTeams.any((t) => t.id == team.id);
//
//       return Container(
//         margin: EdgeInsets.only(bottom: 12.h),
//         padding: EdgeInsets.all(14.w),
//         decoration: BoxDecoration(
//           color: const Color(0xFF111827),
//           borderRadius: BorderRadius.circular(14.r),
//           border: Border.all(color: const Color(0xFF1F2937)),
//         ),
//         child: Row(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(24.r),
//               child: Container(
//                 width: 48.w,
//                 height: 48.w,
//                 color: const Color(0xFF050810),
//                 child: (team.image != null && team.image!.isNotEmpty)
//                     ? Image.network(
//                   ApiEndpoint.resolveImageUrl(team.image) ?? '',
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => const Center(
//                     child: Icon(Icons.shield,
//                         color: Color(0xFF4D94FF), size: 24),
//                   ),
//                 )
//                     : const Center(
//                   child: Icon(Icons.shield,
//                       color: Color(0xFF4D94FF), size: 24),
//                 ),
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     team.name,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 15.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 3.h),
//                   Text(
//                     (team.club != null && team.club!.name.isNotEmpty)
//                         ? team.club!.name
//                         : (team.address != null && team.address!.isNotEmpty)
//                         ? team.address!
//                         : (team.bio != null && team.bio!.isNotEmpty)
//                         ? team.bio!
//                         : 'Hockey Team',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: const Color(0xFF8B95A5),
//                       fontSize: 12.sp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(width: 10.w),
//             if (isJoined)
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF10B981).withValues(alpha: 0.15),
//                   borderRadius: BorderRadius.circular(16.r),
//                 ),
//                 child: const Text(
//                   'Joined',
//                   style: TextStyle(
//                     color: Color(0xFF10B981),
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               )
//             else if (isPending)
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
//                   borderRadius: BorderRadius.circular(16.r),
//                 ),
//                 child: const Text(
//                   'Pending',
//                   style: TextStyle(
//                     color: Color(0xFFF59E0B),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               )
//             else
//               ElevatedButton(
//                 onPressed: controller.isSubmitting.value
//                     ? null
//                     : () => controller.joinTeamAsTrainer(team.id),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF4D94FF),
//                   padding:
//                   EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//                   minimumSize: Size.zero,
//                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16.r),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: Text(
//                   'Join',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       );
//     });
//   }
//
//   // ─── Trainer: Request List Item (Accept / Reject: PATCH /trainer/trainer-accept-reject)
//   Widget _buildTrainerRequestListItem(BuildContext context, TeamModel team) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: EdgeInsets.all(14.w),
//       decoration: BoxDecoration(
//         color: const Color(0xFF111827),
//         borderRadius: BorderRadius.circular(14.r),
//         border: Border.all(color: const Color(0xFF1F2937)),
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(24.r),
//             child: Container(
//               width: 48.w,
//               height: 48.w,
//               color: const Color(0xFF050810),
//               child: (team.image != null && team.image!.isNotEmpty)
//                   ? Image.network(
//                 ApiEndpoint.resolveImageUrl(team.image) ?? '',
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => const Center(
//                   child: Icon(Icons.shield,
//                       color: Color(0xFF4D94FF), size: 24),
//                 ),
//               )
//                   : const Center(
//                 child: Icon(Icons.shield,
//                     color: Color(0xFF4D94FF), size: 24),
//               ),
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   team.name,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 3.h),
//                 Text(
//                   (team.club?.name != null && team.club!.name.isNotEmpty)
//                       ? team.club!.name
//                       : (team.address != null && team.address!.isNotEmpty)
//                       ? team.address!
//                       : 'Team Request',
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: const Color(0xFF8B95A5),
//                     fontSize: 12.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(width: 10.w),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Accept Button
//               GestureDetector(
//                 onTap: controller.isSubmitting.value
//                     ? null
//                     : () => controller.respondToTrainerInvitation(
//                   requestId: team.requestId ?? team.id,
//                   isAccept: true,
//                   teamId: team.id,
//                 ),
//                 child: Container(
//                   padding:
//                   EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF4D94FF),
//                     borderRadius: BorderRadius.circular(20.r),
//                   ),
//                   child: Text(
//                     'Accept',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               // Decline Button
//               GestureDetector(
//                 onTap: controller.isSubmitting.value
//                     ? null
//                     : () => controller.respondToTrainerInvitation(
//                   requestId: team.requestId ?? team.id,
//                   isAccept: false,
//                   teamId: team.id,
//                 ),
//                 child: Container(
//                   padding:
//                   EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF111827),
//                     borderRadius: BorderRadius.circular(20.r),
//                     border: Border.all(color: const Color(0xFF334155)),
//                   ),
//                   child: Text(
//                     'Decline',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════════
//   // ─── CLUB ADMIN: Exact Card Design from Figma ───────────────────────
//   // ═══════════════════════════════════════════════════════════════════
//   Widget _buildTeamCard(BuildContext context, TeamModel team) {
//     const defaultBio =
//         'A community-focused hockey team dedicated to developing players, building strong teams, and creating opportunities for athletes of all skill levels.';
//
//     return GestureDetector(
//       onTap: () => _showTeamDetailsBottomSheet(context, team),
//       child: Container(
//         padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 14.h),
//         decoration: BoxDecoration(
//           color: const Color(0xFF111827),
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(color: const Color(0xFF1F2937)),
//         ),
//         child: Column(
//           children: [
//             // Circular Avatar (Top-center, 58.w)
//             ClipRRect(
//               borderRadius: BorderRadius.circular(30.r),
//               child: Container(
//                 width: 58.w,
//                 height: 58.w,
//                 color: const Color(0xFF050810),
//                 child: (team.image != null && team.image!.isNotEmpty)
//                     ? Image.network(
//                   ApiEndpoint.resolveImageUrl(team.image) ?? '',
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => const Center(
//                     child: Icon(
//                       Icons.shield,
//                       color: Color(0xFF4D94FF),
//                       size: 30,
//                     ),
//                   ),
//                 )
//                     : const Center(
//                   child: Icon(
//                     Icons.shield,
//                     color: Color(0xFF4D94FF),
//                     size: 30,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 12.h),
//
//             // Team Name
//             Text(
//               team.name,
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 6.h),
//
//             // Bio / Address
//             Expanded(
//               child: Text(
//                 (team.bio != null && team.bio!.trim().isNotEmpty)
//                     ? team.bio!
//                     : defaultBio,
//                 textAlign: TextAlign.center,
//                 maxLines: 4,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: Colors.white.withValues(alpha: 0.7),
//                   fontSize: 11.sp,
//                   height: 1.35,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════════
//   // ─── CLUB ADMIN: Team Details & Members BottomSheet ────────────────
//   // ═══════════════════════════════════════════════════════════════════
//   void _showTeamDetailsBottomSheet(BuildContext context, TeamModel team) {
//     controller.fetchActiveTeamMembers(team.id);
//     controller.fetchRequestTeamMembers(team.id);
//
//     int activeTabIndex = 0;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: const Color(0xFF111827),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       builder: (ctx) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return DraggableScrollableSheet(
//               initialChildSize: 0.75,
//               minChildSize: 0.5,
//               maxChildSize: 0.92,
//               expand: false,
//               builder: (context, scrollController) {
//                 return Padding(
//                   padding:
//                   EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Container(
//                           width: 40.w,
//                           height: 4.h,
//                           decoration: BoxDecoration(
//                             color: Colors.white24,
//                             borderRadius: BorderRadius.circular(2.r),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//
//                       // Header with Team Name & Edit/Delete
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   team.name,
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 20.sp,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 if (team.address != null &&
//                                     team.address!.isNotEmpty) ...[
//                                   SizedBox(height: 2.h),
//                                   Text(
//                                     team.address!,
//                                     style: TextStyle(
//                                       color: const Color(0xFF8B95A5),
//                                       fontSize: 12.sp,
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               // Edit Team (PATCH /team/update)
//                               IconButton(
//                                 icon: const Icon(Icons.edit_outlined,
//                                     color: Color(0xFF4D94FF), size: 22),
//                                 onPressed: () {
//                                   Navigator.pop(ctx);
//                                   Get.to(() => AddNewTeamScreen(team: team));
//                                 },
//                               ),
//                               // Delete Team (DELETE /team/:teamId)
//                               IconButton(
//                                 icon: const Icon(Icons.delete_outline,
//                                     color: Colors.redAccent, size: 22),
//                                 onPressed: () {
//                                   _confirmDeleteTeam(ctx, team);
//                                 },
//                               ),
//                               // Close Sheet
//                               IconButton(
//                                 icon: const Icon(Icons.close,
//                                     color: Colors.white54, size: 22),
//                                 onPressed: () => Navigator.pop(ctx),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 14.h),
//
//                       // Tab selector: Active Members & Requests
//                       Container(
//                         height: 44.h,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF0F1522),
//                           borderRadius: BorderRadius.circular(10.r),
//                           border: Border.all(color: const Color(0xFF1F2937)),
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: GestureDetector(
//                                 onTap: () =>
//                                     setModalState(() => activeTabIndex = 0),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: activeTabIndex == 0
//                                         ? const Color(0xFF4D94FF)
//                                         : Colors.transparent,
//                                     borderRadius: BorderRadius.circular(8.r),
//                                   ),
//                                   child: Center(
//                                     child: Obx(() => Text(
//                                       'Active Members (${controller.activeTeamMembers.length})',
//                                       style: TextStyle(
//                                         color: activeTabIndex == 0
//                                             ? Colors.white
//                                             : const Color(0xFF8B95A5),
//                                         fontSize: 13.sp,
//                                         fontWeight: activeTabIndex == 0
//                                             ? FontWeight.bold
//                                             : FontWeight.w500,
//                                       ),
//                                     )),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: GestureDetector(
//                                 onTap: () =>
//                                     setModalState(() => activeTabIndex = 1),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: activeTabIndex == 1
//                                         ? const Color(0xFF4D94FF)
//                                         : Colors.transparent,
//                                     borderRadius: BorderRadius.circular(8.r),
//                                   ),
//                                   child: Center(
//                                     child: Obx(() => Text(
//                                       'Requests (${controller.requestTeamMembers.length})',
//                                       style: TextStyle(
//                                         color: activeTabIndex == 1
//                                             ? Colors.white
//                                             : const Color(0xFF8B95A5),
//                                         fontSize: 13.sp,
//                                         fontWeight: activeTabIndex == 1
//                                             ? FontWeight.bold
//                                             : FontWeight.w500,
//                                       ),
//                                     )),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//
//                       // Tab Content
//                       Expanded(
//                         child: Obx(() {
//                           if (controller.isLoadingMembers.value) {
//                             return const Center(
//                               child: CircularProgressIndicator(
//                                   color: Color(0xFF4D94FF)),
//                             );
//                           }
//
//                           if (activeTabIndex == 0) {
//                             // Active Members (GET /team/active-team-members/:teamId)
//                             if (controller.activeTeamMembers.isEmpty) {
//                               return Center(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(Icons.people_outline,
//                                         color: Colors.white24, size: 40.sp),
//                                     SizedBox(height: 8.h),
//                                     Text('No active team members yet',
//                                         style: TextStyle(
//                                             color: Colors.white54,
//                                             fontSize: 13.sp)),
//                                   ],
//                                 ),
//                               );
//                             }
//                             return ListView.separated(
//                               controller: scrollController,
//                               itemCount: controller.activeTeamMembers.length,
//                               separatorBuilder: (_, __) => Divider(
//                                   color: Colors.white.withValues(alpha: 0.06)),
//                               itemBuilder: (context, idx) {
//                                 final member =
//                                 controller.activeTeamMembers[idx];
//                                 return ListTile(
//                                   contentPadding: EdgeInsets.zero,
//                                   leading: CircleAvatar(
//                                     backgroundColor: const Color(0xFF050810),
//                                     backgroundImage: member.displayImage != null
//                                         ? NetworkImage(
//                                         ApiEndpoint.resolveImageUrl(
//                                             member.displayImage) ??
//                                             '')
//                                         : null,
//                                     child: member.displayImage == null
//                                         ? Text(
//                                       member.displayName.isNotEmpty
//                                           ? member.displayName[0]
//                                           .toUpperCase()
//                                           : 'T',
//                                       style: const TextStyle(
//                                         color: Color(0xFF4D94FF),
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     )
//                                         : null,
//                                   ),
//                                   title: Text(
//                                     member.displayName,
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   subtitle: Text(
//                                     member.displayEmail,
//                                     style: const TextStyle(
//                                       color: Color(0xFF8B95A5),
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                   trailing: Container(
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: 10.w, vertical: 4.h),
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xFF10B981)
//                                           .withValues(alpha: 0.15),
//                                       borderRadius: BorderRadius.circular(10.r),
//                                     ),
//                                     child: const Text(
//                                       'Active',
//                                       style: TextStyle(
//                                         color: Color(0xFF10B981),
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           } else {
//                             // Requests (GET /team/request-team-members/:teamId)
//                             if (controller.requestTeamMembers.isEmpty) {
//                               return Center(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(Icons.inbox_outlined,
//                                         color: Colors.white24, size: 40.sp),
//                                     SizedBox(height: 8.h),
//                                     Text('No pending join requests',
//                                         style: TextStyle(
//                                             color: Colors.white54,
//                                             fontSize: 13.sp)),
//                                   ],
//                                 ),
//                               );
//                             }
//                             return ListView.separated(
//                               controller: scrollController,
//                               itemCount: controller.requestTeamMembers.length,
//                               separatorBuilder: (_, __) => Divider(
//                                   color: Colors.white.withValues(alpha: 0.06)),
//                               itemBuilder: (context, idx) {
//                                 final member =
//                                 controller.requestTeamMembers[idx];
//                                 return Container(
//                                   padding: EdgeInsets.symmetric(vertical: 8.h),
//                                   child: Row(
//                                     children: [
//                                       CircleAvatar(
//                                         backgroundColor:
//                                         const Color(0xFF050810),
//                                         backgroundImage:
//                                         member.displayImage != null
//                                             ? NetworkImage(
//                                             ApiEndpoint.resolveImageUrl(
//                                                 member
//                                                     .displayImage) ??
//                                                 '')
//                                             : null,
//                                         child: member.displayImage == null
//                                             ? Text(
//                                           member.displayName.isNotEmpty
//                                               ? member.displayName[0]
//                                               .toUpperCase()
//                                               : 'T',
//                                           style: const TextStyle(
//                                             color: Color(0xFF4D94FF),
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         )
//                                             : null,
//                                       ),
//                                       SizedBox(width: 12.w),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               member.displayName,
//                                               style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             SizedBox(height: 2.h),
//                                             Text(
//                                               member.displayEmail,
//                                               style: const TextStyle(
//                                                 color: Color(0xFF8B95A5),
//                                                 fontSize: 12,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           // Approve Button (PATCH /team/trainer-accept-reject)
//                                           GestureDetector(
//                                             onTap: () => controller
//                                                 .respondToTeamRequestByAdmin(
//                                               teamId: team.id,
//                                               requestId: member.id,
//                                               isAccept: true,
//                                             ),
//                                             child: Container(
//                                               padding: EdgeInsets.symmetric(
//                                                   horizontal: 14.w,
//                                                   vertical: 6.h),
//                                               decoration: BoxDecoration(
//                                                 color: const Color(0xFF4D94FF),
//                                                 borderRadius:
//                                                 BorderRadius.circular(20.r),
//                                               ),
//                                               child: Text(
//                                                 'Approve',
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 12.sp,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(width: 8.w),
//                                           // Decline Button
//                                           GestureDetector(
//                                             onTap: () => controller
//                                                 .respondToTeamRequestByAdmin(
//                                               teamId: team.id,
//                                               requestId: member.id,
//                                               isAccept: false,
//                                             ),
//                                             child: Container(
//                                               padding: EdgeInsets.symmetric(
//                                                   horizontal: 14.w,
//                                                   vertical: 6.h),
//                                               decoration: BoxDecoration(
//                                                 color: const Color(0xFF111827),
//                                                 borderRadius:
//                                                 BorderRadius.circular(20.r),
//                                                 border: Border.all(
//                                                     color: const Color(
//                                                         0xFF334155)),
//                                               ),
//                                               child: Text(
//                                                 'Decline',
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 12.sp,
//                                                   fontWeight: FontWeight.w500,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             );
//                           }
//                         }),
//                       ),
//                       SizedBox(height: 12.h),
//
//                       // Add Member Button (POST /team/add-member)
//                       SizedBox(
//                         width: double.infinity,
//                         height: 48.h,
//                         child: OutlinedButton.icon(
//                           onPressed: () {
//                             _showAddMemberDialog(context, team);
//                           },
//                           icon: const Icon(Icons.person_add_alt_1,
//                               color: Color(0xFF4D94FF), size: 18),
//                           label: const Text(
//                             'Invite / Add Trainer',
//                             style: TextStyle(
//                               color: Color(0xFF4D94FF),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             side: const BorderSide(color: Color(0xFF4D94FF)),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.r),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // ─── Delete Confirmation Dialog (DELETE /team/:teamId) ────────────
//   void _confirmDeleteTeam(BuildContext parentContext, TeamModel team) {
//     showDialog(
//       context: parentContext,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: const Color(0xFF111827),
//         shape:
//         RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
//         title: const Text('Delete Team',
//             style:
//             TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         content: Text(
//             'Are you sure you want to delete "${team.name}"? This action cannot be undone.',
//             style: const TextStyle(color: Colors.white70)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel',
//                 style: TextStyle(color: Color(0xFF8B95A5))),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(ctx); // Close dialog
//               Navigator.pop(parentContext); // Close bottom sheet
//               await controller.deleteTeam(team.id);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red.shade700,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.r)),
//             ),
//             child: const Text('Delete', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Invite / Add Trainer Dialog (POST /team/add-member) ───────────
//   void _showAddMemberDialog(BuildContext context, TeamModel team) {
//     final nameCtrl = TextEditingController();
//     final emailCtrl = TextEditingController();
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: const Color(0xFF111827),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       builder: (ctx) {
//         return Padding(
//           padding: EdgeInsets.only(
//             left: 20.w,
//             right: 20.w,
//             top: 20.h,
//             bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Add Member to Team',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.white54),
//                     onPressed: () => Navigator.pop(ctx),
//                   ),
//                 ],
//               ),
//               Text(
//                 'Team: ${team.name}',
//                 style:
//                 TextStyle(color: const Color(0xFF4D94FF), fontSize: 13.sp),
//               ),
//               SizedBox(height: 16.h),
//               Text('Trainer Name',
//                   style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
//               SizedBox(height: 6.h),
//               Container(
//                 height: 48.h,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF050810),
//                   borderRadius: BorderRadius.circular(10.r),
//                   border: Border.all(color: const Color(0xFF1F2937)),
//                 ),
//                 child: TextField(
//                   controller: nameCtrl,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: InputDecoration(
//                     hintText: 'Full Name',
//                     hintStyle: TextStyle(
//                         color: const Color(0xFF8B95A5), fontSize: 14.sp),
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 14.h),
//               Text('Trainer Email',
//                   style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
//               SizedBox(height: 6.h),
//               Container(
//                 height: 48.h,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF050810),
//                   borderRadius: BorderRadius.circular(10.r),
//                   border: Border.all(color: const Color(0xFF1F2937)),
//                 ),
//                 child: TextField(
//                   controller: emailCtrl,
//                   keyboardType: TextInputType.emailAddress,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: InputDecoration(
//                     hintText: 'Enter Trainer Email',
//                     hintStyle: TextStyle(
//                         color: const Color(0xFF8B95A5), fontSize: 14.sp),
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20.h),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () {
//                         Navigator.pop(ctx);
//                         Get.to(() => const AddTrainerScreen());
//                       },
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: Color(0xFF334155)),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         padding: EdgeInsets.symmetric(vertical: 14.h),
//                       ),
//                       child: Text(
//                         'Browse Trainers',
//                         style: TextStyle(
//                           color: const Color(0xFF8B95A5),
//                           fontSize: 13.sp,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         if (emailCtrl.text.trim().isEmpty) {
//                           Get.snackbar('Error', 'Please enter trainer email');
//                           return;
//                         }
//                         Navigator.pop(ctx);
//                         await controller.addTeamMember(
//                           teamId: team.id,
//                           trainerName: nameCtrl.text.trim(),
//                           sendEmail: emailCtrl.text.trim(),
//                           isSendByEmail: true,
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF4D94FF),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         padding: EdgeInsets.symmetric(vertical: 14.h),
//                       ),
//                       child: Text(
//                         'Add Member',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 13.sp,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
