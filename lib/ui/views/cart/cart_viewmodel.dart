import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/app/app.router.dart';
import 'package:flutter_app_test_stacked/models/product.dart';
import 'package:flutter_app_test_stacked/services/cart_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

const String fetchingProducts = 'fetchingProducts';

class CartViewModel extends BaseViewModel {
  final _cartService = locator<CartService>();
  final _navigationService = locator<NavigationService>();

  final Map<int, int> _productsCount = {};
  Map<int, int> get productsCount => {..._productsCount};

  List<Product>? _products;
  List<Product>? get products => _products != null ? [..._products!] : null;

  double get total => 337.15;

  Future<void> init() async {
    _fetchProducts();
    rebuildUi();
  }

  Future<void> _fetchProducts() async {
    final response = await runBusyFuture(
      _cartService.getProducts(),
      busyObject: fetchingProducts,
    );

    _products = response.data;
  }

  Future<void> onDeleteCart() async {}

  void onProductTap(int productId) {
    _navigationService.navigateToProductView(productId: productId);
  }

  void onAddProduct(int productId) {
    _cartService.addProduct(productId);
  }

  void onRemoveProduct(int productId) {
    _cartService.removeProduct(productId);
  }
}
