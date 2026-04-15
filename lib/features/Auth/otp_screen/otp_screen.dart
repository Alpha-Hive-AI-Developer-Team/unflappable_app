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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _OtpBody(purpose: purpose, email: email).withAuthScreenPadding(),
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
                  onTap: state.isLoading
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
                            );
                          } else {
                            AppSnackbar.showError(
                              context,
                              message:
                                  'Unable to resend code. Please try again.',
                            );
                          }
                        },
                  child: Text(
                    'Resend code',
                    style: AppTextStyles.bodyLG.copyWith(
                      color: state.isLoading
                          ? AppColors.bodyText
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
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
              child: SecondaryButton(label: 'Back', onTap: () => context.pop()),
            ),
            SizedBox(width: ScreenUtils.md),
            Expanded(
              child: PrimaryButton(
                label: 'Next',
                isLoading: state.isLoading,
                onTap: state.isComplete
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
                            );
                            context.push(AppRoutes.onboarding);
                          } else {
                            AppSnackbar.showSuccess(
                              context,
                              message: 'Code verified. Please create your new password.',
                            );
                            context.push(
                              '${AppRoutes.createNewPassword}?resetToken=${Uri.encodeComponent(resetToken)}',
                            );
                          }
                        } else {
                          AppSnackbar.showError(
                            context,
                            message: 'Invalid code. Please try again.',
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
