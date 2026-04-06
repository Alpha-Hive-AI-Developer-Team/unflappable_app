import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Home/UI/home_screen.dart';
import 'package:unflappable/features/navbar_wrapper/navbar.dart';

final navIndexProvider = StateProvider<int>((_) => 0);

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);

    const pages = [
      HomeScreen(),
      _PlaceholderScreen(label: 'Reset'),
      _PlaceholderScreen(label: 'Progress'),
      _PlaceholderScreen(label: 'Settings'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      // No bottomNavigationBar — navbar floats inside the Stack in body
      body: Stack(
        children: [
          // Page content — padded at bottom so content isn't hidden under navbar
          Positioned.fill(child: pages[index]),

          // Floating pill navbar pinned to bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppNavBar(
              currentIndex: index,
              onTap: (i) => ref.read(navIndexProvider.notifier).state = i,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label, style: AppTextStyles.headingMD));
  }
}
