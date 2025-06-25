import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {

  const ProfileAvatar({
    required this.radius, required this.backgroundColor, required this.iconColor, super.key,
    this.imageUrl,
    this.localImage,
  });
  final String? imageUrl;
  final File? localImage;
  final double radius;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    ImageProvider? backgroundImage;
    if (localImage != null) {
      backgroundImage = FileImage(localImage!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      backgroundImage = CachedNetworkImageProvider(imageUrl!);
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: backgroundImage,
      child:
          backgroundImage == null
              ? Icon(Icons.person, size: radius, color: iconColor)
              : null,
    );
  }
}
