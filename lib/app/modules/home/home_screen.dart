import 'package:bs_flutter/app/bloc/bill_bloc/bill_bloc.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_event.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_state.dart';
import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_bloc.dart';
import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_event.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/res/app_icons.dart';
import 'package:bs_flutter/app/widgets/common_button.dart';
import 'package:bs_flutter/app/widgets/common_outline_button.dart';
import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:bs_flutter/extensions/widget_extensions.dart';
import 'package:bs_flutter/utils/widget_utils.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return BlocBuilder<BillBloc, BillState>(
      builder: (context, state) {
        final bool hasBills = state is BillLoaded && state.bills.isNotEmpty;
        return Scaffold(
          appBar: AppBar(
            leading: SvgPicture.asset(AppIcons.logoIcon, color: colorScheme.primary).paddingOnly(left: 16),
            leadingWidth: 48,
            title: const Text('bill splitter'),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () {
                  context.pushNamed('settings');
                },
                icon: const Icon(Icons.settings_rounded),
              ),
            ],
          ),
          bottomNavigationBar: hasBills
              ? Container(
                  decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(16),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Flexible(
                          child: CommonOutlineButton(
                            borderRadius: 8,
                            text: 'add bill',
                            icon: Icons.add_circle_rounded,
                            iconColor: colorScheme.primary,
                            mainAxisSize: MainAxisSize.max,
                            onTap: () {
                              context.pushNamed('bill', pathParameters: {'id': 'new'});
                            },
                          ),
                        ),
                        horizontalSpace(10),
                        Flexible(
                          child: CommonButton(
                            borderRadius: 8,
                            icon: Icons.calculate_rounded,
                            iconColor: colorScheme.onPrimary,
                            text: 'split',
                            mainAxisSize: MainAxisSize.max,
                            onTap: () {
                              context.read<PaymentPlansBloc>().add(CalculateSplit((state).bills));
                              context.pushNamed('payment-plans');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
          body: BlocBuilder<BillBloc, BillState>(
            builder: (context, state) {
              if (state is BillLoaded && state.bills.isEmpty) {
                return Center(child: _buildAddNewBillButton());
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      if (state is BillLoading)
                        const CircularProgressIndicator()
                      else if (state is BillError)
                        Text('Error: ${state.message}')
                      else if (state is BillLoaded)
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [const Text('bills'), Text('${state.bills.length}')],
                            ),
                            verticalSpace(12),
                            ...state.bills.map((bill) => _dismissibleBillCard(bill)),
                          ],
                        )
                      else
                        const SizedBox(),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAddNewBillButton() {
    final colorScheme = context.colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(AppIcons.logoIcon, color: colorScheme.outline, width: 60, height: 60),
        verticalSpace(12),
        Text('no bills yet', style: TextStyle(color: colorScheme.outline)),
        verticalSpace(24),

        CommonOutlineButton(
          borderRadius: 8,
          text: 'add bill',
          icon: Icons.add_circle_rounded,
          iconColor: colorScheme.primary,
          mainAxisSize: MainAxisSize.max,
          onTap: () {
            context.pushNamed('bill', pathParameters: {'id': 'new'});
          },
        ),
      ],
    ).paddingSymmetric(horizontal: 16);
  }

  Widget _dismissibleBillCard(Bill bill) {
    final colorScheme = context.colorScheme;
    return Dismissible(
      key: ValueKey(bill.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete_outline, color: colorScheme.onError),
      ),
      onDismissed: (direction) {
        HapticFeedback.lightImpact();
        context.read<BillBloc>().add(DeleteBill(bill.id));
      },
      child: billCard(bill),
    ).paddingSymmetric(vertical: 6);
  }

  Widget billCard(Bill bill) {
    final colorScheme = context.colorScheme;
    return ClipPath(
      clipper: ReceiptClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),

        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PAID BY', style: TextStyle(fontSize: 12)),
            verticalSpace(8),
            Text(bill.paidBy, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            verticalSpace(8),
            itemQtyWidget(bill.items),
            verticalSpace(8),
            DottedLine(dashLength: 6, dashColor: colorScheme.onSurface),
            verticalSpace(8),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('tax', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
                    Text('${bill.tax}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
                  ],
                ),
                verticalSpace(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Text('service', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
                    Text('${bill.service}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
                  ],
                ),
              ],
            ),
            verticalSpace(8),
            DottedLine(dashLength: 6, dashColor: colorScheme.onSurface),
            verticalSpace(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                horizontalSpace(8),
                Text(
                  '₹ ${bill.amount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    ).onClick(() {
      context.pushNamed('bill', pathParameters: {'id': bill.id});
    });
  }
}

Widget itemQtyWidget(List<BillItem> items) {
  return Column(
    children: items
        .map(
          (item) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(
                '${item.quantity} x ${item.name}', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis,)),
              horizontalSpace(8),
              Text('₹ ${item.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
            ],
          ).paddingSymmetric(vertical: 4),
        )
        .toList(),
  );
}

class ReceiptClipper extends CustomClipper<Path> {
  final double zigzagDepth;
  final double zigzagWidth;

  ReceiptClipper({this.zigzagDepth = 4, this.zigzagWidth = 6});

  @override
  Path getClip(Size size) {
    final path = Path();

    // Start at top-left with zigzag
    path.moveTo(0, 0);

    // Top zigzag (from left to right)
    double x = 0;

    while (x < size.width) {
      x += zigzagWidth / 2;
      if (x > size.width) x = size.width;
      path.lineTo(x, zigzagDepth);

      x += zigzagWidth / 2;
      if (x > size.width) x = size.width;
      path.lineTo(x, 0);
    }

    // Right edge
    path.lineTo(size.width, size.height);

    // Bottom zigzag (from right to left)
    while (x > 0) {
      x -= zigzagWidth / 2;
      if (x < 0) x = 0;
      path.lineTo(x, size.height - zigzagDepth);

      x -= zigzagWidth / 2;
      if (x < 0) x = 0;
      path.lineTo(x, size.height);
    }

    // Left edge back to start
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
