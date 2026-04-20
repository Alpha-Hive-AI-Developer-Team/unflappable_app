import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/features/Weekly%20Review/Model/review_model.dart';
import 'package:unflappable/features/Weekly%20Review/Provider/review_notifier.dart';
import 'package:unflappable/features/Weekly%20Review/Provider/review_state.dart';
import 'package:unflappable/features/widgets/Common/snackbar.dart';
import 'package:unflappable/features/widgets/Common/buttons.dart';
import 'package:unflappable/features/widgets/Common/helping_appBar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ROOT — switches between list and add screens
// ─────────────────────────────────────────────────────────────────────────────

class WeeklyReviewScreen extends ConsumerWidget {
  const WeeklyReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weeklyReviewProvider);

    ref.listen<WeeklyReviewState>(weeklyReviewProvider, (previous, next) {
      final successMessage = next.successMessage;
      if (previous?.successMessage != successMessage &&
          successMessage != null &&
          context.mounted) {
        AppSnackbar.showSuccess(context, message: successMessage);
        ref.read(weeklyReviewProvider.notifier).clearSuccessMessage();
      }
    });

    if (!state.hasLoaded && !state.isLoading) {
      Future.microtask(
        () => ref.read(weeklyReviewProvider.notifier).loadInitial(),
      );
    }

    final showAdd = ref.watch(
      weeklyReviewProvider.select((s) => s.showAddScreen),
    );

    return showAdd ? const _AddReviewScreen() : const _WeeklyReviewListScreen();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1 ── WEEKLY REVIEW LIST SCREEN
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// 1 ── WEEKLY REVIEW LIST SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class _WeeklyReviewListScreen extends ConsumerWidget {
  const _WeeklyReviewListScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weeklyReviewProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            HelpingAppBar(title: 'Weekly Review'),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: ScreenUtils.authHorizontalMargin,
                  right: ScreenUtils.authHorizontalMargin,
                  top: ScreenUtils.vMd,
                  bottom: 32.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Add Weekly Review card ─────────────────────────────
                    GestureDetector(
                      onTap: () => ref
                          .read(weeklyReviewProvider.notifier)
                          .openAddScreen(),
                      child: Container(
                        width: double.infinity,
                        height: 164.h,
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
                          borderRadius: BorderRadius.circular(
                            ScreenUtils.radiusLg,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4D0089FD),
                              offset: Offset(0, 8),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(9.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: ScreenUtils.iconMd,
                              ),
                            ),
                            SizedBox(height: ScreenUtils.vSm),
                            Text(
                              'Add Weekly Review',
                              style: AppTextStyles.headingMD.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Set clear goals and align actions for today',
                              style: AppTextStyles.bodyMD.copyWith(
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: ScreenUtils.vXl),

                    // ── Review History ─────────────────────────────────────
                    Text(
                      'Review History',
                      style: AppTextStyles.headingMD.copyWith(
                        color: AppColors.headingText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: ScreenUtils.vMd),

                    if (state.errorMessage != null)
                      Text(
                        state.errorMessage!,
                        style: AppTextStyles.bodyMD.copyWith(
                          color: AppColors.error,
                        ),
                      )
                    else if (state.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (state.history.isEmpty)
                      Text(
                        'No review history yet.',
                        style: AppTextStyles.bodyMD.copyWith(
                          color: AppColors.bodyText,
                        ),
                      )
                    else
                      ...state.history.map(
                        (review) => Padding(
                          padding: EdgeInsets.only(bottom: ScreenUtils.vMd),
                          child: _ReviewHistoryCard(review: review),
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
// REVIEW HISTORY CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewHistoryCard extends StatelessWidget {
  final WeeklyReviewData review;

  const _ReviewHistoryCard({required this.review});

  String get _dateLabel {
    if (review.createdAt == null) return 'Review';
    final d = review.createdAt!;
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Date label ──────────────────────────────────────────────────────
        Text(
          _dateLabel,
          style: AppTextStyles.labelMD.copyWith(
            color: AppColors.headingText,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: ScreenUtils.vSm),

        // ── Card container ──────────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secondarySurface,
            borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
          ),
          padding: EdgeInsets.all(ScreenUtils.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Biggest Win
              if (review.biggestWin.isNotEmpty) ...[
                _ReviewAttributeRow(
                  label: 'Biggest Win',
                  content: review.biggestWin,
                ),
              ],

              // Biggest Miss
              if (review.biggestMiss.isNotEmpty) ...[
                SizedBox(height: ScreenUtils.vSm),
                _ReviewAttributeRow(
                  label: 'Biggest Miss',
                  content: review.biggestMiss,
                ),
              ],

              // Cause of Drift
              if (review.causeOfDrift.isNotEmpty) ...[
                SizedBox(height: ScreenUtils.vSm),
                _ReviewAttributeRow(
                  label: 'Cause of Drift',
                  content: review.causeOfDrift,
                ),
              ],

              // One Shift for Next Week
              if (review.oneShiftNextWeek.isNotEmpty) ...[
                SizedBox(height: ScreenUtils.vSm),
                _ReviewAttributeRow(
                  label: 'One Shift for Next Week',
                  content: review.oneShiftNextWeek,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REVIEW ATTRIBUTE ROW
// A single label + content pair rendered inside the history card.
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewAttributeRow extends StatelessWidget {
  final String label;
  final String content;

  const _ReviewAttributeRow({required this.label, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtils.vXs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSM.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            content,
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.headingText),
          ),
        ],
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// 2 ── ADD REVIEW SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class _AddReviewScreen extends ConsumerStatefulWidget {
  const _AddReviewScreen();

  @override
  ConsumerState<_AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends ConsumerState<_AddReviewScreen> {
  late final TextEditingController _winCtrl;
  late final TextEditingController _missCtrl;
  late final TextEditingController _driftCtrl;
  late final TextEditingController _shiftCtrl;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(weeklyReviewProvider.notifier);

    _winCtrl = TextEditingController()
      ..addListener(() => notifier.setBiggestWin(_winCtrl.text));
    _missCtrl = TextEditingController()
      ..addListener(() => notifier.setBiggestMiss(_missCtrl.text));
    _driftCtrl = TextEditingController()
      ..addListener(() => notifier.setCauseOfDrift(_driftCtrl.text));
    _shiftCtrl = TextEditingController()
      ..addListener(() => notifier.setOneShift(_shiftCtrl.text));
  }

  @override
  void dispose() {
    _winCtrl.dispose();
    _missCtrl.dispose();
    _driftCtrl.dispose();
    _shiftCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weeklyReviewProvider);

    ref.listen<WeeklyReviewState>(weeklyReviewProvider, (previous, next) {
      if (previous?.errorMessage != next.errorMessage &&
          next.errorMessage != null &&
          context.mounted) {
        AppSnackbar.showError(context, message: next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            HelpingAppBar(title: 'Add Review'),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtils.authHorizontalMargin,
                  vertical: ScreenUtils.vMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReviewField(label: 'Biggest Win', controller: _winCtrl),
                    SizedBox(height: ScreenUtils.vMd),
                    _ReviewField(label: 'Biggest Miss', controller: _missCtrl),
                    SizedBox(height: ScreenUtils.vMd),
                    _ReviewField(
                      label: 'Cause of Drift',
                      controller: _driftCtrl,
                    ),
                    SizedBox(height: ScreenUtils.vMd),
                    _ReviewField(
                      label: 'One Shift for Next Week',
                      controller: _shiftCtrl,
                    ),
                  ],
                ),
              ),
            ),

            // Save button
            Padding(
              padding: EdgeInsets.only(
                left: ScreenUtils.authHorizontalMargin,
                right: ScreenUtils.authHorizontalMargin,
                bottom: ScreenUtils.vXxl,
                top: ScreenUtils.vMd,
              ),
              child: PrimaryButton(
                label: 'Save Changes',
                isLoading: state.isLoading,
                onTap: state.draft.hasAnyEntry
                    ? () => ref.read(weeklyReviewProvider.notifier).saveReview()
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _ReviewField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMD.copyWith(color: AppColors.headingText),
        ),
        SizedBox(height: ScreenUtils.vSm),
        SizedBox(
          height: ScreenUtils.inputHeight,
          child: TextField(
            controller: controller,
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.labelText),
            decoration: InputDecoration(
              hintText: 'Enter here',
              hintStyle: AppTextStyles.bodyMD.copyWith(
                color: AppColors.bodyText,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ScreenUtils.md,
                vertical: ScreenUtils.vMd,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                borderSide: BorderSide(color: AppColors.borderGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
