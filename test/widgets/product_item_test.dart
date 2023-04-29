import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/utils/formatting.dart';
import 'package:flutter_app_test_stacked/ui/widgets/product_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/data.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('ProductItemTest -', () {
    testWidgets(
      'should display product preview',
      (widgetTester) async {
        int count = 0;

        const product = MockData.product1;

        await testWidget(
          scaffoldBody: (_) => ProductItem(
            product: product,
            onTap: () {
              count = 1;
            },
          ),
          mockNetworkImage: true,
          (helper) async {
            final Image image = helper.widgetByType();

            expect(image.image, isInstanceOf<NetworkImage>());
            expect((image.image as NetworkImage).url, product.thumbnail);

            helper.text(product.price.asCurrency());
            helper.text(
                (product.price * 100 / (100 - product.discountPercentage))
                    .asCurrency());

            await helper.tap(ProductItem);

            expect(count, 1);
          },
        )(widgetTester);
      },
    );

    testWidgets(
      'should display item without discount',
      testWidget(
        scaffoldBody: (_) => const ProductItem(
          product: MockData.product1,
          showDiscount: false,
        ),
        mockNetworkImage: true,
        (helper) async {
          helper.noText(
            (MockData.product1.price *
                    100 /
                    (100 - MockData.product1.discountPercentage))
                .asCurrency(),
          );
        },
      ),
    );

    testWidgets(
      'should display trailing widget',
      testWidget(
        scaffoldBody: (_) => const ProductItem(
          product: MockData.product1,
          trailing: Icon(Icons.abc, key: ValueKey('value')),
        ),
        mockNetworkImage: true,
        (helper) async {
          helper.widgetByValueKey('value');
        },
      ),
    );
  });
}
