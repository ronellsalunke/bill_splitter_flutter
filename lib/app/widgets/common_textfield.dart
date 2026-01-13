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
    final defaultLabelColor = labelColor ?? Theme.of(context).colorScheme.onSurface; // Dark slate grey
    final defaultHintColor = hintColor ?? Theme.of(context).colorScheme.onSurface; // Medium grey
    final defaultInputColor = inputTextColor ?? Theme.of(context).colorScheme.onSurface; // Near black
    final defaultBorderColor = borderColor ?? Theme.of(context).colorScheme.onSurface; // Deep navy/near-black
    final defaultCursorColor = cursorColor ?? Theme.of(context).colorScheme.primary;
    final focusedBorderColor = cursorColor ?? Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: defaultLabelColor, letterSpacing: 1.2),
          ),

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

            contentPadding: const EdgeInsets.only(left: 0, right: 0, top: 8, bottom: 12),

            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: defaultBorderColor, width: 1.0)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: focusedBorderColor, width: 1.4)),
            errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red.shade700, width: 1.0)),
            focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red.shade700, width: 1.0)),
            disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: defaultBorderColor.withOpacity(0.3), width: 1.0)),
            suffixIcon: suffixIcon,
            filled: false,
          ),
        ),
      ],
    );
  }
}
