import 'dart:io';

import 'package:bs_flutter/app/bloc/bill_bloc/bill_bloc.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_event.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_state.dart';
import 'package:bs_flutter/app/di/service_locator.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/models/ocr/ocr_model.dart';
import 'package:bs_flutter/app/modules/edit_bill/upload_image_source_sheet.dart';
import 'package:bs_flutter/app/repository/repository.dart';
import 'package:bs_flutter/app/widgets/common_button.dart';
import 'package:bs_flutter/app/widgets/common_dropdown.dart';
import 'package:bs_flutter/app/widgets/common_multi_dropdown.dart';
import 'package:bs_flutter/app/widgets/common_textfield.dart';
import 'package:bs_flutter/app/widgets/quantity_stepper.dart';
import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:bs_flutter/extensions/widget_extensions.dart';
import 'package:bs_flutter/utils/share_intent_service.dart';
import 'package:bs_flutter/utils/swipe_hint_preferences.dart';
import 'package:bs_flutter/utils/utility.dart';
import 'package:bs_flutter/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

const _everyoneSplitOption = '__everyone_split_option__';

class EditBillScreen extends StatefulWidget {
  const EditBillScreen({super.key, required this.billId, this.sharedOcrModel, this.fromShare = false});

  final String billId;
  final OcrModel? sharedOcrModel;
  final bool fromShare;

  @override
  State<EditBillScreen> createState() => _EditBillScreenState();
}

class _EditBillScreenState extends State<EditBillScreen> {
  final _formData = _BillFormData();
  final _occasionController = TextEditingController();
  final _amountController = TextEditingController();
  final _taxController = TextEditingController(text: '5.0');
  final _serviceController = TextEditingController();
  bool _isOcrProcessing = false;

  // Track participants globally for the bill
  final List<String> _participants = [];
  final _participantsController = TextEditingController();
  final _participantsFocusNode = FocusNode();
  final _occasionFocusNode = FocusNode();
  final _amountFocusNode = FocusNode();
  final _taxFocusNode = FocusNode();
  final _serviceFocusNode = FocusNode();
  DateTime? _existingCreatedAt;

  @override
  void initState() {
    super.initState();
    // Check initial state for data population
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<BillBloc>().state;
      if (widget.billId != 'new' && state is BillLoaded) {
        final bills = state.bills.where((b) => b.id == widget.billId);
        if (bills.isNotEmpty) {
          _populateFormFromBill(bills.first);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill not found')));
          context.pop();
        }
      }
      if (widget.sharedOcrModel != null) {
        _populateFromOcr(widget.sharedOcrModel!);
      }
      if (widget.fromShare) {
        _processSharedImage();
      }
    });
  }

  void _populateFormFromBill(Bill bill) {
    _existingCreatedAt = bill.createdAt;
    _refreshParticipantsFromBill(bill);
    _formData.occasion = bill.occasion;
    _formData.paidBy = bill.paidBy;
    _occasionController.text = bill.occasion;
    _amountController.text = bill.amount.toString();
    _taxController.text = bill.tax.toString();
    _serviceController.text = bill.service.toString();
    final previousItems = List<_ItemFormData>.from(_formData.items);
    _formData.items.clear();
    for (var item in bill.items) {
      var formItem = _ItemFormData()
        ..name = item.name
        ..price = item.price
        ..quantity = item.quantity
        ..consumedBy = List<String>.from(item.consumedBy)
        ..nameController.text = item.name
        ..priceController.text = item.price.toString()
        ..consumedByListenable.value = List<String>.from(item.consumedBy);

      _formData.items.add(formItem);
    }
    // Trigger a rebuild after replacing the editable items.
    setState(() {});
    _disposeItemsNextFrame(previousItems);
  }

  void _refreshParticipantsFromBill(Bill bill) {
    final names = <String>{};
    if (bill.paidBy.isNotEmpty) {
      names.add(bill.paidBy.trim());
    }
    for (var item in bill.items) {
      names.addAll(item.consumedBy.map((n) => n.trim()));
    }

    _participants.clear();
    _participants.addAll(names.where((n) => n.isNotEmpty));
  }

  void _populateFromOcr(OcrModel model) {
    // Clear existing items
    final previousItems = List<_ItemFormData>.from(_formData.items);
    _formData.items.clear();
    // Populate items
    if (model.items != null) {
      for (var item in model.items!) {
        if (item != null) {
          var formItem = _ItemFormData()
            ..name = item.name ?? ''
            ..price = (item.price ?? 0).toDouble()
            ..quantity = item.quantity ?? 1
            ..consumedBy = []
            ..nameController.text = item.name ?? ''
            ..priceController.text = (item.price ?? 0).toString();

          _formData.items.add(formItem);
        }
      }
    }
    // Populate other fields
    _amountController.text = (model.amountPaid ?? 0.00).toString();
    _taxController.text = ((model.taxRate ?? 0.00) * 100).toString();
    _serviceController.text = ((model.serviceCharge ?? 0.00) * 100).toString();
    // Trigger rebuild
    setState(() {});
    _disposeItemsNextFrame(previousItems);
  }

  Future<void> _onOcrTap() async {
    final source = await showUploadImageSourceSheet(context);
    if (!mounted) return;
    if (source == null) return;

    final image = await Utility.pickImage(context, source);
    if (!mounted) return;
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No image selected')));
      return;
    }

    await _processOcr(image);
  }

  Future<void> _processSharedImage() async {
    final path = getIt<ShareIntentService>().sharedImagePath;
    if (path == null) return;

    final image = File(path);
    await _processOcr(image, isShared: true);
  }

  Future<void> _processOcr(File image, {bool isShared = false}) async {
    final colorScheme = context.colorScheme;

    final hasConnection = await Utility.hasInternetConnection();
    if (!mounted) return;
    if (!hasConnection) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No internet connection. Please check your connection and try again.')));
      return;
    }

    setState(() => _isOcrProcessing = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: colorScheme.primary)),
    );
    try {
      final repository = getIt<AppRepository>();
      final ocrModel = await repository.processReceipt(image);
      _populateFromOcr(ocrModel);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt processed successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to process receipt: ${e.toString()}')));
      }
    } finally {
      if (isShared) getIt<ShareIntentService>().sharedImagePath = null;
      if (mounted) {
        setState(() => _isOcrProcessing = false);
        context.pop(); // dismiss loading dialog
      }
    }
  }

  @override
  void dispose() {
    _participantsController.dispose();
    _participantsFocusNode.dispose();
    _occasionController.dispose();
    _amountController.dispose();
    _taxController.dispose();
    _serviceController.dispose();
    _occasionFocusNode.dispose();
    _amountFocusNode.dispose();
    _taxFocusNode.dispose();
    _serviceFocusNode.dispose();
    _disposeAllItemControllers();
    super.dispose();
  }

  void _disposeAllItemControllers() {
    for (final item in _formData.items) {
      item.dispose();
    }
  }

  void _disposeItemsNextFrame(List<_ItemFormData> items) {
    if (items.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final item in items) {
        item.dispose();
      }
    });
  }

  void _syncDropdownModels() {
    // Validate paidBy is still a valid participant
    if (_formData.paidBy.isNotEmpty && !_participants.contains(_formData.paidBy)) {
      _formData.paidBy = '';
    }

    for (var item in _formData.items) {
      item.consumedBy.removeWhere((p) => !_participants.contains(p));
      item.consumedByListenable.value = List<String>.from(item.consumedBy);
    }
    setState(() {});
  }

  List<CommonMultiDropdownItem<String>> _splitWithDropdownItems() {
    return [
      if (_participants.isNotEmpty) const CommonMultiDropdownItem(label: 'Everyone', value: _everyoneSplitOption),
      ..._participants.map((name) => CommonMultiDropdownItem(label: name, value: name)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return BlocConsumer<BillBloc, BillState>(
      listener: (context, state) {
        if (widget.billId != 'new' && state is BillLoaded) {
          final bills = state.bills.where((b) => b.id == widget.billId);
          if (bills.isNotEmpty) {
            _populateFormFromBill(bills.first);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill not found')));
            context.pop();
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.billId == 'new' ? 'new bill' : 'edit bill'), centerTitle: false),
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonButton(
                  text: _isOcrProcessing ? 'processing...' : 'scan receipt',
                  icon: _isOcrProcessing ? null : Icons.document_scanner_rounded,
                  iconColor: colorScheme.onPrimary,
                  borderRadius: 8,
                  mainAxisSize: MainAxisSize.max,
                  onTap: _isOcrProcessing ? null : _onOcrTap,
                ).paddingAll(16),
                _formSection(
                  title: 'participants',
                  showDivider: false,
                  children: [
                    CommonTextField(
                      hintText: 'Add name...',
                      controller: _participantsController,
                      textCapitalization: TextCapitalization.words,
                      currentFocus: _participantsFocusNode,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        tooltip: 'add member',
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        onPressed: _addParticipantFromInput,
                      ),
                      onFieldSubmitted: (_) => _addParticipantFromInput(),
                    ),
                    verticalSpace(10),
                    _participantChips(),
                  ],
                ),
                _formSection(
                  title: 'payment',
                  children: [
                    CommonTextField(
                      label: 'Occasion *',
                      hintText: 'Dinner, outing, groceries',
                      controller: _occasionController,
                      currentFocus: _occasionFocusNode,
                      nextFocus: _amountFocusNode,
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      onChanged: (value) => _formData.occasion = value,
                    ),
                    verticalSpace(16),
                    CommonDropdown<String>(
                      label: 'Paid by',
                      hintText: _participants.isEmpty ? 'add participants first' : 'select person',
                      value: _participants.contains(_formData.paidBy) ? _formData.paidBy : null,
                      items: _participants.map((name) => DropdownMenuItem<String>(value: name, child: Text(name))).toList(),
                      onChanged: (value) {
                        setState(() {
                          if (value != null) _formData.paidBy = value;
                        });
                      },
                    ),
                    verticalSpace(16),
                    CommonTextField(
                      label: 'Amount paid',
                      hintText: '0.00',
                      controller: _amountController,
                      currentFocus: _amountFocusNode,
                      nextFocus: _taxFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                    ),
                    verticalSpace(16),
                    Row(
                      children: [
                        Flexible(
                          child: CommonTextField(
                            label: 'Tax (%)',
                            hintText: '5.0',
                            controller: _taxController,
                            currentFocus: _taxFocusNode,
                            nextFocus: _serviceFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        horizontalSpace(10),
                        Flexible(
                          child: CommonTextField(
                            label: 'Service (%)',
                            hintText: '0.0',
                            controller: _serviceController,
                            currentFocus: _serviceFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _focusItemName(0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _formSection(
                  title: 'items',
                  trailing: Text(
                    '${_formData.items.length}',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  children: [
                    Column(children: _formData.items.asMap().entries.map((entry) => itemCard(entry.key)).toList()),
                    verticalSpace(12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _addItem(focusNewItem: true),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('add item'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.outline),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: CommonButton(
                text: 'save bill',
                mainAxisSize: MainAxisSize.max,
                borderRadius: 8,
                icon: Icons.save,
                iconColor: colorScheme.onPrimary,
                onTap: _saveBill,
              ),
            ),
          ),
        );
      },
    );
  }

  void _addParticipantFromInput() {
    final text = _participantsController.text.trim();
    if (text.isEmpty || _participants.contains(text)) {
      return;
    }

    setState(() {
      _participants.add(text);
      _syncDropdownModels();
    });
    _participantsController.clear();
    _participantsFocusNode.requestFocus();
  }

  void _addItem({bool focusNewItem = false}) {
    final item = _ItemFormData();
    setState(() {
      _formData.items.add(item);
    });
    HapticFeedback.selectionClick();

    if (focusNewItem) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _requestFocus(item.nameFocusNode);
        }
      });
    }
  }

  void _focusItemName(int index) {
    if (index >= _formData.items.length) return;
    _requestFocus(_formData.items[index].nameFocusNode);
  }

  void _focusNextItemName(int index) {
    if (index == _formData.items.length - 1) {
      _addItem(focusNewItem: true);
      return;
    }

    _focusItemName(index + 1);
  }

  void _requestFocus(FocusNode focusNode) {
    focusNode.requestFocus();
    final fieldContext = focusNode.context;
    if (fieldContext != null) {
      Scrollable.ensureVisible(
        fieldContext,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    }
  }

  void _updateItemQuantity(int index, int delta) {
    final item = _formData.items[index];
    if (delta.isNegative && item.quantity == 1) return;

    setState(() {
      item.quantity += delta;
    });
    HapticFeedback.selectionClick();
  }

  Widget _formSection({required String title, Widget? trailing, bool showDivider = true, required List<Widget> children}) {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDivider) Divider(height: 1, thickness: 1, color: colorScheme.outline),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: TextStyle(color: colorScheme.outline, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.8),
                    ),
                  ),
                  ?trailing,
                ],
              ),
              verticalSpace(10),
              ...children,
            ],
          ),
        ),
      ],
    );
  }

  Widget _participantChips() {
    final colorScheme = context.colorScheme;
    if (_participants.isEmpty) {
      return Text('no participants yet', style: TextStyle(color: colorScheme.outline, fontSize: 12));
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 160),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _participants.asMap().entries.map((entry) {
            final name = entry.value;
            final initial = name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
            return Chip(
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              side: BorderSide.none,
              avatar: CircleAvatar(
                radius: 10,
                backgroundColor: colorScheme.tertiary,
                child: Text(
                  initial,
                  style: TextStyle(color: colorScheme.onTertiary, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
              label: Text(name, style: TextStyle(color: colorScheme.onTertiaryContainer)),
              backgroundColor: colorScheme.tertiaryContainer,
              deleteIcon: Icon(Icons.close, size: 16, color: colorScheme.onTertiaryContainer),
              onDeleted: () {
                setState(() {
                  _participants.removeAt(entry.key);
                  _syncDropdownModels();
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _saveBill() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final occasion = _occasionController.text.trim();
    final billBloc = context.read<BillBloc>();
    final router = GoRouter.of(context);

    // Validate
    if (occasion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add an occasion')));
      return;
    }

    if (_formData.paidBy.isEmpty ||
        _amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null ||
        _formData.items.isEmpty ||
        _formData.items.any((item) => item.name.isEmpty || item.consumedBy.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    if (double.tryParse(_amountController.text)! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Amount must be greater than 0')));
      return;
    }

    if (_formData.items.any((item) => item.price <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item price must be greater than 0')));
      return;
    }

    // Create items
    final items = _formData.items
        .map((item) => BillItem(name: item.name, price: item.price, quantity: item.quantity, consumedBy: item.consumedBy))
        .toList();

    final bill = Bill(
      id: widget.billId == 'new' ? DateTime.now().millisecondsSinceEpoch.toString() : widget.billId,
      occasion: occasion,
      paidBy: _formData.paidBy,
      amount: double.parse(_amountController.text),
      tax: double.tryParse(_taxController.text) ?? 5.0,
      service: double.tryParse(_serviceController.text) ?? 0.0,
      items: items,
      createdAt: widget.billId == 'new' ? DateTime.now() : (_existingCreatedAt ?? DateTime.now()),
    );

    if (widget.billId == 'new') {
      await getIt<SwipeHintPreferences>().scheduleHomeBillActionsHint();
      billBloc.add(AddBill(bill));
    } else {
      billBloc.add(UpdateBill(bill));
    }
    if (!mounted) return;
    router.pop();
  }

  Widget itemCard(int index) {
    final colorScheme = context.colorScheme;
    return Slidable(
      key: ObjectKey(_formData.items[index]),
      endActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            setState(() {
              HapticFeedback.lightImpact();
              final removedItem = _formData.items.removeAt(index);
              removedItem.dispose();
            });
          },
        ),
        children: [
          SlidableAction(
            onPressed: (_) {
              setState(() {
                HapticFeedback.lightImpact();
                final removedItem = _formData.items.removeAt(index);
                removedItem.dispose();
              });
            },
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
            icon: Icons.delete_outline,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonTextField(
              hintText: 'item name',
              controller: _formData.items[index].nameController,
              currentFocus: _formData.items[index].nameFocusNode,
              nextFocus: _formData.items[index].priceFocusNode,
              onChanged: (value) => _formData.items[index].name = value,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
            ),
            verticalSpace(8),
            Row(
              children: [
                Expanded(
                  child: CommonTextField(
                    hintText: 'price',
                    controller: _formData.items[index].priceController,
                    currentFocus: _formData.items[index].priceFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => _formData.items[index].price = double.tryParse(value) ?? 0.0,
                    onFieldSubmitted: (_) => _focusNextItemName(index),
                  ),
                ),
                horizontalSpace(12),
                Expanded(
                  child: QuantityStepper(
                    value: _formData.items[index].quantity,
                    onDecrement: _formData.items[index].quantity > 1 ? () => _updateItemQuantity(index, -1) : null,
                    onIncrement: () => _updateItemQuantity(index, 1),
                  ),
                ),
              ],
            ),
            verticalSpace(8),
            CommonMultiDropdown<String>(
              hintText: _participants.isEmpty ? 'add participants first' : 'select participants',
              items: _splitWithDropdownItems(),
              valuesListenable: _formData.items[index].consumedByListenable,
              selectAllValue: _everyoneSplitOption,
              onSelectionChanged: _participants.isEmpty
                  ? null
                  : (selectedItems) {
                      setState(() {
                        _formData.items[index].consumedBy = selectedItems.where(_participants.contains).toList();
                      });
                    },
            ),
          ],
        ),
      ),
    ).paddingSymmetric(vertical: 4);
  }
}

class _ItemFormData {
  String name = '';
  double price = 0.0;
  int quantity = 1;
  List<String> consumedBy = [];
  ValueNotifier<List<String>> consumedByListenable = ValueNotifier<List<String>>([]);
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();
  FocusNode priceFocusNode = FocusNode();

  void dispose() {
    consumedByListenable.dispose();
    nameController.dispose();
    priceController.dispose();
    nameFocusNode.dispose();
    priceFocusNode.dispose();
  }
}

class _BillFormData {
  String occasion = '';
  String paidBy = '';
  double amount = 0.0;
  double tax = 5.0;
  double service = 0.0;
  List<_ItemFormData> items = [_ItemFormData()];
}
