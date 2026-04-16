import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/app_strings.dart';
import 'package:unflappable/core/utils/screen_utils.dart';

enum StatCardType { streak, missions }

class StatCard extends StatelessWidget {
  final StatCardType type;
  final int count;

  const StatCard({super.key, required this.type, required this.count});

  bool get _isEmpty => count == 0;
  bool get _isStreak => type == StatCardType.streak;

  static const _zeroShadows = [
    BoxShadow(color: Color(0x08787878), offset: Offset(1, 1), blurRadius: 4),
    BoxShadow(color: Color(0x08787878), offset: Offset(3, 6), blurRadius: 7),
    BoxShadow(color: Color(0x05787878), offset: Offset(8, 13), blurRadius: 9),
    BoxShadow(color: Color(0x00787878), offset: Offset(13, 23), blurRadius: 11),
    BoxShadow(color: Color(0x00787878), offset: Offset(21, 36), blurRadius: 12),
  ];

  static const _streakBgGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFC),
      Color(0xFFFFF2E9),
      Color(0xFFFFDFC8),
      Color(0xFFFFC49C),
      Color(0xFFFFC49C),
    ],
    stops: [0.0, 0.15, 0.35, 0.60, 0.85, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const _streakTextGradient = LinearGradient(
    colors: [Color(0xFFFFA066), Color(0xFFFF8538)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const _missionBgGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFC),
      Color(0xFFD8EDFF),
      Color(0xFFA5D5FF),
      Color(0xFF66B7FF),
      Color(0xFF66B7FF),
    ],
    stops: [0.0, 0.15, 0.35, 0.60, 0.85, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const _missionTextGradient = LinearGradient(
    colors: [Color(0xFF2699FF), Color(0xFF0088FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) return _buildZeroCard();
    return _isStreak
        ? _buildActiveCard(_streakBgGradient, _streakTextGradient, 'Day Streak')
        : _buildActiveCard(
            _missionBgGradient,
            _missionTextGradient,
            'Missions',
          );
  }

  Widget _buildZeroCard() {
    final label = _isStreak ? 'Day Streak' : 'Missions';
    return Container(
      padding: EdgeInsets.all(ScreenUtils.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
        border: Border.all(color: const Color(0xFFE5E5EA)),
        boxShadow: _zeroShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            _isStreak ? fire_dark : mission_dark,
            width: 58.w,
            height: 58.h,
          ),
          SizedBox(height: ScreenUtils.vMd),
          Text(
            count.toString().padLeft(2, '0'),
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 58.sp,
              letterSpacing: -0.2,
              color: const Color(0xFFD1D1D6),
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodyMD.copyWith(
              color: const Color(0xFFD1D1D6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCard(
    LinearGradient bgGradient,
    LinearGradient textGradient,
    String label,
  ) {
    return Container(
      padding: EdgeInsets.all(ScreenUtils.md),
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
        border: Border.all(
          color: _isStreak ? const Color(0xFFFF8538) : const Color(0xFF5D6EFC),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isStreak ? const Color(0xFFFF8538) : AppColors.primary)
                .withOpacity(0.20),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(_isStreak ? fire : mission, width: 58.w, height: 58.h),
          SizedBox(height: ScreenUtils.vMd),
          ShaderMask(
            shaderCallback: (bounds) => textGradient.createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text(
              count.toString().padLeft(2, '0'),
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 58.sp,
                letterSpacing: -0.2,
              ),
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => textGradient.createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text(
              label,
              style: AppTextStyles.bodyMD.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
