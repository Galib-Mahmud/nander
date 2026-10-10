import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> faqQuestions = [
      "How can I create a training session?".tr,
      "Can I customize training sessions for my team?".tr,
      "Can trainers assign sessions to players?".tr,
      "How can I track player training progress?".tr,
      "Can clubs manage multiple teams and trainers?".tr,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050810),
        foregroundColor: Colors.white,
        title: Text(
          "FAQ's".tr,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: faqQuestions.map((question) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2945),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2A3555),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  title: Text(
                    question,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                  onTap: () {
                    // Add expand/collapse logic here
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}