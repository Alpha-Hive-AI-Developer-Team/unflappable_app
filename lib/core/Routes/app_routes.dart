import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/features/UI/Auth/create_pass.dart';
import 'package:unflappable/features/UI/Auth/forget_passScreen.dart';
import 'package:unflappable/features/UI/Auth/login_screen.dart';
import 'package:unflappable/features/UI/Auth/otp_screen.dart';
import 'package:unflappable/features/UI/Auth/signup_screen.dart';
import 'package:unflappable/features/UI/Onboarding/onboarding_screen.dart';
import 'package:unflappable/features/UI/Onboarding/splash_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const otpVerification = '/otp-verification';
  static const forgotPassword = '/forgot-password';
  static const createNewPassword = '/create-new-password';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.createNewPassword,
        builder: (context, state) => const CreateNewPasswordScreen(),
      ),
    ],
  );
});
