import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nander/nander/newtrainer/team_details_controller.dart';
import 'package:nander/nander/newtrainer/team_details_model.dart';

import '../core/endpoint/api_endpoint.dart';

/// Opens when a team card is tapped on the TrainerTeam screen.
class TrainerTeamDetailScreen extends StatelessWidget {
  final String teamId;

  /// Shown in the header while the request is still loading.
  final String? initialName;

  const TrainerTeamDetailScreen({
    super.key,
    required this.teamId,
    this.initialName,
  });

  static const _bg = Color(0xFF050810);
  static const _card = Color(0xFF0F172A);
  static const _border = Color(0xFF1E293B);
  static const _blue = Color(0xFF3B82F6);
  static const _muted = Color(0xFF8B95A5);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      TrainerTeamDetailController(teamId),
      tag: teamId,
    );

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(controller),
            Expanded(
              child: Obx(() {
                final team = controller.team.value;

                if (controller.isLoading.value && team == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: _blue),
                  );
                }

                return RefreshIndicator(
                  color: _blue,
                  backgroundColor: const Color(0xFF111827),
                  onRefresh: controller.fetchTeam,
                  child: team == null
                      ? _buildError(controller.errorMessage.value)
                      : _buildContent(team),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────
  Widget _buildHeader(TrainerTeamDetailController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 20.w, 8.h),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Obx(() => Text(
              controller.team.value?.name ?? initialName ?? 'Team',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 120.h),
        Icon(Icons.error_outline, color: _muted, size: 56.w),
        SizedBox(height: 14.h),
        Text(
          message.isEmpty ? 'Team not found' : message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ─── Content ────────────────────────────────────────────────────────
  Widget _buildContent(TrainerTeamDetailModel team) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
      children: [
        _buildInfoCard(team),
        SizedBox(height: 24.h),
        Text(
          'Team readiness',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        _buildProgressCard(team),
        SizedBox(height: 24.h),
        _buildStatRow(team),
        SizedBox(height: 16.h),
        _buildChartCard(team.chartData),
      ],
    );
  }

  // Avatar + name + bio + address
  Widget _buildInfoCard(TrainerTeamDetailModel team) {
    final imageUrl = ApiEndpoint.resolveImageUrl(team.image);
    final hasBio = team.bio != null && team.bio!.trim().isNotEmpty;
    final hasAddress = team.address != null && team.address!.trim().isNotEmpty;

    Widget fallbackIcon() => Center(
      child: Icon(Icons.shield, color: _blue, size: 36.w),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          ClipOval(
            child: Container(
              width: 72.w,
              height: 72.w,
              color: _bg,
              child: imageUrl != null
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallbackIcon(),
              )
                  : fallbackIcon(),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            team.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hasBio) ...[
            SizedBox(height: 10.h),
            Text(
              team.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
          ],
          if (hasAddress) ...[
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined, color: _muted, size: 16.w),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    team.address!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _muted, fontSize: 13.sp),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Name + Progress + % + bar
  Widget _buildProgressCard(TrainerTeamDetailModel team) {
    final percent = team.progressPercentage.clamp(0, 100);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            team.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress',
                  style: TextStyle(color: _muted, fontSize: 14.sp)),
              Text(
                '$percent%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6.h,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(_blue),
            ),
          ),
        ],
      ),
    );
  }

  // Total / Completed / Remaining tiles
  Widget _buildStatRow(TrainerTeamDetailModel team) {
    return Row(
      children: [
        Expanded(child: _statTile('Total', team.totalSessions)),
        SizedBox(width: 12.w),
        Expanded(child: _statTile('Completed', team.completedSessions)),
        SizedBox(width: 12.w),
        Expanded(child: _statTile('Remaining', team.remainingSessions)),
      ],
    );
  }

  Widget _statTile(String label, int value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: _muted, fontSize: 13.sp)),
          SizedBox(height: 6.h),
          Text(
            '$value',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Grouped bars per month: total (muted) vs completed (blue)
  Widget _buildChartCard(List<TeamChartPoint> data) {
    final chartHeight = 120.h;
    final maxValue = data.fold<int>(0, (m, e) => e.total > m ? e.total : m);
    final maxY = maxValue == 0 ? 1 : maxValue;

    Widget bar(int value, Color color) {
      final h = value == 0
          ? 3.0
          : (value / maxY * chartHeight).clamp(3.0, chartHeight).toDouble();
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$value',
            style: TextStyle(color: Colors.white70, fontSize: 11.sp),
          ),
          SizedBox(height: 2.h),
          Container(
            width: 16.w,
            height: h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trainings per month',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _legendDot(const Color(0xFF334155), 'Total'),
              SizedBox(width: 16.w),
              _legendDot(_blue, 'Completed'),
            ],
          ),
          SizedBox(height: 16.h),
          if (data.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Text(
                  'No session data yet',
                  style: TextStyle(color: _muted, fontSize: 13.sp),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data
                  .map(
                    (p) => Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: chartHeight + 20.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            bar(p.total, const Color(0xFF334155)),
                            SizedBox(width: 4.w),
                            bar(p.completed, _blue),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        p.name,
                        style: TextStyle(color: _muted, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(label, style: TextStyle(color: _muted, fontSize: 12.sp)),
      ],
    );
  }
}