import 'package:flutter_app_test_stacked/app/utils/iterable_utils.dart';
import 'package:flutter_app_test_stacked/services/network_service.dart';
import 'package:flutter_app_test_stacked/services/product_service.dart';
import 'package:flutter_app_test_stacked/ui/views/cart/cart_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:mockito/mockito.dart';

import '../helpers/data.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('CartViewModel Tests -', () {
    setUp(
      () => TestHelper.initApp(
        mockProductService: true,
        mockCartService: true,
        mockNavigationService: true,
        onProductServiceRegistered: (productService) {
          when(
            productService.getProductsWithIds(
              MockData.cartEntries.mapList((entry) => entry.productId),
              select: [
                ProductField.id,
                ProductField.price,
                ProductField.thumbnail,
                ProductField.title,
              ],
            ),
          ).thenAnswer((_) async {
            await Future.delayed(const Duration(seconds: 1));
            return SuccessApiResponse(data: MockData.cartProducts);
          });
        },
        onCartServiceRegistered: (cartService) {
          when(cartService.getEntries()).thenAnswer((_) async {
            await Future.delayed(const Duration(seconds: 1));
            return SuccessApiResponse(data: MockData.cartEntries);
          });

          when(cartService.entries).thenReturn(MockData.cartEntries);

          when(cartService.count).thenReturn(MockData.cartCount);

          when(cartService.empty()).thenAnswer(
            (_) async {
              await Future.delayed(const Duration(seconds: 1));
              return const SuccessApiResponse();
            },
          );

          when(cartService.addProduct(MockData.cartEntry1.productId))
              .thenAnswer((_) async {
            await Future.delayed(const Duration(seconds: 1));
            return const SuccessApiResponse();
          });

          when(cartService.removeProduct(MockData.cartEntry1.productId))
              .thenAnswer((_) async {
            await Future.delayed(const Duration(seconds: 1));
            return const SuccessApiResponse();
          });
        },
      ),
    );

    tearDown(() => locator.reset());

    test('should initialize', () async {
      final viewModel = CartViewModel();

      final wait = viewModel.init();

      expect(viewModel.busy(fetchingProducts), true);

      await Future.delayed(const Duration(seconds: 1));

      expect(viewModel.busy(fetchingProducts), true);

      await wait;

      expect(viewModel.total, MockData.cartTotal);
      expect(viewModel.products, MockData.cartProducts);
    });

    test('should return product count', () async {
      final viewModel = CartViewModel();

      await viewModel.init();

      expect(
        viewModel.getProductCount(MockData.cartEntry1.productId),
        MockData.cartEntry1.count,
      );
    });

    test('should empty cart', () async {
      final viewModel = CartViewModel();

      await viewModel.init();

      final wait = viewModel.onEmptyCart();

      expect(viewModel.busy(emptyingCart), true);

      await Future.delayed(const Duration(seconds: 1));

      final result = await wait;

      expect(result, true);
    });

    test('should add product', () async {
      final viewModel = CartViewModel();

      await viewModel.init();

      final wait = viewModel.onAddProduct(MockData.cartEntry1.productId);

      expect(viewModel.busy(MockData.cartEntry1.productId), true);

      await Future.delayed(const Duration(seconds: 1));

      final result = await wait;

      expect(result, true);
    });

    test('should remove product', () async {
      final viewModel = CartViewModel();

      await viewModel.init();

      final wait = viewModel.onRemoveProduct(MockData.cartEntry1.productId);

      expect(viewModel.busy(MockData.cartEntry1.productId), true);

      await Future.delayed(const Duration(seconds: 1));

      final result = await wait;

      expect(result, true);
    });
  });
}
