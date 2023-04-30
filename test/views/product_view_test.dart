import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/app/app.dialogs.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/services/cart_service.dart';
import 'package:flutter_app_test_stacked/services/network_service.dart';
import 'package:flutter_app_test_stacked/services/product_service.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';
import 'package:flutter_app_test_stacked/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_header.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_images_carousel.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_price_and_discount.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_rating.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_stock_status.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_view.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_fab.dart';
import 'package:flutter_app_test_stacked/utils/formatting.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/data.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('ProductView Tests -', () {
    group("ProductRating -", () {
      testWidgets(
        'should display rating',
        testWidget(
          scaffoldBodyBuilder: (_) => const ProductRating(
            rating: 3.5,
          ),
          (helper) async {
            helper.text('3.5');

            final RatingBar ratingBar = helper.widgetByType();

            expect(ratingBar.initialRating, 3.5);
          },
        ),
      );
    });

    group("ProductHeader -", () {
      testWidgets(
        'should display correct information',
        (widgetTester) async {
          const product = MockData.product1;

          await testWidget(
            scaffoldBodyBuilder: (_) => ProductHeader(
              brand: product.brand,
              description: product.description,
              rating: product.rating,
              title: product.title,
            ),
            (helper) async {
              helper.text(product.brand);
              helper.text(product.description);
              helper.text(product.title);

              final ProductRating productRating = helper.widgetByType();
              expect(productRating.rating, product.rating);
            },
          )(widgetTester);
        },
      );
    });

    group("ProductImagesCarousel -", () {
      testWidgets(
        'should display pictures and markers',
        (widgetTester) async {
          final images = MockData.product1.images;

          await testWidget(
            scaffoldBodyBuilder: (_) => ProductImagesCarousel(
              images: images,
            ),
            mockNetworkImage: true,
            (helper) async {
              final CarouselSlider carouselSlider = helper.widgetByType();

              expect(carouselSlider.items!.length, images.length);

              helper.nWidgetsByType<GestureDetector>(images.length);
            },
          )(widgetTester);
        },
      );

      testWidgets(
        'should move on marker tap',
        (widgetTester) async {
          final images = MockData.product1.images;
          final key = GlobalKey<ProductImagesCarouselState>();

          await testWidget(
            scaffoldBodyBuilder: (_) => ProductImagesCarousel(
              key: key,
              images: images,
            ),
            mockNetworkImage: true,
            (helper) async {
              List<GestureDetector> markers =
                  helper.nWidgetsByType(images.length);

              await helper.tapWidget(markers[3]);

              expect(key.currentState!.current, 3);

              markers = helper.nWidgetsByType(images.length);

              await helper.tapWidget(markers[0]);

              expect(key.currentState!.current, 0);
            },
          )(widgetTester);
        },
      );
    });

    group("ProductStockStatus -", () {
      testWidgets(
        'should display In stock',
        testWidget(
          scaffoldBodyBuilder: (_) => const ProductStockStatus(stock: 20),
          (helper) async {
            final text = helper.text('In stock');
            expect(text.style!.color, Colors.green);
          },
        ),
      );

      testWidgets(
        'should display Few in stock',
        testWidget(
          scaffoldBodyBuilder: (_) => const ProductStockStatus(stock: 9),
          (helper) async {
            final text = helper.text('Few in stock');
            expect(text.style!.color, kcOrange);
          },
        ),
      );

      testWidgets(
        'should display Not in stock',
        testWidget(
          scaffoldBodyBuilder: (_) => const ProductStockStatus(stock: 0),
          (helper) async {
            final text = helper.text('Not in stock');
            expect(text.style!.color, Colors.red);
          },
        ),
      );
    });

    group("ProductPriceAndDiscount -", () {
      testWidgets(
        'should display correct information',
        (widgetTester) async {
          const price = 542.43;
          const discount = 12.34;

          await testWidget(
            scaffoldBodyBuilder: (_) => const ProductPriceAndDiscount(
              price: price,
              discount: discount,
            ),
            (helper) async {
              final RichText richText =
                  helper.widgetByValueKey('productPriceAndDiscountPrice');

              final children =
                  (richText.text as TextSpan).children!.cast<TextSpan>();

              expect(children[0].text, '\$542.');
              expect(children[1].text, '43');

              final Column discountPercentageCol = helper
                  .widgetByValueKey('productPriceAndDiscountDiscountPerc');

              helper.descendantText(of: discountPercentageCol, text: 'DISC.');
              helper.descendantText(of: discountPercentageCol, text: '-12%');

              final Column discountCol =
                  helper.widgetByValueKey('productPriceAndDiscountDiscount');

              helper.descendantText(of: discountCol, text: 'MSRP');
              helper.descendantText(
                of: discountCol,
                text: (price * 100 / (100 - discount)).asCurrency(),
              );
            },
          )(widgetTester);
        },
      );
    });

    group('View -', () {
      setUpAll(() {
        testWidgetSetUpAll(
          screenBuilder: (_) => ProductView(productId: MockData.product1.id),
        );
      });

      tearDownAll(testWidgetReset);

      setUp(() {
        setUpServices(
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
            ).thenAnswer(
              (_) async {
                await Future.delayed(const Duration(seconds: 1));

                return const SuccessApiResponse(data: MockData.product1);
              },
            );
          },
        );
      });

      tearDown(tearDownServices);

      testWidgets(
        'should display components',
        testWidget(
          settle: false,
          wait: null,
          mockNetworkImage: true,
          (helper) async {
            await helper.wait(milliseconds: 500);

            helper.noWidgetByType(CustomFab);
            helper.widgetByType<CircularProgressIndicator>();

            await helper.settle();

            const product = MockData.product1;

            final ProductHeader productHeader = helper.widgetByType();

            expect(productHeader.brand, product.brand);
            expect(productHeader.description, product.description);
            expect(productHeader.rating, product.rating);
            expect(productHeader.title, product.title);

            final ProductImagesCarousel carousel = helper.widgetByType();

            expect(carousel.images, product.images);

            final ProductStockStatus stockStatus = helper.widgetByType(
              skipOffstage: false,
            );

            expect(stockStatus.stock, product.stock);

            final ProductPriceAndDiscount priceAndDiscount =
                helper.widgetByType(
              skipOffstage: false,
            );

            expect(priceAndDiscount.discount, product.discountPercentage);
            expect(priceAndDiscount.price, product.price);

            helper.widgetByType<CustomFab>();
          },
        ),
      );

      testWidgets(
        'should display error',
        testWidget(
          setUp: () {
            final productService = locator<ProductService>();

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
            ).thenAnswer(
              (_) async => const ErrorApiResponse(),
            );
          },
          (helper) async {
            helper.noWidgetByType(CustomFab);
            helper.text('Error fetching product');
          },
        ),
      );

      testWidgets(
        'should refresh',
        testWidget(
          mockNetworkImage: true,
          (helper) async {
            final productService = locator<ProductService>();
            const product = MockData.product2;

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
            ).thenAnswer((_) async => const SuccessApiResponse(data: product));

            await helper.tapWithValueKey('productViewRefreshButton');

            final ProductHeader productHeader = helper.widgetByType();

            expect(productHeader.brand, product.brand);
            expect(productHeader.description, product.description);
            expect(productHeader.rating, product.rating);
            expect(productHeader.title, product.title);

            final ProductImagesCarousel carousel = helper.widgetByType();

            expect(carousel.images, product.images);

            final ProductStockStatus stockStatus = helper.widgetByType(
              skipOffstage: false,
            );

            expect(stockStatus.stock, product.stock);

            final ProductPriceAndDiscount priceAndDiscount =
                helper.widgetByType(
              skipOffstage: false,
            );

            expect(priceAndDiscount.discount, product.discountPercentage);
            expect(priceAndDiscount.price, product.price);

            helper.widgetByType<CustomFab>();
          },
        ),
      );

      group('Add to cart -', () {
        testWidgets(
          'should show success dialog',
          testWidget(
            setUp: () {
              setupDialogUi();
            },
            mockNetworkImage: true,
            (helper) async {
              final cartService = locator<CartService>();

              when(
                cartService.addProduct(MockData.product1.id),
              ).thenAnswer((_) async => const SuccessApiResponse());

              await helper.tap(CustomFab);

              await helper.settle();

              final InfoAlertDialog infoAlertDialog = helper.widgetByType();

              expect(infoAlertDialog.request.title, 'Hooray!');
              expect(infoAlertDialog.request.description,
                  'Product added to cart.');
              expect(infoAlertDialog.request.data, true);
            },
          ),
        );

        testWidgets(
          'should show error dialog',
          testWidget(
            setUp: () {
              setupDialogUi();
            },
            mockNetworkImage: true,
            (helper) async {
              final cartService = locator<CartService>();

              when(
                cartService.addProduct(MockData.product1.id),
              ).thenAnswer((_) async => const ErrorApiResponse());

              await helper.tap(CustomFab);

              await helper.settle();

              final InfoAlertDialog infoAlertDialog = helper.widgetByType();

              expect(infoAlertDialog.request.title, 'Oops!');
              expect(infoAlertDialog.request.description,
                  'Something went wrong trying to add product to cart.');
              expect(infoAlertDialog.request.data, false);
            },
          ),
        );
      });
    });
  });
}
