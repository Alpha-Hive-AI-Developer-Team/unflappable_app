import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/utils/app_strings.dart';
import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Reset/Provider/reset_provider.dart';

class ResetScreen extends ConsumerWidget {
  const ResetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(resetProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [_ResetHomeBody(state: state).withScreenPadding()]),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _ResetHomeBody extends ConsumerWidget {
  final dynamic state;
  const _ResetHomeBody({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppHeader(
          title: 'Reset',
          subtitle: 'Clear your mind and regain focus.',
        ),
        SizedBox(height: ScreenUtils.vMd),

        // Gradient Run Reset Card
        _RunResetCard(state: state),
        SizedBox(height: ScreenUtils.vMd),

        // Upgrade Banner
        !state.isPro ? _UpgradeBanner() : SizedBox.shrink(),

        // Reset History Section
        if (state.totalReset > 0) ...[
          Padding(
            padding: EdgeInsets.only(top: ScreenUtils.vLg),
            child: Text(
              'Reset History',
              style: AppTextStyles.headingSM.copyWith(
                color: AppColors.headingText,
              ),
            ),
          ),
          SizedBox(height: ScreenUtils.vMd),
          _ResetHistoryList(state: state),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Run Reset Gradient Card
// ---------------------------------------------------------------------------

class _RunResetCard extends ConsumerWidget {
  final dynamic state;
  const _RunResetCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (!state.hasResetsLeft) return;
        context.push(AppRoutes.resetTrigger);
      },
      child: Container(
        width: double.infinity,
        height: 192.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0089FD),
              Color(0xFF1892FF),
              Color(0xFF299FFF),
              Color(0xFF3AB2FF),
              Color(0xFF4CC4FF),
              Color(0xFF55CFFF),
            ],
            stops: [0.0, 0.15, 0.35, 0.60, 0.85, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
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
            // Refresh icon circle
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Image.asset(
                refresh,
                color: Colors.white,
                width: 24.w,
                height: 24.h,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Run Reset',
              style: AppTextStyles.headingMD.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${state.resetsUsedToday} resets used today',
              style: AppTextStyles.bodyMD.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              state.isPro
                  ? 'Pro plan — unlimited resets'
                  : 'Free plan includes ${state.dailyResetLimit} reset per day.',
              style: AppTextStyles.bodyMD.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Upgrade Banner
// ---------------------------------------------------------------------------

class _UpgradeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.md,
        vertical: ScreenUtils.vSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt, color: AppColors.primary, size: ScreenUtils.iconMd),
          SizedBox(width: ScreenUtils.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade to Pro',
                  style: AppTextStyles.labelMD.copyWith(
                    color: AppColors.labelText,
                  ),
                ),
                Text(
                  'Clear your mind',
                  style: AppTextStyles.bodySM.copyWith(
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to upgrade screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtils.md,
                vertical: ScreenUtils.vSm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
              ),
            ),
            child: Text('Upgrade', style: AppTextStyles.buttonSM),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reset History List
// ---------------------------------------------------------------------------

class _ResetHistoryList extends StatelessWidget {
  final dynamic state;

  const _ResetHistoryList({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.resetHistory.isEmpty) {
      return SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: ClipRect(
        child: Stack(
          children: [
            Column(
              children: state.resetHistory
                  .map<Widget>(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: ScreenUtils.vMd),
                      child: _ResetHistoryCard(item: item),
                    ),
                  )
                  .toList(),
            ),
            if (!state.isPro) ...[
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(color: Colors.black.withOpacity(0.03)),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 77.w),
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(lock, width: 38.w, height: 38.h),
                      SizedBox(height: 5.h),
                      Text(
                        'History Locked',
                        style: AppTextStyles.bodyLG.copyWith(
                          color: AppColors.labelText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Upgrade to Pro to view your past\nresets and insights',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMD.copyWith(
                          color: AppColors.labelText,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      PrimaryButton(
                        label: 'Unlock History',
                        isLoading: false,
                        onTap: () {},
                      ),
                    ],
                  ),
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
// Reset History Card
// ---------------------------------------------------------------------------

class _ResetHistoryCard extends StatelessWidget {
  final dynamic item;

  const _ResetHistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtils.md, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
        border: Border.all(color: AppColors.borderGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Trigger & Time ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.formattedTime,
                style: AppTextStyles.bodyMD.copyWith(
                  color: AppColors.bodyText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: item.emotions
                    .map<Widget>(
                      (emotion) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.borderGrey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(40.r),
                        ),
                        child: Text(
                          emotion,
                          style: AppTextStyles.bodyMD.copyWith(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),

          SizedBox(height: ScreenUtils.vLg),

          // ── Emotions ──────────────────────────────────────────────────────
          Text(
            item.trigger,
            style: AppTextStyles.labelLG.copyWith(color: AppColors.headingText),
          ),
          SizedBox(height: ScreenUtils.vLg),

          // ── Reframe Text ──────────────────────────────────────────────────
          Container(
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
                  'Reframe:',
                  style: AppTextStyles.labelLG.copyWith(
                    color: AppColors.labelText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.reframeText,
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
