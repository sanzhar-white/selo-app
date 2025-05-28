import 'package:flutter/material.dart';

enum _TextColor {
  greenPrimary,
  greenOnPrimary,
  contrastInversePrimary,
  contrastOnPrimary,
  secondary,
}

TextStyle _textStyle(
  BuildContext context, {
  required double fontSize,
  required bool isBold,
  required _TextColor colorType,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  final color = switch (colorType) {
    _TextColor.greenPrimary => colorScheme.primary,
    _TextColor.greenOnPrimary => colorScheme.onPrimary,
    _TextColor.contrastInversePrimary => colorScheme.inversePrimary,
    _TextColor.contrastOnPrimary => colorScheme.onPrimary,
    _TextColor.secondary => colorScheme.secondary,
  };

  return TextStyle(
    fontSize: fontSize,
    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    color: color,
  );
}

// GREEN styles
TextStyle greenXS(BuildContext context) => _textStyle(
  context,
  fontSize: 10,
  isBold: false,
  colorType: _TextColor.greenPrimary,
);
TextStyle greenBoldXS(BuildContext context) => _textStyle(
  context,
  fontSize: 10,
  isBold: true,
  colorType: _TextColor.greenPrimary,
);

TextStyle greenS(BuildContext context) => _textStyle(
  context,
  fontSize: 12,
  isBold: false,
  colorType: _TextColor.greenPrimary,
);
TextStyle greenBoldS(BuildContext context) => _textStyle(
  context,
  fontSize: 12,
  isBold: true,
  colorType: _TextColor.greenPrimary,
);

TextStyle greenM(BuildContext context) => _textStyle(
  context,
  fontSize: 16,
  isBold: false,
  colorType: _TextColor.greenPrimary,
);
TextStyle greenBoldM(BuildContext context) => _textStyle(
  context,
  fontSize: 16,
  isBold: true,
  colorType: _TextColor.greenPrimary,
);

TextStyle greenL(BuildContext context) => _textStyle(
  context,
  fontSize: 24,
  isBold: false,
  colorType: _TextColor.greenPrimary,
);
TextStyle greenBoldL(BuildContext context) => _textStyle(
  context,
  fontSize: 24,
  isBold: true,
  colorType: _TextColor.greenPrimary,
);

// OVER GREEN styles (onPrimary)
TextStyle overGreenXS(BuildContext context) => _textStyle(
  context,
  fontSize: 10,
  isBold: false,
  colorType: _TextColor.greenOnPrimary,
);
TextStyle overGreenBoldXS(BuildContext context) => _textStyle(
  context,
  fontSize: 10,
  isBold: true,
  colorType: _TextColor.greenOnPrimary,
);

TextStyle overGreenS(BuildContext context) => _textStyle(
  context,
  fontSize: 12,
  isBold: false,
  colorType: _TextColor.greenOnPrimary,
);
TextStyle overGreenBoldS(BuildContext context) => _textStyle(
  context,
  fontSize: 12,
  isBold: true,
  colorType: _TextColor.greenOnPrimary,
);

TextStyle overGreenM(BuildContext context) => _textStyle(
  context,
  fontSize: 16,
  isBold: false,
  colorType: _TextColor.greenOnPrimary,
);
TextStyle overGreenBoldM(BuildContext context) => _textStyle(
  context,
  fontSize: 16,
  isBold: true,
  colorType: _TextColor.greenOnPrimary,
);

TextStyle overGreenL(BuildContext context) => _textStyle(
  context,
  fontSize: 24,
  isBold: false,
  colorType: _TextColor.greenOnPrimary,
);
TextStyle overGreenBoldL(BuildContext context) => _textStyle(
  context,
  fontSize: 24,
  isBold: true,
  colorType: _TextColor.greenOnPrimary,
);

// CONTRAST styles
TextStyle contrastXS(BuildContext context) => _textStyle(
  context,
  fontSize: 10,
  isBold: false,
  colorType: _TextColor.contrastInversePrimary,
);
TextStyle contrastBoldXS(BuildContext context) => _textStyle(
  context,
  fontSize: 10,
  isBold: true,
  colorType: _TextColor.contrastInversePrimary,
);

TextStyle contrastS(BuildContext context) => _textStyle(
  context,
  fontSize: 12,
  isBold: false,
  colorType: _TextColor.contrastInversePrimary,
);
TextStyle contrastBoldS(BuildContext context) => _textStyle(
  context,
  fontSize: 12,
  isBold: true,
  colorType: _TextColor.contrastInversePrimary,
);

TextStyle contrastM(BuildContext context) => _textStyle(
  context,
  fontSize: 16,
  isBold: false,
  colorType: _TextColor.contrastInversePrimary,
);
TextStyle contrastBoldM(BuildContext context) => _textStyle(
  context,
  fontSize: 16,
  isBold: true,
  colorType: _TextColor.contrastInversePrimary,
);

TextStyle contrastL(BuildContext context) => _textStyle(
  context,
  fontSize: 24,
  isBold: false,
  colorType: _TextColor.contrastInversePrimary,
);
TextStyle contrastBoldL(BuildContext context) => _textStyle(
  context,
  fontSize: 24,
  isBold: true,
  colorType: _TextColor.contrastInversePrimary,
);

// OVER CONTRAST styles (onPrimary)
TextStyle overContrastXS(BuildContext context) => _textStyle(
  context,
  fontSize: 10,
  isBold: false,
  colorType: _TextColor.contrastOnPrimary,
);
TextStyle overContrastBoldXS(BuildContext context) => _textStyle(
  context,
  fontSize: 10,
  isBold: true,
  colorType: _TextColor.contrastOnPrimary,
);

TextStyle overContrastS(BuildContext context) => _textStyle(
  context,
  fontSize: 12,
  isBold: false,
  colorType: _TextColor.contrastOnPrimary,
);
TextStyle overContrastBoldS(BuildContext context) => _textStyle(
  context,
  fontSize: 12,
  isBold: true,
  colorType: _TextColor.contrastOnPrimary,
);

TextStyle overContrastM(BuildContext context) => _textStyle(
  context,
  fontSize: 16,
  isBold: false,
  colorType: _TextColor.contrastOnPrimary,
);
TextStyle overContrastBoldM(BuildContext context) => _textStyle(
  context,
  fontSize: 16,
  isBold: true,
  colorType: _TextColor.contrastOnPrimary,
);

TextStyle overContrastL(BuildContext context) => _textStyle(
  context,
  fontSize: 24,
  isBold: false,
  colorType: _TextColor.contrastOnPrimary,
);
TextStyle overContrastBoldL(BuildContext context) => _textStyle(
  context,
  fontSize: 24,
  isBold: true,
  colorType: _TextColor.contrastOnPrimary,
);

TextStyle grayL(BuildContext context) => _textStyle(
  context,
  fontSize: 24,
  isBold: false,
  colorType: _TextColor.secondary,
);

TextStyle grayBoldL(BuildContext context) => _textStyle(
  context,
  fontSize: 24,
  isBold: true,
  colorType: _TextColor.secondary,
);

TextStyle grayM(BuildContext context) => _textStyle(
  context,
  fontSize: 16,
  isBold: false,
  colorType: _TextColor.secondary,
);

TextStyle grayBoldM(BuildContext context) => _textStyle(
  context,
  fontSize: 16,
  isBold: true,
  colorType: _TextColor.secondary,
);

TextStyle grayS(BuildContext context) => _textStyle(
  context,
  fontSize: 12,
  isBold: false,
  colorType: _TextColor.secondary,
);

TextStyle grayBoldS(BuildContext context) => _textStyle(
  context,
  fontSize: 12,
  isBold: true,
  colorType: _TextColor.secondary,
);

TextStyle grayXS(BuildContext context) => _textStyle(
  context,
  fontSize: 10,
  isBold: false,
  colorType: _TextColor.secondary,
);

TextStyle grayBoldXS(BuildContext context) => _textStyle(
  context,
  fontSize: 10,
  isBold: true,
  colorType: _TextColor.secondary,
);
