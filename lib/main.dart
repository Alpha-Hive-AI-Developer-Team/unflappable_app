import 'package:firebase_core/firebase_core.dart';
import 'package:unflappable/core/notifications/notification_manager.dart';
import 'package:unflappable/core/storage/local_storage.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/service/dio_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  await Firebase.initializeApp();
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
          title: 'Framt App',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        );
      },
    );
  }
}
