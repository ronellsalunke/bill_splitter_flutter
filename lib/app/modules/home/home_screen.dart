import 'package:bs_flutter/app/bloc/bill_bloc/bill_bloc.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_event.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_state.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/res/app_colors.dart';
import 'package:bs_flutter/app/res/app_icons.dart';
import 'package:bs_flutter/app/widgets/common_button.dart';
import 'package:bs_flutter/app/widgets/common_dotted_button.dart';
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
    return BlocBuilder<BillBloc, BillState>(
      builder: (context, state) {
        final bool hasBills = state is BillLoaded && state.bills.isNotEmpty;
        return Scaffold(
          appBar: AppBar(
            leading: SvgPicture.asset(AppIcons.logoIcon).paddingOnly(left: 16),
            leadingWidth: 48,
            title: const Text('bill splitter'),
            centerTitle: false,
          ),
          bottomNavigationBar: hasBills
              ? Container(
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundColor,
                    border: Border(top: BorderSide(color: Colors.black, width: 1)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DottedButton(
                          text: 'add new bill',
                          icon: Icons.add,
                          mainAxisSize: MainAxisSize.max,
                          onTap: () {
                            context.pushNamed('bill', pathParameters: {'id': 'new'});
                          },
                        ),
                        verticalSpace(10),
                        CommonButton(text: 'calculate split', mainAxisSize: MainAxisSize.max, onTap: () {}),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(AppIcons.logoIcon, color: AppColors.hintColor, width: 60, height: 60),
        verticalSpace(12),
        Text('no bills yet', style: TextStyle(color: AppColors.hintColor)),
        verticalSpace(24),

        DottedButton(
          text: 'add new bill',
          icon: Icons.add,
          mainAxisSize: MainAxisSize.max,
          onTap: () {
            context.pushNamed('bill', pathParameters: {'id': 'new'});
          },
        ),
      ],
    ).paddingSymmetric(horizontal: 16);
  }

  Widget _dismissibleBillCard(Bill bill) {
    return Dismissible(
      key: ValueKey(bill.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (direction) {
        HapticFeedback.lightImpact();
        context.read<BillBloc>().add(DeleteBill(bill.id));
      },
      child: billCard(bill),
    ).paddingSymmetric(vertical: 6);
  }

  Widget billCard(Bill bill) {
    return ClipPath(
      clipper: ReceiptClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),

        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PAID BY', style: TextStyle(fontSize: 12)),
            verticalSpace(8),
            Text(bill.paidBy, style: const TextStyle(fontSize: 16)),
            verticalSpace(8),
            itemQtyWidget(bill.items),
            verticalSpace(8),
            Row(
              children: [
                Text('tax: ${bill.tax}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                horizontalSpace(8),
                Text('service: ${bill.service}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
            verticalSpace(8),
            DottedLine(dashLength: 6, dashColor: AppColors.dividerColor),
            verticalSpace(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('total', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                horizontalSpace(8),
                Text('₹ ${bill.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
              Text('${item.quantity} x ${item.name}', style: TextStyle(fontSize: 12)),
              Text('₹ ${item.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 12)),
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
