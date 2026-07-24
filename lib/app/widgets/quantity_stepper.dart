import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({super.key, required this.value, required this.onDecrement, required this.onIncrement})
    : assert(value >= 1);

  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appThemeColors = context.appThemeColors;

    return Semantics(
      label: 'Quantity: $value',
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            IconButton(
              color: colorScheme.error,
              tooltip: 'Decrease quantity',
              onPressed: onDecrement,
              icon: const Icon(Icons.remove_rounded),
            ),
            Expanded(
              child: Center(
                child: Text('$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            IconButton(
              color: appThemeColors.success,
              tooltip: 'Increase quantity',
              onPressed: onIncrement,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
