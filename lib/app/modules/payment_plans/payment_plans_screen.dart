import 'dart:math' as math;

import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_cubit.dart';
import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_state.dart';
import 'package:bs_flutter/app/models/split/split_model.dart';
import 'package:bs_flutter/app/widgets/clickable.dart';
import 'package:bs_flutter/app/widgets/common_button.dart';
import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:bs_flutter/extensions/extensions.dart';
import 'package:bs_flutter/extensions/widget_extensions.dart';
import 'package:bs_flutter/utils/payment_plan_exporter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
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
      body: BlocBuilder<PaymentPlansCubit, PaymentPlansState>(
        builder: (context, state) {
          return switch (state) {
            PaymentPlansLoading() => Center(child: CircularProgressIndicator(color: colorScheme.primary)),
            PaymentPlansError(message: final message) => _buildError(message),
            PaymentPlansOffline() => _buildOffline(),
            PaymentPlansLoaded(splitModel: final splitModel) => _buildPaymentPlans(splitModel),
            PaymentPlansInitial() => const SizedBox(),
          };
        },
      ),
      bottomNavigationBar: BlocBuilder<PaymentPlansCubit, PaymentPlansState>(
        builder: (context, state) {
          final sharePlans = switch (state) {
            PaymentPlansLoaded(splitModel: final splitModel) when splitModel.paymentPlans?.isNotEmpty ?? false =>
              () => _sharePaymentPlans(splitModel),
            PaymentPlansLoaded() ||
            PaymentPlansInitial() ||
            PaymentPlansLoading() ||
            PaymentPlansError() ||
            PaymentPlansOffline() => null,
          };
          return Container(
            decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: CommonButton(
                borderRadius: 8,
                icon: Icons.share_rounded,
                iconColor: colorScheme.onPrimary,
                text: 'share',
                mainAxisSize: MainAxisSize.max,
                onTap: sharePlans,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return _buildRetryable(icon: Icons.error_outline_rounded, title: 'could not calculate split', subtitle: message);
  }

  Widget _buildOffline() {
    return _buildRetryable(
      icon: Icons.wifi_off_rounded,
      title: 'could not connect',
      subtitle: 'check your connection and try again.',
    );
  }

  Widget _buildRetryable({required IconData icon, required String title, required String subtitle}) {
    final colorScheme = context.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: colorScheme.outline),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          CommonButton(
            borderRadius: 8,
            icon: Icons.refresh_rounded,
            iconColor: colorScheme.onPrimary,
            text: 'retry',
            onTap: context.read<PaymentPlansCubit>().retry,
          ),
        ],
      ),
    ).paddingSymmetric(horizontal: 24);
  }

  Widget _buildPaymentPlans(SplitModel splitModel) {
    final instructions = _paymentInstructions(splitModel);
    if (instructions.isEmpty) {
      return const Center(child: Text('No pending payments.'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [const _SettledHero(), ...instructions.map(_paymentTile)],
    );
  }

  List<({String from, String to, double amount})> _paymentInstructions(SplitModel splitModel) {
    final instructions = <({String from, String to, double amount})>[];

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

        instructions.add((from: payer, to: payee, amount: amount));
      }
    }

    return instructions;
  }

  Widget _paymentTile(({String from, String to, double amount}) instruction) {
    return Clickable(
      onClick: () => _copyInstruction(instruction),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${instruction.from.toCapitalized} → ${instruction.to.toCapitalized}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            _paymentAmount(instruction.amount),
          ],
        ),
      ),
    );
  }

  Widget _paymentAmount(double amount) {
    final colorScheme = context.colorScheme;
    final parts = amount.toStringAsFixed(2).split('.');
    const fontFeatures = [FontFeature.tabularFigures(), FontFeature.slashedZero()];

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '₹ ${parts.first}',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          TextSpan(
            text: '.${parts.last}',
            style: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.62)),
          ),
        ],
      ),
      semanticsLabel: '₹ ${amount.toStringAsFixed(2)}',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFeatures: fontFeatures),
    );
  }

  Future<void> _copyInstruction(({String from, String to, double amount}) instruction) async {
    final amount = instruction.amount;
    final amountString = amount == amount.truncateToDouble() ? amount.toInt().toString() : amount.toStringAsFixed(2);
    final text = '${instruction.from.toCapitalized} → ${instruction.to.toCapitalized} ₹$amountString';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(const SnackBar(content: Text('copied to clipboard')));
    }
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
