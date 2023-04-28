import 'dart:async';

import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/app/app.router.dart';
import 'package:flutter_app_test_stacked/app/utils/formatting.dart';
import 'package:flutter_app_test_stacked/app/utils/iterable_utils.dart';
import 'package:flutter_app_test_stacked/services/cart_service.dart';
import 'package:flutter_app_test_stacked/services/product_service.dart';
import 'package:flutter_app_test_stacked/ui/views/home/product_fetching_result.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

const String fetchingCategories = 'fetchingCategories';
const String gettingCartCount = 'gettingCartCount';
const String allCategories = 'All';
const int productsLimit = 10;

class HomeViewModel extends ReactiveViewModel {
  final _productService = locator<ProductService>();
  final _navigationService = locator<NavigationService>();
  final _cartService = locator<CartService>();

  List<String> _categories = [];
  List<String> get categories => [..._categories];

  int get cartCount => _cartService.count;

  String _searchText = '';

  Future<bool> init() async {
    final result = _fetchCategories();
    _cartService.getEntries();

    rebuildUi();

    return result;
  }

  Future<bool> _fetchCategories() async {
    final categoriesResult = await runBusyFuture(
      _productService.getCategories(),
      busyObject: fetchingCategories,
    );

    if (!categoriesResult.success) {
      _categories = [allCategories];
      return false;
    }

    _categories = [
      allCategories,
      ...categoriesResult.data!.map((e) => e.capitalize()),
    ];

    return true;
  }

  Future<bool> refreshCategories() async {
    final result = _fetchCategories();
    rebuildUi();

    return result;
  }

  Future<ProductFetchingResult> getCategoryProducts(
    String category,
    int page,
  ) async {
    final result = category == allCategories
        ? await _productService.getProducts(
            limit: productsLimit,
            skip: page * productsLimit,
            search: _searchText,
            select: [
              ProductField.id,
              ProductField.price,
              ProductField.thumbnail,
              ProductField.title,
              ProductField.discountPercentage,
            ],
          )
        : await _productService.getCategoryProducts(
            category,
            limit: productsLimit,
            skip: page * productsLimit,
            select: [
              ProductField.id,
              ProductField.price,
              ProductField.thumbnail,
              ProductField.title,
              ProductField.discountPercentage,
            ],
          );

    if (result.success) {
      final last = result.skip! + result.limit! >= result.total!;

      final products = category == allCategories
          ? result.data!
          : result.data!.whereList(
              (product) => product.title.contains(_searchText),
            );

      return ProductFetchingResult(
        products: products,
        last: last,
      );
    }

    return const ProductFetchingResult();
  }

  void onSearchTextChanged(String searchText) {
    _searchText = searchText;
  }

  Future<bool> onProductShoppingCartTap(int productId) async {
    final result = await runBusyFuture(
      _cartService.addProduct(productId),
      busyObject: productId,
    );

    return result.success;
  }

  void onProductTap(int productId) {
    _navigationService.navigateToProductView(productId: productId);
  }

  void onCartButtonPressed() {
    _navigationService.navigateToCartView();
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [_cartService];
}
