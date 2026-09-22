import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool isPassword1Visible = false;
  bool isPassword2Visible = false;
  final AuthController controller = AuthController.to;

  @override
  Widget build(BuildContext context) {
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
              const Text('Reset Your Password', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // ─── Step indicator text ───────────────────────────
              Obx(() => Text(
                controller.resetOtpVerified.value
                    ? 'Enter your new password below.'
                    : "Enter your email — we'll send a code to confirm the change.",
                style: const TextStyle(color: Color(0xFF8B95A5), fontSize: 14, height: 1.4),
              )),
              const SizedBox(height: 20),

              // ─── Email field — only shown before OTP is verified ──
              Obx(() {
                if (controller.resetOtpVerified.value) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Email Address', style: TextStyle(color: Color(0xFF8B95A5), fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2236),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2A3550)),
                      ),
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
                    const SizedBox(height: 20),
                  ],
                );
              }),

              // ─── Password fields — only shown after OTP is verified ──
              Obx(() {
                if (!controller.resetOtpVerified.value) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Password', style: TextStyle(color: Color(0xFF8B95A5), fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(color: const Color(0xFF1A2236), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A3550))),
                      child: TextField(
                        controller: controller.newPasswordController,
                        obscureText: !isPassword1Visible,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          hintText: '********',
                          hintStyle: const TextStyle(color: Color(0xFF8B95A5), fontSize: 16),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => isPassword1Visible = !isPassword1Visible),
                            child: Icon(isPassword1Visible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF8B95A5)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('Re Type Password', style: TextStyle(color: Color(0xFF8B95A5), fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(color: const Color(0xFF1A2236), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A3550))),
                      child: TextField(
                        controller: controller.confirmNewPasswordController,
                        obscureText: !isPassword2Visible,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          hintText: '********',
                          hintStyle: const TextStyle(color: Color(0xFF8B95A5), fontSize: 16),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => isPassword2Visible = !isPassword2Visible),
                            child: Icon(isPassword2Visible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF8B95A5)),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 40),

              // ─── Button — branches based on flow step ─────────
              Obx(() => Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(color: const Color(0xFF4D94FF), borderRadius: BorderRadius.circular(14)),
                child: GestureDetector(
                  onTap: controller.isLoading.value
                      ? null
                      : (controller.resetOtpVerified.value
                      ? controller.setNewPassword
                      : controller.forgotPassword),
                  child: Center(
                    child: controller.isLoading.value
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(
                      controller.resetOtpVerified.value ? 'Confirm' : 'Send Code',
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                    ),
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