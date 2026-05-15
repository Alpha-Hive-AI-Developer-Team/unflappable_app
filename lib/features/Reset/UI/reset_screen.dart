import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/utils/app_strings.dart';
import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';
import 'package:unflappable/features/Reset/Provider/reset_provider.dart';
import 'package:unflappable/features/Reset/Provider/reset_state.dart';
import 'package:unflappable/features/widgets/Common/snackbar.dart';

class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({super.key});

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resetProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(resetProvider.notifier).loadInitial(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(resetProvider);
    final userState = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _ResetHomeBody(
            resetState: resetState,
            isPro: userState.isPro || resetState.unlimitedDailyResets,
          ).withScreenPadding(),
        ],
      ),
    );
  }
}

class _ResetHomeBody extends ConsumerWidget {
  final ResetState resetState;
  final bool isPro;

  const _ResetHomeBody({required this.resetState, required this.isPro});

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
        _RunResetCard(resetState: resetState, isPro: isPro),
        SizedBox(height: ScreenUtils.vMd),
        if (!isPro) _UpgradeBanner(),
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
        if (resetState.status == ResetStatus.loading &&
            resetState.resetHistory.isEmpty) ...[
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ] else ...[
          _ResetHistoryList(resetState: resetState, isPro: isPro),
        ],
      ],
    );
  }
}

class _RunResetCard extends ConsumerWidget {
  final ResetState resetState;
  final bool isPro;

  const _RunResetCard({required this.resetState, required this.isPro});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (!resetState.hasResetsLeft && !isPro) {
          AppSnackbar.showError(
            context,
            message:
                'You have used your free reset for today. If you want more resets, continue to premium.',
          );
          return;
        }
        context.push(AppRoutes.resetTrigger);
      },
      child: Container(
        width: double.infinity,
        height: 192.h,
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
              resetState.status == ResetStatus.loading
                  ? 'Loading...'
                  : '${resetState.resetsUsedToday} resets used today',
              style: AppTextStyles.bodyMD.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              isPro
                  ? 'Pro plan - unlimited resets'
                  : 'Free plan includes ${resetState.dailyResetLimit} reset per day.',
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
              context.push(AppRoutes.pricing);
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

class _ResetHistoryList extends StatelessWidget {
  final ResetState resetState;
  final bool isPro;

  const _ResetHistoryList({required this.resetState, required this.isPro});

  @override
  Widget build(BuildContext context) {
    if (resetState.resetHistory.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            resetState.status == ResetStatus.error
                ? resetState.errorMessage ?? 'Unable to load reset history.'
                : 'No reset history yet.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.bodyText),
          ),
        ),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        child: ClipRect(
          child: Stack(
            children: [
              Column(
                children: resetState.resetHistory
                    .map<Widget>(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: ScreenUtils.vMd),
                        child: _ResetHistoryCard(item: item),
                      ),
                    )
                    .toList(),
              ),
              if (!isPro) ...[
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
                          onTap: () {
                            context.push(AppRoutes.pricing);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

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
          Text(
            item.trigger,
            style: AppTextStyles.labelLG.copyWith(color: AppColors.headingText),
          ),
          SizedBox(height: ScreenUtils.vLg),
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
