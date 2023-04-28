import 'dart:convert';

import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/app/utils/iterable_utils.dart';
import 'package:flutter_app_test_stacked/models/product.dart';
import 'package:flutter_app_test_stacked/services/network_service.dart';

class ProductService {
  final _networkService = locator<NetworkService>();

  Future<ApiResponse<List<String>>> getCategories() async {
    try {
      final response = await _networkService.get('products/categories');

      if (response.statusCode != StatusCode.ok) {
        return const ErrorApiResponse();
      }

      final categories = (json.decode(response.body) as List).cast<String>();

      return SuccessApiResponse(data: categories);
    } on Exception catch (e) {
      return ErrorApiResponse(errorMessage: e.toString());
    }
  }

  Future<ApiResponse<List<Product>>> getProducts({
    int limit = 0,
    int skip = 0,
    String search = '',
  }) async {
    try {
      final response = await _networkService.get(
        'products/search',
        params: {
          'limit': limit.toString(),
          'skip': skip.toString(),
          'q': search,
        },
      );

      if (response.statusCode != StatusCode.ok) {
        return const ErrorApiResponse();
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final productsData =
          (data['products'] as List).cast<Map<String, dynamic>>();

      final products = productsData.mapList(Product.fromMap);

      return SuccessApiResponse(
        data: products,
        limit: data['limit'],
        skip: data['skip'],
        total: data['total'],
      );
    } on Exception catch (e) {
      return ErrorApiResponse(errorMessage: e.toString());
    }
  }

  Future<ApiResponse<List<Product>>> getProductsWithIds(List<int> ids) async {
    try {
      final productsResult = await getProducts(limit: 100);

      if (!productsResult.success) {
        return productsResult;
      }

      return SuccessApiResponse(
        data: productsResult.data!
            .whereList((product) => ids.contains(product.id)),
      );
    } on Exception catch (e) {
      return ErrorApiResponse(errorMessage: e.toString());
    }
  }

  Future<ApiResponse<List<Product>>> getCategoryProducts(
    String category, {
    int limit = 0,
    int skip = 0,
  }) async {
    try {
      final response = await _networkService.get(
        'products/category/$category',
        params: {
          'limit': limit.toString(),
          'skip': skip.toString(),
        },
      );

      if (response.statusCode != StatusCode.ok) {
        return const ErrorApiResponse();
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final productsData =
          (data['products'] as List).cast<Map<String, dynamic>>();

      final products = productsData.mapList(Product.fromMap);

      return SuccessApiResponse(
        data: products,
        limit: data['limit'],
        skip: data['skip'],
        total: data['total'],
      );
    } on Exception catch (e) {
      return ErrorApiResponse(errorMessage: e.toString());
    }
  }

  Future<ApiResponse<Product>> getProduct(int id) async {
    try {
      final response = await _networkService.get('products/$id');

      if (response.statusCode != StatusCode.ok) {
        return const ErrorApiResponse();
      }

      return SuccessApiResponse(
        data: Product.fromJson(response.body),
      );
    } on Exception catch (e) {
      return ErrorApiResponse(errorMessage: e.toString());
    }
  }
}
