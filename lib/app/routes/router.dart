import 'package:bs_flutter/app/models/ocr/ocr_model.dart';
import 'package:bs_flutter/app/modules/edit_bill/edit_bill_screen.dart';
import 'package:bs_flutter/app/modules/home/home_screen.dart';
import 'package:bs_flutter/app/modules/payment_plans/payment_plans_screen.dart';
import 'package:bs_flutter/app/modules/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: [
    GoRoute(name: 'home', path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(name: 'settings', path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(
      name: 'bill',
      path: '/bill/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final extra = state.extra;
        OcrModel? ocrModel;
        bool fromShare = false;
        if (extra is Map) {
          ocrModel = extra['ocr'];
          fromShare = extra['fromShare'] == true;
        } else if (extra is OcrModel) {
          ocrModel = extra;
        }
        return EditBillScreen(billId: id, sharedOcrModel: ocrModel, fromShare: fromShare);
      },
    ),
    GoRoute(name: 'payment-plans', path: '/payment-plans', builder: (context, state) => const PaymentPlansScreen()),
  ],
);
