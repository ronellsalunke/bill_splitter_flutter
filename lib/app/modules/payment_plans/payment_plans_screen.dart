import 'dart:math' as math;

import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_bloc.dart';
import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_state.dart';
import 'package:bs_flutter/app/models/split/split_model.dart';
import 'package:bs_flutter/app/widgets/common_button.dart';
import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:bs_flutter/extensions/extensions.dart';
import 'package:bs_flutter/utils/payment_plan_exporter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_segmented_list/material_segmented_list.dart';
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
            return Center(child: CircularProgressIndicator(color: colorScheme.primary));
          } else if (state is PaymentPlansError) {
            return Center(child: Text(state.message));
          } else if (state is PaymentPlansLoaded) {
            final instructions = _paymentInstructions(state.splitModel);
            if (instructions.isEmpty) {
              return const Center(child: Text('No pending payments.'));
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const _SettledHero(),
                SegmentedListSection(
                  children: instructions
                      .map((instruction) => _PaymentInstructionTile(instruction: instruction, amountColor: colorScheme.primary))
                      .toList(),
                ),
              ],
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

  List<_PaymentInstruction> _paymentInstructions(SplitModel splitModel) {
    final instructions = <_PaymentInstruction>[];

    for (final plan in splitModel.paymentPlans ?? <PaymentPlans?>[]) {
      final payer = plan?.name?.trim();
      if (payer == null || payer.isEmpty) {
        continue;
      }

      for (final payment in plan?.payments ?? <Payments?>[]) {
        final payee = payment?.to?.trim();
        final amount = payment?.amount;

        if (payee == null || payee.isEmpty || amount == null || amount <= 0) {
          continue;
        }

        instructions.add(_PaymentInstruction(from: payer, to: payee, amount: amount));
      }
    }

    return instructions;
  }
}

class _SettledHero extends StatefulWidget {
  const _SettledHero();

  @override
  State<_SettledHero> createState() => _SettledHeroState();
}

class _SettledHeroState extends State<_SettledHero> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _labelOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..forward();
    _labelOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.62, 1, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          SizedBox.square(
            dimension: 112,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _SettlementSuccessPainter(
                    progress: _controller.value,
                    arcColor: colorScheme.tertiary,
                    circleColor: colorScheme.tertiary,
                    checkColor: colorScheme.tertiaryContainer,
                  ),
                  size: const Size.square(112),
                );
              },
            ),
          ),
          FadeTransition(opacity: _labelOpacity, child: const SizedBox(height: 12)),
          FadeTransition(
            opacity: _labelOpacity,
            child: Text(
              'all settled up!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementSuccessPainter extends CustomPainter {
  final double progress;
  final Color arcColor;
  final Color circleColor;
  final Color checkColor;

  const _SettlementSuccessPainter({
    required this.progress,
    required this.arcColor,
    required this.circleColor,
    required this.checkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 38.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final arcProgress = Curves.easeInOutCubic.transform((progress / 0.58).clamp(0.0, 1.0));
    final fillProgress = Curves.easeOutBack.transform(((progress - 0.42) / 0.28).clamp(0.0, 1.0));
    final checkProgress = Curves.easeOutCubic.transform(((progress - 0.62) / 0.38).clamp(0.0, 1.0));

    if (fillProgress > 0) {
      final fillPaint = Paint()
        ..color = circleColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius * fillProgress, fillPaint);
    }

    final trackPaint = Paint()
      ..color = arcColor.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * arcProgress, false, arcPaint);

    if (checkProgress > 0) {
      final checkPaint = Paint()
        ..color = checkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final checkPath = Path()
        ..moveTo(center.dx - 18, center.dy)
        ..lineTo(center.dx - 5, center.dy + 13)
        ..lineTo(center.dx + 20, center.dy - 16);

      for (final metric in checkPath.computeMetrics()) {
        final visiblePath = metric.extractPath(0, metric.length * checkProgress);
        canvas.drawPath(visiblePath, checkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SettlementSuccessPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.arcColor != arcColor ||
        oldDelegate.circleColor != circleColor ||
        oldDelegate.checkColor != checkColor;
  }
}

class _PaymentInstructionTile extends SegmentedListTile {
  _PaymentInstructionTile({required _PaymentInstruction instruction, required Color amountColor})
    : super(
        title: Text(
          '${instruction.from.toCapitalized} → ${instruction.to.toCapitalized}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '₹ ${instruction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: amountColor,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures(), FontFeature.slashedZero()],
          ),
        ),
      );
}

class _PaymentInstruction {
  final String from;
  final String to;
  final double amount;

  const _PaymentInstruction({required this.from, required this.to, required this.amount});
}
