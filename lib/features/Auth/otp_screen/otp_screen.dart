import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/Routes/app_routes.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_paddings.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/features/Auth/otp_screen/otp_provider/otp_provider.dart';
import 'package:unflappable/features/Auth/otp_screen/otp_provider/otp_state.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';
import 'package:unflappable/features/widgets/Common/app_header.dart';
import 'package:unflappable/features/widgets/Common/buttons.dart';
import 'package:unflappable/features/widgets/Common/snackbar.dart';

class OtpVerificationScreen extends ConsumerWidget {
  final OtpPurpose purpose;
  final String email;

  const OtpVerificationScreen({
    super.key,
    this.purpose = OtpPurpose.forgotPassword,
    required this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      // UA-30: take explicit control of back navigation (hardware/gesture
      // back) instead of leaving it to the platform default, which was
      // landing on Home or crashing. If there's nothing to pop to, send the
      // user to a known-safe screen instead of letting it fall through.
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _OtpBody(purpose: purpose, email: email).withAuthScreenPadding(),
      ),
    );
  }
}

class _OtpBody extends ConsumerWidget {
  final OtpPurpose purpose;
  final String email;

  const _OtpBody({required this.purpose, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(otpProvider);
    final notifier = ref.read(otpProvider.notifier);

    final minutes = state.secondsLeft ~/ 60;
    final seconds = state.secondsLeft % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppHeader(
          title: 'Verify Email',
          subtitle: purpose == OtpPurpose.signup
              ? "We've sent a 4-digit code to your email address to complete signup."
              : "We've sent a 4-digit code to your email address.",
        ),
        SizedBox(height: ScreenUtils.vXxl),

        // OTP inputs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            4,
            (i) => _OtpBox(
              index: i,
              value: state.digits[i],
              onChanged: (v) => notifier.setDigit(i, v),
            ),
          ),
        ),

        SizedBox(height: ScreenUtils.vMd),

        // Resend timer / resend button
        Center(
          child: state.secondsLeft == 0
              ? GestureDetector(
                  // UA-9: guard against either in-flight request, not just
                  // this one — resend shouldn't fire mid-verify either.
                  onTap: state.isBusy
                      ? null
                      : () async {
                          final success = await notifier.resendCode(
                            email: email,
                            purpose: purpose,
                          );
                          if (!context.mounted) return;
                          if (success) {
                            AppSnackbar.showSuccess(
                              context,
                              message: 'A new code was sent to your email.',
                              // UA-6: extra clearance above the Back/Next row.
                              extraBottomMargin: 72.h,
                            );
                          } else {
                            AppSnackbar.showError(
                              context,
                              message:
                                  'Unable to resend code. Please try again.',
                              extraBottomMargin: 72.h,
                            );
                          }
                        },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // UA-9: the loading state now shows here, on the
                      // actual Resend action, instead of on the Next
                      // button (which was misleading).
                      if (state.isResending) ...[
                        SizedBox(
                          width: 14.w,
                          height: 14.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.bodyText,
                          ),
                        ),
                        SizedBox(width: ScreenUtils.sm),
                      ],
                      Text(
                        state.isResending ? 'Sending...' : 'Resend code',
                        style: AppTextStyles.bodyLG.copyWith(
                          color: state.isBusy
                              ? AppColors.bodyText
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyLG.copyWith(
                      color: AppColors.bodyText,
                    ),
                    children: [
                      const TextSpan(text: 'Resend code in: '),
                      TextSpan(
                        text: timeStr,
                        style: AppTextStyles.bodyLG.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
        ),

        const Spacer(),

        Row(
          children: [
            Expanded(
              // UA-9: disabled during either verify or resend — previously
              // had no guard at all and stayed tappable throughout.
              child: SecondaryButton(
                label: 'Back',
                onTap: state.isBusy ? null : () => context.pop(),
              ),
            ),
            SizedBox(width: ScreenUtils.md),
            Expanded(
              child: PrimaryButton(
                label: 'Next',
                // UA-9: only reflects verify's own loading now — resend no
                // longer makes this button spin for an action it didn't
                // trigger.
                isLoading: state.isVerifying,
                onTap: (state.isComplete && !state.isBusy)
                    ? () async {
                        final resetToken = await notifier.verify(
                          email: email,
                          purpose: purpose,
                        );
                        if (!context.mounted) return;
                        if (resetToken != null) {
                          if (purpose == OtpPurpose.signup) {
                            AppSnackbar.showSuccess(
                              context,
                              message: 'Email verified successfully.',
                              extraBottomMargin: 72.h,
                            );
                            await ref
                                .read(userProvider.notifier)
                                .restoreSessionIfNeeded();
                            if (!context.mounted) return;
                            // UA-11: go() instead of push() — leaving the
                            // OTP screen in the stack behind onboarding is
                            // what lets the iOS edge-swipe gesture engage
                            // at all, even with PopScope(canPop: false)
                            // blocking the pop itself.
                            context.go(AppRoutes.onboarding);
                          } else {
                            AppSnackbar.showSuccess(
                              context,
                              message: 'Code verified. Please create your new password.',
                              extraBottomMargin: 72.h,
                            );
                            context.push(
                              '${AppRoutes.createNewPassword}?resetToken=${Uri.encodeComponent(resetToken)}',
                            );
                          }
                        } else {
                          AppSnackbar.showError(
                            context,
                            message: 'Invalid code. Please try again.',
                            extraBottomMargin: 72.h,
                          );
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OtpBox extends StatefulWidget {
  final int index;
  final String value;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.index,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88.w,
      height: 80.h,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: AppTextStyles.headingLG.copyWith(color: AppColors.headingText),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        onChanged: (v) {
          widget.onChanged(v);
          if (v.isNotEmpty) {
            // Move to next field
            FocusScope.of(context).nextFocus();
          } else {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }
}
