import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Home/Provider/home_provider.dart';
import 'package:unflappable/features/Home/model/mission.dart';
import 'package:unflappable/features/Home/model/mission_task.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: ScreenUtils.vMd,
          bottom: 8.h + 65.h + 16.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _HomeHeader(userName: state.userName),
            SizedBox(height: ScreenUtils.vMd),

            // Mission card — changes based on state
            state.hasMission
                ? _ActiveMissionCard(mission: state.activeMission!)
                : _SetDailyDirectionCard(),

            SizedBox(height: ScreenUtils.vMd),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    type: _StatCardType.streak,
                    count: state.dayStreak,
                  ),
                ),
                SizedBox(width: ScreenUtils.md),
                Expanded(
                  child: _StatCard(
                    type: _StatCardType.missions,
                    count: state.missionCount,
                  ),
                ),
              ],
            ),

            SizedBox(height: ScreenUtils.vMd),

            // Quick actions row
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    label: 'Run Reset',
                    sublabel: 'Clear your mind',
                    onTap: () {},
                    image: 'assets/images/reset.png',
                  ),
                ),
                SizedBox(width: ScreenUtils.md),
                Expanded(
                  child: _QuickActionCard(
                    label: 'Weekly Review',
                    sublabel: 'Reflect & plan',
                    onTap: () {},
                    image: 'assets/images/calender.png',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _HomeHeader extends ConsumerWidget {
  final String userName;
  const _HomeHeader({required this.userName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: AppTextStyles.headingMD.copyWith(
                color: AppColors.headingText,
              ),
            ),
            Text(
              'Welcome Back',
              style: AppTextStyles.bodySM.copyWith(color: AppColors.bodyText),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.notifications),
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondarySurface,
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: ScreenUtils.iconMd,
              color: AppColors.headingText,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SET DAILY DIRECTION CARD (no mission)
// ─────────────────────────────────────────────────────────────────────────────

class _SetDailyDirectionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.mission),
      child: Container(
        width: double.infinity,
        height: 140.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0089FD), // top    — brand blue
              Color(0xFF1892FF), // 15%
              Color(0xFF299FFF), // 35%
              Color(0xFF3AB2FF), // 60%
              Color(0xFF4CC4FF), // 85%
              Color(0xFF55CFFF), // bottom — light sky blue
            ],
            stops: [0.0, 0.15, 0.35, 0.60, 0.85, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Color(0x4D0089FD),
              offset: Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle circle decoration
            Positioned(
              top: -20.h,
              right: -20.w,
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: ScreenUtils.iconMd,
                    ),
                  ),
                  SizedBox(height: ScreenUtils.vSm),
                  Text(
                    'Set Daily Direction',
                    style: AppTextStyles.labelLG.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Set clear goals and align actions for today',
                    style: AppTextStyles.bodySM.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE MISSION CARD (mission set)
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveMissionCard extends ConsumerWidget {
  final Mission mission;
  const _ActiveMissionCard({required this.mission});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = mission.progress;
    final progressPct = (progress * 100).toInt();
    final notifier = ref.read(homeProvider.notifier);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0089FD), // top    — brand blue
            Color(0xFF1892FF), // 15%
            Color(0xFF299FFF), // 35%
            Color(0xFF3AB2FF), // 60%
            Color(0xFF4CC4FF), // 85%
            Color(0xFF55CFFF), // bottom — light sky blue
          ],
          stops: [0.0, 0.15, 0.35, 0.60, 0.85, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Color(0x4D0089FD),
            offset: Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtils.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Objective + badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    mission.objective,
                    style: AppTextStyles.headingMD.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: ScreenUtils.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtils.sm,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
                    border: Border.all(color: AppColors.white),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.white.withOpacity(0.2),
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    mission.isDone ? 'Done' : 'Completed',
                    style: AppTextStyles.labelLG.copyWith(
                      color: mission.isAllCompleted
                          ? Colors.white
                          : AppColors.bodyText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: ScreenUtils.vSm),

            // Progress label + percent
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: AppTextStyles.labelLG.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '$progressPct%',
                  style: AppTextStyles.labelSM.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.h),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(100.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6.h,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),

            SizedBox(height: ScreenUtils.vMd),

            // Task list
            ...mission.tasks.map(
              (task) => _MissionTaskRow(
                task: task,
                onToggle: () => notifier.toggleTask(task.id),
              ),
            ),

            // Done button when all complete
            if (mission.isAllCompleted && !mission.isDone) ...[
              SizedBox(height: ScreenUtils.vSm),
              GestureDetector(
                onTap: notifier.markMissionDone,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: ScreenUtils.iconSm,
                      ),
                      SizedBox(width: ScreenUtils.xs),
                      Text(
                        'Done',
                        style: AppTextStyles.labelMD.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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

class _MissionTaskRow extends StatelessWidget {
  final MissionTask task;
  final VoidCallback onToggle;

  const _MissionTaskRow({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtils.md),
      margin: EdgeInsets.only(bottom: ScreenUtils.vMd),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.25),
        borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
        border: Border.all(color: AppColors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.white.withOpacity(0.2),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onToggle,
        child: Row(
          children: [
            // Circle check
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: Colors.white.withOpacity(0.7),
                  width: 1.5,
                ),
              ),
              child: task.isCompleted
                  ? Icon(
                      Icons.check_rounded,
                      size: 12.w,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            SizedBox(width: ScreenUtils.sm),
            Expanded(
              child: Text(
                task.title,
                style: AppTextStyles.bodyMD.copyWith(
                  color: Colors.white.withOpacity(
                    task.isCompleted ? 0.6 : 0.95,
                  ),
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CARD
// ─────────────────────────────────────────────────────────────────────────────

enum _StatCardType { streak, missions }

class _StatCard extends StatelessWidget {
  final _StatCardType type;
  final int count;

  const _StatCard({required this.type, required this.count});

  bool get _isEmpty => count == 0;
  bool get _isStreak => type == _StatCardType.streak;

  // ── Zero state (both cards) ──────────────────────────────────────────────
  static const _zeroShadows = [
    BoxShadow(color: Color(0x08787878), offset: Offset(1, 1), blurRadius: 4),
    BoxShadow(color: Color(0x08787878), offset: Offset(3, 6), blurRadius: 7),
    BoxShadow(color: Color(0x05787878), offset: Offset(8, 13), blurRadius: 9),
    BoxShadow(color: Color(0x00787878), offset: Offset(13, 23), blurRadius: 11),
    BoxShadow(color: Color(0x00787878), offset: Offset(21, 36), blurRadius: 12),
  ];

  // ── Streak active gradients (sampled from Figma asset) ──────────────────
  static const _streakBgGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFC), // top   — near white
      Color(0xFFFFF2E9), // 15%
      Color(0xFFFFDFC8), // 35%
      Color(0xFFFFC49C),
      Color(0xFFFFC49C), // 60%
      //Color(0xFFFFA066), // 85%
    ],
    stops: [0.0, 0.15, 0.35, 0.60, 0.85, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const _streakTextGradient = LinearGradient(
    colors: [
      Color(0xFFFFA066), // top text — mid orange
      Color(0xFFFF8538), // bottom text — deep orange
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Missions active (blue, same as before) ────────────────────────────────
  static const _missionBgGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF), // top   — pure white
      Color(0xFFFFFFFC),
      Color(0xFFD8EDFF), // 15%   — icy blue tint
      Color(0xFFA5D5FF), // 35%   — soft sky
      Color(0xFF66B7FF),
      Color(0xFF66B7FF), // 60%   — mid blue
    ],
    stops: [0.0, 0.15, 0.35, 0.60, 0.85, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const _missionTextGradient = LinearGradient(
    colors: [
      Color(0xFF2699FF), // top text — strong blue
      Color(0xFF0088FF), // bottom text — brand blue
    ],
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

  // ── Zero state card ───────────────────────────────────────────────────────
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
            _isStreak ? 'assets/images/fire.png' : 'assets/images/mission.png',
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

  // ── Active gradient card ──────────────────────────────────────────────────
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
          Image.asset(
            _isStreak ? 'assets/images/fire.png' : 'assets/images/complete.png',
            width: 58.w,
            height: 58.h,
          ),
          SizedBox(height: ScreenUtils.vMd),
          // Gradient text via ShaderMask
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

// ─────────────────────────────────────────────────────────────────────────────
// QUICK ACTION CARD
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  final String image;

  const _QuickActionCard({
    required this.label,
    required this.sublabel,
    required this.onTap,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtils.md),
        decoration: BoxDecoration(
          color: AppColors.secondarySurface,
          borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(image, height: 38.h, width: 38.w),
            SizedBox(height: ScreenUtils.vSm),
            Text(
              label,
              style: AppTextStyles.labelLG.copyWith(
                color: AppColors.headingText,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              sublabel,
              style: AppTextStyles.bodyMD.copyWith(color: AppColors.bodyText),
            ),
          ],
        ),
      ),
    );
  }
}
