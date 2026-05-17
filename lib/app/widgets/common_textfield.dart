import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? currentFocus;
  final FocusNode? nextFocus;

  final String? label;
  final String hintText;
  final bool readOnly;
  final bool obscureText;
  final bool enabled;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final Function()? onTap;
  final Function()? onTapOutside;
  final String? errorText;
  final Color? labelColor;
  final Color? hintColor;
  final Color? inputTextColor;
  final Color? borderColor;
  final Color? cursorColor;
  final Widget? suffixIcon;
  final TextCapitalization? textCapitalization;

  const CommonTextField({
    super.key,
    this.label,
    required this.hintText,
    this.controller,
    this.currentFocus,
    this.nextFocus,
    this.readOnly = false,
    this.obscureText = false,
    this.enabled = true,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.onTap,
    this.onTapOutside,
    this.errorText,
    this.labelColor,
    this.hintColor,
    this.inputTextColor,
    this.borderColor,
    this.cursorColor,
    this.suffixIcon,
    this.textCapitalization,
  });

  @override
  Widget build(BuildContext context) {
    // Default colors
    final colorScheme = Theme.of(context).colorScheme;
    final defaultLabelColor = labelColor ?? colorScheme.onSurface;
    final defaultHintColor = hintColor ?? colorScheme.onSurfaceVariant;
    final defaultInputColor = inputTextColor ?? colorScheme.onSurface;
    final defaultBorderColor = borderColor ?? colorScheme.outline;
    final defaultCursorColor = cursorColor ?? colorScheme.primary;
    final focusedBorderColor = cursorColor ?? colorScheme.primary;
    final borderRadius = BorderRadius.circular(8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: defaultLabelColor, letterSpacing: 1.2),
          ),
        if (label != null) const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          focusNode: currentFocus,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          keyboardType: keyboardType,
          obscureText: obscureText,
          obscuringCharacter: '•',
          minLines: minLines,
          maxLines: maxLines,
          maxLength: maxLength,
          readOnly: readOnly,
          enabled: enabled,
          cursorColor: defaultCursorColor,
          cursorWidth: 1.5,
          cursorHeight: 24,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: defaultInputColor, height: 1.4),
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onTapOutside: (_) {
            if (onTapOutside != null) {
              onTapOutside!();
            }
          },
          onFieldSubmitted:
              onFieldSubmitted ??
              (value) {
                if (currentFocus != null && nextFocus != null) {
                  currentFocus!.unfocus();
                  FocusScope.of(context).requestFocus(nextFocus);
                }
              },
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            counterText: '',

            hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: defaultHintColor, height: 1.4),

            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: defaultBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: focusedBorderColor, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: Colors.red.shade700),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: Colors.red.shade700, width: 1.4),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: defaultBorderColor.withValues(alpha: 0.3)),
            ),
            suffixIcon: suffixIcon,
            filled: false,
          ),
        ),
      ],
    );
  }
}
