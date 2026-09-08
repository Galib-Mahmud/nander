import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/route_name.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool isPasswordVisible = false;
  bool isReTypePasswordVisible = false;

  final TextEditingController emailController = TextEditingController(text: 'Rhebhek@gmail.com');
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController retypePasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
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
                  width: 120, // লোগোটি যেন স্ক্রিন জুড়ে বড় না হয়ে যায়, তাই শুধু এইটুকু দেওয়া হলো
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 50),

              // Tab Toggle (Login / Sign Up)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2236),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A3550)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isLogin = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isLogin ? const Color(0xFF0A0E1A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: isLogin ? Border.all(color: const Color(0xFF2A3550)) : null,
                          ),
                          child: Center(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: isLogin ? Colors.white : Colors.white54,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isLogin = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: !isLogin ? const Color(0xFF0A0E1A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: !isLogin ? Border.all(color: const Color(0xFF2A3550)) : null,
                          ),
                          child: Center(
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: !isLogin ? Colors.white : Colors.white54,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Email Field
              const Text(
                  'Email Address',
                  style: TextStyle(color: Color(0xFF8B95A5), fontSize: 16, fontWeight: FontWeight.w500)
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: const Color(0xFF1A2236),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A3550))
                ),
                child: TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    hintText: 'Rhebhek@gmail.com',
                    hintStyle: TextStyle(color: Color(0xFF8B95A5), fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password Field
              const Text(
                  'Password',
                  style: TextStyle(color: Color(0xFF8B95A5), fontSize: 16, fontWeight: FontWeight.w500)
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: const Color(0xFF1A2236),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A3550))
                ),
                child: TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    hintText: '********',
                    hintStyle: const TextStyle(color: Color(0xFF8B95A5), fontSize: 16),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => isPasswordVisible = !isPasswordVisible),
                      child: Icon(
                          isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: const Color(0xFF8B95A5)
                      ),
                    ),
                  ),
                ),
              ),

              // Login Mode: Forgot Password & Error
              if (isLogin) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(RouteName.forgotPassword);
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Color(0xFF4D94FF), fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4444), size: 18),
                    SizedBox(width: 6),
                    Text(
                        'Please enter correct password',
                        style: TextStyle(color: Color(0xFFFF4444), fontSize: 14)
                    ),
                  ],
                ),
              ],

              // Signup Mode: Re-Type Password
              if (!isLogin) ...[
                const SizedBox(height: 20),
                const Text(
                    'Re Type Password',
                    style: TextStyle(color: Color(0xFF8B95A5), fontSize: 16, fontWeight: FontWeight.w500)
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFF1A2236),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2A3550))
                  ),
                  child: TextField(
                    controller: retypePasswordController,
                    obscureText: !isReTypePasswordVisible,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      hintText: '********',
                      hintStyle: const TextStyle(color: Color(0xFF8B95A5), fontSize: 16),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => isReTypePasswordVisible = !isReTypePasswordVisible),
                        child: Icon(
                            isReTypePasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF8B95A5)
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // Login/Signup Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                    color: const Color(0xFF4D94FF),
                    borderRadius: BorderRadius.circular(14)
                ),
                child: GestureDetector(
                  onTap: () {

                  Get.toNamed(RouteName.home);
                  },
                  child: Center(
                    child: Text(
                      isLogin ? 'Login' : 'Sign up',
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              // Signup Mode: Privacy Policy
              if (!isLogin) ...[
                const SizedBox(height: 20),
                const Text(
                  'By clicking the "sign up" button, you accept the terms of the Privacy Policy.',
                  style: TextStyle(color: Color(0xFF8B95A5), fontSize: 14, fontStyle: FontStyle.italic, height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}