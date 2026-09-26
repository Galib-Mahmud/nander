import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../team/controller/team_controller.dart';
import '../../team/controller/team_model.dart';
import 'add_new_team_screen.dart';

class MyTeamsScreen extends StatelessWidget {
  const MyTeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TeamController controller = TeamController.to;

    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050810),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'My Teams',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.teams.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4D94FF)));
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              Expanded(
                child: controller.teams.isEmpty
                    ? Center(
                        child: Text(
                          'No teams found',
                          style: TextStyle(color: Colors.white54, fontSize: 15.sp),
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF4D94FF),
                        backgroundColor: const Color(0xFF111827),
                        onRefresh: controller.fetchTeams,
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: controller.teams.length,
                          itemBuilder: (context, index) {
                            return _buildTeamCard(context, controller.teams[index], controller);
                          },
                        ),
                      ),
              ),

              // Add New Team Button (Only for Club Admin)
              if (controller.isClubAdmin.value)
                GestureDetector(
                  onTap: () => Get.to(() => const AddNewTeamScreen()),
                  child: Container(
                    width: double.infinity,
                    height: 54.h,
                    margin: EdgeInsets.only(bottom: 24.h, top: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4D94FF),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: const Center(
                      child: Text(
                        'Add New Team',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTeamCard(BuildContext context, TeamModel team, TeamController controller) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Team Image
          ClipRRect(
            borderRadius: BorderRadius.circular(30.r),
            child: Container(
              width: 56.w,
              height: 56.w,
              color: const Color(0xFF050810),
              child: (team.image != null && team.image!.isNotEmpty)
                  ? Image.network(
                      ApiEndpoint.resolveImageUrl(team.image) ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.shield, color: Color(0xFF4D94FF), size: 28)),
                    )
                  : const Center(child: Icon(Icons.shield, color: Color(0xFF4D94FF), size: 28)),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            team.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            team.bio ?? (team.trainerName != null ? 'Trainer: ${team.trainerName}' : 'No bio available'),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11.sp,
              height: 1.3,
            ),
          ),
          const Spacer(),
          if (controller.isClubAdmin.value)
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () => Get.to(() => AddNewTeamScreen(team: team)),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFF161E30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit_outlined, size: 16.w, color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
    );
  }
}