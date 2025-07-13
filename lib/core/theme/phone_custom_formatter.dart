import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    var selectionIndex = newValue.selection.end;
    final buffer = StringBuffer();
    int usedDigits = 0;

    buffer.write('+7');
    if (digitsOnly.length > 1) {
      buffer.write(' (');
      final end = digitsOnly.length >= 4 ? 4 : digitsOnly.length;
      buffer.write(digitsOnly.substring(1, end));
      usedDigits = end;
    }

    if (digitsOnly.length >= 4) {
      buffer.write(') ');
      final end = digitsOnly.length >= 7 ? 7 : digitsOnly.length;
      buffer.write(digitsOnly.substring(4, end));
      usedDigits = end;
    }

    if (digitsOnly.length >= 7) {
      buffer.write(' ');
      final end = digitsOnly.length > 11 ? 11 : digitsOnly.length;
      buffer.write(digitsOnly.substring(7, end));
      usedDigits = end;
    }

    // Корректируем позицию курсора
    int nonDigitCount = buffer.toString().replaceAll(RegExp(r'\d'), '').length;
    selectionIndex = buffer.length;

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

final phoneMaskFormatter = MaskTextInputFormatter(
  mask: '+7 (###) ### ####',
  filter: {"#": RegExp(r'\\d')},
);
