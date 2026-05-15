import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/Routes/app_routes.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/features/Reset/Provider/reset_provider.dart';
import 'package:unflappable/features/Reset/Provider/reset_state.dart';
import 'package:unflappable/features/widgets/Common/buttons.dart';
import 'package:unflappable/features/widgets/Common/helping_appBar.dart';

class ResetEmotionScreen extends ConsumerWidget {
  const ResetEmotionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resetProvider);
    final notifier = ref.read(resetProvider.notifier);
    final isLoading = state.status == ResetStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── AppBar ───────────────────────────────────────────────────
                HelpingAppBar(title: 'Reset'),

                // ── Content ──────────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtils.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How are you feeling right now?',
                          style: AppTextStyles.headingSM.copyWith(
                            color: AppColors.labelText,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: ScreenUtils.vLg),

                        // ── Emotion Chips ─────────────────────────────────────
                        _EmotionChipsGrid(
                          emotions: state.emotions,
                          selectedEmotions: state.selectedEmotions,
                          onToggle: notifier.toggleEmotion,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Continue Button ──────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    ScreenUtils.lg,
                    0,
                    ScreenUtils.lg,
                    ScreenUtils.vXxl,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: ScreenUtils.buttonHeight,
                    child: PrimaryButton(
                      onTap: state.selectedEmotions.isEmpty || isLoading
                          ? null
                          : () async {
                              await notifier.runReset();
                            },
                      label: 'Continue',
                      isLoading: isLoading,
                    ),
                  ),
                ),
              ],
            ),
            if (context.mounted &&
                ref.read(resetProvider).status == ResetStatus.success) ...[
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
              ),

              // ── Reset Complete Dialog Card ────────────────────────────────
              Center(
                child: _ResetCompleteCard(
                  state: state,
                  onBackToHome: () {
                    ref.read(resetProvider.notifier).resetFlow();
                    context.go(AppRoutes.home);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Emotion Chips Grid
// ---------------------------------------------------------------------------

class _EmotionChipsGrid extends StatelessWidget {
  final List<String> emotions;
  final List<String> selectedEmotions;
  final void Function(String) onToggle;

  const _EmotionChipsGrid({
    required this.emotions,
    required this.selectedEmotions,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: emotions
          .map(
            (e) => _EmotionChip(
              label: e,
              isSelected: selectedEmotions.contains(e),
              onTap: () => onToggle(e),
            ),
          )
          .toList(),
    );
  }
}

class _EmotionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmotionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtils.md,
          vertical: ScreenUtils.vSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderGrey,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMD.copyWith(
            color: isSelected ? Colors.white : AppColors.labelText,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reset Complete Card
// ---------------------------------------------------------------------------

class _ResetCompleteCard extends StatelessWidget {
  final ResetState state;
  final VoidCallback onBackToHome;

  const _ResetCompleteCard({required this.state, required this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtils.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top: icon + title ────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(ScreenUtils.xl),
            child: Column(
              children: [
                Icon(Icons.bolt, color: AppColors.primary, size: 38.w),
                SizedBox(height: ScreenUtils.vSm),
                Text(
                  'Reset Complete',
                  style: AppTextStyles.bodyLG.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'You are back in control.',
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),

          // ── Reframe ──────────────────────────────────────────────────
          _ResultTile(title: 'Reframe', body: state.reframeText ?? ''),

          // ── Next Action ───────────────────────────────────────────────
          _ResultTile(title: 'Next Action', body: state.nextActionText ?? ''),

          // ── Back to Home Button ──────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(ScreenUtils.lg),
            child: SizedBox(
              width: double.infinity,
              height: ScreenUtils.buttonHeight,
              child: ElevatedButton(
                onPressed: onBackToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                  ),
                ),
                child: Text('Back to Home', style: AppTextStyles.buttonLG),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Result Tile (Reframe / Next Action)
// ---------------------------------------------------------------------------

class _ResultTile extends StatelessWidget {
  final String title;
  final String body;

  const _ResultTile({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtils.md,
        vertical: ScreenUtils.vSm,
      ),
      alignment: Alignment.centerLeft,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.borderGrey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelLG.copyWith(color: AppColors.labelText),
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.bodyText),
          ),
        ],
      ),
    );
  }
}
