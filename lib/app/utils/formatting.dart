import 'package:intl/intl.dart';

extension DoubleFormattingExtension on double {
  String asCurrency() {
    final formatter = NumberFormat.simpleCurrency(
      decimalDigits: 2,
      name: 'USD',
    );

    return formatter.format(this);
  }
}

extension StringFormattingExtension on String {
  String capitalize() {
    if (length == 0) {
      return this;
    }

    final firstLetter = this[0];
    final rest = substring(1);

    return '${firstLetter.toUpperCase()}$rest';
  }
}
