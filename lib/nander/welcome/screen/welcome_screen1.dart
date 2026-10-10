import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/route_name.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/hockey_field.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.4)),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // ✅ Logo Image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Elevate Your Hockey Training'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Plan smarter training sessions, develop your teams, and manage your hockey club from one powerful platform.'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                const Spacer(),

                Padding(
                  padding: const EdgeInsets.all(30),
                  child: GestureDetector(
                    onTap: () => Get.toNamed(RouteName.wellcome2),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D94FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () => Get.toNamed(RouteName.login),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Text(
                      'I Already Have an Account'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
