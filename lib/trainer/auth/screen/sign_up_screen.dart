import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isLogin = false;
  bool isPassword1Visible = false;
  bool isPassword2Visible = false;
  final TextEditingController emailController = TextEditingController(text: 'Rhebhek@gmail.com');
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController retypePasswordController = TextEditingController();

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
              // Logo
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1628),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4D94FF).withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'TU',
                        style: TextStyle(
                          color: Color(0xFF4D94FF),
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        'TRAIN UP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // Tab Toggle
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
              // Email Label
              const Text(
                'Email Address',
                style: TextStyle(
                  color: Color(0xFF8B95A5),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              // Email Field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2236),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A3550)),
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
              // Sign Up Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF4D94FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Privacy Policy Text
              const Text(
                'By clicking the "sign up" button, you accept the terms of the Privacy Policy.',
                style: TextStyle(
                  color: Color(0xFF8B95A5),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}