import 'package:flutter_app_test_stacked/utils/formatting.dart';
import 'package:flutter_app_test_stacked/services/cart_service.dart';
import 'package:flutter_app_test_stacked/services/network_service.dart';
import 'package:flutter_app_test_stacked/services/product_service.dart';
import 'package:flutter_app_test_stacked/ui/views/home/home_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:mockito/mockito.dart';

import '../helpers/data.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('HomeViewmodel Tests -', () {
    setUp(
      () => TestHelper.initApp(
        mockProductService: true,
        mockCartService: true,
        onProductServiceRegistered: (productService) {
          when(productService.getCategories()).thenAnswer((_) async {
            await Future.delayed(const Duration(seconds: 1));
            return SuccessApiResponse(data: MockData.categories);
          });
        },
      ),
    );

    tearDown(() => locator.reset());

    test('should initialize', () async {
      final viewModel = HomeViewModel();

      final wait = viewModel.init();

      expect(viewModel.busy(fetchingCategories), true);

      final result = await wait;

      expect(result, true);
      expect(
        viewModel.categories,
        [allCategories, ...MockData.categories.map((e) => e.capitalize())],
      );
    });

    test('should refresh categories', () async {
      final productService = locator<ProductService>();

      final categories = MockData.categories.take(2).toList();

      when(productService.getCategories()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return SuccessApiResponse(data: categories);
      });

      final viewModel = HomeViewModel();

      await viewModel.init();

      final wait = viewModel.refreshCategories();

      expect(viewModel.busy(fetchingCategories), true);

      final result = await wait;

      expect(result, true);
      expect(
        viewModel.categories,
        [allCategories, ...categories.map((e) => e.capitalize())],
      );
    });

    group('Get category products -', () {
      test('should fetch all products', () async {
        final productService = locator<ProductService>();

        when(productService.getProducts(
          limit: productsLimit,
          skip: 1 * productsLimit,
          search: '',
          select: [
            ProductField.id,
            ProductField.price,
            ProductField.thumbnail,
            ProductField.title,
            ProductField.discountPercentage,
          ],
        )).thenAnswer(
          (_) async => SuccessApiResponse(
            data: MockData.products,
            limit: productsLimit,
            skip: 11,
            total: 10,
          ),
        );

        when(productService.getProducts(
          limit: productsLimit,
          skip: 1 * productsLimit,
          search: 'asd',
          select: [
            ProductField.id,
            ProductField.price,
            ProductField.thumbnail,
            ProductField.title,
            ProductField.discountPercentage,
          ],
        )).thenAnswer(
          (_) async => SuccessApiResponse(
            data: MockData.products,
            limit: productsLimit,
            skip: 11,
            total: 100,
          ),
        );

        final viewModel = HomeViewModel();

        await viewModel.init();

        final resultLast =
            await viewModel.getCategoryProducts(allCategories, 1);

        expect(resultLast.last, true);
        expect(resultLast.products, MockData.products);

        viewModel.onSearchTextChanged('asd');

        final resultNotLast =
            await viewModel.getCategoryProducts(allCategories, 1);

        expect(resultNotLast.last, false);
        expect(resultNotLast.products, MockData.products);
      });

      test('should fetch category products', () async {
        final productService = locator<ProductService>();

        const category = MockData.category1;
        final categoryProducts =
            MockData.getCategoryProducts(MockData.category1);

        when(productService.getCategoryProducts(
          category,
          limit: productsLimit,
          skip: 1 * productsLimit,
          select: [
            ProductField.id,
            ProductField.price,
            ProductField.thumbnail,
            ProductField.title,
            ProductField.discountPercentage,
          ],
        )).thenAnswer(
          (_) async => SuccessApiResponse(
            data: categoryProducts,
            limit: productsLimit,
            skip: 11,
            total: 10,
          ),
        );

        final viewModel = HomeViewModel();

        await viewModel.init();

        final result = await viewModel.getCategoryProducts(category, 1);

        expect(result.products, categoryProducts);

        viewModel.onSearchTextChanged(categoryProducts.first.title);

        final resultWithSearch =
            await viewModel.getCategoryProducts(category, 1);

        expect(resultWithSearch.products, [categoryProducts.first]);
      });
    });

    test('should add product to cart', () async {
      final cartService = locator<CartService>();

      when(cartService.addProduct(MockData.cartEntry1.productId))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return const SuccessApiResponse();
      });

      final viewModel = HomeViewModel();

      await viewModel.init();

      final wait = viewModel.onProductShoppingCartTap(MockData.product1.id);

      expect(viewModel.busy(MockData.product1.id), true);

      final result = await wait;

      expect(result, true);
    });
  });
}
