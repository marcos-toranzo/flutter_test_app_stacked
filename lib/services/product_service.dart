import 'dart:convert';

import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/models/product.dart';
import 'package:flutter_app_test_stacked/services/network_service.dart';

class ProductService {
  Future<ApiResponse<List<String>>> getCategories() async {
    final networkService = locator<NetworkService>();

    try {
      final response = await networkService.get('products/categories');

      if (response.statusCode == StatusCode.ok) {
        final categories = (json.decode(response.body) as List).cast<String>();

        return ApiResponse(success: true, data: categories);
      }
    } on Exception catch (e) {
      return ApiResponse(
        success: false,
        errorMessage: e.toString(),
      );
    }

    return const ApiResponse(success: false);
  }

  Future<ApiResponse<List<Product>>> getProducts({
    int limit = 0,
    int skip = 0,
    String search = '',
  }) async {
    final networkService = locator<NetworkService>();

    try {
      final response = await networkService.get(
        'products/search',
        params: {
          'limit': limit.toString(),
          'skip': skip.toString(),
          'q': search,
        },
      );

      if (response.statusCode == StatusCode.ok) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final productsData =
            (data['products'] as List).cast<Map<String, dynamic>>();

        final products = productsData.map(Product.fromMap).toList();

        return ApiResponse(
          success: true,
          data: products,
          limit: data['limit'],
          skip: data['skip'],
          total: data['total'],
        );
      }
    } on Exception catch (e) {
      return ApiResponse(
        success: false,
        errorMessage: e.toString(),
      );
    }

    return const ApiResponse(success: false);
  }

  Future<ApiResponse<List<Product>>> getCategoryProducts(
    String category, {
    int limit = 0,
    int skip = 0,
  }) async {
    final networkService = locator<NetworkService>();

    try {
      final response = await networkService.get(
        'products/category/$category',
        params: {
          'limit': limit.toString(),
          'skip': skip.toString(),
        },
      );

      if (response.statusCode == StatusCode.ok) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final productsData =
            (data['products'] as List).cast<Map<String, dynamic>>();

        final products = productsData.map(Product.fromMap).toList();

        return ApiResponse(
          success: true,
          data: products,
          limit: data['limit'],
          skip: data['skip'],
          total: data['total'],
        );
      }
    } on Exception catch (e) {
      return ApiResponse(
        success: false,
        errorMessage: e.toString(),
      );
    }

    return const ApiResponse(success: false);
  }
}
