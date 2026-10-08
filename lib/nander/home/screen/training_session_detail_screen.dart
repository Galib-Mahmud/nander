import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/training_session_controller.dart';
import '../model/training_session_model.dart';

class TrainingSessionDetailScreen extends StatefulWidget {
  final TrainingSessionModel session;
  const TrainingSessionDetailScreen({super.key, required this.session});

  @override
  State<TrainingSessionDetailScreen> createState() =>
      _TrainingSessionDetailScreenState();
}

class _TrainingSessionDetailScreenState
    extends State<TrainingSessionDetailScreen> {
  final TrainingSessionController _controller =
      TrainingSessionController.to;

  late bool _isCompleted;
  final TextEditingController _notesCtrl = TextEditingController();
  String _selectedTopic = 'Tactical Feedback';
  final List<String> _topics = [
    'Tactical Feedback',
    'Player Injury',
    'Late Issue',
    'Equipment Missing',
    'General Note',
  ];

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.session.isCompleted;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final dateStr = s.createdAt != null
        ? '${s.createdAt!.day}/${s.createdAt!.month}/${s.createdAt!.year}'
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        foregroundColor: Colors.white,
        title: Text(
          s.displayTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge and Title Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2236),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFF2A3550)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4D94FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          s.displayFocus.toUpperCase(),
                          style: TextStyle(
                            color: const Color(0xFF4D94FF),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (dateStr.isNotEmpty)
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12.sp,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    s.displayTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Meta Row
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _buildChip(
                        icon: Icons.timer_outlined,
                        label: "${s.durationMinutes} min",
                      ),
                      _buildChip(
                        icon: Icons.shield_outlined,
                        label: s.teamName,
                      ),
                      _buildChip(
                        icon: Icons.speed,
                        label: s.displayDifficulty,
                      ),
                      _buildChip(
                        icon: Icons.crop_square,
                        label: s.displayFieldsize,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Overview Section
            if (s.sessionOverview != null && s.sessionOverview!.isNotEmpty) ...[
              Text(
                'Session Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2236),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFF2A3550)),
                ),
                child: Text(
                  s.sessionOverview!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // Rationale Section
            if (s.coachingRationale != null &&
                s.coachingRationale!.isNotEmpty) ...[
              Text(
                'Coaching Rationale',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2236),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFF2A3550)),
                ),
                child: Text(
                  s.coachingRationale!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // Exercises
            if (s.exercises.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercises (${s.exercises.length})',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${s.durationMinutes} min total',
                    style: TextStyle(
                      color: const Color(0xFF4D94FF),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              ...s.exercises.map((ex) => _buildExerciseCard(ex)),
              SizedBox(height: 16.h),
            ],

            // Complete Toggle Button
            Obx(() {
              final loading = _controller.isUpdating.value;
              return GestureDetector(
                onTap: loading
                    ? null
                    : () async {
                        final ok = await _controller.toggleSessionComplete(
                            s.id, !_isCompleted);
                        if (ok) {
                          setState(() {
                            _isCompleted = !_isCompleted;
                          });
                        }
                      },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: _isCompleted
                        ? const Color(0xFF10B981)
                        : const Color(0xFF1A2236),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _isCompleted
                          ? const Color(0xFF10B981)
                          : const Color(0xFF2A3550),
                    ),
                  ),
                  child: Center(
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isCompleted
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                color: Colors.white,
                                size: 20.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                _isCompleted
                                    ? 'Completed Session'
                                    : 'Mark as Completed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            }),
            SizedBox(height: 20.h),

            // Submit Session Report
            Text(
              'Session Report & Notes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2236),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFF2A3550)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTopic,
                    dropdownColor: const Color(0xFF1A2236),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Report Topic',
                      labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide:
                            const BorderSide(color: Color(0xFF2A3550)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide:
                            const BorderSide(color: Color(0xFF2A3550)),
                      ),
                    ),
                    items: _topics
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTopic = val);
                    },
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter observation, feedback or notes...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide:
                            const BorderSide(color: Color(0xFF2A3550)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide:
                            const BorderSide(color: Color(0xFF2A3550)),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Obx(() {
                    final isReporting =
                        _controller.isSubmittingReport.value;
                    return ElevatedButton(
                      onPressed: isReporting
                          ? null
                          : () async {
                              if (_notesCtrl.text.trim().isEmpty) {
                                Get.snackbar('Error', 'Please enter notes');
                                return;
                              }
                              final ok =
                                  await _controller.submitSessionReport(
                                s.id,
                                _selectedTopic,
                                _notesCtrl.text.trim(),
                              );
                              if (ok) {
                                _notesCtrl.clear();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D94FF),
                        minimumSize: Size(double.infinity, 44.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: isReporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Submit Report',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFF2A3550)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 14.w),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel ex) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2236),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF2A3550)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF4D94FF).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${ex.exerciseNumber}',
                    style: TextStyle(
                      color: const Color(0xFF4D94FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  ex.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${ex.durationMinutes}\'',
                style: TextStyle(
                  color: const Color(0xFF4D94FF),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (ex.description != null && ex.description!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              ex.description!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
          ],
          if (ex.coachingPoints.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              'Coaching Points:',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            ...ex.coachingPoints.map(
              (cp) => Padding(
                padding: EdgeInsets.only(bottom: 3.h, left: 6.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: TextStyle(
                            color: const Color(0xFF4D94FF), fontSize: 13.sp)),
                    Expanded(
                      child: Text(
                        cp,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
