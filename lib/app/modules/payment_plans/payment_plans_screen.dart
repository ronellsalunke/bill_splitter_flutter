import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_bloc.dart';
import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_state.dart';
import 'package:bs_flutter/app/res/app_colors.dart';
import 'package:bs_flutter/extensions/extensions.dart';
import 'package:bs_flutter/extensions/widget_extensions.dart';
import 'package:bs_flutter/utils/widget_utils.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentPlansScreen extends StatefulWidget {
  const PaymentPlansScreen({super.key});

  @override
  State<PaymentPlansScreen> createState() => _PaymentPlansScreenState();
}

class _PaymentPlansScreenState extends State<PaymentPlansScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('payment plans'), centerTitle: false),
      body: BlocBuilder<PaymentPlansBloc, PaymentPlansState>(
        builder: (context, state) {
          if (state is PaymentPlansLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.buttonColor, year2023: false));
          } else if (state is PaymentPlansError) {
            return Center(child: Text(state.message));
          } else if (state is PaymentPlansLoaded) {
            return ListView.builder(
              itemCount: state.splitModel.paymentPlans?.length ?? 0,
              itemBuilder: (context, index) {
                final plan = state.splitModel.paymentPlans![index];
                final totalOwed = plan?.payments?.fold(0.0, (sum, p) => sum + (p?.amount ?? 0)) ?? 0;
                return Container(
                  decoration: const BoxDecoration(color: Colors.white, border: Border()),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan?.name?.toCapitalized ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        verticalSpace(10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [const Text('owes'), Text('₹${totalOwed.toStringAsFixed(2)}')],
                        ),
                        verticalSpace(8),
                        const DottedLine(dashLength: 6, dashColor: AppColors.dividerColor),
                        verticalSpace(8),
                        ...?plan?.payments?.map(
                          (p) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('→ ${p?.to?.toCapitalized}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('₹${p?.amount?.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).paddingSymmetric(horizontal: 16, vertical: 8);
              },
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
