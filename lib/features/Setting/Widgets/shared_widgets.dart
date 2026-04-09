import 'package:flutter/cupertino.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/export.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelMD.copyWith(color: AppColors.bodyText),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtils.lg,
          vertical: ScreenUtils.vLg,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: ScreenUtils.iconMd,
              color: iconColor ?? AppColors.setting_text,
            ),
            SizedBox(width: ScreenUtils.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelLG.copyWith(
                  color: labelColor ?? AppColors.setting_text,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: ScreenUtils.iconMd,
              color: iconColor ?? AppColors.setting_text,
            ),
          ],
        ),
      ),
    );
  }
}

class ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.labelLG.copyWith(color: AppColors.headingText),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.success,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class TimePickerRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const TimePickerRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLG.copyWith(color: AppColors.headingText),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtils.md,
              vertical: ScreenUtils.vMd,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: Row(
              children: [
                Text(
                  value,
                  style: AppTextStyles.labelMD.copyWith(
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: ScreenUtils.iconMd,
                  color: AppColors.bodyText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AccountField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final bool filled;

  const AccountField({
    super.key,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.filled = false,
  });

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
            readOnly: readOnly,
            style: AppTextStyles.bodyMD.copyWith(
              color: readOnly ? AppColors.bodyText : AppColors.labelText,
            ),
            decoration: InputDecoration(
              filled: filled,
              fillColor: filled ? AppColors.secondarySurface : null,
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
                borderSide: BorderSide(
                  color: readOnly ? AppColors.borderGrey : AppColors.primary,
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                borderSide: BorderSide(color: AppColors.borderGrey),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
