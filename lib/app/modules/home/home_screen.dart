import 'package:bs_flutter/app/bloc/bill_bloc/bill_bloc.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_event.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_state.dart';
import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_cubit.dart';
import 'package:bs_flutter/app/bloc/update/update_cubit.dart';
import 'package:bs_flutter/app/bloc/update/update_state.dart';
import 'package:bs_flutter/app/data/endpoints.dart';
import 'package:bs_flutter/app/di/service_locator.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/modules/home/home_bill_card.dart';
import 'package:bs_flutter/app/modules/home/update_changelog_sheet.dart';
import 'package:bs_flutter/app/res/app_icons.dart';
import 'package:bs_flutter/app/widgets/common_button.dart';
import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:bs_flutter/extensions/widget_extensions.dart';
import 'package:bs_flutter/utils/share_intent_service.dart';
import 'package:bs_flutter/utils/scroll_reveal_fab_mixin.dart';
import 'package:bs_flutter/utils/swipe_hint_preferences.dart';
import 'package:bs_flutter/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with ScrollRevealFabMixin {
  @override
  void initState() {
    super.initState();
    initScrollRevealController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      getIt<ShareIntentService>().checkPendingShareIntent();
      context.read<UpdateCubit>().checkForUpdate();
    });
  }

  @override
  void dispose() {
    disposeScrollRevealController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return BlocListener<UpdateCubit, UpdateState>(
      listener: (context, updateState) {
        if (updateState is UpdateAvailable) {
          _showUpdateBanner(context, updateState);
        } else if (updateState is UpdateChangelogAvailable) {
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          _showUpdateChangelog(updateState);
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
            floatingActionButton: buildScrollRevealFab(
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(30)),
                enableFeedback: true,
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                onPressed: () {
                  context.pushNamed('bill', pathParameters: {'id': 'new'});
                },
                child: const Icon(Icons.add),
              ),
            ),
            bottomNavigationBar: hasBills
                ? Container(
                    decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.all(16),
                    child: SafeArea(
                      child: CommonButton(
                        borderRadius: 8,
                        icon: Icons.calculate_rounded,
                        iconColor: colorScheme.onPrimary,
                        text: 'split all',
                        mainAxisSize: MainAxisSize.max,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.read<PaymentPlansCubit>().calculateSplit(state.bills);
                          context.pushNamed('payment-plans');
                        },
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
                  controller: scrollRevealController,
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
                                  HomeBillCard(
                                    key: ValueKey(entry.value.id),
                                    bill: entry.value,
                                    showPreview: shouldPreviewFirstBill && entry.key == 0,
                                    onOpen: () {
                                      context.pushNamed('bill', pathParameters: {'id': entry.value.id});
                                    },
                                    onDelete: () => _deleteBill(entry.value),
                                    onSplit: () => _splitBill(entry.value),
                                    onPreviewCompleted: () async {
                                      await getIt<SwipeHintPreferences>().markHomeBillActionsHintShown();
                                    },
                                  ),
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
                  context.read<UpdateCubit>().dismissBanner();
                  launchUrl(Uri.parse(Endpoints.latestRelease), mode: LaunchMode.externalApplication);
                },
                child: const Text('update'),
              ),
              IconButton(
                tooltip: 'close',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  context.read<UpdateCubit>().dismissBanner();
                },
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateChangelog(UpdateChangelogAvailable state) async {
    await showUpdateChangelogSheet(context, release: state.release);
    if (!mounted) return;
    await context.read<UpdateCubit>().acknowledgeChangelogAndRecheck();
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
        Text('no bills yet! tap the + button to add a new bill', style: TextStyle(color: colorScheme.outline)),
      ],
    ).paddingSymmetric(horizontal: 16);
  }

  void _deleteBill(Bill bill) {
    HapticFeedback.lightImpact();
    context.read<BillBloc>().add(DeleteBill(bill.id));
  }

  void _splitBill(Bill bill) {
    HapticFeedback.selectionClick();
    context.read<PaymentPlansCubit>().calculateSplit([bill]);
    context.pushNamed('payment-plans');
  }
}
