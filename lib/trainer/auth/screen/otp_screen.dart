import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final AuthController controller = AuthController.to;
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

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
              Center(
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1628),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: const Color(0xFF4D94FF).withOpacity(0.2), blurRadius: 30, spreadRadius: 5)],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('TU', style: TextStyle(color: Color(0xFF4D94FF), fontSize: 42, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                      Text('TRAIN UP', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),
              const Text('Enter Your OTP', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              const Text('Enter Code', style: TextStyle(color: Color(0xFF8B95A5), fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48, height: 64,
                    child: TextField(
                      controller: controller.otpControllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '-',
                        hintStyle: const TextStyle(color: Color(0xFF8B95A5), fontSize: 22),
                        filled: true,
                        fillColor: const Color(0xFF1A2236),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A3550))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A3550))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4D94FF), width: 2)),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              Obx(() => Center(
                child: GestureDetector(
                  onTap: controller.isLoading.value ? null : controller.resendCode,
                  child: const Text('Resend code', style: TextStyle(color: Color(0xFF4D94FF), fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              )),
              const SizedBox(height: 24),

              Obx(() => GestureDetector(
                onTap: controller.isLoading.value ? null : controller.verifyOtp,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(color: const Color(0xFF4D94FF), borderRadius: BorderRadius.circular(14)),
                  child: Center(
                    child: controller.isLoading.value
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
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