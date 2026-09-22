import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = AuthController.to;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(child: Image.asset('assets/images/logo.png', width: 120, fit: BoxFit.contain)),
              const SizedBox(height: 50),
              const Text('Forgot Password', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                "Enter your email and we'll send you a code to reset your password.",
                style: TextStyle(color: Color(0xFF8B95A5), fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 30),

              const Text('Email Address', style: TextStyle(color: Color(0xFF8B95A5), fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(color: const Color(0xFF1A2236), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A3550))),
                child: TextField(
                  controller: controller.forgotEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    hintText: 'you@example.com',
                    hintStyle: TextStyle(color: Color(0xFF8B95A5), fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Obx(() => Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(color: const Color(0xFF4D94FF), borderRadius: BorderRadius.circular(14)),
                child: GestureDetector(
                  onTap: controller.isLoading.value ? null : controller.forgotPassword,
                  child: Center(
                    child: controller.isLoading.value
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Send Code', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}