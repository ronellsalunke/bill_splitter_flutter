import 'package:bs_flutter/app/models/update/update_manifest.dart';
import 'package:bs_flutter/app/routes/router.dart';
import 'package:bs_flutter/app/widgets/common_button.dart';
import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:bs_flutter/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';

Future<void> showUpdateChangelogSheet(BuildContext context, {required UpdateRelease release}) async {
  await rootNavigatorKey.currentState!.push(
    StupidSimpleSheetRoute<void>(barrierDismissible: false, draggable: false, child: _UpdateChangelogSheet(release: release)),
  );
}

class _UpdateChangelogSheet extends StatelessWidget {
  const _UpdateChangelogSheet({required this.release});

  final UpdateRelease release;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SheetBackground(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(999)),
                ),
              ),
              verticalSpace(20),
              Text(
                'what’s new',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, decoration: TextDecoration.none),
              ),
              verticalSpace(16),
              for (final change in release.changes) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    horizontalSpace(8),
                    Expanded(
                      child: Text(change, style: textTheme.bodyMedium?.copyWith(height: 1.45, decoration: TextDecoration.none)),
                    ),
                  ],
                ),
                verticalSpace(10),
              ],
              verticalSpace(8),
              CommonButton(text: 'ok', mainAxisSize: MainAxisSize.max, borderRadius: 8, onTap: () => context.pop()),
            ],
          ),
        ),
      ),
    );
  }
}
