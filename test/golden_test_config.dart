import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(Future<void> Function() testMain) async {
  await GoldenToolkit.runWithConfiguration(
    () async {
      await loadAppFonts();
      await testMain();
    },
    config: GoldenToolkitConfiguration(
      defaultDevices: [
        Device.phone,
        Device.iphone11,
        Device(size: const Size(600, 800), name: 'Custom'),
      ],
    ),
  );
}
