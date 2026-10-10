import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/controller/club_controller.dart';
import '../../routes/route_name.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole; // 'admin' | 'trainer'
  final AuthController authController = AuthController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 3-segment progress bar — step 2 of 3
              Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: i < 2 ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text('Step 2 of 3'.tr,
                  style: const TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 24),
              Text(
                'How will you use Train Up?'.tr,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Select your primary role to customize your dashboard.'.tr,
                style: const TextStyle(color: Colors.white54, fontSize: 15),
              ),
              const SizedBox(height: 24),

              // Club Administrator Card
              GestureDetector(
                onTap: () => setState(() => _selectedRole = 'admin'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedRole == 'admin'
                        ? const Color(0xFF4D94FF).withValues(alpha: 0.1)
                        : const Color(0xFF1A2236),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedRole == 'admin'
                          ? const Color(0xFF4D94FF)
                          : const Color(0xFF2A3550),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Club Administrator'.tr,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                          'Manage your club, teams, trainers, schedules, and performance.'.tr,
                          style:
                              const TextStyle(color: Colors.white54, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Trainer Card
              GestureDetector(
                onTap: () => setState(() => _selectedRole = 'trainer'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedRole == 'trainer'
                        ? const Color(0xFF4D94FF).withValues(alpha: 0.1)
                        : const Color(0xFF1A2236),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedRole == 'trainer'
                          ? const Color(0xFF4D94FF)
                          : const Color(0xFF2A3550),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trainer'.tr,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                          'Create training plans, track player progress, and run sessions.'.tr,
                          style:
                              const TextStyle(color: Colors.white54, fontSize: 14)),
                    ],
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFF2A3550), width: 1),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: Text('Back'.tr,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_selectedRole == null) {
                          Get.snackbar(
                            'Selection Required'.tr,
                            'Please select a role to continue'.tr,
                            backgroundColor: const Color(0xFF1A2236),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        // Persist the choice onto AuthController — signup()
                        // will send this value as-is.
                        authController.role.value =
                            _selectedRole == 'admin' ? 'CLUB_ADMIN' : 'TRAINER';

                        if (_selectedRole == 'admin') {
                          // Club admins skip club selection entirely
                          Get.toNamed(RouteName.login,
                              arguments: {'startTab': 'signup'});
                        } else {
                          // Trainers get an optional club-picking step
                          ClubController.to.reset();
                          Get.toNamed(RouteName.selectClub);
                        }
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4D94FF),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Continue'.tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward,
                                color: Colors.white, size: 20),
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
