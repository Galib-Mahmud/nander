import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ClubProfileScreen extends StatelessWidget {
  const ClubProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manchester United',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Notification Bell
          Stack(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2236),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2A3550)),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.white.withOpacity(0.7),
                  size: 20.w,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5252),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          // More Options
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2236),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2A3550)),
            ),
            child: Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 20.w,
            ),
          ),
          SizedBox(width: 20.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'Keep up with your rewards and rankings.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Club Info Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2236),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFF2A3550)),
                ),
                child: Column(
                  children: [
                    // Club Logo
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.shield,
                          color: const Color(0xFF0A0E1A),
                          size: 50.w,
                        ),
                        // Replace with actual image:
                        // child: Image.asset(
                        //   'assets/icons/club_logo.png',
                        //   width: 60.w,
                        //   height: 60.w,
                        // ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    const Text(
                      'Manchester United',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'A community-focused hockey club dedicated to developing players, building strong teams, and creating opportunities for athletes of all skill levels.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14.sp,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    const Text(
                      'Coach : Michel Anderson',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Club Readiness Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Club readiness',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'All',
                        style: TextStyle(
                          color: const Color(0xFF4D94FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildReadinessCard('Nordkap U18 Elite', '22/24 sessions', 81, 92),
                  _buildReadinessCard('Nordkap U18 Elite', '22/24 sessions', 81, 92),
                  _buildReadinessCard('Nordkap U18 Elite', '22/24 sessions', 81, 92),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Session Stats
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSessionCard('84', '+13 vs last'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildSessionCard('84', '+13 vs last'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildSessionCard('84', '+13 vs last'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Training Chart
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2236),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFF2A3550)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trainingen per week (Laatste 8w)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      height: 150.h,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          labelStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11.sp,
                          ),
                          majorGridLines: const MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          isVisible: false,
                          majorGridLines: const MajorGridLines(width: 0),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: false),
                        series: <CartesianSeries>[
                          ColumnSeries<TrainingData, String>(
                            dataSource: [
                              TrainingData('W1', 20),
                              TrainingData('W2', 45),
                              TrainingData('W3', 65),
                              TrainingData('W4', 40),
                              TrainingData('W5', 80),
                              TrainingData('W6', 60),
                              TrainingData('W7', 85),
                              TrainingData('W8', 95),
                            ],
                            xValueMapper: (TrainingData data, _) => data.week,
                            yValueMapper: (TrainingData data, _) => data.value,
                            color: const Color(0xFF4D94FF),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildReadinessCard(String title, String subtitle, int score, int percentage) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1424),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF2A3550)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E1A),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFF2A3550)),
                ),
                child: Text(
                  score.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: const Color(0xFF2A3550),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4D94FF),
                    ),
                    minHeight: 6.h,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(String value, String change) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2236),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF2A3550)),
      ),
      child: Column(
        children: [
          Text(
            'Session',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            change,
            style: const TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class TrainingData {
  TrainingData(this.week, this.value);
  final String week;
  final double value;
}