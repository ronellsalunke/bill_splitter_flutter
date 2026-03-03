import 'package:bs_flutter/extensions/context_extensions.dart';
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
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down, color: defaultTextColor),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: defaultTextColor,
            height: 1.4,
            fontFamily: 'jetbrains_mono',
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: defaultHintColor,
              height: 1.4,
              fontFamily: 'jetbrains_mono',
            ),
            contentPadding: const EdgeInsets.only(left: 0, right: 0, top: 8, bottom: 12),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: defaultBorderColor, width: 1.0)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: focusedBorderColor, width: 1.4)),
            errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.colorScheme.error, width: 1.0)),
            focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.colorScheme.error, width: 1.0)),
            disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: defaultBorderColor.withOpacity(0.3), width: 1.0)),
            filled: false,
          ),
        ),
      ],
    );
  }
}
