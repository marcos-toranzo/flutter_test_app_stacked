import 'dart:async';

import 'package:flutter_app_test_stacked/app/app.dialogs.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/app/app.router.dart';
import 'package:flutter_app_test_stacked/app/utils/formatting.dart';
import 'package:flutter_app_test_stacked/services/product_service.dart';
import 'package:flutter_app_test_stacked/ui/views/home/product_fetching_result.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

const String fetchingCategories = 'categories';
const String allCategories = 'All';
const int productsLimit = 10;

class HomeViewModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _productService = locator<ProductService>();
  final _navigationService = locator<NavigationService>();

  List<String> _categories = [];
  List<String> get categories => [..._categories];

  String _searchText = '';

  Future<void> init() async {
    _fetchCategories();
    rebuildUi();
  }

  Future<void> _fetchCategories() async {
    final categoriesResult = await runBusyFuture(
      _productService.getCategories(),
      busyObject: fetchingCategories,
    );

    if (!categoriesResult.success) {
      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Oops!',
        description: 'Something went wrong trying to fetch the categories.',
      );

      _categories = [allCategories];
      return;
    }

    _categories = [
      allCategories,
      ...categoriesResult.data!.map((e) => e.capitalize()),
    ];
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
          )
        : await _productService.getCategoryProducts(
            category,
            limit: productsLimit,
            skip: page * productsLimit,
          );

    if (result.success) {
      final last = result.skip! + result.limit! >= result.total!;

      final products = category == allCategories
          ? result.data!
          : result.data!
              .where(
                (product) => product.title.contains(_searchText),
              )
              .toList();

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

  void onProductShoppingCartTap(int productId) {}

  void onProductTap(int productId) {
    _navigationService.navigateToProductView(productId: productId);
  }

  void onCartButtonPressed() {
    _navigationService.navigateToCartView();
  }
}
