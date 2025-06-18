import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:selo/core/theme/responsive_radius.dart';
import 'package:selo/core/theme/text_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:selo/generated/l10n.dart';

class ImageSection extends StatelessWidget {
  final List<XFile?> images;
  final VoidCallback onPickImage;
  final ValueChanged<int> onRemoveImage;
  final bool error;
  final String? errorText;

  const ImageSection({
    super.key,
    required this.images,
    required this.onPickImage,
    required this.onRemoveImage,
    this.error = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        SizedBox(height: screenSize.height * 0.015),
        _buildMainImage(context),
        if (error && errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 12.0),
          ),
        ],
        SizedBox(height: screenSize.height * 0.015),
        _buildImageGrid(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(S.of(context).images, style: contrastBoldM(context)),
        const SizedBox(width: 8),
        Text('(${S.of(context).images_optional})', style: grayM(context)),
      ],
    );
  }

  Widget _buildMainImage(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final radius = ResponsiveRadius.screenBased(context);

    return Container(
      width: double.infinity,
      height: screenSize.height * 0.25,
      decoration: BoxDecoration(borderRadius: radius),
      child:
          images.isEmpty
              ? _AddImagePlaceholder(onTap: onPickImage, withText: true)
              : ClipRRect(
                borderRadius: radius,
                child: Image.file(
                  File(images.first!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final radius = ResponsiveRadius.screenBased(context);

    final itemCount = images.length < 10 ? images.length + 1 : 10;

    return SizedBox(
      height:
          (screenSize.width / 2.1) * (itemCount / 2).ceil() +
          8, // Примерно высота гридов
      child: GridView.count(
        padding: EdgeInsets.zero,
        crossAxisCount: 2,
        shrinkWrap: true,
        crossAxisSpacing: screenSize.width * 0.01,
        mainAxisSpacing: screenSize.height * 0.01,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.3,
        children: List.generate(itemCount, (index) {
          if (index < images.length) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: radius,
                  child: Image.file(
                    File(images[index]!.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onRemoveImage(index),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return GestureDetector(
              onTap: onPickImage,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.onSurface,
                  borderRadius: radius,
                ),
                child: Center(
                  child: Icon(
                    CupertinoIcons.plus_square_fill,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}

class _AddImagePlaceholder extends StatelessWidget {
  final VoidCallback onTap;
  final bool withText;

  const _AddImagePlaceholder({required this.onTap, this.withText = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveRadius.screenBased(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.onSurface,
          borderRadius: radius,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.plus_square_fill,
                size: 32,
                color: colorScheme.primary,
              ),
              if (withText) ...[
                const SizedBox(height: 8),
                Text(S.of(context).add_photo, style: greenM(context)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
