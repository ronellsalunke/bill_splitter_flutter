import 'package:bs_flutter/app/bloc/bill_bloc/bill_bloc.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_event.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_state.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/res/app_colors.dart';
import 'package:bs_flutter/app/widgets/common_button.dart';
import 'package:bs_flutter/app/widgets/common_dotted_button.dart';
import 'package:bs_flutter/app/widgets/common_textfield.dart';
import 'package:bs_flutter/extensions/widget_extensions.dart';
import 'package:bs_flutter/utils/widget_utils.dart';
import 'package:bs_flutter/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditBillScreen extends StatefulWidget {
  const EditBillScreen({super.key, required this.billId});

  final String billId;

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
                    label: Text(entry.value, style: const TextStyle(color: AppColors.buttonTextColor)),
                    backgroundColor: AppColors.buttonColor,
                    deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.buttonTextColor),
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
                  text: 'upload receipt (OCR)',
                  icon: Icons.file_upload_outlined,
                  mainAxisSize: MainAxisSize.max,
                  onTap: () {
                    Utility.pickImg(context);
                  },
                ),
                verticalSpace(20),
                CommonTextField(label: 'PAID BY', hintText: 'enter name', controller: _paidByController),
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
                Text('ITEMS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                verticalSpace(10),
                Column(children: _formData.items.asMap().entries.map((entry) => itemCard(entry.key)).toList()),
              ],
            ).paddingSymmetric(horizontal: 16),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              border: const Border(top: BorderSide(color: Colors.black, width: 1)),
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
        color: AppColors.errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, border: Border.all()),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            CommonTextField(
              hintText: 'item name',
              controller: _formData.items[index].nameController,
              onChanged: (value) => _formData.items[index].name = value,
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
