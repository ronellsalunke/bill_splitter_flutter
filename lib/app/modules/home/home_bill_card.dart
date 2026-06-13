import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/modules/home/home_bill_date_formatter.dart';
import 'package:bs_flutter/app/widgets/clickable.dart';
import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:bs_flutter/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomeBillCard extends StatefulWidget {
  const HomeBillCard({
    super.key,
    required this.bill,
    required this.onOpen,
    required this.onDelete,
    required this.onSplit,
    required this.onPreviewCompleted,
    required this.showPreview,
  });

  final Bill bill;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback onSplit;
  final Future<void> Function() onPreviewCompleted;
  final bool showPreview;

  @override
  State<HomeBillCard> createState() => _HomeBillCardState();
}

class _HomeBillCardState extends State<HomeBillCard> with SingleTickerProviderStateMixin {
  late final SlidableController _controller;
  bool _previewStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = SlidableController(this);
    _maybeRunPreview();
  }

  @override
  void didUpdateWidget(covariant HomeBillCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.showPreview && widget.showPreview) {
      _maybeRunPreview();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _maybeRunPreview() {
    if (_previewStarted || !widget.showPreview) {
      return;
    }

    _previewStarted = true;
    _runPreview();
  }

  Future<void> _runPreview() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _waitUntilVisible();
    if (!mounted) return;

    await _controller.openStartActionPane(duration: const Duration(milliseconds: 400));
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    await _controller.close(duration: const Duration(milliseconds: 300));
    await Future.delayed(const Duration(milliseconds: 400));
    await _waitUntilVisible();
    if (!mounted) return;

    await _controller.openEndActionPane(duration: const Duration(milliseconds: 400));
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    await _controller.close(duration: const Duration(milliseconds: 300));
    if (!mounted) return;

    await widget.onPreviewCompleted();
  }

  Future<void> _waitUntilVisible() async {
    while (mounted && ModalRoute.of(context)?.isCurrent != true) {
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appThemeColors = context.appThemeColors;
    final bill = widget.bill;
    final occasion = bill.occasion.trim().isEmpty ? 'untitled bill' : bill.occasion.trim();

    return Slidable(
      key: ValueKey(bill.id),
      controller: _controller,
      startActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => widget.onSplit(),
            backgroundColor: appThemeColors.success,
            foregroundColor: appThemeColors.onSuccess,
            icon: Icons.calculate_rounded,
          ),
        ],
      ),
      endActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(onDismissed: widget.onDelete),
        children: [
          SlidableAction(
            onPressed: (_) => widget.onDelete(),
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
            icon: Icons.delete_outline,
          ),
        ],
      ),
      child: Clickable(
        onClick: widget.onOpen,
        child: Container(
          decoration: BoxDecoration(color: colorScheme.surface),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      occasion,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    verticalSpace(8),
                    Text(
                      '${bill.paidBy} paid • ${formatHomeBillCreatedAt(bill.createdAt)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              horizontalSpace(12),
              Text(
                '₹${bill.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures(), FontFeature.slashedZero()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
