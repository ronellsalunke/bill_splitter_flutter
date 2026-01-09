import 'package:bs_flutter/extensions/widget_extensions.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class DottedButton extends StatelessWidget {
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

  const DottedButton({
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
    this.dashPattern = const [6, 3],
    this.borderWidth = 1,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    this.spacing = 8,
    this.enabled = true,
    this.alignment = MainAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = iconColor ?? Theme.of(context).iconTheme.color;
    final defaultTextColor = textColor ?? Theme.of(context).textTheme.bodyLarge?.color;
    final bgColor = backgroundColor ?? Colors.white;

    return DottedBorder(
      options: const RoundedRectDottedBorderOptions(radius: Radius.circular(0), dashPattern: [6, 4], padding: EdgeInsets.all(1)),
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: defaultTextColor,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          side: BorderSide.none,
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
      ),
    );
  }
}

class DottedButtonCustom extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderRadius;
  final List<double> dashPattern;
  final double borderWidth;
  final bool enabled;

  const DottedButtonCustom({
    super.key,
    required this.child,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius = 2,
    this.dashPattern = const [8, 4],
    this.borderWidth = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: DottedBorder(
          options: const RoundedRectDottedBorderOptions(radius: Radius.circular(0), dashPattern: [6, 2]),
          child: Container(color: backgroundColor, child: child),
        ),
      ),
    );
  }
}
