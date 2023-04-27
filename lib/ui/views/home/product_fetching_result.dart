import 'package:flutter_app_test_stacked/models/product.dart';

class ProductFetchingResult {
  final List<Product>? products;
  final bool last;

  const ProductFetchingResult({
    this.products,
    this.last = false,
  });
}
