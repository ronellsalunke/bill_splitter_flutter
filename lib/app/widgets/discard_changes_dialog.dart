import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class DiscardChangesDialog {
  const DiscardChangesDialog._();

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('discard changes?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: const Text('unsaved changes will be lost.', style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                context.pop(false);
              },
              child: const Text('keep editing'),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                context.pop(true);
              },
              child: Text('discard', style: TextStyle(color: colorScheme.error)),
            ),
          ],
        );
      },
    );
  }
}
