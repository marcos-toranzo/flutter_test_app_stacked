import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/app/app.router.dart';
import 'package:flutter_app_test_stacked/app/utils/iterable_utils.dart';
import 'package:flutter_app_test_stacked/models/cart_entry.dart';
import 'package:flutter_app_test_stacked/models/product.dart';
import 'package:flutter_app_test_stacked/services/cart_service.dart';
import 'package:flutter_app_test_stacked/services/product_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

const String fetchingProducts = 'fetchingProducts';
const String emptyingCart = 'emptyingCart';

class CartViewModel extends ReactiveViewModel {
  final _cartService = locator<CartService>();
  final _productService = locator<ProductService>();
  final _navigationService = locator<NavigationService>();

  Map<int, CartEntry> get productIdCartEntryMap {
    final Map<int, CartEntry> result = {};

    for (var cartEntry in _cartService.entries) {
      result[cartEntry.productId] = cartEntry;
    }

    return result;
  }

  List<Product>? _products;
  List<Product>? get products => _products != null ? [..._products!] : null;

  double get total =>
      products?.reduceAndCompute(
          (acc, product) =>
              acc! + product.price * productIdCartEntryMap[product.id]!.count,
          0.0) ??
      0;

  int get count => _cartService.count;

  Future<void> init() async {
    _fetchProducts();
    rebuildUi();
  }

  Future<void> _fetchProducts() async {
    final cartEntries = await _fetchCartEntries();

    _products = null;

    if (cartEntries != null) {
      final response = await runBusyFuture(
        _productService.getProductsWithIds(
          cartEntries.mapList((entry) => entry.productId),
          select: [
            ProductField.id,
            ProductField.price,
            ProductField.thumbnail,
            ProductField.title,
          ],
        ),
        busyObject: fetchingProducts,
      );

      _products = response.data;
    }
  }

  Future<List<CartEntry>?> _fetchCartEntries() async {
    final response = await runBusyFuture(
      _cartService.getEntries(),
      busyObject: fetchingProducts,
    );

    return response.data;
  }

  int getProductCount(int productId) =>
      productIdCartEntryMap[productId]?.count ?? 0;

  Future<bool> onEmptyCart() async {
    final result = await runBusyFuture(
      _cartService.empty(),
      busyObject: emptyingCart,
    );

    if (!result.success) {
      return false;
    }

    _products = [];

    rebuildUi();
    return true;
  }

  void onProductTap(int productId) {
    _navigationService.navigateToProductView(productId: productId);
  }

  Future<bool> onAddProduct(int productId) async {
    final result = await runBusyFuture(
      _cartService.addProduct(productId),
      busyObject: productId,
    );

    if (!result.success) {
      return false;
    }

    rebuildUi();
    return true;
  }

  Future<bool> onRemoveProduct(int productId) async {
    final result = await runBusyFuture(
      _cartService.removeProduct(productId),
      busyObject: productId,
    );

    if (!result.success) {
      return false;
    }

    if (result.data == null) {
      _products = _products!.whereList((element) => element.id != productId);
    }

    rebuildUi();
    return true;
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [_cartService];
}
