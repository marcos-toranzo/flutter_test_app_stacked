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

class HomeViewModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _productService = locator<ProductService>();

  Map<String, List<Product>> _categoryProducts = {allCategories: []};

  List<Product> _filteredCategoryProducts = [];

  List<String> get categories => _categoryProducts.keys.toList();

  List<Product> getCategoryProducts(String category) {
    final products = _categoryProducts[category];

    if (products == null) {
      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Oops!',
        description: 'Something went wrong.',
      );

      return [];
    }

    return products;
  }

  void onTabChanged(int index) {
    _fetchCategoryProducts(categories[index]);
  }

  Future<void> _fetchCategoryProducts(String category) async {
    if (!busy(category)) {
      final products = _categoryProducts[category];

      if (products?.isEmpty != false) {
        final result = await runBusyFuture(
          _productService.getCategoryProducts(category),
          busyObject: category,
        );

        if (!result.success) {
          _dialogService.showCustomDialog(
            variant: DialogType.infoAlert,
            title: 'Oops!',
            description: 'Something went wrong trying to fetch the categories.',
          );

          return;
        }

        _categoryProducts[category] = result.data!;

        rebuildUi();
      }
    }
  }

  Future<void> _fetchCategories() async {
    _categoryProducts = {allCategories: []};

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
      return;
    }

    for (var category in categoriesResult.data!) {
      _categoryProducts[category.capitalize()] = [];
    }

    final productsResult = await runBusyFuture(
      _productService.getProducts(),
      busyObject: allCategories,
    );

    if (!productsResult.success) {
      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        title: 'Oops!',
        description: 'Something went wrong trying to fetch the products.',
      );
      return;
    }

    _categoryProducts[allCategories] = productsResult.data!;
  }

  Future<void> init() async {
    _fetchCategories();
    rebuildUi();
  }
}
