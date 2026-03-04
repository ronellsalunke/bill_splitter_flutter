import 'dart:io';

import 'package:bs_flutter/app/bloc/bill_bloc/bill_bloc.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_event.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_state.dart';
import 'package:bs_flutter/app/di/service_locator.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/models/ocr/ocr_model.dart';
import 'package:bs_flutter/app/repository/repository.dart';
import 'package:bs_flutter/app/widgets/common_button.dart';
import 'package:bs_flutter/app/widgets/common_dropdown.dart';
import 'package:bs_flutter/app/widgets/common_multi_dropdown.dart';
import 'package:bs_flutter/app/widgets/common_outline_button.dart';
import 'package:bs_flutter/app/widgets/common_textfield.dart';
import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:bs_flutter/extensions/widget_extensions.dart';
import 'package:bs_flutter/utils/share_intent_service.dart';
import 'package:bs_flutter/utils/utility.dart';
import 'package:bs_flutter/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

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
  final _amountController = TextEditingController();
  final _taxController = TextEditingController(text: '5.0');
  final _serviceController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  bool _isOcrProcessing = false;

  // Track participants globally for the bill
  final List<String> _participants = [];
  final _participantsController = TextEditingController();
  final _participantsFocusNode = FocusNode();

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
    _refreshParticipantsFromBill(bill);
    _formData.paidBy = bill.paidBy;
    _amountController.text = bill.amount.toString();
    _taxController.text = bill.tax.toString();
    _serviceController.text = bill.service.toString();
    _formData.items.clear();
    for (var item in bill.items) {
      var formItem = _ItemFormData()
        ..name = item.name
        ..price = item.price
        ..quantity = item.quantity
        ..consumedBy = List<String>.from(item.consumedBy)
        ..nameController.text = item.name
        ..priceController.text = item.price.toString()
        ..quantityController.text = item.quantity.toString()
        ..consumedByController.setItems(_participants.map((m) => DropdownItem(label: m, value: m)).toList());

      formItem.consumedByController.selectWhere((i) => item.consumedBy.contains(i.value));

      _formData.items.add(formItem);
    }
    // Trigger rebuild for AnimatedList
    setState(() {});
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
            ..priceController.text = (item.price ?? 0).toString()
            ..quantityController.text = (item.quantity ?? 1).toString()
            ..consumedByController.setItems(_participants.map((m) => DropdownItem(label: m, value: m)).toList());

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
  }

  Future<void> _onOcrTap() async {
    final colorScheme = context.colorScheme;
    final source = await showModalBottomSheet<ImageSource>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Row(
            children: [
              Flexible(
                child: CommonButton(
                  borderRadius: 8,
                  text: 'gallery',
                  icon: Icons.photo_library_rounded,
                  iconColor: colorScheme.onPrimary,
                  mainAxisSize: MainAxisSize.max,
                  onTap: () {
                    context.pop(ImageSource.gallery);
                  },
                ),
              ),
              horizontalSpace(10),
              Flexible(
                child: CommonButton(
                  borderRadius: 8,
                  icon: Icons.camera_alt_rounded,
                  iconColor: colorScheme.onPrimary,
                  text: 'camera',
                  mainAxisSize: MainAxisSize.max,
                  onTap: () {
                    context.pop(ImageSource.camera);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;

    final image = await Utility.pickImage(context, source);
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
      builder: (context) => Center(child: CircularProgressIndicator(color: colorScheme.primary, year2023: false)),
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
      await image.delete();
      if (isShared) getIt<ShareIntentService>().sharedImagePath = null;
      setState(() => _isOcrProcessing = false);
      if (mounted) {
        Navigator.of(context).pop(); // dismiss loading dialog
      }
    }
  }

  @override
  void dispose() {
    _participantsController.dispose();
    _participantsFocusNode.dispose();
    for (var item in _formData.items) {
      item.consumedByController.dispose();
    }
    super.dispose();
  }

  void _syncDropdownModels() {
    // Validate paidBy is still a valid participant
    if (_formData.paidBy.isNotEmpty && !_participants.contains(_formData.paidBy)) {
      _formData.paidBy = '';
    }

    for (var item in _formData.items) {
      item.consumedBy.removeWhere((p) => !_participants.contains(p));
      final dropdownItems = _participants.map((m) => DropdownItem(label: m, value: m)).toList();
      item.consumedByController.setItems(dropdownItems);
      item.consumedByController.selectWhere((element) => item.consumedBy.contains(element.value));
    }
    setState(() {});
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(12),
                CommonButton(
                  text: _isOcrProcessing ? 'Processing...' : 'scan receipt',
                  icon: _isOcrProcessing ? null : Icons.document_scanner_rounded,
                  iconColor: colorScheme.onPrimary,
                  borderRadius: 8,
                  mainAxisSize: MainAxisSize.max,
                  onTap: _isOcrProcessing ? null : _onOcrTap,
                ),
                verticalSpace(20),
                CommonTextField(
                  hintText: 'add members',
                  label: 'participants',
                  controller: _participantsController,
                  textCapitalization: TextCapitalization.words,
                  currentFocus: _participantsFocusNode,
                  keyboardType: TextInputType.name,
                  onFieldSubmitted: (value) {
                    final text = value.trim();
                    if (text.isNotEmpty && !_participants.contains(text)) {
                      setState(() {
                        _participants.add(text);
                        _syncDropdownModels();
                      });
                      _participantsController.clear();
                      _participantsFocusNode.requestFocus();
                    }
                  },
                ),
                verticalSpace(8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: Wrap(
                    spacing: 8,
                    children: _participants
                        .asMap()
                        .entries
                        .map(
                          (entry) => Chip(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            side: BorderSide.none,
                            label: Text(entry.value, style: TextStyle(color: colorScheme.onSecondary)),
                            backgroundColor: colorScheme.secondary,
                            deleteIcon: Icon(Icons.close, size: 16, color: colorScheme.onSecondary),
                            onDeleted: () {
                              setState(() {
                                _participants.removeAt(entry.key);
                                _syncDropdownModels();
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
                verticalSpace(20),
                CommonDropdown<String>(
                  label: 'PAID BY',
                  hintText: 'select person',
                  value: _participants.contains(_formData.paidBy) ? _formData.paidBy : null,
                  items: _participants
                      .map((name) => DropdownItem<String>(label: name, value: name))
                      .map((item) => DropdownMenuItem<String>(value: item.value, child: Text(item.label)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      if (value != null) _formData.paidBy = value;
                    });
                  },
                ),
                verticalSpace(20),
                CommonTextField(
                  label: 'AMOUNT PAID',
                  hintText: '0.00',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                ),
                verticalSpace(20),
                Row(
                  children: [
                    Flexible(
                      child: CommonTextField(
                        label: 'TAX (%)',
                        hintText: '5.0',
                        controller: _taxController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    horizontalSpace(8),
                    Flexible(
                      child: CommonTextField(
                        label: 'SERVICE (%)',
                        hintText: '0.0',
                        controller: _serviceController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                verticalSpace(20),
                const Text('ITEMS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                verticalSpace(10),
                Column(children: _formData.items.asMap().entries.map((entry) => itemCard(entry.key)).toList()),
              ],
            ).paddingSymmetric(horizontal: 16),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(10)),

            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Row(
                children: [
                  Flexible(
                    child: CommonOutlineButton(
                      text: 'add item',
                      icon: Icons.add_circle,
                      iconColor: colorScheme.primary,
                      mainAxisSize: MainAxisSize.max,
                      borderRadius: 8,
                      onTap: () {
                        setState(() {
                          final item = _ItemFormData();
                          item.consumedByController.setItems(_participants.map((m) => DropdownItem(label: m, value: m)).toList());
                          _formData.items.add(item);
                        });
                        _listKey.currentState?.insertItem(_formData.items.length - 1);
                      },
                    ),
                  ),
                  horizontalSpace(10),
                  Flexible(
                    child: CommonButton(
                      text: 'save bill',
                      mainAxisSize: MainAxisSize.max,
                      borderRadius: 8,
                      icon: Icons.save,
                      iconColor: colorScheme.onPrimary,
                      onTap: _saveBill,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveBill() {
    // Validate
    if (_formData.paidBy.isEmpty ||
        _amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null ||
        _formData.items.isEmpty ||
        _formData.items.any((item) => item.name.isEmpty || item.consumedBy.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    // Create items
    final items = _formData.items
        .map((item) => BillItem(name: item.name, price: item.price, quantity: item.quantity, consumedBy: item.consumedBy))
        .toList();

    final bill = Bill(
      id: widget.billId == 'new' ? DateTime.now().millisecondsSinceEpoch.toString() : widget.billId,
      paidBy: _formData.paidBy,
      amount: double.parse(_amountController.text),
      tax: double.tryParse(_taxController.text) ?? 5.0,
      service: double.tryParse(_serviceController.text) ?? 0.0,
      items: items,
      createdAt: widget.billId == 'new' ? DateTime.now() : DateTime.now(), // or keep original, but since no original, use now
    );

    if (widget.billId == 'new') {
      context.read<BillBloc>().add(AddBill(bill));
    } else {
      context.read<BillBloc>().add(UpdateBill(bill));
    }
    context.pop();
  }

  Widget itemCard(int index) {
    final colorScheme = context.colorScheme;
    return Dismissible(
      key: ObjectKey(_formData.items[index]),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => setState(() => _formData.items.removeAt(index)),
      background: Container(
        decoration: BoxDecoration(color: colorScheme.error),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete_outline, color: colorScheme.onError),
      ),
      child: Container(
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            CommonTextField(
              hintText: 'item name',
              controller: _formData.items[index].nameController,
              onChanged: (value) => _formData.items[index].name = value,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
            ),
            verticalSpace(10),
            Row(
              children: [
                Flexible(
                  child: CommonTextField(
                    hintText: 'price',
                    controller: _formData.items[index].priceController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _formData.items[index].price = double.tryParse(value) ?? 0.0,
                  ),
                ),
                horizontalSpace(8),
                Flexible(
                  child: CommonTextField(
                    hintText: 'quantity',
                    controller: _formData.items[index].quantityController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _formData.items[index].quantity = int.tryParse(value) ?? 1,
                  ),
                ),
              ],
            ),
            verticalSpace(10),
            CommonMultiDropdown<String>(
              hintText: 'select participants',
              label: 'consumed by',
              items: _participants
                  .map((m) => DropdownItem(label: m, value: m, selected: _formData.items[index].consumedBy.contains(m)))
                  .toList(),
              controller: _formData.items[index].consumedByController,
              onSelectionChanged: (selectedItems) {
                setState(() {
                  _formData.items[index].consumedBy = List<String>.from(selectedItems);
                });
              },
            ),
            if (_participants.isNotEmpty) ...[
              verticalSpace(8),
              Row(
                children: [
                  Checkbox(
                    value: _participants.every((m) => _formData.items[index].consumedBy.contains(m)),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _formData.items[index].consumedBy = List<String>.from(_participants);
                          _formData.items[index].consumedByController.selectAll();
                        } else {
                          _formData.items[index].consumedBy.clear();
                          _formData.items[index].consumedByController.clearAll();
                        }
                      });
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  const Text('Consumed by all', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
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
  MultiSelectController<String> consumedByController = MultiSelectController<String>();
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController(text: '1');
}

class _BillFormData {
  String paidBy = '';
  double amount = 0.0;
  double tax = 5.0;
  double service = 0.0;
  List<_ItemFormData> items = [_ItemFormData()];
}
