import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'add_new_team_screen.dart';

class MyTeamsScreen extends StatelessWidget {
  const MyTeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75, // ✅ Increased height ratio to prevent overflow
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return _buildTeamCard();
                },
              ),
            ),
            // Add New Team Button
            GestureDetector(
              onTap: () {
                Get.to(() => const AddNewTeamScreen());
              },
              child: Container(
                width: double.infinity,
                height: 56.h,
                margin: EdgeInsets.only(bottom: 20.h, top: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D94FF),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: const Center(
                  child: Text(
                    'Add New Team',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard() {
    return Container(
      padding: EdgeInsets.all(12.w), // ✅ Slightly reduced padding for better fit
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ Prevents column from expanding infinitely
        children: [
          Container(
            width: 60.w, // ✅ Slightly smaller to save vertical space
            height: 60.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/avatar1.png'), // ✅ Your custom profile picture
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          const Text(
            'Manchester',
            textAlign: TextAlign.center,
            maxLines: 1, // ✅ Prevents title overflow
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'A community-focused hockey club dedicated to developing players, building strong teams, and creating opportunities for athletes of all skill levels.',
            textAlign: TextAlign.center,
            maxLines: 4, // ✅ Limits description lines to prevent flex overflow
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11.sp,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}