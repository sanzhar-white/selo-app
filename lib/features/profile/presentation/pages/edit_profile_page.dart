import 'package:flutter/material.dart';
import 'package:selo/core/theme/text_styles.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: contrastBoldM(context)),
        iconTheme: IconThemeData(color: colorScheme.inversePrimary),
      ),
      body: CustomScrollView(
        slivers: [SliverToBoxAdapter(child: Text('Edit Profile'))],
      ),
    );
  }
}
