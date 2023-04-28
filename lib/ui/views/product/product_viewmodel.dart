import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/models/product.dart';
import 'package:flutter_app_test_stacked/services/cart_service.dart';
import 'package:flutter_app_test_stacked/services/product_service.dart';
import 'package:stacked/stacked.dart';

const String fetchingProduct = 'fetchingProduct';
const String addingToCart = 'addingToCart';

class ProductViewModel extends BaseViewModel {
  final _productService = locator<ProductService>();
  final _cartService = locator<CartService>();

  final int productId;

  ProductViewModel(this.productId);

  Product? _product;
  Product? get product => _product;

  Future<void> init() async {
    _fetchProduct();
    rebuildUi();
  }

  Future<void> onRefresh() async {
    _fetchProduct();
    rebuildUi();
  }

  Future<void> _fetchProduct() async {
    final response = await runBusyFuture(
      _productService.getProduct(productId),
      busyObject: fetchingProduct,
    );

    _product = response.data;
  }

  Future<bool> onAddToCartPressed() async {
    final result = await runBusyFuture(
      _cartService.addProduct(productId),
      busyObject: addingToCart,
    );

    return result.success;
  }
}
