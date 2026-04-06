import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/features/home/home_screen/home_direction_screen.dart';
import 'package:unflappable/features/home/home_screen/insights_screen.dart';
import 'package:unflappable/features/home/home_screen/plan_screen.dart';
import 'package:unflappable/features/home/home_screen/weekly_screen.dart';

// Notifier for managing navbar index
class HomeNavbarNotifier extends StateNotifier<int> {
  HomeNavbarNotifier() : super(0);

  void setIndex(int index) => state = index;
}

// Provider to manage navbar state
final homeNavbarIndexProvider = StateNotifierProvider<HomeNavbarNotifier, int>(
  (_) => HomeNavbarNotifier(),
);

class HomeNavBarWrapper extends ConsumerWidget {
  const HomeNavBarWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(homeNavbarIndexProvider);
    final destinations = _adaptiveDestinations;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: const [
            HomeDirectionScreen(),
            InsightsScreen(),
            PlanScreen(),
            WeeklyScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NativeGlassNavBar(
        tabs: destinations
            .map(
              (dest) =>
                  NativeGlassNavBarItem(label: dest.label, symbol: dest.symbol),
            )
            .toList(),
        currentIndex: selectedIndex,
        onTap: (index) =>
            ref.read(homeNavbarIndexProvider.notifier).setIndex(index),
        tintColor: AppColors.primary,
        actionButton: TabBarActionButton(
          symbol: PlatformInfo.isIOS26OrHigher()
              ? 'plus.circle.fill'
              : 'plus.circle',
          onTap: () => ref.read(homeNavbarIndexProvider.notifier).setIndex(0),
        ),
        fallback: Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: destinations.asMap().entries.map((entry) {
              final i = entry.key;
              final dest = entry.value;
              final isSelected = i == selectedIndex;
              return _NavItem(
                icon: dest.icon,
                activeIcon: dest.selectedIcon,
                label: dest.label,
                selected: isSelected,
                onTap: () =>
                    ref.read(homeNavbarIndexProvider.notifier).setIndex(i),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  List<_AdaptiveDestination> get _adaptiveDestinations => [
    _AdaptiveDestination(
      label: 'Home',
      iosSymbol: 'house.fill',
      iosIcon: CupertinoIcons.home,
      iosSelectedIcon: CupertinoIcons.home,
      androidIcon: Icons.home_outlined,
      androidSelectedIcon: Icons.home,
    ),
    _AdaptiveDestination(
      label: 'Reset',
      iosSymbol: 'arrow.counterclockwise',
      iosIcon: CupertinoIcons.refresh,
      iosSelectedIcon: CupertinoIcons.refresh,
      androidIcon: Icons.refresh_outlined,
      androidSelectedIcon: Icons.refresh,
    ),
    _AdaptiveDestination(
      label: 'Progress',
      iosSymbol: 'chart.bar.fill',
      iosIcon: CupertinoIcons.chart_bar,
      iosSelectedIcon: CupertinoIcons.chart_bar,
      androidIcon: Icons.show_chart_outlined,
      androidSelectedIcon: Icons.show_chart,
    ),
    _AdaptiveDestination(
      label: 'Setting',
      iosSymbol: 'gear',
      iosIcon: CupertinoIcons.gear,
      iosSelectedIcon: CupertinoIcons.gear,
      androidIcon: Icons.settings_outlined,
      androidSelectedIcon: Icons.settings,
    ),
  ];
}

class _AdaptiveDestination {
  final String label;
  final String iosSymbol;
  final IconData iosIcon;
  final IconData iosSelectedIcon;
  final IconData androidIcon;
  final IconData androidSelectedIcon;

  _AdaptiveDestination({
    required this.label,
    required this.iosSymbol,
    required this.iosIcon,
    required this.iosSelectedIcon,
    required this.androidIcon,
    required this.androidSelectedIcon,
  });

  String get symbol => PlatformInfo.isIOS26OrHigher() ? iosSymbol : iosSymbol;

  IconData get icon => PlatformInfo.isIOS() ? iosIcon : androidIcon;

  IconData get selectedIcon =>
      PlatformInfo.isIOS() ? iosSelectedIcon : androidSelectedIcon;
}

class PlatformInfo {
  static bool isIOS() => Platform.isIOS;

  static bool isIOS26OrHigher() {
    if (!Platform.isIOS) return false;
    final version = Platform.operatingSystemVersion;
    final regex = RegExp(r'OS (\d+)_?');
    final match = regex.firstMatch(version);
    if (match == null) return false;
    final major = int.tryParse(match.group(1) ?? '0') ?? 0;
    return major >= 16; // iOS16+ for modern symbols
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: selected ? AppColors.primary : AppColors.bodyText,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.bodyText,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
