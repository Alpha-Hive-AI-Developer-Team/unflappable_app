import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';
// PRO FEATURE — disabled for the current free-only release (UserState was
// only needed for the Subscription label below).
// import 'package:unflappable/features/Auth/providers/user_state.dart';
import 'package:unflappable/features/Setting/Provider/setting_notifier.dart';
import 'package:unflappable/features/Setting/Widgets/shared_widgets.dart';
import 'package:unflappable/features/widgets/Common/helping_appBar.dart';
import 'package:unflappable/features/widgets/Common/snackbar.dart';

// PRO FEATURE — disabled for the current free-only release.
// String _subscriptionLabel(UserState userState) {
//   if (!userState.isPro) return 'Free';
//   final id = userState.user?.proProductId ?? '';
//   final lower = id.toLowerCase();
//   if (lower.contains('yearly')) return 'Pro Yearly';
//   if (lower.contains('monthly')) return 'Pro Monthly';
//   return 'Pro';
// }
//
// // Free-only release: subscriptions are disabled, always show Free.
// String _subscriptionLabel(UserState userState) => 'Free';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  // Using `ref` inside dispose() is unsafe (the widget is already
  // unmounting) — capture the notifier here instead, while it's still safe.
  late final SettingsNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(settingsProvider.notifier);
    final draft = ref.read(settingsProvider).accountDraft;
    _nameCtrl = TextEditingController(text: draft.fullName)
      ..addListener(() => _notifier.setDraftName(_nameCtrl.text));
    _emailCtrl = TextEditingController(text: draft.email)
      ..addListener(() => _notifier.setDraftEmail(_emailCtrl.text));
  }

  @override
  void dispose() {
    // US-27: discard any unsaved name edit so it can't reappear next time
    // this screen opens.
    _notifier.discardUnsavedAccountDraft();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);
    // PRO FEATURE — disabled for the current free-only release (was only
    // read here for the Subscription field below).
    // final userState = ref.watch(userProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            HelpingAppBar(title: 'Account'),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtils.authHorizontalMargin,
                  vertical: ScreenUtils.vMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    AccountField(
                      label: 'Full Name',
                      controller: _nameCtrl,
                      errorText: state.accountNameError,
                      maxLength: 50,
                    ),
                    SizedBox(height: ScreenUtils.vMd),

                    // Email — read-only
                    AccountField(
                      label: 'Email',
                      controller: _emailCtrl,
                      readOnly: true,
                      filled: true,
                    ),
                    // PRO FEATURE — disabled for the current free-only
                    // release. No subscription indicator on the Account
                    // screen while the app is free-only.
                    // SizedBox(height: ScreenUtils.vMd),
                    // AccountField(
                    //   label: 'Subscription',
                    //   controller: TextEditingController(
                    //     text: _subscriptionLabel(userState),
                    //   ),
                    //   readOnly: true,
                    //   filled: true,
                    // ),
                  ],
                ),
              ),
            ),

            // Save Changes
            Padding(
              padding: EdgeInsets.only(
                left: ScreenUtils.authHorizontalMargin,
                right: ScreenUtils.authHorizontalMargin,
                bottom: ScreenUtils.vXxl,
                top: ScreenUtils.vMd,
              ),
              child: PrimaryButton(
                label: 'Save Changes',
                isLoading: state.isSavingAccount,
                // US-26 / US-27: disabled until the name actually changed
                // from what's saved, and is itself valid.
                onTap:
                    (!state.hasUnsavedAccountChanges ||
                        state.accountNameError != null)
                    ? null
                    : () async {
                  await notifier.saveAccount();
                  if (!context.mounted) return;
                  final latest = ref.read(settingsProvider);
                  if (latest.errorMessage != null) {
                    AppSnackbar.showError(
                      context,
                      message: latest.errorMessage!,
                    );
                    return;
                  }
                  ref
                      .read(userProvider.notifier)
                      .updateUserInfo(
                        name: latest.accountDraft.fullName,
                        email: latest.accountDraft.email,
                      );
                  AppSnackbar.showSuccess(
                    context,
                    message: 'Account updated successfully.',
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
