import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class CommonMultiDropdown<T extends Object> extends StatelessWidget {
  final MultiSelectController<T> controller;
  final List<DropdownItem<T>> items;
  final void Function(List<T>)? onSelectionChanged;
  final String? label;
  final String hintText;
  final Color? labelColor;
  final Color? hintColor;
  final Color? textColor;
  final Color? borderColor;

  const CommonMultiDropdown({
    super.key,
    required this.controller,
    required this.items,
    required this.hintText,
    this.onSelectionChanged,
    this.label,
    this.labelColor,
    this.hintColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultLabelColor = labelColor ?? context.colorScheme.onSurface;
    final defaultHintColor = hintColor ?? context.colorScheme.onSurface;
    final defaultTextColor = textColor ?? context.colorScheme.onSurface;
    final defaultBorderColor = borderColor ?? context.colorScheme.onSurface;
    final focusedBorderColor = context.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: defaultLabelColor, letterSpacing: 1.2),
          ),
        const SizedBox(height: 8),
        MultiDropdown<T>(
          items: items,
          controller: controller,
          enabled: true,
          chipDecoration: ChipDecoration(
            backgroundColor: context.colorScheme.secondary,
            borderRadius: BorderRadiusGeometry.circular(4),
            wrap: true,
            runSpacing: 2,
            spacing: 10,
            labelStyle: TextStyle(color: context.colorScheme.onSecondary, fontFamily: 'jetbrains_mono'),
            deleteIcon: Icon(Icons.close, size: 16, color: context.colorScheme.onSecondary),
          ),
          fieldDecoration: FieldDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: defaultHintColor,
              fontFamily: 'jetbrains_mono',
            ),
            showClearIcon: false,
            border: UnderlineInputBorder(borderSide: BorderSide(color: defaultBorderColor, width: 1.0)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: focusedBorderColor, width: 1.4)),
          ),
          dropdownDecoration: DropdownDecoration(
            maxHeight: 250,
            backgroundColor: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          dropdownItemDecoration: DropdownItemDecoration(
            selectedIcon: Icon(Icons.check, color: context.colorScheme.primary),
            selectedBackgroundColor: context.colorScheme.primary.withOpacity(0.1),
            selectedTextStyle: TextStyle(color: defaultTextColor, fontFamily: 'jetbrains_mono'),
            textColor: defaultTextColor,
            textStyle: const TextStyle(fontFamily: 'jetbrains_mono'),
          ),
          onSelectionChange: onSelectionChanged,
        ),
      ],
    );
  }
}
