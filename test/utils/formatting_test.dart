import 'package:flutter_app_test_stacked/utils/formatting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatting Tests -', () {
    test('should format currency', () {
      expect(43.0.asCurrency(), '\$43.00');

      expect(43.23.asCurrency(), '\$43.23');

      expect(43.001.asCurrency(), '\$43.00');
    });

    test('should capitalize string', () {
      expect('asd'.capitalize(), 'Asd');
      expect('a'.capitalize(), 'A');
      expect(''.capitalize(), '');
    });
  });
}
