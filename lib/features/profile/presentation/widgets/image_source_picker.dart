import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:selo/generated/l10n.dart';

class ImageSourcePicker extends StatelessWidget {
  const ImageSourcePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.photo_library, color: colorScheme.inversePrimary),
          title: Text(S.of(context)!.gallery, style: contrastM(context)),
          onTap: () => Navigator.pop(context, ImageSource.gallery),
        ),
        ListTile(
          leading: Icon(Icons.camera_alt, color: colorScheme.inversePrimary),
          title: Text(S.of(context)!.camera, style: contrastM(context)),
          onTap: () => Navigator.pop(context, ImageSource.camera),
        ),
      ],
    );
  }
}
