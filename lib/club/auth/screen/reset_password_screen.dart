import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/route_name.dart';
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool isPassword1Visible = false;
  bool isPassword2Visible = false;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController retypePasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    retypePasswordController.dispose();
    super.dispose();
  }

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

              // ✅ একদম ক্লিন লোগো (কোনো Container, Shadow বা Error Builder নেই)
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 120, // লোগোটি যেন স্ক্রিন জুড়ে বড় না হয়ে যায়
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 50),

              // Title
              const Text(
                'Reset Your Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Password Label
              const Text(
                'Password',
                style: TextStyle(
                  color: Color(0xFF8B95A5),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              // Password Field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2236),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A3550)),
                ),
                child: TextField(
                  controller: passwordController,
                  obscureText: !isPassword1Visible,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    hintText: '********',
                    hintStyle: const TextStyle(color: Color(0xFF8B95A5), fontSize: 16),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => isPassword1Visible = !isPassword1Visible),
                      child: Icon(
                        isPassword1Visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFF8B95A5),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Re Type Password Label
              const Text(
                'Re Type Password',
                style: TextStyle(
                  color: Color(0xFF8B95A5),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              // Re Type Password Field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2236),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A3550)),
                ),
                child: TextField(
                  controller: retypePasswordController,
                  obscureText: !isPassword2Visible,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    hintText: '********',
                    hintStyle: const TextStyle(color: Color(0xFF8B95A5), fontSize: 16),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => isPassword2Visible = !isPassword2Visible),
                      child: Icon(
                        isPassword2Visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFF8B95A5),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Confirm Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF4D94FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: GestureDetector(
                  onTap: () {

                   Get.toNamed(RouteName.otp);
                  },
                  child: const Center(
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}