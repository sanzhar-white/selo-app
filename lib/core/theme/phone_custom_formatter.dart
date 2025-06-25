import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    final buffer = StringBuffer();
    int selectionIndex = newValue.selection.end;

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    buffer.write('+7');

    if (digitsOnly.length >= 1) {
      buffer.write(' (');
      buffer.write(digitsOnly.substring(1, digitsOnly.length.clamp(4, 4)));
    }

    if (digitsOnly.length >= 4) {
      buffer.write(') ');
      buffer.write(digitsOnly.substring(4, digitsOnly.length.clamp(7, 7)));
    }

    if (digitsOnly.length >= 7) {
      buffer.write(' ');
      buffer.write(digitsOnly.substring(7, digitsOnly.length.clamp(11, 11)));
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
