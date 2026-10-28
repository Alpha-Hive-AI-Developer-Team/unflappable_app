// lib/features/mission_history/screens/mission_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/features/Home/model/mission.dart';
import 'package:unflappable/features/Home/model/mission_task.dart';
import 'package:unflappable/features/Mission%20History/missionHistory_notifier.dart';
import 'package:unflappable/features/Mission%20History/missionHistory_state.dart';
import 'package:unflappable/features/widgets/Common/helping_appBar.dart';

// ---------------------------------------------------------------------------
// SCREEN
// ---------------------------------------------------------------------------

class MissionHistoryScreen extends ConsumerWidget {
  const MissionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(missionHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // UP-54: use the same header everywhere else uses, instead of a
            // one-off with mismatched icon/typography.
            const HelpingAppBar(title: 'Mission History'),
            Expanded(child: _buildBody(context, ref, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    MissionHistoryState state,
  ) {
    // ── Loading ──
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // ── Error ──
    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.errorMessage!,
              style: AppTextStyles.bodyMD.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ScreenUtils.vMd),
            TextButton(
              onPressed: () =>
                  ref.read(missionHistoryProvider.notifier).refresh(),
              child: Text(
                'Retry',
                style: AppTextStyles.labelMD.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    // ── Empty ──
    if (state.missions.isEmpty) {
      return Center(
        child: Text(
          'No missions yet.',
          style: AppTextStyles.bodyMD.copyWith(color: AppColors.bodyText),
        ),
      );
    }

    // ── List ──
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(missionHistoryProvider.notifier).refresh(),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtils.lg,
          vertical: ScreenUtils.vMd,
        ),
        itemCount: state.missions.length,
        separatorBuilder: (_, _) => SizedBox(height: ScreenUtils.vMd),
        itemBuilder: (context, index) =>
            _MissionCard(mission: state.missions[index]),
      ),
    );
  }
}


// ---------------------------------------------------------------------------
// MISSION CARD
// ---------------------------------------------------------------------------

class _MissionCard extends StatelessWidget {
  final Mission mission;

  const _MissionCard({required this.mission});

  /// e.g. DateTime → "Apr 14, 2026"
  String get _formattedDate {
    final value = mission.date ?? DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[value.month - 1]} ${value.day}, ${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
      ),
      padding: EdgeInsets.all(ScreenUtils.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formattedDate,
                style: AppTextStyles.bodySM.copyWith(color: AppColors.bodyText),
              ),
              _StatusBadge(mission: mission),
            ],
          ),

          SizedBox(height: ScreenUtils.vSm),

          // ── Mission objective (maps to your `objective` field) ──
          Text(
            mission.objective,
            style: AppTextStyles.headingMD.copyWith(
              color: AppColors.headingText,
            ),
          ),

          SizedBox(height: ScreenUtils.vSm),

          // ── Task list ──
          ...mission.tasks.map(
            (task) => Padding(
              padding: EdgeInsets.only(top: ScreenUtils.vXs),
              child: _TaskRow(task: task),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// STATUS BADGE  (Done | 67%)
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final Mission mission;

  const _StatusBadge({required this.mission});

  @override
  Widget build(BuildContext context) {
    // Uses mission.isDone and mission.progress from your existing model
    if (mission.isDone || mission.isAllCompleted) {
      return Text(
        'Done',
        style: AppTextStyles.labelSM.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final percent = (mission.progress * 100).round();
    return Text(
      '$percent%',
      style: AppTextStyles.labelSM.copyWith(
        color: AppColors.bodyText,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TASK ROW
// ---------------------------------------------------------------------------

class _TaskRow extends StatelessWidget {
  final MissionTask task;

  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Checkbox icon ──
        // UN-62: one fixed-size circle for both states, with the checkmark
        // drawn inside it — avoids the Icon-glyph-vs-border-circle size
        // mismatch the two different widgets previously produced.
        Container(
          width: ScreenUtils.iconMd,
          height: ScreenUtils.iconMd,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: task.isCompleted ? AppColors.primary : AppColors.borderGrey,
              width: 1.5,
            ),
          ),
          child: task.isCompleted
              ? Icon(
                  Icons.check_rounded,
                  size: ScreenUtils.iconMd * 0.65,
                  color: AppColors.primary,
                )
              : null,
        ),

        SizedBox(width: ScreenUtils.sm),

        // ── Task title ──
        Expanded(
          child: Text(
            task.title,
            style: AppTextStyles.bodyMD.copyWith(
              color: task.isCompleted
                  ? AppColors.bodyText
                  : AppColors.labelText,
              decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              decorationColor: AppColors.bodyText,
            ),
          ),
        ),
      ],
    );
  }
}
