import 'package:flutter/widgets.dart';

/// Used by [GoRouter] and auth/session interceptors so navigation works
/// without a widget [BuildContext] from the caller site.
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
