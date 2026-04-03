import 'package:flutter/material.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/core/theme/app_colors.dart';

// ── Field Label ───────────────────────────────────────────────────────────────

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelMD.copyWith(color: AppColors.labelText),
    );
  }
}

// ── Text Field ────────────────────────────────────────────────────────────────

class AuthTextField extends StatelessWidget {
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final String? errorText;

  const AuthTextField({
    super.key,
    required this.hint,
    required this.obscureText,
    this.keyboardType,
    this.onChanged,
    this.suffixIcon,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: AppTextStyles.bodyMD.copyWith(color: AppColors.labelText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMD.copyWith(color: AppColors.bodyText),
        suffixIcon: suffixIcon,
        errorText: errorText,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

// ── Apple Button ──────────────────────────────────────────────────────────────

class AppleButton extends StatelessWidget {
  const AppleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ScreenUtils.buttonHeight,
      child: OutlinedButton(
        onPressed: () {
          // TODO: handle Apple sign-in
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.borderGrey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
          ),
          backgroundColor: AppColors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apple,
              size: ScreenUtils.iconMd,
              color: AppColors.headingText,
            ),
            SizedBox(width: ScreenUtils.sm),
            Text(
              'Sign in with Apple',
              style: AppTextStyles.labelLG.copyWith(
                color: AppColors.headingText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
