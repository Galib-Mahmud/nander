import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050810),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Stack(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: Icon(Icons.notifications_outlined, color: Colors.white.withOpacity(0.7), size: 22.w),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                  child: Center(
                    child: Text('3', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Icon(Icons.more_vert, color: Colors.white, size: 22.w),
          ),
          SizedBox(width: 20.w),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              children: [
                // Received message
                _buildReceivedMessage('Hey, are you coming to hockey training today?'),
                SizedBox(height: 16.h),
                // Sent message
                _buildSentMessage('Yeah! What time does it start?', '11:23 PM'),
                SizedBox(height: 16.h),
                // Received message
                _buildReceivedMessage("At 5 PM. We're focusing on skating and shooting today."),
                SizedBox(height: 16.h),
                // Sent message
                _buildSentMessage('Nice! I really need to improve my shooting.', null),
                SizedBox(height: 16.h),
                // Received message
                _buildReceivedMessage("Same here. Let's practice together after the session."),
                SizedBox(height: 16.h),
                // Sent message
                _buildSentMessage('Nice! I really need to improve my shooting.', null),
                SizedBox(height: 16.h),
                // Received message
                _buildReceivedMessage("At 5 PM. We're focusing on skating and shooting today."),
                SizedBox(height: 16.h),
                // Sent message
                _buildSentMessage('Nice! I really need to improve my shooting.', null),
              ],
            ),
          ),
          // Input area
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(26.r),
                      border: Border.all(color: const Color(0xFF1F2937)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 20.w),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Type Here...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14.sp),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4D94FF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4D94FF).withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: AssetImage('assets/images/avatar1.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentMessage(String text, String? time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFF1F2937)),
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
        if (time != null) ...[
          SizedBox(height: 4.h),
          Text(
            '• $time',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11.sp),
          ),
        ],
      ],
    );
  }
}