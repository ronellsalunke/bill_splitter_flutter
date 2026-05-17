import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:dropdown_button2/dropdown_button2.dart' as dropdown_button2;
import 'package:flutter/material.dart';

class CommonMultiDropdownItem<T extends Object> {
  final String label;
  final T value;

  const CommonMultiDropdownItem({required this.label, required this.value});
}

class CommonMultiDropdown<T extends Object> extends StatelessWidget {
  final ValueNotifier<List<T>> valuesListenable;
  final List<CommonMultiDropdownItem<T>> items;
  final void Function(List<T>)? onSelectionChanged;
  final String? label;
  final String hintText;
  final T? selectAllValue;
  final String allSelectedText;
  final Color? labelColor;
  final Color? hintColor;
  final Color? textColor;
  final Color? borderColor;

  const CommonMultiDropdown({
    super.key,
    required this.valuesListenable,
    required this.items,
    required this.hintText,
    this.onSelectionChanged,
    this.label,
    this.selectAllValue,
    this.allSelectedText = 'Everyone',
    this.labelColor,
    this.hintColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultLabelColor = labelColor ?? context.colorScheme.onSurface;
    final defaultHintColor = hintColor ?? context.colorScheme.onSurfaceVariant;
    final defaultTextColor = textColor ?? context.colorScheme.onSurface;
    final defaultBorderColor = borderColor ?? context.colorScheme.outline;
    final borderRadius = BorderRadius.circular(8);
    final textStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: defaultTextColor,
      height: 1.4,
      fontFamily: 'jetbrains_mono',
    );
    final hintStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: defaultHintColor,
      height: 1.4,
      fontFamily: 'jetbrains_mono',
    );
    final selectableValues = items.where((item) => item.value != selectAllValue).map((item) => item.value).toList();
    final isEnabled = onSelectionChanged != null && items.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: defaultLabelColor, letterSpacing: 1.2),
          ),
        if (label != null) const SizedBox(height: 6),
        DropdownButtonHideUnderline(
          child: dropdown_button2.DropdownButton2<T>(
            multiValueListenable: valuesListenable,
            items: items
                .map(
                  (item) => dropdown_button2.DropdownItem<T>(
                    value: item.value,
                    height: 44,
                    closeOnTap: false,
                    child: ValueListenableBuilder<List<T>>(
                      valueListenable: valuesListenable,
                      builder: (context, values, _) {
                        final isSelected = item.value == selectAllValue
                            ? selectableValues.isNotEmpty && selectableValues.every(values.contains)
                            : values.contains(item.value);

                        return Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              color: isSelected ? context.colorScheme.primary : defaultHintColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: textStyle),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                )
                .toList(),
            onChanged: isEnabled
                ? (value) {
                    if (value == null) return;

                    final currentValues = List<T>.from(valuesListenable.value);
                    final nextValues = _nextSelection(
                      value: value,
                      currentValues: currentValues,
                      selectableValues: selectableValues,
                    );

                    valuesListenable.value = nextValues;
                    onSelectionChanged?.call(nextValues);
                  }
                : null,
            isExpanded: true,
            hint: Text(hintText, style: hintStyle, overflow: TextOverflow.ellipsis),
            disabledHint: Text(hintText, style: hintStyle, overflow: TextOverflow.ellipsis),
            selectedItemBuilder: (context) => items
                .map(
                  (_) => ValueListenableBuilder<List<T>>(
                    valueListenable: valuesListenable,
                    builder: (context, values, _) => Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        _selectedLabel(values, selectableValues),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: values.isEmpty ? hintStyle : textStyle,
                      ),
                    ),
                  ),
                )
                .toList(),
            style: textStyle,
            buttonStyleData: dropdown_button2.ButtonStyleData(
              height: 48,
              width: double.infinity,
              padding: const EdgeInsets.only(left: 12, right: 12),
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(color: isEnabled ? defaultBorderColor : defaultBorderColor.withValues(alpha: 0.3)),
              ),
              elevation: 0,
            ),
            iconStyleData: dropdown_button2.IconStyleData(
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: isEnabled ? defaultTextColor : defaultHintColor),
              iconSize: 22,
            ),
            dropdownStyleData: dropdown_button2.DropdownStyleData(
              maxHeight: 250,
              decoration: BoxDecoration(color: context.colorScheme.surface, borderRadius: borderRadius),
              elevation: 2,
            ),
            menuItemStyleData: const dropdown_button2.MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 12)),
          ),
        ),
      ],
    );
  }

  List<T> _nextSelection({required T value, required List<T> currentValues, required List<T> selectableValues}) {
    if (value == selectAllValue) {
      final allSelected = selectableValues.isNotEmpty && selectableValues.every(currentValues.contains);
      return allSelected ? <T>[] : List<T>.from(selectableValues);
    }

    if (currentValues.contains(value)) {
      return currentValues.where((item) => item != value).toList();
    }

    return [...currentValues, value];
  }

  String _selectedLabel(List<T> values, List<T> selectableValues) {
    if (values.isEmpty) return hintText;

    final allSelected = selectableValues.isNotEmpty && selectableValues.every(values.contains);
    if (allSelected) return allSelectedText;

    return items
        .where((item) => item.value != selectAllValue)
        .where((item) => values.contains(item.value))
        .map((item) => item.label)
        .join(', ');
  }
}
