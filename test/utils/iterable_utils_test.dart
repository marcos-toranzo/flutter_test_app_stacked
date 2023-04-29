import 'package:flutter_app_test_stacked/utils/iterable_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/data.dart';

void main() {
  group('IterableUtils Tests -', () {
    test('should reduce and compute correctly', () {
      final products = MockData.products;

      final double totalComputed =
          products.reduceAndCompute((acc, element) => acc + element.price, 0.0);

      double total = 0;

      for (var product in products) {
        total += product.price;
      }

      expect(totalComputed, total);
    });
  });
}
