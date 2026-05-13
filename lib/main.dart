import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:unflappable/core/notifications/notification_manager.dart';
import 'package:unflappable/core/storage/local_storage.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/firebase_options.dart';
import 'package:unflappable/service/dio_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  DioHelper.init();
  await NotificationManager.init();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  bool _hasConfiguredRouter = false;
  StreamSubscription<List<PurchaseDetails>>? _iapPurchaseSub;

  @override
  void initState() {
    super.initState();
    // in_app_purchase: subscribe early so purchase updates are not missed
    // (especially fast sandbox completions during Upgrade).
    _iapPurchaseSub = InAppPurchase.instance.purchaseStream.listen(
      (List<PurchaseDetails> _) {},
      onError: (Object e, StackTrace st) {
        assert(() {
          debugPrint('IAP purchaseStream error: $e');
          return true;
        }());
      },
    );
  }

  @override
  void dispose() {
    unawaited(_iapPurchaseSub?.cancel());
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasConfiguredRouter) {
      _hasConfiguredRouter = true;
      final router = ref.read(goRouterProvider);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationManager.configureRouter(router);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(ScreenUtils.designWidth, ScreenUtils.designHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Unflappable App',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        );
      },
    );
  }
}
