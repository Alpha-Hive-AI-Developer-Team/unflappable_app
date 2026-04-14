  
import 'package:unflappable/core/storage/local_storage.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/service/dio_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  DioHelper.init();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
