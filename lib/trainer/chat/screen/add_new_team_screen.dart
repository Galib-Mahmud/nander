import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/endpoint/api_endpoint.dart';
import '../../team/controller/team_controller.dart';
import '../../team/controller/team_model.dart';

class AddNewTeamScreen extends StatefulWidget {
  final TeamModel? team; // if passed, we are in Edit mode

  const AddNewTeamScreen({super.key, this.team});

  @override
  State<AddNewTeamScreen> createState() => _AddNewTeamScreenState();
}

class _AddNewTeamScreenState extends State<AddNewTeamScreen> {
  final TeamController controller = TeamController.to;

  late final TextEditingController nameCtrl;
  late final TextEditingController bioCtrl;
  late final TextEditingController trainerNameCtrl;
  late final TextEditingController sendEmailCtrl;
  late final TextEditingController addressCtrl;

  bool get isEditing => widget.team != null;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.team?.name ?? '');
    bioCtrl = TextEditingController(text: widget.team?.bio ?? '');
    trainerNameCtrl = TextEditingController(text: widget.team?.trainerName ?? '');
    sendEmailCtrl = TextEditingController(text: widget.team?.sendEmail ?? '');
    addressCtrl = TextEditingController(text: widget.team?.address ?? '');
    controller.clearSelectedImage();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    bioCtrl.dispose();
    trainerNameCtrl.dispose();
    sendEmailCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  void _showImageSourceBottomSheet() {
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
                  'Select Team Image',
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
          isEditing ? 'Edit Team' : 'Add New Team',
          style: const TextStyle(
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
            _buildLabel('Team Name *'),
            SizedBox(height: 8.h),
            _buildTextField(hint: 'Full Team name', controller: nameCtrl),
            SizedBox(height: 20.h),

            _buildLabel('Team Bio'),
            SizedBox(height: 8.h),
            _buildTextField(hint: 'Enter Team Bio....', controller: bioCtrl, maxLines: 3),
            SizedBox(height: 20.h),

            _buildLabel('Lead Trainer Name'),
            SizedBox(height: 8.h),
            _buildTextField(hint: 'Enter Lead Trainer Name..', controller: trainerNameCtrl),
            SizedBox(height: 20.h),

            _buildLabel('Lead Trainer Email'),
            SizedBox(height: 8.h),
            _buildTextField(hint: 'Enter Lead Trainer Email', controller: sendEmailCtrl, keyboardType: TextInputType.emailAddress),
            SizedBox(height: 20.h),

            _buildLabel('Address'),
            SizedBox(height: 8.h),
            _buildTextField(hint: 'Type here.....', controller: addressCtrl),
            SizedBox(height: 20.h),

            _buildLabel('Upload Image'),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: _showImageSourceBottomSheet,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: Obx(() {
                  final file = controller.selectedImage.value;
                  final existingImage = widget.team?.image;

                  return Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF050810),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFF1F2937)),
                        ),
                        child: Text(
                          file != null ? 'Change image' : 'Choose image',
                          style: const TextStyle(color: Color(0xFF8B95A5), fontSize: 14),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          file != null
                              ? file.path.split('/').last
                              : (existingImage != null && existingImage.isNotEmpty)
                                  ? 'Current image loaded'
                                  : 'No image selected',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                        ),
                      ),
                      if (file != null || (existingImage != null && existingImage.isNotEmpty))
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: file != null
                              ? Image.file(file, width: 36.w, height: 36.w, fit: BoxFit.cover)
                              : Image.network(
                                  ApiEndpoint.resolveImageUrl(existingImage) ?? '',
                                  width: 36.w,
                                  height: 36.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54),
                                ),
                        ),
                    ],
                  );
                }),
              ),
            ),
            SizedBox(height: 36.h),

            // Submit Button
            Obx(() {
              final isBusy = controller.isSubmitting.value;

              return SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: isBusy
                      ? null
                      : () {
                          if (nameCtrl.text.trim().isEmpty) {
                            Get.snackbar('Error', 'Please enter a team name');
                            return;
                          }

                          if (isEditing) {
                            controller.updateTeam(
                              id: widget.team!.id,
                              name: nameCtrl.text,
                              bio: bioCtrl.text,
                              address: addressCtrl.text,
                              sendEmail: sendEmailCtrl.text,
                              trainerName: trainerNameCtrl.text,
                            );
                          } else {
                            controller.createTeam(
                              name: nameCtrl.text,
                              bio: bioCtrl.text,
                              address: addressCtrl.text,
                              sendEmail: sendEmailCtrl.text,
                              trainerName: trainerNameCtrl.text,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D94FF),
                    disabledBackgroundColor: const Color(0xFF4D94FF).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                  child: isBusy
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isEditing ? 'Update Team' : 'Save Team',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            }),
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
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        ),
      ),
    );
  }
}