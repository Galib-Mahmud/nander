import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/endpoint/api_endpoint.dart';
import '../controller/profile_controller.dart';

class ProfileUpdateScreen extends StatelessWidget {
  const ProfileUpdateScreen({super.key});

  void _showImageSourceBottomSheet(BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161E30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Profile Photo',
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.h),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF4D94FF)),
                  title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF4D94FF)),
                  title: const Text('Take a Photo', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = ProfileController.to;

    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050810),
        foregroundColor: Colors.white,
        title: const Text('Profile Update', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.nameController.text.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4D94FF)));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),

              // Avatar with camera icon
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 140.w,
                      height: 140.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161E30),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF253045), width: 3),
                      ),
                      child: ClipOval(
                        child: controller.selectedImage.value != null
                            ? Image.file(
                                controller.selectedImage.value!,
                                fit: BoxFit.cover,
                              )
                            : (controller.profileImageUrl.value.isNotEmpty
                                ? Image.network(
                                    ApiEndpoint.resolveImageUrl(controller.profileImageUrl.value) ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Center(child: Icon(Icons.person, size: 70, color: Colors.white70)),
                                  )
                                : const Center(child: Icon(Icons.person, size: 70, color: Colors.white70))),
                      ),
                    ),
                    Positioned(
                      bottom: 4.w,
                      right: 4.w,
                      child: GestureDetector(
                        onTap: () => _showImageSourceBottomSheet(context, controller),
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4D94FF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 20.w),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),
              Center(
                child: Text(
                  controller.email.value,
                  style: TextStyle(color: const Color(0xFF8B95A5), fontSize: 14.sp),
                ),
              ),

              SizedBox(height: 30.h),

              const _SectionLabel(text: 'Full Name'),
              SizedBox(height: 8.h),
              _CustomTextField(
                hintText: 'Enter your name',
                controller: controller.nameController,
              ),

              SizedBox(height: 20.h),
              const _SectionLabel(text: 'Bio'),
              SizedBox(height: 8.h),
              _CustomTextField(
                hintText: 'Enter bio...',
                controller: controller.bioController,
                maxLines: 3,
              ),

              SizedBox(height: 20.h),
              const _SectionLabel(text: 'Address'),
              SizedBox(height: 8.h),
              _CustomTextField(
                hintText: 'Enter address...',
                controller: controller.addressController,
              ),

              SizedBox(height: 20.h),
              const _SectionLabel(text: 'Profile Image'),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () => _showImageSourceBottomSheet(context, controller),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161E30),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFF253045)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1522),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFF253045)),
                        ),
                        child: Text(
                          controller.selectedImage.value != null
                              ? 'Change image'
                              : 'Choose image',
                          style: TextStyle(color: const Color(0xFF8B95A5), fontSize: 14.sp),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          controller.selectedImage.value != null
                              ? controller.selectedImage.value!.path.split('/').last
                              : (controller.profileImageUrl.value.isNotEmpty ? 'Current photo loaded' : 'No file chosen'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 36.h),

              // Save Button
              Obx(() {
                final isSaving = controller.isUpdating.value;
                return SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : () => controller.updateProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D94FF),
                      disabledBackgroundColor: const Color(0xFF4D94FF).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                  ),
                );
              }),

              SizedBox(height: 30.h),
            ],
          ),
        );
      }),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w500),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final int maxLines;
  const _CustomTextField({
    required this.hintText,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161E30),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF253045)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: Colors.white, fontSize: 15.sp),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          hintText: hintText,
          hintStyle: TextStyle(color: const Color(0xFF8B95A5), fontSize: 15.sp),
        ),
      ),
    );
  }
}