import 'package:firebase_core/firebase_core.dart';
import 'package:unflappable/core/notifications/notification_manager.dart';
import 'package:unflappable/core/storage/local_storage.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/firebase_options.dart';
import 'package:unflappable/service/dio_helper.dart';
import 'package:unflappable/service/in_app_purchase/in_app_purchase_service.dart';

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
  late InAppPurchaseService _iapService;

  @override
  void initState() {
    super.initState();
    _initializeInAppPurchase();
  }

  Future<void> _initializeInAppPurchase() async {
    _iapService = InAppPurchaseService();
    
    try {
      await _iapService.initialize(
        onPurchaseUpdate: (purchase) {
          _handlePurchaseUpdate(purchase);
        },
        onError: (error) {
          _handlePurchaseError(error);
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize in-app purchase: $e');
    }
  }

  void _handlePurchaseUpdate(dynamic purchase) {
    // This will be handled by the subscription notifier when a purchase is made
    debugPrint('Purchase update: $purchase');
  }

  void _handlePurchaseError(String error) {
    debugPrint('Purchase error: $error');
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
  void dispose() {
    _iapService.dispose();
    super.dispose();
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
