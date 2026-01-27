import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_bloc.dart';
import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_state.dart';
import 'package:bs_flutter/app/models/split/split_model.dart';
import 'package:bs_flutter/app/widgets/common_button.dart';
import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:bs_flutter/extensions/extensions.dart';
import 'package:bs_flutter/extensions/widget_extensions.dart';
import 'package:bs_flutter/utils/payment_plan_exporter.dart';
import 'package:bs_flutter/utils/widget_utils.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class PaymentPlansScreen extends StatefulWidget {
  const PaymentPlansScreen({super.key});

  @override
  State<PaymentPlansScreen> createState() => _PaymentPlansScreenState();
}

class _PaymentPlansScreenState extends State<PaymentPlansScreen> {
  void _sharePaymentPlans(SplitModel splitModel) {
    final content = PaymentPlanExporter.exportToText(splitModel);
    SharePlus.instance.share(ShareParams(text: content, subject: 'Payment Plans'));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('payment plans'), centerTitle: false),
      body: BlocBuilder<PaymentPlansBloc, PaymentPlansState>(
        builder: (context, state) {
          if (state is PaymentPlansLoading) {
            return Center(child: CircularProgressIndicator(color: colorScheme.primary, year2023: false));
          } else if (state is PaymentPlansError) {
            return Center(child: Text(state.message));
          } else if (state is PaymentPlansLoaded) {
            return ListView.builder(
              itemCount: state.splitModel.paymentPlans?.length ?? 0,
              itemBuilder: (context, index) {
                final plan = state.splitModel.paymentPlans![index];
                final totalOwed = plan?.payments?.fold(0.0, (sum, p) => sum + (p?.amount ?? 0)) ?? 0;
                return Container(
                  decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${plan?.name?.toCapitalized ?? ''} owes ₹${totalOwed.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        verticalSpace(10),
                        DottedLine(dashLength: 6, dashColor: colorScheme.onSurface),
                        verticalSpace(8),
                        const Text('to be paid to:'),
                        verticalSpace(8),
                        ...?plan?.payments?.map(
                          (p) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${p?.to?.toCapitalized}', style: const TextStyle(fontWeight: FontWeight.w600)),
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
      bottomNavigationBar: BlocBuilder<PaymentPlansBloc, PaymentPlansState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: CommonButton(
                borderRadius: 8,
                icon: Icons.share_rounded,
                iconColor: colorScheme.onPrimary,
                text: 'share',
                mainAxisSize: MainAxisSize.max,
                onTap:
                    (state is PaymentPlansLoaded &&
                        state.splitModel.paymentPlans != null &&
                        state.splitModel.paymentPlans!.isNotEmpty)
                    ? () => _sharePaymentPlans(state.splitModel)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
