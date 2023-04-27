import 'dart:convert';

import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/models/product.dart';
import 'package:flutter_app_test_stacked/services/network_service.dart';

class CartService {
  final _networkService = locator<NetworkService>();

  Future<ApiResponse<List<Product>>> getProducts() async {
    try {
      final response = await _networkService.get(
        'products',
        params: {'limit': '6'},
      );

      if (response.statusCode == StatusCode.ok) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final productsData =
            (data['products'] as List).cast<Map<String, dynamic>>();

        final products = productsData.map(Product.fromMap).toList();

        return ApiResponse(
          success: true,
          data: products,
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

  Future<ApiResponse> addProduct(int productId) async {
    return const ApiResponse(success: true);
  }

  Future<ApiResponse> removeProduct(int productId) async {
    return const ApiResponse(success: true);
  }
}
