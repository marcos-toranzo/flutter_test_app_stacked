import 'dart:async';

import 'package:flutter_app_test_stacked/app/app.dialogs.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/app/utils/formatting.dart';
import 'package:flutter_app_test_stacked/models/product.dart';
import 'package:flutter_app_test_stacked/services/product_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

const String busyFetchingCategories = 'categories';
const String allCategories = 'All';
const int productsLimit = 10;

class HomeViewModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _productService = locator<ProductService>();

  List<String> _categories = [];
  List<String> get categories => _categories;

  String _searchText = '';

  Future<ProductFetchingResult> getCategoryProducts(
    String category,
    int page,
  ) async {
    if (category == allCategories) {
      final result = await _productService.getProducts(
        limit: productsLimit,
        skip: page * productsLimit,
        search: _searchText,
      );

      if (!result.success) {
        _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: 'Oops!',
          description: 'Something went wrong trying to fetch all the products.',
        );

        return const ProductFetchingResult();
      }

      return ProductFetchingResult(
        products: result.data!,
        last: result.skip! + result.limit! >= result.total!,
      );
    }

    final result = await _productService.getCategoryProducts(
      category,
      limit: productsLimit,
      skip: page * productsLimit,
    );

    if (!result.success) {
      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Oops!',
        description: 'Something went wrong trying to fetch category products.',
      );

      return const ProductFetchingResult();
    }

    return ProductFetchingResult(
      products: result.data!
          .where((element) => element.title.contains(_searchText))
          .toList(),
      last: result.skip! + result.limit! >= result.total!,
    );
  }

  void onTabChanged(int index) {}

  void onSearchTextChanged(String searchText) {
    _searchText = searchText;
  }

  Future<void> _fetchCategories() async {
    _categories = [];
    rebuildUi();

    final categoriesResult = await runBusyFuture(
      _productService.getCategories(),
      busyObject: busyFetchingCategories,
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

  Future<void> init() async {
    _fetchCategories();
    rebuildUi();
  }
}

class ProductFetchingResult {
  final List<Product>? products;
  final bool last;

  const ProductFetchingResult({
    this.products,
    this.last = false,
  });
}
