import 'package:bs_flutter/extensions/widget_extensions.dart';
import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final double? iconSize;
  final double fontSize;
  final FontWeight? fontWeight;
  final double borderRadius;
  final List<double> dashPattern;
  final double borderWidth;
  final EdgeInsets padding;
  final double spacing;
  final bool enabled;
  final MainAxisAlignment alignment;
  final MainAxisSize mainAxisSize;

  const CommonButton({
    super.key,
    required this.text,
    this.icon,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.iconSize,
    this.fontSize = 14,
    this.fontWeight,
    this.borderRadius = 2,
    this.dashPattern = const [8, 4],
    this.borderWidth = 1,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    this.spacing = 8,
    this.enabled = true,
    this.alignment = MainAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = iconColor ?? Theme.of(context).iconTheme.color;
    final defaultTextColor = textColor ?? Theme.of(context).colorScheme.onPrimary;
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.primary;

    return ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: defaultTextColor,
        disabledBackgroundColor: bgColor.withOpacity(0.5),
        disabledForegroundColor: defaultTextColor.withOpacity(0.5),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderColor != null ? BorderSide(color: borderColor!, width: borderWidth) : BorderSide.none,
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: mainAxisSize == MainAxisSize.max ? const Size(double.infinity, 0) : null,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: alignment,
        children: [
          if (icon != null) ...[Icon(icon, size: iconSize, color: defaultIconColor), SizedBox(width: spacing)],
          Text(
            text,
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: defaultTextColor),
          ),
        ],
      ).paddingSymmetric(vertical: 4),
    );
  }
}
