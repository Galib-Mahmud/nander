import 'package:flutter/material.dart';
import 'package:get/get.dart';
// You can reuse the widgets from terms_screen.dart or copy them here.
// For simplicity, I'm assuming you copy the helper classes (_SectionHeader, _BulletPoint) here.

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050810),
        foregroundColor: Colors.white,
        title: Text(
          'Privacy Policy'.tr,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Privacy Policy describes how we collect, use, and protect your information when you use our Money Management App ("we," "our," or "us"). By using the app, you agree to this policy.'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            const _SectionHeader(title: 'Information We Collect'),
            const _BulletPoint(
                text:
                    'Personal details such as your name, email, and phone number.'),
            const _BulletPoint(
                text:
                    'Financial data you enter manually, such as income, expenses, and savings goals.'),
            const _BulletPoint(
                text: 'Device information (for performance and analytics).'),
            const SizedBox(height: 30),
            const _SectionHeader(title: 'How We Use Your Data'),
            const _BulletPoint(
                text: 'To track and visualize your spending and income.'),
            const _BulletPoint(
                text:
                    'To personalize insights, reminders, and budgeting tips.'),
            const _BulletPoint(
                text: 'To improve app performance and user experience.'),
            const SizedBox(height: 30),
            const _SectionHeader(title: 'Data Security'),
            Text(
              'We use encryption and secure storage to keep your information safe. Your data is never sold to third parties.'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            const _SectionHeader(title: 'Third-Party Services'),
            Text(
              'Some app features may integrate with secure third-party services (like Google or Apple Sign-In). We never share your financial data without your consent.'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            const _SectionHeader(title: 'Your Control'),
            Text(
              'You can delete your account and all data anytime from Settings → Delete Account.'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// Copy these helper classes here if not importing from terms_screen.dart
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title.tr,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic)),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white, fontSize: 16)),
          Expanded(
              child: Text(text.tr,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, height: 1.4))),
        ],
      ),
    );
  }
}
