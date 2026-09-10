import 'package:flutter/material.dart';
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
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
            const Text(
              'This Privacy Policy describes how we collect, use, and protect your information when you use our Money Management App ("we," "our," or "us"). By using the app, you agree to this policy.',
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            _SectionHeader(title: 'Information We Collect'),
            _BulletPoint(text: 'Personal details such as your name, email, and phone number.'),
            _BulletPoint(text: 'Financial data you enter manually, such as income, expenses, and savings goals.'),
            _BulletPoint(text: 'Device information (for performance and analytics).'),
            const SizedBox(height: 30),
            _SectionHeader(title: 'How We Use Your Data'),
            _BulletPoint(text: 'To track and visualize your spending and income.'),
            _BulletPoint(text: 'To personalize insights, reminders, and budgeting tips.'),
            _BulletPoint(text: 'To improve app performance and user experience.'),
            const SizedBox(height: 30),
            _SectionHeader(title: 'Data Security'),
            const Text(
              'We use encryption and secure storage to keep your information safe. Your data is never sold to third parties.',
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            _SectionHeader(title: 'Third-Party Services'),
            const Text(
              'Some app features may integrate with secure third-party services (like Google or Apple Sign-In). We never share your financial data without your consent.',
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            _SectionHeader(title: 'Your Control'),
            const Text(
              'You can delete your account and all data anytime from Settings → Delete Account.',
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
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
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
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
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4))),
        ],
      ),
    );
  }
}