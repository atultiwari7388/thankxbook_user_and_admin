import 'package:flutter/services.dart';

class WordLimitFormatter extends TextInputFormatter {
  final int maxWords;

  WordLimitFormatter({required this.maxWords});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    List<String> words = newValue.text.trim().split(RegExp(r'\s+'));

    if (words.length > maxWords) {
      return oldValue;
    }

    return newValue;
  }
}
