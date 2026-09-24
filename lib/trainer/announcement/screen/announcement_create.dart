import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/announcement_controller.dart';
import '../controller/announcement_model.dart';

class AnnouncementCreateScreen extends StatefulWidget {
  final AnnouncementModel? announcement; // Pass if editing

  const AnnouncementCreateScreen({super.key, this.announcement});

  @override
  State<AnnouncementCreateScreen> createState() => _AnnouncementCreateScreenState();
}

class _AnnouncementCreateScreenState extends State<AnnouncementCreateScreen> {
  final controller = AnnouncementController.to;
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.announcement != null) {
      isEditing = true;
      titleCtrl.text = widget.announcement!.title;
      descCtrl.text = widget.announcement!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        foregroundColor: Colors.white,
        title: Text(isEditing ? 'Edit Announcement' : 'New Announcement',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Keep up with your rewards and rankings.',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14.sp)),
            SizedBox(height: 30.h),

            // Title Field
            Text('Announcement Title', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
            SizedBox(height: 8.h),
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter title',
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1A2236),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
            ),
            SizedBox(height: 20.h),

            // Description Field
            Text('Description', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
            SizedBox(height: 8.h),
            TextField(
              controller: descCtrl,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter description....',
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1A2236),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),
            SizedBox(height: 30.h),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty) {
                    Get.snackbar('Error', 'Please fill all fields');
                    return;
                  }

                  if (isEditing && widget.announcement != null) {
                    controller.updateAnnouncement(widget.announcement!.id, titleCtrl.text, descCtrl.text);
                  } else {
                    controller.createAnnouncement(titleCtrl.text, descCtrl.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D94FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(isEditing ? 'Update' : 'Save',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}