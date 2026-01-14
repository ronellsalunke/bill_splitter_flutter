import 'dart:io';

import 'package:bs_flutter/app/bloc/bill_bloc/bill_bloc.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_event.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_state.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/models/ocr/ocr_model.dart';
import 'package:bs_flutter/app/repository/repository.dart';
import 'package:bs_flutter/app/widgets/common_button.dart';
import 'package:bs_flutter/app/widgets/common_dotted_button.dart';
import 'package:bs_flutter/app/widgets/common_textfield.dart';
import 'package:bs_flutter/extensions/widget_extensions.dart';
import 'package:bs_flutter/utils/share_intent_service.dart';
import 'package:bs_flutter/utils/utility.dart';
import 'package:bs_flutter/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EditBillScreen extends StatefulWidget {
  const EditBillScreen({super.key, required this.billId, this.sharedOcrModel, this.fromShare = false});

  final String billId;
  final OcrModel? sharedOcrModel;
  final bool fromShare;

  @override
  State<EditBillScreen> createState() => _EditBillScreenState();
}

class NameChipsField extends StatefulWidget {
  const NameChipsField({super.key, required this.consumedBy});

  final List<String> consumedBy;

  @override
  State<NameChipsField> createState() => _NameChipsFieldState();
}

class _NameChipsFieldState extends State<NameChipsField> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextField(
          hintText: 'add names',
          label: 'consumed by',
          controller: _controller,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.name,
          onFieldSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() => widget.consumedBy.add(value));
              _controller.clear();
            }
          },
        ),
        verticalSpace(8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: Wrap(
            spacing: 8,
            children: widget.consumedBy
                .asMap()
                .entries
                .map(
                  (entry) => Chip(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    side: BorderSide.none,
                    label: Text(entry.value, style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    deleteIcon: Icon(Icons.close, size: 16, color: Theme.of(context).colorScheme.onSecondary),
                    onDeleted: () => setState(() => widget.consumedBy.removeAt(entry.key)),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ItemFormData {
  String name = '';
  double price = 0.0;
  int quantity = 1;
  List<String> consumedBy = [];
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

class _EditBillScreenState extends State<EditBillScreen> {
  final _formData = _BillFormData();
  final _paidByController = TextEditingController();
  final _amountController = TextEditingController();
  final _taxController = TextEditingController(text: '5.0');
  final _serviceController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  bool _isOcrProcessing = false;

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
          context.goNamed('home');
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
    _paidByController.text = bill.paidBy;
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
        ..quantityController.text = item.quantity.toString();
      _formData.items.add(formItem);
    }
    // Trigger rebuild for AnimatedList
    setState(() {});
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
            ..quantityController.text = (item.quantity ?? 1).toString();
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
    final source = await showModalBottomSheet<ImageSource>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, size: 24),
              title: const Text('Gallery', style: TextStyle(fontSize: 14)),
              onTap: () => context.pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, size: 24),
              title: const Text('Camera', style: TextStyle(fontSize: 14)),
              onTap: () => context.pop(ImageSource.camera),
            ),
            const Divider(),
            ListTile(
              title: const Text('Cancel', textAlign: TextAlign.center),
              onTap: () => context.pop(),
            ),
          ],
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
    final path = ShareIntentService.sharedImagePath;
    if (path == null) return;

    final image = File(path);
    await _processOcr(image, isShared: true);
  }

  Future<void> _processOcr(File image, {bool isShared = false}) async {
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
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, year2023: false)),
    );
    try {
      final repository = AppRepository();
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
      if (isShared) ShareIntentService.sharedImagePath = null;
      setState(() => _isOcrProcessing = false);
      if (mounted) {
        Navigator.of(context).pop(); // dismiss loading dialog
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillBloc, BillState>(
      listener: (context, state) {
        if (widget.billId != 'new' && state is BillLoaded) {
          final bills = state.bills.where((b) => b.id == widget.billId);
          if (bills.isNotEmpty) {
            _populateFormFromBill(bills.first);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill not found')));
            context.goNamed('home');
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
                DottedButton(
                  text: _isOcrProcessing ? 'Processing...' : 'upload receipt (OCR)',
                  icon: _isOcrProcessing ? null : Icons.file_upload_outlined,
                  mainAxisSize: MainAxisSize.max,
                  onTap: _isOcrProcessing ? null : _onOcrTap,
                ),
                verticalSpace(20),
                CommonTextField(
                  label: 'PAID BY',
                  hintText: 'enter name',
                  controller: _paidByController,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
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
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 1)),
            ),

            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DottedButton(
                    text: 'add item',
                    icon: Icons.add,
                    mainAxisSize: MainAxisSize.max,
                    onTap: () {
                      setState(() => _formData.items.add(_ItemFormData()));
                      _listKey.currentState?.insertItem(_formData.items.length - 1);
                    },
                  ),
                  verticalSpace(10),
                  CommonButton(text: 'save bill', mainAxisSize: MainAxisSize.max, onTap: _saveBill),
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
    if (_paidByController.text.isEmpty ||
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
      paidBy: _paidByController.text,
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
    context.goNamed('home');
  }

  Widget itemCard(int index) {
    return Dismissible(
      key: ObjectKey(_formData.items[index]),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => setState(() => _formData.items.removeAt(index)),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onError),
      ),
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border.all()),
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
            NameChipsField(consumedBy: _formData.items[index].consumedBy),
          ],
        ),
      ),
    ).paddingSymmetric(vertical: 4);
  }
}
