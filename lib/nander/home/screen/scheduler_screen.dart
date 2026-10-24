import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nander/nander/home/screen/schedule_screen.dart';

import '../../widget/controller/app_drawer_controller.dart';
import '../controller/training_session_controller.dart';

class NewTrainingPlanScreen extends StatefulWidget {
  const NewTrainingPlanScreen({super.key});

  @override
  State<NewTrainingPlanScreen> createState() => _NewTrainingPlanScreenState();
}

class _NewTrainingPlanScreenState extends State<NewTrainingPlanScreen> {
  final TrainingSessionController _controller = TrainingSessionController.to;

  // Wizard steps
  // 0: Period (weeks)  1: Sessions per week  2: Focus
  // 3: Difficulty + Field size  4: Training type + Duration (optional)
  // 5: Session overview (API response)
  static const int _stepPeriod = 0;
  static const int _stepSessions = 1;
  static const int _stepFocus = 2;
  static const int _stepSetup = 3;
  static const int _stepOptional = 4;
  static const int _stepOverview = 5;
  static const int _totalWizardSteps = 5;

  int _currentStep = _stepPeriod;

  final TextEditingController _reportCtrl = TextEditingController();
  String _selectedReportTopic = 'Late Issue';
  final List<String> _reportTopics = [
    'Late Issue',
    'Tactical Feedback',
    'Player Injury',
    'Equipment Missing',
    'General Note',
  ];

  // (weeks, subtitle)
  final List<(int, String)> _periodOptions = const [
    (2, 'Start strong'),
    (3, 'Build momentum'),
    (4, 'Improve your game'),
    (5, 'Reach your potential'),
  ];

  // (trainings per week, subtitle)
  final List<(int, String)> _sessionsOptions = const [
    (1, 'Light & consistent'),
    (2, 'Balanced training'),
    (3, 'High intensity'),
  ];

  @override
  void initState() {
    super.initState();
    // New plan: reset previous selection
    _controller.selectedDurationWeeks.value = 2;
    _controller.selectedTrainingsPerWeek.value = 1;
    _controller.selectedFocus.value = 'ATTACK';
    _controller.selectedDifficulty.value = 'EASY';
    _controller.selectedFieldsize.value = 'FULL_FIELD';
    _controller.targetDurationMinutes.value = 0; // 0 = do not send (optional)
    _controller.trainingTypeCtrl.clear();
    _controller.fetchActiveTeams(); // first active team is auto-selected
  }

  @override
  void dispose() {
    _reportCtrl.dispose();
    super.dispose();
  }

  // ─── Navigation ──────────────────────────────────────────────────
  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _handleNextStep() async {
    // Last input step -> POST everything at once
    if (_currentStep == _stepOptional) {
      final session = await _controller.createTrainingSession();
      if (session != null && mounted) {
        setState(() => _currentStep = _stepOverview);
      }
      return;
    }

    setState(() => _currentStep++);
  }

  // ─── Build ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_currentStep < _stepOverview) _buildProgress(),
          Expanded(
            child: Obx(() {
              if (_controller.isCreating.value) {
                return _buildGenerating();
              }
              return _buildCurrentStep();
            }),
          ),
          if (_currentStep < _stepOverview) _buildBottomBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF050810),
      elevation: 0,
      leading: IconButton(
        icon:
        const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: _goBack,
      ),
      title: Obx(() {
        final team = _controller.selectedTeam.value;
        final teamName = team?.name ?? '';
        final session = _controller.currentSession.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentStep == _stepOverview
                  ? (session?.displayTitle ?? 'Training Session'.tr)
                  : 'New Training Plan'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (teamName.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                teamName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );
      }),
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
                color: Colors.white.withValues(alpha: 0.7),
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
        GestureDetector(
          onTap: () {
            try {
              Get.find<AppDrawerController>().open();
            } catch (_) {}
          },
          child: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: const Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        SizedBox(width: 20.w),
      ],
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step @step of @total'.trParams({
              'step': '${_currentStep + 1}',
              'total': '$_totalWizardSteps',
            }),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: List.generate(_totalWizardSteps, (i) {
              return [
                _buildProgressSegment(i),
                if (i != _totalWizardSteps - 1) SizedBox(width: 8.w),
              ];
            }).expand((e) => e).toList(),
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
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildGenerating() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF4D94FF)),
          SizedBox(height: 20.h),
          Text(
            'Generating AI Training Plan...'.tr,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Designing tactical drills & session structure'.tr,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLast = _currentStep == _stepOptional;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050810),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF1F2937).withValues(alpha: 0.5),
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goBack,
            child: Container(
              height: 56.h,
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2A3550)),
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Center(
                child: Text(
                  'Back'.tr,
                  style: const TextStyle(
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
              onTap: _handleNextStep,
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF4D94FF),
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast ? 'Generate Plan'.tr : 'Continue'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      isLast ? Icons.auto_awesome : Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: isLast ? 20 : 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case _stepPeriod:
        return _buildStepPeriod();
      case _stepSessions:
        return _buildStepSessions();
      case _stepFocus:
        return _buildStepFocus();
      case _stepSetup:
        return _buildStepSetup();
      case _stepOptional:
        return _buildStepOptional();
      case _stepOverview:
        return _buildSessionOverview();
      default:
        return const SizedBox();
    }
  }

  Widget _stepTitle(String text, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 8.h),
          Text(
            subtitle.tr,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14.sp,
            ),
          ),
        ],
        SizedBox(height: 28.h),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        text.tr,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Simple selectable card (title + subtitle), used by step 1 and step 2
  Widget _buildChoiceCard(
      String title,
      String subtitle,
      bool isSelected, {
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
            isSelected ? const Color(0xFF4D94FF) : const Color(0xFF1F2937),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle.tr,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Period (durationWeeks) ───────────────────────────────
  Widget _buildStepPeriod() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Which period do you want to train for?'.tr),
          Obx(() {
            final selected = _controller.selectedDurationWeeks.value;
            // Rows with intrinsic height instead of GridView + fixed
            // childAspectRatio, so the cards grow with their content and
            // never overflow.
            Widget cardAt(int i) {
              final o = _periodOptions[i];
              return _buildChoiceCard(
                '${o.$1} ${'weeks'.tr}',
                o.$2.tr,
                selected == o.$1,
                onTap: () => _controller.selectedDurationWeeks.value = o.$1,
              );
            }

            final rows = <Widget>[];
            for (var i = 0; i < _periodOptions.length; i += 2) {
              rows.add(
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: cardAt(i)),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: i + 1 < _periodOptions.length
                              ? cardAt(i + 1)
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Column(children: rows);
          }),
        ],
      ),
    );
  }

  // ── Step 2: Sessions per week (trainingsPerWeek) ─────────────────
  Widget _buildStepSessions() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('How many training sessions per week?'.tr),
          Obx(() {
            final selected = _controller.selectedTrainingsPerWeek.value;
            return Column(
              children: _sessionsOptions.map((o) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildChoiceCard(
                    '${o.$1}× ${'per week'.tr}',
                    o.$2.tr,
                    selected == o.$1,
                    onTap: () =>
                    _controller.selectedTrainingsPerWeek.value = o.$1,
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // ── Step 3: Focus ────────────────────────────────────────────────
  Widget _buildStepFocus() {
    final trainingTypes = [
      (
      'Attacking',
      'Depth, tempo and goal-focused play',
      Icons.sports_hockey,
      'ATTACK'
      ),
      (
      'Defending',
      'Stay compact, apply pressure',
      Icons.shield_outlined,
      'DEFENCE'
      ),
      (
      'Transition',
      'Quickly switch between attack/defense',
      Icons.sync,
      'TRANSITION'
      ),
      (
      'Technique',
      'Receiving, passing, dribbling',
      Icons.auto_awesome,
      'TECHNIQUE'
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('What would you like to train?'.tr),
          Obx(() {
            final selectedFocus = _controller.selectedFocus.value;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: trainingTypes.map((t) {
                return _buildTrainingTypeCard(
                  t.$1.tr,
                  t.$2.tr,
                  t.$3,
                  selectedFocus == t.$4,
                  onTap: () => _controller.selectedFocus.value = t.$4,
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // ── Step 4: Difficulty + Field size ──────────────────────────────
  Widget _buildStepSetup() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Set up the session'.tr),
          _sectionLabel('Difficulty Level'.tr),
          Obx(() {
            final diff = _controller.selectedDifficulty.value;
            return Row(
              children: [
                _buildOptionChip('EASY', 'Easy'.tr, diff == 'EASY', () {
                  _controller.selectedDifficulty.value = 'EASY';
                }, const Color(0xFF10B981)),
                SizedBox(width: 10.w),
                _buildOptionChip('MEDIUM', 'Medium'.tr, diff == 'MEDIUM', () {
                  _controller.selectedDifficulty.value = 'MEDIUM';
                }, const Color(0xFFFFB800)),
                SizedBox(width: 10.w),
                _buildOptionChip('HARD', 'Hard'.tr, diff == 'HARD', () {
                  _controller.selectedDifficulty.value = 'HARD';
                }, const Color(0xFFEF4444)),
              ],
            );
          }),
          SizedBox(height: 28.h),
          _sectionLabel('Field Setup'.tr),
          Obx(() {
            final fs = _controller.selectedFieldsize.value;
            return Row(
              children: [
                _buildOptionChip('FULL_FIELD', 'Full Field'.tr, fs == 'FULL_FIELD',
                        () {
                      _controller.selectedFieldsize.value = 'FULL_FIELD';
                    }, const Color(0xFF4D94FF)),
                SizedBox(width: 10.w),
                _buildOptionChip('HALF_FIELD', 'Half Field'.tr, fs == 'HALF_FIELD',
                        () {
                      _controller.selectedFieldsize.value = 'HALF_FIELD';
                    }, const Color(0xFF4D94FF)),
                SizedBox(width: 10.w),
                _buildOptionChip('CAROUSEL', 'Carousel'.tr, fs == 'CAROUSEL', () {
                  _controller.selectedFieldsize.value = 'CAROUSEL';
                }, const Color(0xFF4D94FF)),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Step 5: Optional (Training type + Duration) ──────────────────
  Widget _buildStepOptional() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle(
            'Anything else?'.tr,
            subtitle: 'Both fields are optional. You can generate right away.'.tr,
          ),
          _sectionLabel('Training Type (Optional)'.tr),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: TextField(
              controller: _controller.trainingTypeCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Circle entry, Tactical Session...'.tr,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 28.h),
          _sectionLabel('Target Duration (Optional)'.tr),
          Obx(() {
            final currentDur = _controller.targetDurationMinutes.value;
            final durations = [60, 90, 120, 160];
            return Row(
              children: durations.map((d) {
                final isSel = currentDur == d;
                return Expanded(
                  child: GestureDetector(
                    // Tap again to deselect (optional)
                    onTap: () =>
                    _controller.targetDurationMinutes.value = isSel ? 0 : d,
                    child: Container(
                      margin: EdgeInsets.only(right: d != 160 ? 8.w : 0),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isSel
                            ? const Color(0xFF4D94FF)
                            : const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSel
                              ? const Color(0xFF4D94FF)
                              : const Color(0xFF1F2937),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$d ${'min'.tr}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight:
                            isSel ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptionChip(String value, String label, bool isSelected,
      VoidCallback onTap, Color activeColor) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.2)
                : const Color(0xFF111827),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFF1F2937),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : Colors.white70,
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingTypeCard(
      String title, String subtitle, IconData icon, bool isSelected,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
            isSelected ? const Color(0xFF4D94FF) : const Color(0xFF1F2937),
            width: isSelected ? 2 : 1,
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
                      color:
                      isSelected ? const Color(0xFF4D94FF) : Colors.white,
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
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Session Overview (API response) ──────────────────────────────
  Widget _buildSessionHeader({
    required String difficulty,
    required String focus,
    required String sessionTitle,
    required double titleSize,
    required FontWeight titleWeight,
    required int duration,
    required String teamName,
    required String fieldsize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTag(
              difficulty.toLowerCase(),
              const Color(0xFF1F2937),
              textColor: Colors.white,
            ),
            SizedBox(width: 8.w),
            _buildTag(focus.toLowerCase(), const Color(0xFFDC2626)),
            SizedBox(width: 8.w),
            _buildTag(
              'ai',
              const Color(0xFF1F2937),
              icon: Icons.auto_awesome,
              textColor: const Color(0xFF4D94FF),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          sessionTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize,
            fontWeight: titleWeight,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(Icons.access_time,
                color: Colors.white.withValues(alpha: 0.6), size: 16.w),
            SizedBox(width: 6.w),
            Text(
              'Thu 27 Aug · 16:30 · $duration ${'min'.tr}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(Icons.location_on_outlined,
                color: Colors.white.withValues(alpha: 0.6), size: 16.w),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                '$teamName · $fieldsize',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13.sp,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionOverview() {
    return Obx(() {
      final session = _controller.currentSession.value;
      final sessionTitle = session?.displayTitle ?? 'Training Session'.tr;
      final duration = session?.durationMinutes ?? 0;
      final difficulty =
          session?.displayDifficulty ?? _controller.selectedDifficulty.value;
      final focus = session?.displayFocus ?? _controller.selectedFocus.value;
      final teamName =
          session?.teamName ?? _controller.selectedTeam.value?.name ?? '';
      final fieldsize = session?.displayFieldsize ?? 'Full Field';

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
                  _buildSessionHeader(
                    difficulty: difficulty,
                    focus: focus,
                    sessionTitle: sessionTitle,
                    titleSize: 18,
                    titleWeight: FontWeight.bold,
                    duration: duration,
                    teamName: teamName,
                    fieldsize: fieldsize,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          // Change settings and generate again
                          onTap: () =>
                              setState(() => _currentStep = _stepOptional),
                          child: Container(
                            height: 44.h,
                            decoration: BoxDecoration(
                              border:
                              Border.all(color: const Color(0xFF2A3550)),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Text(
                                'Reschedule'.tr,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.to(
                                  () => const ScheduleScreen(activeTabIndex: 3)),
                          child: Container(
                            height: 44.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4D94FF),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Continue'.tr,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
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

            // Coaching Rationale & Overview Text
            if (session?.sessionOverview != null &&
                session!.sessionOverview!.isNotEmpty) ...[
              _buildOverviewCard('Session Rationale'.tr, session.sessionOverview!),
              SizedBox(height: 12.h),
            ],

            Text(
              'Session Overview'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),

            // Generated exercises
            if (session != null && session.exercises.isNotEmpty)
              ...session.exercises.map((ex) {
                final cue =
                ex.keyCoachingCue != null && ex.keyCoachingCue!.isNotEmpty
                    ? '\nCue: ${ex.keyCoachingCue}'
                    : '';
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildOverviewCard(
                    '${ex.slotName ?? "Exercise ${ex.order}".tr} - ${ex.exerciseName}',
                    '${ex.description ?? "Focus on execution, tactical movement and teamwork.".tr}$cue (${ex.allocatedDuration ?? "${ex.durationMinutes} ${'min'.tr}"})',
                  ),
                );
              }),

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
                  Text(
                    'Report Lead Trainer'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Report Topic'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedReportTopic,
                        dropdownColor: const Color(0xFF111827),
                        style:
                        const TextStyle(color: Colors.white, fontSize: 14),
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: Colors.white.withValues(alpha: 0.6)),
                        isExpanded: true,
                        items: _reportTopics.map((t) {
                          return DropdownMenuItem<String>(
                            value: t,
                            child: Text(t.tr),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedReportTopic = val);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Your Report'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
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
                    child: TextField(
                      controller: _reportCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type here...'.tr,
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Obx(() {
                    final isSubmitting = _controller.isSubmittingReport.value;
                    return GestureDetector(
                      onTap: isSubmitting
                          ? null
                          : () async {
                        if (_reportCtrl.text.trim().isEmpty) {
                          Get.snackbar(
                            'Note Required'.tr,
                            'Please type your report message first'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor:
                            Colors.red.withValues(alpha: 0.8),
                            colorText: Colors.white,
                          );
                          return;
                        }
                        final sessionId = session?.id ?? '';
                        if (sessionId.isNotEmpty) {
                          final ok =
                          await _controller.submitSessionReport(
                            sessionId,
                            _selectedReportTopic,
                            _reportCtrl.text.trim(),
                          );
                          if (ok) _reportCtrl.clear();
                        } else {
                          Get.snackbar(
                            'Success'.tr,
                            'Report recorded for current session'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF10B981),
                            colorText: Colors.white,
                          );
                          _reportCtrl.clear();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: isSubmitting
                              ? const Color(0xFF2A3550)
                              : const Color(0xFF4D94FF),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: isSubmitting
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            'Submit Report'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Bottom Session Card with Done Session Button
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
                  _buildSessionHeader(
                    difficulty: difficulty,
                    focus: focus,
                    sessionTitle: sessionTitle,
                    titleSize: 16,
                    titleWeight: FontWeight.w600,
                    duration: duration,
                    teamName: teamName,
                    fieldsize: fieldsize,
                  ),
                  SizedBox(height: 16.h),
                  Obx(() {
                    final isUpdating = _controller.isUpdating.value;
                    return GestureDetector(
                      onTap: isUpdating
                          ? null
                          : () async {
                        final sessionId = session?.id ?? '';
                        if (sessionId.isNotEmpty) {
                          await _controller.toggleSessionComplete(
                              sessionId, true);
                        }
                        Get.to(() =>
                        const ScheduleScreen(activeTabIndex: 3));
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: isUpdating
                              ? const Color(0xFF2A3550)
                              : const Color(0xFF4D94FF),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isUpdating)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            else ...[
                              const Icon(Icons.check,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Done Session'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      );
    });
  }

  Widget _buildTag(String text, Color bgColor,
      {IconData? icon, Color? textColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                color: textColor ?? Colors.white.withValues(alpha: 0.7),
                size: 14.w),
            SizedBox(width: 4.w),
          ],
          Text(
            text.tr,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String title, String description) {
    return Container(
      width: double.infinity,
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
            title.tr,
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
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}