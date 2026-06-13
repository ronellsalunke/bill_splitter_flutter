import 'package:bs_flutter/app/bloc/bill_bloc/bill_bloc.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_event.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_state.dart';
import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_bloc.dart';
import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_event.dart';
import 'package:bs_flutter/app/bloc/update/update_bloc.dart';
import 'package:bs_flutter/app/bloc/update/update_event.dart';
import 'package:bs_flutter/app/bloc/update/update_state.dart';
import 'package:bs_flutter/app/data/endpoints.dart';
import 'package:bs_flutter/app/di/service_locator.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/res/app_icons.dart';
import 'package:bs_flutter/app/widgets/clickable.dart';
import 'package:bs_flutter/app/widgets/common_button.dart';
import 'package:bs_flutter/app/widgets/common_outline_button.dart';
import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:bs_flutter/extensions/widget_extensions.dart';
import 'package:bs_flutter/utils/share_intent_service.dart';
import 'package:bs_flutter/utils/swipe_hint_preferences.dart';
import 'package:bs_flutter/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<ShareIntentService>().checkPendingShareIntent();
      context.read<UpdateBloc>().add(CheckForUpdate());
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return BlocListener<UpdateBloc, UpdateState>(
      listener: (context, updateState) {
        if (updateState is UpdateAvailable) {
          _showUpdateBanner(context, updateState);
        } else if (updateState is UpdateNotAvailable || updateState is UpdateBannerDismissed) {
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        }
      },
      child: BlocBuilder<BillBloc, BillState>(
        builder: (context, state) {
          final bool hasBills = state is BillLoaded && state.bills.isNotEmpty;
          return Scaffold(
            appBar: AppBar(
              leading: SvgPicture.asset(
                AppIcons.logoIcon,
                colorFilter: ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
              ).paddingOnly(left: 16),
              leadingWidth: 48,
              title: const Text('bill splitter'),
              centerTitle: false,
              actions: [
                IconButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
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
                                HapticFeedback.selectionClick();
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
                                HapticFeedback.selectionClick();
                                context.read<PaymentPlansBloc>().add(CalculateSplit(state.bills));
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
                  child: Column(
                    children: [
                      if (state is BillLoading)
                        const CircularProgressIndicator()
                      else if (state is BillError)
                        Text('Error: ${state.message}')
                      else if (state is BillLoaded)
                        Builder(
                          builder: (context) {
                            final hintPrefs = getIt<SwipeHintPreferences>();
                            final shouldPreviewFirstBill = state.bills.length == 1 && hintPrefs.isHomeBillActionsHintPending;
                            return Column(
                              children: [
                                verticalSpace(12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [const Text('bills'), Text('${state.bills.length}')],
                                  ),
                                ),
                                verticalSpace(12),
                                for (final entry in state.bills.asMap().entries) ...[
                                  _slidableBillCard(entry.value, showPreview: shouldPreviewFirstBill && entry.key == 0),
                                  if (entry.key != state.bills.length - 1) const Divider(height: 1),
                                ],
                              ],
                            );
                          },
                        )
                      else
                        const SizedBox(),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showUpdateBanner(BuildContext context, UpdateAvailable state) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentMaterialBanner();
    scaffoldMessenger.showMaterialBanner(
      MaterialBanner(
        forceActionsBelow: false,

        content: Text(state.manifest.message ?? 'update available'),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  context.read<UpdateBloc>().add(DismissUpdateBanner());
                  launchUrl(Uri.parse(Endpoints.latestRelease), mode: LaunchMode.externalApplication);
                },
                child: const Text('update'),
              ),
              IconButton(
                tooltip: 'close',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  context.read<UpdateBloc>().add(DismissUpdateBanner());
                },
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewBillButton() {
    final colorScheme = context.colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppIcons.logoIcon,
          colorFilter: ColorFilter.mode(colorScheme.outline, BlendMode.srcIn),
          width: 60,
          height: 60,
        ),
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
            HapticFeedback.selectionClick();
            context.pushNamed('bill', pathParameters: {'id': 'new'});
          },
        ),
      ],
    ).paddingSymmetric(horizontal: 16);
  }

  Widget _slidableBillCard(Bill bill, {bool showPreview = false}) {
    final colorScheme = context.colorScheme;
    return _BillSlidableCard(
      key: ValueKey(bill.id),
      bill: bill,
      onDelete: () => _deleteBill(bill),
      onSplit: () => _splitBill(bill),
      onPreviewCompleted: () async {
        await getIt<SwipeHintPreferences>().markHomeBillActionsHintShown();
      },
      colorScheme: colorScheme,
      showPreview: showPreview,
      child: billCard(bill),
    );
  }

  void _deleteBill(Bill bill) {
    HapticFeedback.lightImpact();
    context.read<BillBloc>().add(DeleteBill(bill.id));
  }

  void _splitBill(Bill bill) {
    HapticFeedback.selectionClick();
    context.read<PaymentPlansBloc>().add(CalculateSplit([bill]));
    context.pushNamed('payment-plans');
  }

  Widget billCard(Bill bill) {
    final colorScheme = context.colorScheme;
    final occasion = bill.occasion.trim().isEmpty ? 'untitled bill' : bill.occasion.trim();
    return Clickable(
      onClick: () {
        context.pushNamed('bill', pathParameters: {'id': bill.id});
      },
      child: Container(
        decoration: BoxDecoration(color: colorScheme.surface),

        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              occasion,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            verticalSpace(12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    bill.paidBy,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                horizontalSpace(12),
                Text(
                  '₹ ${bill.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                    fontFeatures: const [FontFeature.tabularFigures(), FontFeature.slashedZero()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BillSlidableCard extends StatefulWidget {
  const _BillSlidableCard({
    super.key,
    required this.bill,
    required this.child,
    required this.colorScheme,
    required this.onDelete,
    required this.onSplit,
    required this.onPreviewCompleted,
    required this.showPreview,
  });

  final Bill bill;
  final Widget child;
  final ColorScheme colorScheme;
  final VoidCallback onDelete;
  final VoidCallback onSplit;
  final Future<void> Function() onPreviewCompleted;
  final bool showPreview;

  @override
  State<_BillSlidableCard> createState() => _BillSlidableCardState();
}

class _BillSlidableCardState extends State<_BillSlidableCard> with SingleTickerProviderStateMixin {
  late final SlidableController _controller;
  bool _previewStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = SlidableController(this);
    _maybeRunPreview();
  }

  @override
  void didUpdateWidget(covariant _BillSlidableCard oldWidget) {
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
    final colorScheme = widget.colorScheme;
    return Slidable(
      key: ValueKey(widget.bill.id),
      controller: _controller,
      startActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => widget.onSplit(),
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
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
      child: widget.child,
    );
  }
}
