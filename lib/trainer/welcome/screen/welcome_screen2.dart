import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controller/auth_controller.dart';
import '../../routes/route_name.dart';

class NameInputScreen extends StatelessWidget {
  const NameInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = AuthController.to;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 3-segment progress bar — step 1 of 3
              Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: i == 0 ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              const Text('Step 1 of 3', style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 24),
              const Text(
                'What should we call you?',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter your name to personalize your hockey training experience.',
                style: TextStyle(color: Colors.white54, fontSize: 15),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2236),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF2A3550), width: 1),
                ),
                child: TextField(
                  controller: controller.nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Your full name',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 16),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF2A3550), width: 1),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Center(
                        child: Text('Back', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (controller.nameController.text.trim().isEmpty) {
                          Get.snackbar(
                            'Name Required',
                            'Please enter your name to continue',
                            backgroundColor: const Color(0xFF1A2236),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        Get.toNamed(RouteName.onboarding);
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4D94FF),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Continue', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}