import 'package:bs_flutter/app/routes/router.dart';
import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:bs_flutter/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_segmented_list/material_segmented_list.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';

Future<ImageSource?> showUploadImageSourceSheet(BuildContext context) {
  return rootNavigatorKey.currentState!.push(StupidSimpleSheetRoute<ImageSource>(child: const _UploadImageSourceSheet()));
}

class _UploadImageSourceSheet extends StatelessWidget {
  const _UploadImageSourceSheet();

  @override
  Widget build(BuildContext context) {
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
                  decoration: BoxDecoration(color: context.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(999)),
                ),
              ),
              verticalSpace(20),
              Text('upload image', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              verticalSpace(16),
              SegmentedListSection(
                children: [
                  SegmentedListTile(
                    onTap: () => context.pop(ImageSource.gallery),
                    leading: Icon(Icons.photo_library_outlined, color: context.colorScheme.primary),
                    title: const Text('gallery', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  SegmentedListTile(
                    onTap: () => context.pop(ImageSource.camera),
                    leading: Icon(Icons.camera_alt_outlined, color: context.colorScheme.primary),
                    title: const Text('camera', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
