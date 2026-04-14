import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/features/Auth/create_password/create_pass.dart';
import 'package:unflappable/features/Auth/forget_password/forget_passScreen.dart';
import 'package:unflappable/features/Auth/login_screen/login_screen.dart';
import 'package:unflappable/features/Auth/otp_screen/otp_screen.dart';
import 'package:unflappable/features/Auth/signup_screen/signup_screen.dart';
import 'package:unflappable/features/Pricing/UI/pricing_screen.dart';
import 'package:unflappable/features/Reset/UI/reset_emotion.dart';
import 'package:unflappable/features/Setting/UI/account_screen.dart';
import 'package:unflappable/features/Setting/UI/Help%20Center/help_center.dart';
import 'package:unflappable/features/Setting/UI/Legal%20Screens/legal_screen.dart';
import 'package:unflappable/features/Setting/Model/legal_model.dart';
import 'package:unflappable/features/Setting/UI/Legal%20Screens/privacy_term.dart';
import 'package:unflappable/features/Setting/UI/notification_setting.dart';
import 'package:unflappable/features/Setting/UI/setting_screen.dart';
import 'package:unflappable/features/Weekly%20Review/UI/review_screen.dart';
import 'package:unflappable/features/navbar_wrapper/home_shell.dart';
import 'package:unflappable/features/Home/UI/new_mission.dart';
import 'package:unflappable/features/Home/UI/notification.dart';
import 'package:unflappable/features/Onboarding/UI/onboarding_screen.dart';
import 'package:unflappable/features/Reset/UI/reset_screen.dart';
import 'package:unflappable/features/Reset/UI/reset_trigger.dart';
import 'package:unflappable/features/Welcome%20Screens/welcome_screen.dart';
import 'package:unflappable/features/Welcome%20Screens/splash_screen.dart';

class PolicyScreenArgs {
  final String title;
  final String lastUpdated;
  final List<PolicySection> sections;

  const PolicyScreenArgs({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });
}

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
  static const weeklyReview = '/weeklyReview';
  static const pricing = '/pricing';
  static const helpCenter = '/help-center';
  static const legal = '/legal';
  static const account = '/account';
  static const settings = '/settings';
  static const notificationSetting = '/notificationSetting';

  static const privacyPolicy = '/privacy-policy';
  static const termsOfUse = '/terms-of-use';
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
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpVerificationScreen(purpose: purpose, email: email);
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
      GoRoute(
        name: 'weeklyReview',
        path: AppRoutes.weeklyReview,
        builder: (context, state) => const WeeklyReviewScreen(),
      ),
      GoRoute(
        name: 'pricing',
        path: AppRoutes.pricing,
        builder: (context, state) => const PricingPlansScreen(),
      ),
      GoRoute(
        name: 'settings',
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        name: 'account',
        path: AppRoutes.account,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        name: 'help-center',
        path: AppRoutes.helpCenter,
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        name: 'legal',
        path: AppRoutes.legal,
        builder: (context, state) => const LegalScreen(),
      ),
      GoRoute(
        name: 'notificationSetting',
        path: AppRoutes.notificationSetting,
        builder: (context, state) => const NotificationsSetting(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (context, state) {
          final args = state.extra as PolicyScreenArgs;
          return PolicyScreen(
            title: args.title,
            lastUpdated: args.lastUpdated,
            sections: args.sections,
          );
        },
      ),
    ],
  );
});
