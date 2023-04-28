import 'package:flutter_app_test_stacked/services/network_service.dart';
import 'package:flutter_app_test_stacked/services/product_service.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:mockito/mockito.dart';

import '../helpers/data.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('ProductViewModel Tests -', () {
    setUp(
      () => TestHelper.initApp(
        mockProductService: true,
        mockCartService: true,
        onProductServiceRegistered: (productService) {
          when(
            productService.getProduct(
              MockData.product1.id,
              select: [
                ProductField.id,
                ProductField.title,
                ProductField.description,
                ProductField.price,
                ProductField.discountPercentage,
                ProductField.rating,
                ProductField.stock,
                ProductField.brand,
                ProductField.category,
                ProductField.images,
              ],
            ),
          ).thenAnswer((_) async {
            await Future.delayed(const Duration(seconds: 1));
            return const SuccessApiResponse(data: MockData.product1);
          });
        },
        onCartServiceRegistered: (cartService) {
          when(cartService.addProduct(MockData.cartEntry1.productId))
              .thenAnswer((_) async {
            await Future.delayed(const Duration(seconds: 1));
            return const SuccessApiResponse();
          });
        },
      ),
    );

    tearDown(() => locator.reset());

    test('should initialize', () async {
      final viewModel = ProductViewModel(MockData.product1.id);

      final wait = viewModel.init();

      expect(viewModel.busy(fetchingProduct), true);

      await Future.delayed(const Duration(seconds: 1));

      await wait;

      expect(viewModel.product, MockData.product1);
    });

    test('should add to cart', () async {
      final viewModel = ProductViewModel(MockData.product1.id);

      await viewModel.init();

      final wait = viewModel.onAddToCartPressed();

      expect(viewModel.busy(addingToCart), true);

      await Future.delayed(const Duration(seconds: 1));

      final result = await wait;

      expect(result, true);
    });
  });
}
