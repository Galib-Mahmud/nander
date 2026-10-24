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
  // Rate & review form
  int _rating = 0; // 0 = not rated yet, otherwise 1..5
  bool _reviewSubmitted = false;
  final TextEditingController _reviewCtrl = TextEditingController();
  final TextEditingController _evaluationCtrl = TextEditingController();
  final TextEditingController _feedbackCtrl = TextEditingController();
  final TextEditingController _goalCtrl = TextEditingController();
  final TextEditingController _yourReportCtrl = TextEditingController();
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
    _reviewCtrl.dispose();
    _evaluationCtrl.dispose();
    _feedbackCtrl.dispose();
    _goalCtrl.dispose();
    _yourReportCtrl.dispose();
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
                'Session Overview'.tr,
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
                'Coaching Rationale'.tr,
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
                    'Exercises (${s.exercises.length})'.tr,
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
                              : 'Mark as Completed'.tr,
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

            // Rate & Review
            _buildReviewSection(),
            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }

  // ─── Rate & Review ───────────────────────────────────────────────
  static const List<String> _ratingLabels = [
    'Poor',
    'Fair',
    'Good',
    'Very good',
    'Excellent',
  ];

  static const Color _starColor = Color(0xFFFFB800);

  Future<void> _submitReview() async {
    if (_rating == 0) {
      Get.snackbar(
        'Rating required',
        'Please select a star rating first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    final ok = await _controller.submitSessionReview(
      sessionId: widget.session.id,
      rating: _rating,
      review: _reviewCtrl.text.trim(),
      evaluation: _evaluationCtrl.text.trim(),
      feedback: _feedbackCtrl.text.trim(),
      trainingGoal: _goalCtrl.text.trim(),
      reportTopic: _selectedTopic,
      yourReport: _yourReportCtrl.text.trim(),
    );
    if (ok && mounted) {
      setState(() => _reviewSubmitted = true);
    }
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate & Review Session',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2236),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFF2A3550)),
          ),
          child: _reviewSubmitted ? _buildReviewThanks() : _buildReviewForm(),
        ),
      ],
    );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatingPicker(),
        _buildReviewField(
          label: 'Review',
          controller: _reviewCtrl,
          hint: 'Write a short review of this session...',
        ),
        _buildReviewField(
          label: 'Evaluation',
          controller: _evaluationCtrl,
          hint: 'How did the players perform overall?',
        ),
        _buildReviewField(
          label: 'Feedback',
          controller: _feedbackCtrl,
          hint: 'Feedback on drills, intensity or structure...',
        ),
        _buildReviewField(
          label: 'Training Goal',
          controller: _goalCtrl,
          hint: 'What was the goal and was it achieved?',
        ),
        SizedBox(height: 14.h),
        DropdownButtonFormField<String>(
          initialValue: _selectedTopic,
          dropdownColor: const Color(0xFF1A2236),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Report Topic',
            labelStyle:
            TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF2A3550)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF2A3550)),
            ),
          ),
          items: _topics
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedTopic = val);
          },
        ),
        _buildReviewField(
          label: 'Your Report',
          controller: _yourReportCtrl,
          hint: 'Enter observation, notes or issues...',
          maxLines: 3,
        ),
        SizedBox(height: 18.h),
        Obx(() {
          final loading = _controller.isSubmittingReview.value;
          return ElevatedButton(
            onPressed: loading ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4D94FF),
              disabledBackgroundColor: const Color(0xFF2A3550),
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: loading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              'Submit Review'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }),
      ],
    );
  }

  /// 5-star picker. Tap a star to set rating 1..5.
  Widget _buildRatingPicker() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _rating > 0
              ? _starColor.withValues(alpha: 0.5)
              : const Color(0xFF2A3550),
        ),
      ),
      child: Column(
        children: [
          Text(
            'How was this session?',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: AnimatedScale(
                    scale: filled ? 1.12 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      filled
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 40.w,
                      color: filled
                          ? _starColor
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 10.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _rating == 0
                  ? 'Tap a star to rate'
                  : '$_rating/5 · ${_ratingLabels[_rating - 1]}',
              key: ValueKey(_rating),
              style: TextStyle(
                color: _rating == 0
                    ? Colors.white.withValues(alpha: 0.5)
                    : _starColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 2,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13.sp,
              ),
              filled: true,
              fillColor: const Color(0xFF0A0E1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF2A3550)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF2A3550)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF4D94FF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewThanks() {
    return Column(
      children: [
        Icon(Icons.check_circle_rounded,
            color: const Color(0xFF10B981), size: 44.w),
        SizedBox(height: 10.h),
        Text(
          'Thanks for your review!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            return Icon(
              i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 24.w,
              color: i < _rating
                  ? _starColor
                  : Colors.white.withValues(alpha: 0.3),
            );
          }),
        ),
      ],
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