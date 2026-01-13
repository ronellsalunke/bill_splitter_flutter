import 'package:bs_flutter/app/modules/edit_bill/edit_bill_screen.dart';
import 'package:bs_flutter/app/modules/home/home_screen.dart';
import 'package:bs_flutter/app/modules/payment_plans/payment_plans_screen.dart';
import 'package:bs_flutter/app/modules/settings/settings_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(name: 'home', path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(name: 'settings', path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(
      name: 'bill',
      path: '/bill/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EditBillScreen(billId: id);
      },
    ),
    GoRoute(name: 'payment-plans', path: '/payment-plans', builder: (context, state) => const PaymentPlansScreen())
  ],
);
