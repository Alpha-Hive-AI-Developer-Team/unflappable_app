import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/Routes/app_routes.dart';
import 'package:unflappable/core/storage/local_storage.dart';
import 'package:unflappable/core/utils/app_strings.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';
import 'package:unflappable/features/Welcome%20Screens/splash-provider/splash_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref.read(splashProvider.notifier).navigateNext(() async {
        final isLoggedIn =
            LocalStorage.getData(LocalStorage.accessToken)?.isNotEmpty ==
                true;
        if (isLoggedIn) {
          await ref.read(userProvider.notifier).restoreSessionIfNeeded();
        }
        if (!mounted) return;
        final stillLoggedIn =
            LocalStorage.getData(LocalStorage.accessToken)?.isNotEmpty ==
                true;
        if (stillLoggedIn) {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.welcome);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 2),
          tween: Tween<double>(begin: 0.5, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform.scale(scale: value, child: child),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 280.h),
              Image.asset(logo, width: 440.w, height: 294.h),
              const Spacer(),
              Text(
                "Loading…",
                style: AppTextStyles.headingSM.copyWith(
                  color: AppColors.bodyText,
                ),
              ),
              SizedBox(height: 24.h), // Optional: bottom spacing
            ],
          ),
        ),
      ),
    );
  }
}
