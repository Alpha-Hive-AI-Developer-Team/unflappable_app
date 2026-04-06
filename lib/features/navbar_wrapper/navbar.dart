import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/app_strings.dart';
import 'package:unflappable/core/utils/screen_utils.dart';

class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppNavBar({super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(label: 'Home', icon: home),
    _NavItem(label: 'Reset', icon: refresh),
    _NavItem(label: 'Progress', icon: progress),
    _NavItem(label: 'Setting', icon: settings),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      margin: EdgeInsets.fromLTRB(26.w, 0, 26.w, 20.h),
      height: 81.h,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(300.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          final selected = i == currentIndex;
          final item = _items[i];

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.all(selected ? 6.w : 0),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryWithOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Image.asset(
                      item.icon,
                      width: 24.w,
                      height: 24.h,
                      color: selected ? AppColors.primary : AppColors.bodyText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.label,
                    style: AppTextStyles.labelSM.copyWith(
                      color: selected ? AppColors.primary : AppColors.bodyText,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String icon;
  const _NavItem({required this.label, required this.icon});
}
