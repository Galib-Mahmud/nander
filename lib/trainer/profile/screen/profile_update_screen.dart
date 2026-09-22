import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';

class ProfileUpdateScreen extends StatelessWidget {
  const ProfileUpdateScreen({super.key});

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
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.nameController.text.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4D94FF)));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: controller.profileImageUrl.value.isNotEmpty
                      ? ClipOval(
                    child: Image.network(
                      controller.profileImageUrl.value,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.shield, size: 120, color: Color(0xFF0A0E1A)),
                    ),
                  )
                      : const Center(child: Icon(Icons.shield, size: 120, color: Color(0xFF0A0E1A))),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  controller.email.value,
                  style: const TextStyle(color: Color(0xFF8B95A5), fontSize: 14),
                ),
              ),
              const SizedBox(height: 40),

              const _SectionLabel(text: 'Club Name'),
              const SizedBox(height: 10),
              _CustomTextField(hintText: 'Full Name', controller: controller.nameController),

              const SizedBox(height: 20),
              const _SectionLabel(text: 'Club Bio'),
              const SizedBox(height: 10),
              _CustomTextField(hintText: 'Enter Club Bio....', controller: controller.bioController),

              const SizedBox(height: 20),
              const _SectionLabel(text: 'Address'),
              const SizedBox(height: 10),
              _CustomTextField(hintText: 'Type here.....', controller: controller.addressController),

              const SizedBox(height: 20),
              const _SectionLabel(text: 'Upload Image'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF161E30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF253045)),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1522),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF253045)),
                  ),
                  child: const Text('Choose your image', style: TextStyle(color: Color(0xFF8B95A5), fontSize: 15)),
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D94FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
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
    return Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500));
  }
}

class _CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  const _CustomTextField({required this.hintText, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161E30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF253045)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF8B95A5), fontSize: 16),
        ),
      ),
    );
  }
}