import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CommonDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? label;
  final String hintText;
  final Color? labelColor;
  final Color? hintColor;
  final Color? textColor;
  final Color? borderColor;

  const CommonDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.label,
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
    final textStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: defaultTextColor, height: 1.4);
    final hintStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: defaultHintColor, height: 1.4);
    final dropdownItems = items
        .map(
          (item) => DropdownItem<T>(
            value: item.value,
            height: 44,
            child: DefaultTextStyle(style: textStyle, child: item.child),
          ),
        )
        .toList();

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
          child: DropdownButton2<T>(
            valueListenable: ValueNotifier<T?>(value),
            items: dropdownItems,
            onChanged: onChanged,
            isExpanded: true,
            hint: Text(hintText, style: hintStyle, overflow: TextOverflow.ellipsis),
            disabledHint: Text(hintText, style: hintStyle, overflow: TextOverflow.ellipsis),
            style: textStyle,
            buttonStyleData: ButtonStyleData(
              height: 48,
              width: double.infinity,
              padding: const EdgeInsets.only(left: 12, right: 12),
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(color: onChanged == null ? defaultBorderColor.withValues(alpha: 0.3) : defaultBorderColor),
              ),
              elevation: 0,
            ),
            iconStyleData: IconStyleData(
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: onChanged == null ? defaultHintColor : defaultTextColor),
              iconSize: 22,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 250,
              decoration: BoxDecoration(color: context.colorScheme.surface, borderRadius: borderRadius),
              elevation: 2,
            ),
            menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 12)),
          ),
        ),
      ],
    );
  }
}
