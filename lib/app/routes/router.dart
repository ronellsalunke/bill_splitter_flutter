import 'package:go_router/go_router.dart';
import 'package:bs_flutter/app/modules/splash/splash_screen.dart';
import 'package:bs_flutter/app/modules/home/home_screen.dart';
import 'package:bs_flutter/app/modules/settings/settings_screen.dart';
import 'package:bs_flutter/app/modules/edit_bill/edit_bill_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(name: 'splash', path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(name: 'home', path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(name: 'settings', path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(
      name: 'bill',
      path: '/bill/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EditBillScreen(billId: id);
      },
    ),
  ],
);
