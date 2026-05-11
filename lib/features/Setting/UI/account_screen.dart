import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';
import 'package:unflappable/features/Setting/Provider/setting_notifier.dart';
import 'package:unflappable/features/Setting/Widgets/shared_widgets.dart';
import 'package:unflappable/features/Subscription/Provider/subscription_notifier.dart';
import 'package:unflappable/features/widgets/Common/helping_appBar.dart';
import 'package:unflappable/features/widgets/Common/snackbar.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(settingsProvider).accountDraft;
    _nameCtrl = TextEditingController(text: draft.fullName)
      ..addListener(
        () => ref.read(settingsProvider.notifier).setDraftName(_nameCtrl.text),
      );
    _emailCtrl = TextEditingController(text: draft.email)
      ..addListener(
        () =>
            ref.read(settingsProvider.notifier).setDraftEmail(_emailCtrl.text),
      );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);
    final userState = ref.watch(userProvider);
    final subscriptionState = ref.watch(subscriptionProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final subscriptionNotifier = ref.read(subscriptionProvider.notifier);

    if (!subscriptionState.hasLoadedInitialData) {
      Future.microtask(subscriptionNotifier.loadInitialData);
    }

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
                    AccountField(label: 'Full Name', controller: _nameCtrl),
                    SizedBox(height: ScreenUtils.vMd),

                    // Email — read-only
                    AccountField(
                      label: 'Email',
                      controller: _emailCtrl,
                      readOnly: true,
                      filled: true,
                    ),
                    SizedBox(height: ScreenUtils.vMd),

                    // Subscription — read-only
                    AccountField(
                      label: 'Subscription',
                      controller: TextEditingController(
                        text: subscriptionState.isPro ? 'Pro Monthly' : 'Free',
                      ),
                      readOnly: true,
                      filled: true,
                    ),
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
                onTap: () async {
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
