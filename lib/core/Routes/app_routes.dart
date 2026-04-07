import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/features/Auth/create_password/create_pass.dart';
import 'package:unflappable/features/Auth/forget_password/forget_passScreen.dart';
import 'package:unflappable/features/Auth/login_screen/login_screen.dart';
import 'package:unflappable/features/Auth/otp_screen/otp_screen.dart';
import 'package:unflappable/features/Auth/signup_screen/signup_screen.dart';
import 'package:unflappable/features/Reset/UI/reset_emotion.dart';
import 'package:unflappable/features/navbar_wrapper/home_shell.dart';
import 'package:unflappable/features/Home/UI/new_mission.dart';
import 'package:unflappable/features/Home/UI/notification.dart';
import 'package:unflappable/features/Onboarding/UI/onboarding_screen.dart';
import 'package:unflappable/features/Reset/UI/reset_screen.dart';
import 'package:unflappable/features/Reset/UI/reset_trigger.dart';
import 'package:unflappable/features/Welcome%20Screens/welcome_screen.dart';
import 'package:unflappable/features/Welcome%20Screens/splash_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const otpVerification = '/otp-verification';
  static const forgotPassword = '/forgot-password';
  static const createNewPassword = '/create-new-password';
  static const home = '/home';
  static const notifications = '/notifications';
  static const mission = '/mission';
  static const reset = '/reset';
  static const resetTrigger = '/reset/trigger';
  static const resetEmotion = '/reset/emotion';
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
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
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
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingQuestionnaireScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        builder: (context, state) {
          final purpose = state.uri.queryParameters['purpose'] == 'signup'
              ? OtpPurpose.signup
              : OtpPurpose.forgotPassword;
          return OtpVerificationScreen(purpose: purpose);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.createNewPassword,
        builder: (context, state) => const CreateNewPasswordScreen(),
      ),
      GoRoute(
        name: 'home',
        path: AppRoutes.home,
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        name: 'mission',
        path: AppRoutes.mission,
        builder: (context, state) => const NewMissionScreen(),
      ),
      GoRoute(
        name: 'notifications',
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        name: 'reset',
        path: AppRoutes.reset,
        builder: (context, state) => const ResetScreen(),
      ),
      GoRoute(
        name: 'resetTrigger',
        path: AppRoutes.resetTrigger,
        builder: (context, state) => const ResetTriggerScreen(),
      ),
      GoRoute(
        name: 'resetEmotion',
        path: AppRoutes.resetEmotion,
        builder: (context, state) => const ResetEmotionScreen(),
      ),
    ],
  );
});
