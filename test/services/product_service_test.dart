import 'dart:convert';

import 'package:flutter_app_test_stacked/app/utils/iterable_utils.dart';
import 'package:flutter_app_test_stacked/services/network_service.dart';
import 'package:flutter_app_test_stacked/services/product_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:mockito/mockito.dart';

import '../helpers/data.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('ProductServiceTest -', () {
    setUp(() {
      TestHelper.initApp(
        mockNetworkService: true,
        onNetworkServiceRegistered: (networkService) {
          when(networkService.get('products/categories')).thenAnswer(
            (_) async {
              return NetworkResponse(
                statusCode: StatusCode.ok,
                body: json.encode(MockData.categories),
              );
            },
          );
        },
      );
    });

    tearDown(() => locator.reset());

    group('Get categories -', () {
      test('should fetch categories', () async {
        final productService = locator<ProductService>();

        final response = await productService.getCategories();

        expect(response.success, true);
        expect(response.data, isNotNull);
        expect(response.data!, MockData.categories);
      });
    });

    group('Get products -', () {
      test('should fetch products', () async {
        final productService = locator<ProductService>();
        final networkService = locator<NetworkService>();

        when(networkService.get('products/search', params: {
          'limit': '0',
          'skip': '0',
          'q': '',
        })).thenAnswer(
          (_) async {
            return NetworkResponse(
              statusCode: StatusCode.ok,
              body: json.encode(
                {
                  'products': MockData.products.mapList((p0) => p0.toMap()),
                  "total": MockData.products.length,
                  "skip": 0,
                  "limit": MockData.products.length,
                },
              ),
            );
          },
        );

        final response = await productService.getProducts();

        expect(response.success, true);
        expect(response.data, isNotNull);
        expect(response.data!, MockData.products);
        expect(response.total, isNotNull);
        expect(response.total!, MockData.products.length);
        expect(response.skip, isNotNull);
        expect(response.skip!, 0);
        expect(response.limit, isNotNull);
        expect(response.limit!, MockData.products.length);
      });

      test('should fetch products with params', () async {
        final productService = locator<ProductService>();
        final networkService = locator<NetworkService>();

        const limit = 3;
        const skip = 4;
        const q = 'as';
        const select = [
          ProductField.id,
          ProductField.price,
          ProductField.thumbnail,
          ProductField.title,
          ProductField.discountPercentage,
        ];

        when(networkService.get('products/search', params: {
          'limit': limit.toString(),
          'skip': skip.toString(),
          'q': q,
          'select': select.map((e) => e.name).toList(),
        })).thenAnswer(
          (_) async {
            return NetworkResponse(
              statusCode: StatusCode.ok,
              body: json.encode(
                {
                  'products': MockData.products.mapList((p0) => p0.toMap()),
                  "total": MockData.products.length,
                  "skip": skip,
                  "limit": limit,
                },
              ),
            );
          },
        );

        final response = await productService.getProducts(
            limit: limit, skip: skip, search: q, select: select);

        expect(response.success, true);
        expect(response.data, isNotNull);
        expect(response.data!, MockData.products);
        expect(response.total, isNotNull);
        expect(response.total!, MockData.products.length);
        expect(response.skip, isNotNull);
        expect(response.skip!, skip);
        expect(response.limit, isNotNull);
        expect(response.limit!, limit);
      });
    });

    group('Get products with ids -', () {
      test('should fetch products with ids', () async {
        final productService = locator<ProductService>();
        final networkService = locator<NetworkService>();

        when(networkService.get('products/search', params: {
          'limit': '100',
          'skip': '0',
          'q': '',
        })).thenAnswer(
          (_) async {
            return NetworkResponse(
              statusCode: StatusCode.ok,
              body: json.encode(
                {
                  'products': MockData.products.mapList((p0) => p0.toMap()),
                  "total": MockData.products.length,
                  "skip": 0,
                  "limit": 100,
                },
              ),
            );
          },
        );

        final response = await productService.getProductsWithIds([
          MockData.product1.id,
          MockData.product2.id,
        ]);

        expect(response.success, true);
        expect(response.data, isNotNull);
        expect(response.data!, [MockData.product1, MockData.product2]);
      });

      test('should fetch products with ids with params', () async {
        final productService = locator<ProductService>();
        final networkService = locator<NetworkService>();

        const select = [
          ProductField.id,
          ProductField.price,
          ProductField.thumbnail,
          ProductField.title,
          ProductField.discountPercentage,
        ];

        when(networkService.get('products/search', params: {
          'limit': '100',
          'skip': '0',
          'q': '',
          'select': select.map((e) => e.name).toList(),
        })).thenAnswer(
          (_) async {
            return NetworkResponse(
              statusCode: StatusCode.ok,
              body: json.encode(
                {
                  'products': MockData.products.mapList((p0) => p0.toMap()),
                  "total": MockData.products.length,
                  "skip": 0,
                  "limit": 100,
                },
              ),
            );
          },
        );

        final response = await productService.getProductsWithIds(
          [
            MockData.product1.id,
            MockData.product2.id,
          ],
          select: select,
        );

        expect(response.success, true);
        expect(response.data, isNotNull);
        expect(response.data!, [MockData.product1, MockData.product2]);
      });
    });

    group('Get category products -', () {
      test('should fetch category products', () async {
        final productService = locator<ProductService>();
        final networkService = locator<NetworkService>();

        const category = MockData.category1;

        when(networkService.get('products/category/$category', params: {
          'limit': '0',
          'skip': '0',
        })).thenAnswer(
          (_) async {
            return NetworkResponse(
              statusCode: StatusCode.ok,
              body: json.encode(
                {
                  'products': MockData.products.mapList((p0) => p0.toMap()),
                  "total": MockData.products.length,
                  "skip": 0,
                  "limit": MockData.products.length,
                },
              ),
            );
          },
        );

        final response = await productService.getCategoryProducts(category);

        expect(response.success, true);
        expect(response.data, isNotNull);
        expect(response.data!, MockData.products);
      });

      test('should fetch category products with params', () async {
        final productService = locator<ProductService>();
        final networkService = locator<NetworkService>();

        const category = MockData.category1;

        const limit = 3;
        const skip = 4;
        const select = [
          ProductField.id,
          ProductField.price,
          ProductField.thumbnail,
          ProductField.title,
          ProductField.discountPercentage,
        ];

        when(networkService.get('products/category/$category', params: {
          'limit': limit.toString(),
          'skip': skip.toString(),
          'select': select.map((e) => e.name).toList(),
        })).thenAnswer(
          (_) async {
            return NetworkResponse(
              statusCode: StatusCode.ok,
              body: json.encode(
                {
                  'products': MockData.products.mapList((p0) => p0.toMap()),
                  "total": MockData.products.length,
                  "skip": skip,
                  "limit": limit,
                },
              ),
            );
          },
        );

        final response = await productService.getCategoryProducts(
          category,
          limit: limit,
          skip: skip,
          select: select,
        );

        expect(response.success, true);
        expect(response.data, isNotNull);
        expect(response.data!, MockData.products);
      });
    });

    group('Get product -', () {
      test('should fetch product', () async {
        final productService = locator<ProductService>();
        final networkService = locator<NetworkService>();

        const product = MockData.product1;

        when(networkService.get('products/${product.id}', params: {}))
            .thenAnswer(
          (_) async {
            return NetworkResponse(
              statusCode: StatusCode.ok,
              body: product.toJson(),
            );
          },
        );

        final response = await productService.getProduct(product.id);

        expect(response.success, true);
        expect(response.data, isNotNull);
        expect(response.data!, product);
      });

      test('should fetch product with params', () async {
        final productService = locator<ProductService>();
        final networkService = locator<NetworkService>();

        const select = [
          ProductField.id,
          ProductField.price,
          ProductField.thumbnail,
          ProductField.title,
          ProductField.discountPercentage,
        ];
        const product = MockData.product1;

        when(networkService.get('products/${product.id}', params: {
          'select': select.map((e) => e.name).toList(),
        })).thenAnswer(
          (_) async {
            return NetworkResponse(
              statusCode: StatusCode.ok,
              body: product.toJson(),
            );
          },
        );

        final response = await productService.getProduct(
          product.id,
          select: select,
        );

        expect(response.success, true);
        expect(response.data, isNotNull);
        expect(response.data!, product);
      });
    });
  });
}
