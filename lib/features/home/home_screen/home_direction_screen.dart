import 'package:flutter/material.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'home_screen_widgets.dart';

class HomeDirectionScreen extends StatelessWidget {
  const HomeDirectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtils.lg,
          vertical: ScreenUtils.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderWidget(),
            SizedBox(height: ScreenUtils.vXxl),
            const DailyDirectionCard(),
            SizedBox(height: ScreenUtils.vXxl),
            const StatsSection(),
            SizedBox(height: ScreenUtils.vXxl),
            const SurfaceAreaSection(),
            SizedBox(height: ScreenUtils.vXxl),
          ],
        ),
      ),
    );
  }
}
