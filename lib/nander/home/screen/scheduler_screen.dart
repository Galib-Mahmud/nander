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
  // 0: Team  1: Focus  2: Difficulty + Field size  3: Training type + Duration (optional)
  // 4: Session overview (API response)
  static const int _stepTeam = 0;
  static const int _stepFocus = 1;
  static const int _stepSetup = 2;
  static const int _stepOptional = 3;
  static const int _stepOverview = 4;
  static const int _totalWizardSteps = 4;

  int _currentStep = _stepTeam;

  final TextEditingController _reportCtrl = TextEditingController();
  String _selectedReportTopic = 'Late Issue';
  final List<String> _reportTopics = [
    'Late Issue',
    'Tactical Feedback',
    'Player Injury',
    'Equipment Missing',
    'General Note',
  ];

  @override
  void initState() {
    super.initState();
    // Notun plan: purono selection reset
    _controller.selectedFocus.value = 'ATTACK';
    _controller.selectedDifficulty.value = 'EASY';
    _controller.selectedFieldsize.value = 'FULL_FIELD';
    _controller.targetDurationMinutes.value = 0; // 0 = pathabo na (optional)
    _controller.trainingTypeCtrl.clear();
    _controller.fetchActiveTeams();
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
    // Step 1: team must be selected
    if (_currentStep == _stepTeam && _controller.selectedTeamId.value.isEmpty) {
      Get.snackbar(
        'Select Team',
        'Please select a team to continue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    // Last input step -> ekshathe shob data POST
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
                  ? (session?.displayTitle ?? 'Training Session')
                  : 'New Training Plan',
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
            'Step ${_currentStep + 1} of $_totalWizardSteps',
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
            'Generating AI Training Plan...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Designing tactical drills & session structure',
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
                      isLast ? 'Generate Plan' : 'Continue',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      isLast ? Icons.auto_awesome : Icons.arrow_forward,
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
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case _stepTeam:
        return _buildStepTeam();
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
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 8.h),
          Text(
            subtitle,
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
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Step 1: Team ─────────────────────────────────────────────────
  Widget _buildStepTeam() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Which team is this plan for?'),
          Obx(() {
            if (_controller.isLoadingTeams.value) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF4D94FF),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Loading teams...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (_controller.activeTeams.isEmpty) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFFEF4444), size: 20),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'No active team found.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _controller.fetchActiveTeams(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4D94FF),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final selectedId = _controller.selectedTeamId.value;
            return Column(
              children: _controller.activeTeams.map((team) {
                final isSelected = team.teamId == selectedId;
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildTeamCard(
                    team.name,
                    isSelected,
                    onTap: () => _controller.selectTeam(team),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTeamCard(String name, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF4D94FF) : const Color(0xFF1F2937),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: const Color(0xFF4D94FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: const Icon(Icons.shield, color: Color(0xFF4D94FF)),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Container(
                width: 26.w,
                height: 26.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF4D94FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Focus ────────────────────────────────────────────────
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
          _stepTitle('What would you like to train?'),
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
                  t.$1,
                  t.$2,
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

  // ── Step 3: Difficulty + Field size ──────────────────────────────
  Widget _buildStepSetup() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Set up the session'),
          _sectionLabel('Difficulty Level'),
          Obx(() {
            final diff = _controller.selectedDifficulty.value;
            return Row(
              children: [
                _buildOptionChip('EASY', 'Easy', diff == 'EASY', () {
                  _controller.selectedDifficulty.value = 'EASY';
                }, const Color(0xFF10B981)),
                SizedBox(width: 10.w),
                _buildOptionChip('MEDIUM', 'Medium', diff == 'MEDIUM', () {
                  _controller.selectedDifficulty.value = 'MEDIUM';
                }, const Color(0xFFFFB800)),
                SizedBox(width: 10.w),
                _buildOptionChip('HARD', 'Hard', diff == 'HARD', () {
                  _controller.selectedDifficulty.value = 'HARD';
                }, const Color(0xFFEF4444)),
              ],
            );
          }),
          SizedBox(height: 28.h),
          _sectionLabel('Field Setup'),
          Obx(() {
            final fs = _controller.selectedFieldsize.value;
            return Row(
              children: [
                _buildOptionChip('FULL_FIELD', 'Full Field', fs == 'FULL_FIELD',
                    () {
                  _controller.selectedFieldsize.value = 'FULL_FIELD';
                }, const Color(0xFF4D94FF)),
                SizedBox(width: 10.w),
                _buildOptionChip('HALF_FIELD', 'Half Field', fs == 'HALF_FIELD',
                    () {
                  _controller.selectedFieldsize.value = 'HALF_FIELD';
                }, const Color(0xFF4D94FF)),
                SizedBox(width: 10.w),
                _buildOptionChip('CAROUSEL', 'Carousel', fs == 'CAROUSEL', () {
                  _controller.selectedFieldsize.value = 'CAROUSEL';
                }, const Color(0xFF4D94FF)),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Step 4: Optional (Training type + Duration) ──────────────────
  Widget _buildStepOptional() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle(
            'Anything else?',
            subtitle: 'Both fields are optional. You can generate right away.',
          ),
          _sectionLabel('Training Type (Optional)'),
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
                hintText: 'e.g. Circle entry, Tactical Session...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 28.h),
          _sectionLabel('Target Duration (Optional)'),
          Obx(() {
            final currentDur = _controller.targetDurationMinutes.value;
            final durations = [60, 90, 120, 160];
            return Row(
              children: durations.map((d) {
                final isSel = currentDur == d;
                return Expanded(
                  child: GestureDetector(
                    // Abar tap korle deselect hobe (optional)
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
                          '$d min',
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

  // ── Step 5: Session Overview (API response) ──────────────────────
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
              'Thu 27 Aug · 16:30 · $duration min',
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
      final sessionTitle = session?.displayTitle ?? 'Training Session';
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
                          // Settings change kore abar generate korar jonno
                          onTap: () =>
                              setState(() => _currentStep = _stepOptional),
                          child: Container(
                            height: 44.h,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFF2A3550)),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: const Center(
                              child: Text(
                                'Reschedule',
                                style: TextStyle(
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
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Continue',
                                  style: TextStyle(
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
              _buildOverviewCard('Session Rationale', session.sessionOverview!),
              SizedBox(height: 12.h),
            ],

            const Text(
              'Session Overview',
              style: TextStyle(
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
                    '${ex.slotName ?? "Exercise ${ex.order}"} - ${ex.exerciseName}',
                    '${ex.description ?? "Focus on execution, tactical movement and teamwork."}$cue (${ex.allocatedDuration ?? "${ex.durationMinutes} min"})',
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
                    style: TextStyle(color: Colors.white, fontSize: 14),
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
                            child: Text(t),
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
                  const Text(
                    'Your Report',
                    style: TextStyle(color: Colors.white, fontSize: 14),
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
                      decoration: const InputDecoration(
                        hintText: 'Type here...',
                        hintStyle: TextStyle(color: Colors.white54),
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
                                  'Note Required',
                                  'Please type your report message first',
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
                                  'Success',
                                  'Report recorded for current session',
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
                              : const Text(
                                  'Submit Report',
                                  style: TextStyle(
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
                              const Text(
                                'Done Session',
                                style: TextStyle(
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
            text,
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
