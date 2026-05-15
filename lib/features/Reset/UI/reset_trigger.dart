import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/Routes/app_routes.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/features/Reset/Provider/reset_provider.dart';
import 'package:unflappable/features/widgets/Common/buttons.dart';
import 'package:unflappable/features/widgets/Common/helping_appBar.dart';

class ResetTriggerScreen extends ConsumerStatefulWidget {
  const ResetTriggerScreen({super.key});

  @override
  ConsumerState<ResetTriggerScreen> createState() => _ResetTriggerScreenState();
}

class _ResetTriggerScreenState extends ConsumerState<ResetTriggerScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Pre-fill if user already typed something
    _controller = TextEditingController(
      text: ref.read(resetProvider).trigger ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onContinue() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(resetProvider.notifier).setTrigger(text);
    context.push(AppRoutes.resetEmotion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── AppBar ───────────────────────────────────────────────────
            HelpingAppBar(title: 'Reset'),
            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtils.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What triggered this feeling?',
                      style: AppTextStyles.headingSM.copyWith(
                        color: AppColors.labelText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: ScreenUtils.vMd),

                    // ── Text Field ───────────────────────────────────────
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      style: AppTextStyles.bodyLG.copyWith(
                        color: AppColors.labelText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. Client delayed decision',
                        hintStyle: AppTextStyles.captionHint.copyWith(
                          color: AppColors.bodyText,
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.borderGrey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: ScreenUtils.vSm,
                        ),
                      ),
                      onChanged: (val) =>
                          ref.read(resetProvider.notifier).setTrigger(val),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _onContinue(),
                    ),
                  ],
                ),
              ),
            ),

            // ── Continue Button ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                ScreenUtils.lg,
                0,
                ScreenUtils.lg,
                ScreenUtils.vXxl,
              ),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (_, value, __) {
                  final enabled = value.text.trim().isNotEmpty;
                  return SizedBox(
                    width: double.infinity,
                    height: ScreenUtils.buttonHeight,
                    child: PrimaryButton(
                      isLoading: false,
                      label: 'Continue',
                      onTap: enabled ? _onContinue : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
