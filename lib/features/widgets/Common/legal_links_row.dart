import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/Routes/app_routes.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/features/Setting/Model/legal_model.dart';

/// UN-46: Privacy Policy / Terms of Use links for Login and Signup — reuses
/// the same generic Policy screen route/content Settings → Legal uses.
class LegalLinksRow extends StatelessWidget {
  const LegalLinksRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTextStyles.bodySM.copyWith(color: AppColors.bodyText),
          children: [
            const TextSpan(text: 'By continuing, you agree to our '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => context.push(
                  AppRoutes.privacyPolicy,
                  extra: const PolicyScreenArgs(
                    title: 'Terms of Use',
                    lastUpdated: 'September 1, 2023',
                    sections: termsOfUseSections,
                  ),
                ),
                child: Text(
                  'Terms of Use',
                  style: AppTextStyles.bodySM.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const TextSpan(text: ' and '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => context.push(
                  AppRoutes.privacyPolicy,
                  extra: const PolicyScreenArgs(
                    title: 'Privacy Policy',
                    lastUpdated: 'September 1, 2023',
                    sections: privacyPolicySections,
                  ),
                ),
                child: Text(
                  'Privacy Policy',
                  style: AppTextStyles.bodySM.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
