import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'profile_update_screen.dart';

class AddNewTeamScreen extends StatelessWidget {
  const AddNewTeamScreen({super.key});

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
          'Add New Team',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Team Name'),
            SizedBox(height: 8.h),
            _buildTextField('Full Team name'),
            SizedBox(height: 20.h),
            _buildLabel('Team Bio'),
            SizedBox(height: 8.h),
            _buildTextField('Enter Team Bio....'),
            SizedBox(height: 20.h),
            _buildLabel('Lead Trainer'),
            SizedBox(height: 8.h),
            _buildTextField('Enter Lead Trainer Name..'),
            SizedBox(height: 20.h),
            _buildLabel('Lead Trainer Email'),
            SizedBox(height: 8.h),
            _buildTextField('Enter Lead Trainer Email'),
            SizedBox(height: 20.h),
            _buildLabel('Address'),
            SizedBox(height: 8.h),
            _buildTextField('Type here.....'),
            SizedBox(height: 20.h),
            _buildLabel('Upload Image'),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF050810),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFF1F2937)),
                    ),
                    child: const Text(
                      'Choose your image',
                      style: TextStyle(color: Color(0xFF8B95A5), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            GestureDetector(
              onTap: () {
                Get.to(() => const ProfileUpdateScreen());
              },
              child: Container(
                width: double.infinity,
                height: 56.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF4D94FF),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: const Center(
                  child: Text(
                    'Save',
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
        ),
      ),
    );
  }
}