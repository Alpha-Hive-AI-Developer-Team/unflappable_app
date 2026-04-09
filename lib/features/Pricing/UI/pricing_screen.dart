import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Pricing/Provider/pricing_notifier.dart';
import 'package:unflappable/features/Pricing/Provider/pricing_state.dart';
import 'package:unflappable/features/widgets/Common/error_dialog.dart';
import 'package:unflappable/features/widgets/Common/helping_appBar.dart';

class PricingPlansScreen extends ConsumerWidget {
  const PricingPlansScreen({super.key});

  static const _features = [
    _PlanFeature(
      'Unlimited Resets',
      'Reset your mindset as often as you need.',
    ),
    _PlanFeature('Reset History Access', 'Review past triggers and reframes.'),
    _PlanFeature(
      'Advanced Insights',
      'Track your emotional patterns over time.',
    ),
    _PlanFeature('Premium Templates', 'Access exclusive designed templates.'),
    _PlanFeature(
      'Deeper Coaching Prompts',
      'AI-powered prompts for deeper reflection.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pricingPlansProvider);
    final notifier = ref.read(pricingPlansProvider.notifier);

    // Navigate away on successful upgrade
    ref.listen<PricingPlansState>(pricingPlansProvider, (prev, next) {
      if (next.status == PricingStatus.success) {
        Navigator.of(context).maybePop();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ── Tilted horizontal ribbons behind the card ─────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRect(
                child: CustomPaint(
                  painter: _RibbonPainter(
                    upperColor: const Color(0xFF67B8FF),
                    lowerColor: const Color(0xFFB4DCFF),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: ScreenUtils.designHeight / 2,
                decoration: BoxDecoration(
                  color: AppColors.primaryWithOpacity(0.05),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(ScreenUtils.radiusXl),
                    bottomRight: Radius.circular(ScreenUtils.radiusXl),
                  ),
                ),
              ),
            ),
          ),

          // ── Main scrollable content ────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                HelpingAppBar(title: 'Pricing Plans'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: ScreenUtils.vSm),
                        _Header(),
                        SizedBox(height: ScreenUtils.vXl),
                        _PlanCard(features: _features),
                        SizedBox(height: ScreenUtils.vXl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Blur + failure dialog overlay ──────────────────────────────
          if (state.showFailureOverlay) ...[
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),
            Center(
              child: ErrorDialog(
                title: 'Purchase Failure',
                message:
                    state.errorMessage ?? "Your Purchase didn't go through",
                onTryAgain: notifier.clearError,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.primaryWithOpacity(0.1),
            borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
          ),
          child: Text(
            'Pricing plans',
            style: AppTextStyles.labelMD.copyWith(color: AppColors.primary),
          ),
        ),
        SizedBox(height: ScreenUtils.vMd),
        Text(
          'Upgrade to Pro',
          style: AppTextStyles.headingXL.copyWith(color: Color(0xFF004F94)),
        ),
        SizedBox(height: ScreenUtils.vMd),
        Text(
          'Unlock your full potential with\nunlimited access.',
          textAlign: TextAlign.center,
          style: AppTextStyles.headingSM.copyWith(
            color: Color(0xFF58B1FF),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Plan Card
// ---------------------------------------------------------------------------

class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.features});
  final List<_PlanFeature> features;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pricingPlansProvider);
    final notifier = ref.read(pricingPlansProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _BillingToggle(
            isYearly: state.isYearly,
            onChanged: (isYearly) => notifier.setBillingCycle(
              isYearly ? BillingCycle.yearly : BillingCycle.monthly,
            ),
          ),
          SizedBox(height: ScreenUtils.vLg),

          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.primaryWithOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt,
              color: AppColors.primary,
              size: ScreenUtils.iconMd,
            ),
          ),
          SizedBox(height: ScreenUtils.vMd),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              state.price,
              key: ValueKey(state.billingCycle),
              style: AppTextStyles.headingXL.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.headingText,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            state.billingLabel,
            style: AppTextStyles.bodyLG.copyWith(color: AppColors.bodyText),
          ),
          SizedBox(height: ScreenUtils.vLg),

          Divider(color: AppColors.borderGrey, height: 1),
          SizedBox(height: ScreenUtils.vLg),

          ...List.generate(
            features.length,
            (i) => Padding(
              padding: EdgeInsets.fromLTRB(
                ScreenUtils.xl,
                0,
                ScreenUtils.xl,
                i < features.length - 1 ? ScreenUtils.vMd : 0,
              ),
              child: _FeatureRow(feature: features[i]),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(ScreenUtils.xl),
            child: PrimaryButton(
              label: 'Upgrade',
              isLoading: state.isLoading,
              onTap: () => notifier.upgrade(),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Billing Toggle
// ---------------------------------------------------------------------------

class _BillingToggle extends StatelessWidget {
  const _BillingToggle({required this.isYearly, required this.onChanged});
  final bool isYearly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Row(
        children: [
          _ToggleTab(
            label: 'Monthly',
            isActive: !isYearly,
            onTap: () => onChanged(false),
          ),
          _ToggleTab(
            label: 'Yearly',
            isActive: isYearly,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isActive ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(ScreenUtils.radiusXs + 2.r),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMD.copyWith(
              color: isActive ? AppColors.headingText : AppColors.bodyText,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feature Row
// ---------------------------------------------------------------------------

class _PlanFeature {
  const _PlanFeature(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature});
  final _PlanFeature feature;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(
            color: AppColors.primaryWithOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 13.w, color: AppColors.primary),
        ),
        SizedBox(width: ScreenUtils.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: AppTextStyles.labelLG.copyWith(
                  color: AppColors.labelText,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                feature.subtitle,
                style: AppTextStyles.bodyMD.copyWith(
                  color: AppColors.labelText,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RibbonPainter extends CustomPainter {
  const _RibbonPainter({required this.upperColor, required this.lowerColor});
  final Color upperColor;
  final Color lowerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paintUpper = Paint()..color = upperColor;
    final paintLower = Paint()..color = lowerColor;

    const double tilt = 30.0;

    const double thickness = 36.0;

    const double gap = 1.0;

    final double centerY = size.height * 0.52;

    // ── Band 1 (top) ─────────────────────────────────────────────────────
    final topBand1 = centerY - gap / 2 - thickness;
    final path1 = Path()
      ..moveTo(0, topBand1)
      ..lineTo(size.width, topBand1 - tilt)
      ..lineTo(size.width, topBand1 - tilt + thickness)
      ..lineTo(0, topBand1 + thickness)
      ..close();

    // ── Band 2 (bottom) ───────────────────────────────────────────────────
    final topBand2 = centerY + gap / 2;
    final path2 = Path()
      ..moveTo(0, topBand2)
      ..lineTo(size.width, topBand2 - tilt)
      ..lineTo(size.width, topBand2 - tilt + thickness)
      ..lineTo(0, topBand2 + thickness)
      ..close();

    canvas.drawPath(path1, paintUpper);
    canvas.drawPath(path2, paintLower);
  }

  @override
  bool shouldRepaint(_RibbonPainter old) =>
      old.upperColor != upperColor || old.lowerColor != lowerColor;
}
