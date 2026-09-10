import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../club/home/screen/schedule_screen.dart';

// ✅ IMPORTANT: Update this path to match your actual ScheduleScreen location
// import 'package:nander/club/home/screen/schedule_screen.dart';

class NewTrainingPlanScreen extends StatefulWidget {
  const NewTrainingPlanScreen({super.key});

  @override
  State<NewTrainingPlanScreen> createState() => _NewTrainingPlanScreenState();
}

class _NewTrainingPlanScreenState extends State<NewTrainingPlanScreen> {
  int _currentStep = 0; // 0: Step 1, 1: Step 2, 2: Step 3, 3: Session Overview
  String? _selectedPeriod;
  String? _selectedSessions;
  String? _selectedTrainingType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050810),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentStep == 3 ? 'Neutral zone regroups' : 'New Training Plan',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Nordkap U18 Elite',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
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
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.white.withOpacity(0.7),
                  size: 22.w,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
            child: Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 22.w,
            ),
          ),
          SizedBox(width: 20.w),
        ],
      ),
      body: Column(
        children: [
          if (_currentStep < 3) ...[
            // Progress Indicator
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${_currentStep + 1} of 4',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _buildProgressSegment(0),
                      SizedBox(width: 8.w),
                      _buildProgressSegment(1),
                      SizedBox(width: 8.w),
                      _buildProgressSegment(2),
                      SizedBox(width: 8.w),
                      _buildProgressSegment(3),
                    ],
                  ),
                ],
              ),
            ),
          ],
          // Content based on step
          Expanded(
            child: _buildCurrentStep(),
          ),
          // Bottom Navigation Buttons
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep--);
                    }
                  },
                  child: Container(
                    height: 56.h,
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2A3550)),
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    child: const Center(
                      child: Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_currentStep < 3) {
                        setState(() => _currentStep++);
                      }
                    },
                    child: Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D94FF),
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSegment(int index) {
    final isActive = index <= _currentStep;
    return Expanded(
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildSessionOverview();
      default:
        return const SizedBox();
    }
  }

  // Step 1: Which period do you want to train for?
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Which period do you want to train for?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 32.h),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              _buildPeriodCard('2 weeks', 'Short focus period', true),
              _buildPeriodCard('3 weeks', 'One block', false, hasCheckmark: true),
              _buildPeriodCard('4 weeks', 'Quarter', false),
              _buildPeriodCard('5 weeks', 'Half season', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(String title, String subtitle, bool isSelected, {bool hasCheckmark = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected ? const Color(0xFF4D94FF) : const Color(0xFF1F2937),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          if (hasCheckmark)
            Positioned(
              right: 12.w,
              top: 12.h,
              child: Icon(
                Icons.check,
                color: Colors.white.withOpacity(0.6),
                size: 20.w,
              ),
            ),
        ],
      ),
    );
  }

  // Step 2: How many training sessions per week?
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How many training sessions per week?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 32.h),
          _buildSessionCard('1× per week', 'Light & consistent', true),
          SizedBox(height: 12.h),
          _buildSessionCard('2× per week', 'Balanced training', false),
          SizedBox(height: 12.h),
          _buildSessionCard('3× per week', 'High intensity', false),
        ],
      ),
    );
  }

  Widget _buildSessionCard(String title, String subtitle, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected ? const Color(0xFF4D94FF) : const Color(0xFF1F2937),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: What would you like to train?
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What would you like to train in the coming period?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 32.h),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildTrainingTypeCard(
                'Attacking',
                'Depth, tempo and goal-focused play',
                Icons.eleven_mp,
                true,
              ),
              _buildTrainingTypeCard(
                'Defending',
                'Stay compact, apply pressure',
                Icons.shield,
                false,
              ),
              _buildTrainingTypeCard(
                'Transition',
                'Quickly switch between attack/defense',
                Icons.sync,
                false,
              ),
              _buildTrainingTypeCard(
                'Technique',
                'Receiving, passing, dribbling',
                Icons.auto_awesome,
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingTypeCard(String title, String subtitle, IconData icon, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected ? const Color(0xFF4D94FF) : const Color(0xFF1F2937),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF050810),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24.w,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              right: 12.w,
              top: 12.h,
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF4D94FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Step 4: Session Overview
  Widget _buildSessionOverview() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Session Card
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildTag('medium', Colors.black),
                    SizedBox(width: 8.w),
                    _buildTag('high intensity', const Color(0xFFDC2626)),
                    SizedBox(width: 8.w),
                    _buildTag('ai', Colors.black, icon: Icons.auto_awesome),
                  ],
                ),
                SizedBox(height: 12.h),
                const Text(
                  'Edge work & tight turns',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white.withOpacity(0.6), size: 16.w),
                    SizedBox(width: 6.w),
                    Text(
                      'Thu 27 Aug · 16:30 · 75 min',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.6), size: 16.w),
                    SizedBox(width: 6.w),
                    Text(
                      'Nordkap U14 · Skating',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF2A3550)),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: const Center(
                          child: Text(
                            'Reschedule',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // ✅ FIXED: Continue Button with Navigation to activeTabIndex 3
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => const ScheduleScreen(activeTabIndex: 3));
                        },
                        child: Container(
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4D94FF),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Continue',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          const Text(
            'Session Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          _buildOverviewCard('Stick Skills - Session 1', 'Improve ball control, dribbling, and quick stick movements.'),
          SizedBox(height: 12.h),
          _buildOverviewCard('Passing & Receiving - Session 2', 'Improve ball control, dribbling, and quick stick movements.'),
          SizedBox(height: 12.h),
          _buildOverviewCard('Speed & Agility - Session 3', 'Develop acceleration, footwork, balance, and reaction speed.'),
          SizedBox(height: 24.h),

          // Report Section
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report Lead Trainer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.h),
                const Text(
                  'Report Topic',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 52.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF050810),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFF1F2937)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Late Issue',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.white.withOpacity(0.6)),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                const Text(
                  'Your Report',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 52.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF050810),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFF1F2937)),
                  ),
                  child: const TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type here...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4D94FF),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Center(
                    child: Text(
                      'Submit Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Bottom Session Card
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildTag('medium', Colors.black),
                    SizedBox(width: 8.w),
                    _buildTag('high intensity', const Color(0xFFDC2626)),
                    SizedBox(width: 8.w),
                    _buildTag('ai', Colors.black, icon: Icons.auto_awesome),
                  ],
                ),
                SizedBox(height: 12.h),
                const Text(
                  'Edge work & tight turns',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white.withOpacity(0.6), size: 16.w),
                    SizedBox(width: 6.w),
                    Text(
                      'Thu 27 Aug · 16:30 · 75 min',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.6), size: 16.w),
                    SizedBox(width: 6.w),
                    Text(
                      'Nordkap U14 · Skating',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // ✅ FIXED: Done Session Button with Navigation to activeTabIndex 3
                GestureDetector(
                  onTap: () {
                    Get.to(() => const ScheduleScreen(activeTabIndex: 3));
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4D94FF),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Done Session',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor == Colors.black ? const Color(0xFF1F2937) : bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white.withOpacity(0.7), size: 14.w),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              color: bgColor == Colors.black ? Colors.white : Colors.white,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String title, String description) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}