import 'dart:ui';

import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';
import 'package:unflappable/features/Home/Provider/Home%20Provider/home_notifier.dart';
import 'package:unflappable/features/Home/Provider/Home%20Provider/home_state.dart';
import 'package:unflappable/features/Home/UI/stat_card.dart';
import 'package:unflappable/features/Home/model/mission.dart';
import 'package:unflappable/features/Home/model/mission_task.dart';
import 'package:unflappable/features/widgets/Common/setting_dialog.dart';
import 'package:unflappable/features/widgets/Common/snackbar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final userState = ref.watch(userProvider);
    final notifier = ref.read(homeProvider.notifier);

    ref.listen<HomeState>(homeProvider, (previous, next) {
      final successMessage = next.successMessage;
      if (previous?.successMessage != successMessage &&
          successMessage != null &&
          context.mounted) {
        AppSnackbar.showSuccess(context, message: successMessage);
        notifier.clearSuccessMessage();
      }
    });

    if (!homeState.hasLoaded && !homeState.isLoading) {
      Future.microtask(() => notifier.loadHome());
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: ScreenUtils.vMd,
          bottom: 8.h + 65.h + 16.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppHeader(title: userState.userName, subtitle: 'Welcome Back'),
                IconButton(
                  onPressed: () {
                    context.push(AppRoutes.notifications);
                  },
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.headingText,
                    size: ScreenUtils.iconMd,
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtils.vMd),

            // Mission card — changes based on state
            if (homeState.isLoading && !homeState.hasLoaded)
              const Center(child: CircularProgressIndicator())
            else if (homeState.hasMission)
              _ActiveMissionCard(
                mission: homeState.activeMission!,
                homeState: homeState,
              )
            else
              _SetDailyDirectionCard(),

            if (homeState.errorMessage != null) ...[
              SizedBox(height: ScreenUtils.vSm),
              Text(
                homeState.errorMessage!,
                style: AppTextStyles.bodySM.copyWith(color: AppColors.error),
              ),
            ],

            SizedBox(height: ScreenUtils.vMd),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    type: StatCardType.streak,
                    count: homeState.dayStreak,
                  ),
                ),
                SizedBox(width: ScreenUtils.md),
                Expanded(
                  child: StatCard(
                    type: StatCardType.missions,
                    count: homeState.missionCount,
                  ),
                ),
              ],
            ),

            SizedBox(height: ScreenUtils.vMd),

            // Quick actions row
            GestureDetector(
              onTap: () {
                context.push(AppRoutes.weeklyReview);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(ScreenUtils.md),
                decoration: BoxDecoration(
                  color: AppColors.secondarySurface,
                  borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/calender.png',
                      height: 38.h,
                      width: 38.w,
                    ),
                    SizedBox(height: ScreenUtils.vSm),
                    Text(
                      'Weekly Review',
                      style: AppTextStyles.labelLG.copyWith(
                        color: AppColors.headingText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Reflect & plan',
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.bodyText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SET DAILY DIRECTION CARD (no mission)
// ─────────────────────────────────────────────────────────────────────────────

class _SetDailyDirectionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.mission),
      child: Container(
        width: double.infinity,
        height: 140.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF55CFFF),
              Color(0xFF4CC4FF),
              Color(0xFF3AB2FF),
              Color(0xFF299FFF),
              Color(0xFF0089FD),
              Color(0xFF1892FF),
            ],
            stops: [0.0, 0.15, 0.35, 0.60, 0.85, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Color(0x4D0089FD),
              offset: Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle circle decoration
            Positioned(
              top: -20.h,
              right: -20.w,
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: ScreenUtils.iconMd,
                    ),
                  ),
                  SizedBox(height: ScreenUtils.vSm),
                  Text(
                    'Set Daily Direction',
                    style: AppTextStyles.headingMD.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Set clear goals and align actions for today',
                    style: AppTextStyles.bodyMD.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE MISSION CARD (mission set)
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveMissionCard extends ConsumerWidget {
  final Mission mission;
  final HomeState homeState;

  const _ActiveMissionCard({
    required this.mission,
    required this.homeState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = mission.progress;
    final progressPct = (progress * 100).toInt();
    final notifier = ref.read(homeProvider.notifier);
    final isCompletedState = mission.isAllCompleted;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF55CFFF),
            Color(0xFF4CC4FF),
            Color(0xFF3AB2FF),
            Color(0xFF299FFF),
            Color(0xFF0089FD),
            Color(0xFF1892FF),
          ],
          stops: [0.0, 0.15, 0.35, 0.60, 0.85, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Color(0x4D0089FD),
            offset: Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtils.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Objective + badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    mission.objective,
                    style: AppTextStyles.headingMD.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: ScreenUtils.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtils.sm,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
                    border: Border.all(color: AppColors.white),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.white.withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    isCompletedState ? 'Completed' : 'Pending',
                    style: AppTextStyles.labelLG.copyWith(
                      color: isCompletedState
                          ? Colors.white
                          : AppColors.bodyText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtils.sm),
                GestureDetector(
                  onTap: () => _confirmDeleteMission(context, ref),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: ScreenUtils.iconMd,
                  ),
                ),
              ],
            ),

            SizedBox(height: ScreenUtils.vSm),

            // Progress label + percent
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: AppTextStyles.labelLG.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '$progressPct%',
                  style: AppTextStyles.labelSM.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.h),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(100.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6.h,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),

            SizedBox(height: ScreenUtils.vMd),

            // Task list
            ...mission.tasks.asMap().entries.map((entry) {
              final task = entry.value;

              return _MissionTaskRow(
                task: task,
                isLoading: homeState.activeTaskId == task.id,
                canDelete: mission.tasks.length > 1,
                onToggle: () async {
                  // UH-16: tasks can be completed independently, out of
                  // order — the old "previous tasks first" gate was a
                  // frontend-only restriction with no backend requirement.
                  if (task.isCompleted) {
                    AppSnackbar.showError(
                      context,
                      message: 'Already completed task.',
                    );
                    return;
                  }

                  await notifier.toggleTask(task.id);
                },
                onEdit: () => _showEditTaskDialog(context, ref, task),
                onDelete: () => _confirmDeleteTask(context, ref, task),
              );
            }),

          ],
        ),
      ),
    );
  }
}

class _MissionTaskRow extends StatelessWidget {
  final MissionTask task;
  final bool isLoading;
  final bool canDelete;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MissionTaskRow({
    required this.task,
    required this.isLoading,
    required this.canDelete,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtils.md),
      margin: EdgeInsets.only(bottom: ScreenUtils.vMd),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.25),
        borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
        border: Border.all(color: AppColors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.white.withOpacity(0.2),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: isLoading ? null : onToggle,
        child: Row(
          children: [
            // Circle check
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: Colors.white.withOpacity(0.7),
                  width: 1.5,
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 12.w,
                      height: 12.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.9),
                        ),
                      ),
                    )
                  : task.isCompleted
                  ? Icon(
                      Icons.check_rounded,
                      size: 12.w,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            SizedBox(width: ScreenUtils.sm),
            Expanded(
              child: Text(
                task.title,
                style: AppTextStyles.bodyMD.copyWith(
                  color: Colors.white.withOpacity(
                    task.isCompleted ? 0.6 : 0.95,
                  ),
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
            GestureDetector(
              onTap: onEdit,
              child: Icon(
                Icons.edit_outlined,
                size: ScreenUtils.iconSm,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
            SizedBox(width: ScreenUtils.sm),
            GestureDetector(
              onTap: canDelete ? onDelete : null,
              child: Icon(
                Icons.delete_outline_rounded,
                size: ScreenUtils.iconSm,
                color: Colors.white.withOpacity(canDelete ? 0.85 : 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit / delete actions — today's mission only.
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _showEditTaskDialog(
  BuildContext context,
  WidgetRef ref,
  MissionTask task,
) async {
  final controller = TextEditingController(text: task.title);
  // Lives outside the builder closure so it survives setDialogState rebuilds.
  var isSaving = false;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {

          Future<void> handleSave() async {
            final title = controller.text.trim();
            if (title.isEmpty || isSaving) return;
            setDialogState(() => isSaving = true);
            await ref
                .read(homeProvider.notifier)
                .editTaskTitle(taskId: task.id, title: title);
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          }

          return PopScope(
            canPop: !isSaving,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: ScreenUtils.md),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtils.md,
                  vertical: 24.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: AppColors.borderGrey),
                  borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Task',
                      style: AppTextStyles.labelLG.copyWith(
                        color: AppColors.headingText,
                      ),
                    ),
                    SizedBox(height: ScreenUtils.vMd),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      enabled: !isSaving,
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.headingText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Task title',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ScreenUtils.radiusMd,
                          ),
                          borderSide: BorderSide(color: AppColors.borderGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ScreenUtils.radiusMd,
                          ),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtils.vXl),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.borderGrey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ScreenUtils.radiusMd,
                                ),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.labelLG.copyWith(
                                color: AppColors.labelText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: ScreenUtils.sm),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Save',
                            isLoading: isSaving,
                            onTap: handleSave,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _confirmDeleteTask(
  BuildContext context,
  WidgetRef ref,
  MissionTask task,
) async {
  await showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.2),
    builder: (dialogContext) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          backgroundColor: Colors.transparent,
          child: SettingDialog(
            title: 'Delete Task',
            message: 'Remove "${task.title}" from today\'s mission?',
            button1Text: 'Delete',
            purpose: 'delete',
            icon: Icons.delete_outline_rounded,
            onButton1: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(homeProvider.notifier).deleteTask(task.id);
            },
          ),
        ),
      );
    },
  );
}

Future<void> _confirmDeleteMission(BuildContext context, WidgetRef ref) async {
  await showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.2),
    builder: (dialogContext) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          backgroundColor: Colors.transparent,
          child: SettingDialog(
            title: 'Delete Mission',
            message:
                "This removes today's mission and all of its tasks. You can "
                'start a new one right after.',
            button1Text: 'Delete',
            purpose: 'delete',
            icon: Icons.delete_outline_rounded,
            onButton1: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(homeProvider.notifier).deleteMission();
            },
          ),
        ),
      );
    },
  );
}
