import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/services/cart_service.dart';
import 'package:flutter_app_test_stacked/services/network_service.dart';
import 'package:flutter_app_test_stacked/services/product_service.dart';
import 'package:flutter_app_test_stacked/ui/views/home/home_app_bar.dart';
import 'package:flutter_app_test_stacked/ui/views/home/home_view.dart';
import 'package:flutter_app_test_stacked/ui/views/home/home_viewmodel.dart';
import 'package:flutter_app_test_stacked/ui/views/home/product_fetching_result.dart';
import 'package:flutter_app_test_stacked/ui/views/home/products_list.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_icon.dart';
import 'package:flutter_app_test_stacked/ui/widgets/product_item.dart';
import 'package:flutter_app_test_stacked/utils/formatting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/data.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('HomeView Tests -', () {
    group('HomeAppBar -', () {
      group('AppTabBar -', () {
        testWidgets(
          'should display basic structure',
          testWidget(
            screenBuilder: (_) => DefaultTabController(
              length: 7,
              child: Scaffold(
                appBar: AppBar(
                  bottom: AppTabBar(
                    tabsLabels: const [
                      'Tab1',
                      'Tab2',
                      'Tab3',
                      'Tab4',
                      'Tab5',
                      'Tab6',
                      'Tab7',
                    ],
                    onCategoriesRefresh: () {},
                  ),
                ),
              ),
            ),
            (helper) async {
              final TabBar tabBar = helper.widgetByType();

              expect(tabBar.tabs.length, 7);

              for (var i = 0; i < 7; i++) {
                expect((tabBar.tabs[i] as Text).data, 'Tab${i + 1}');
              }

              helper.widgetByType<CustomIcon>();
              helper.noWidgetByType(LinearProgressIndicator);
            },
          ),
        );

        testWidgets(
          'should display loading status',
          testWidget(
            screenBuilder: (_) => DefaultTabController(
              length: 1,
              child: Scaffold(
                appBar: AppBar(
                  bottom: AppTabBar(
                    tabsLabels: const ['Tab1'],
                    onCategoriesRefresh: () {},
                    loading: true,
                  ),
                ),
              ),
            ),
            settleAfterPump: false,
            (helper) async {
              final TabBar tabBar = helper.widgetByType();

              expect(tabBar.tabs.length, 1);
              expect((tabBar.tabs[0] as Text).data, 'Tab1');

              helper.widgetByType<LinearProgressIndicator>();

              helper.widgetByType<CustomIcon>();
            },
          ),
        );

        testWidgets(
          'should display refresh button',
          (widgetTester) async {
            bool pressed = false;

            await testWidget(
              screenBuilder: (_) => DefaultTabController(
                length: 1,
                child: Scaffold(
                  appBar: AppBar(
                    bottom: AppTabBar(
                      tabsLabels: const ['Tab1'],
                      onCategoriesRefresh: () {
                        pressed = true;
                      },
                    ),
                  ),
                ),
              ),
              (helper) async {
                final TabBar tabBar = helper.widgetByType();

                expect(tabBar.tabs.length, 1);
                expect((tabBar.tabs[0] as Text).data, 'Tab1');

                helper.noWidgetByType(LinearProgressIndicator);

                helper.widgetByType<CustomIcon>();

                await helper.tapWithValueKey('appTabBarRefreshButton');

                assert(pressed);
              },
            )(widgetTester);
          },
        );
      });

      group('ShoppingCartAppBarButton -', () {
        testWidgets(
          'should not show counter',
          testWidget(
            scaffoldBodyBuilder: (_) => ShoppingCartAppBarButton(
              onPressed: () {},
              count: 0,
            ),
            (helper) async {
              helper.noText('0');
            },
          ),
        );

        testWidgets(
          'should show counter',
          testWidget(
            scaffoldBodyBuilder: (_) => ShoppingCartAppBarButton(
              onPressed: () {},
              count: 2,
            ),
            (helper) async {
              helper.text('2');
            },
          ),
        );

        testWidgets(
          'should call onPressed',
          (widgetTester) async {
            bool pressed = false;

            await testWidget(
              scaffoldBodyBuilder: (_) => ShoppingCartAppBarButton(
                onPressed: () {
                  pressed = true;
                },
                count: 0,
              ),
              (helper) async {
                await helper.tap(ShoppingCartAppBarButton);

                assert(pressed);
              },
            )(widgetTester);
          },
        );
      });

      testWidgets(
        'should show basic structure',
        testWidget(
          screenBuilder: (_) => DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: HomeAppBar(
                tabsLabels: const ['Tab1', 'Tab2', 'Tab3'],
                onCartButtonPressed: () {},
                onCategoriesRefresh: () {},
                cartCount: 3,
              ),
            ),
          ),
          (helper) async {
            final HomeAppBar appBar = helper.widgetByType();

            helper.descendant<SearchBar>(appBar.title!);

            expect(appBar.bottom, isInstanceOf<AppTabBar>());

            final appTabBar = appBar.bottom! as AppTabBar;

            expect(appTabBar.tabsLabels, ['Tab1', 'Tab2', 'Tab3']);
            expect(appTabBar.loading, false);

            helper.widgetByType<ShoppingCartAppBarButton>();

            final ShoppingCartAppBarButton shoppingCartAppBarButton =
                helper.widgetByType();

            expect(shoppingCartAppBarButton.count, 3);
          },
        ),
      );

      testWidgets(
        'should call onCartButtonPressed',
        (widgetTester) async {
          bool pressed = false;

          await testWidget(
            screenBuilder: (_) => DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: HomeAppBar(
                  tabsLabels: const ['Tab1', 'Tab2', 'Tab3'],
                  onCartButtonPressed: () {
                    pressed = true;
                  },
                  onCategoriesRefresh: () {},
                ),
              ),
            ),
            (helper) async {
              await helper.tap(ShoppingCartAppBarButton);

              assert(pressed);
            },
          )(widgetTester);
        },
      );

      testWidgets(
        'should show loading status',
        testWidget(
          screenBuilder: (_) => DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: HomeAppBar(
                tabsLabels: const ['Tab1', 'Tab2', 'Tab3'],
                onCartButtonPressed: () {},
                onCategoriesRefresh: () {},
                tabsLoading: true,
              ),
            ),
          ),
          settleAfterPump: false,
          (helper) async {
            final AppTabBar appTabBar = helper.widgetByType();

            expect(appTabBar.loading, true);
          },
        ),
      );

      testWidgets(
        'should show error fetching categories and call onCategoriesRefresh',
        (widgetTester) async {
          bool pressed = false;

          await testWidget(
            screenBuilder: (_) => DefaultTabController(
              length: 1,
              child: Scaffold(
                appBar: HomeAppBar(
                  tabsLabels: const ['Tab1'],
                  onCartButtonPressed: () {},
                  onCategoriesRefresh: () {
                    pressed = true;
                  },
                ),
              ),
            ),
            (helper) async {
              await helper.tapWithValueKey('appTabBarRefreshButton');

              assert(pressed);
            },
          )(widgetTester);
        },
      );

      testWidgets(
        'should call onSearchTextChanged',
        (widgetTester) async {
          String searchText = '';

          await testWidget(
            screenBuilder: (_) => DefaultTabController(
              length: 1,
              child: Scaffold(
                appBar: HomeAppBar(
                  tabsLabels: const ['Tab1'],
                  onCartButtonPressed: () {},
                  onCategoriesRefresh: () {},
                  onSearchTextChanged: (value) {
                    searchText = value;
                  },
                ),
              ),
            ),
            (helper) async {
              final SearchBar searchBar = helper.widgetByType();

              await helper.enterText(searchBar, 'asd');

              expect(searchText, 'asd');
            },
          )(widgetTester);
        },
      );
    });

    group('ProductsList -', () {
      testWidgets(
        'should fetch products and show total',
        (widgetTester) async {
          final products = MockData.products.take(2).toList();

          await testWidget(
            scaffoldBodyBuilder: (_) => ProductsList(
              onFetchPage: (_) async => ProductFetchingResult(
                products: products,
                last: true,
              ),
            ),
            mockNetworkImage: true,
            (helper) async {
              await helper.settle();

              final List<ProductItem> items =
                  helper.nWidgetsByType(products.length);

              expect(items.map((e) => e.product).toList(), products);

              helper.text('${products.length} products', skipOffstage: false);
            },
          )(widgetTester);
        },
      );

      testWidgets(
        'should fetch products by step',
        (widgetTester) async {
          final products = MockData.products.take(10).toList();

          const productsLimit = 5;
          int currentPage = 0;

          await testWidget(
            scaffoldBodyBuilder: (_) => ProductsList(
              onFetchPage: (page) async {
                await Future.delayed(const Duration(seconds: 1));

                currentPage = page;

                return ProductFetchingResult(
                  products: products.sublist(
                    currentPage * productsLimit,
                    (currentPage + 1) * productsLimit,
                  ),
                  last: (currentPage + 1) * productsLimit >= products.length,
                );
              },
            ),
            mockNetworkImage: true,
            settleAfterPump: false,
            (helper) async {
              helper.widgetByType<CircularProgressIndicator>();

              await helper.wait(seconds: 1);

              final List<ProductItem> items =
                  helper.nWidgetsByType(productsLimit, skipOffstage: false);

              expect(
                items.map((e) => e.product).toList(),
                products.sublist(0, productsLimit),
              );

              helper.widgetByValueKey<CircularProgressIndicator>(
                'productsListNewPageProgressIndicator',
                skipOffstage: false,
              );

              await helper.settle();

              for (var product in products) {
                await helper.ensureVisible('ProductItem#${product.id}');
              }

              helper.text('${products.length} products', skipOffstage: false);

              await helper.settle();
            },
          )(widgetTester);
        },
      );

      testWidgets(
        'should call on onProductTap',
        (widgetTester) async {
          final products = MockData.products.take(2).toList();

          final productTappedMap = Map.fromIterables(
            products.map((e) => e.id),
            List.filled(products.length, false),
          );

          await testWidget(
            scaffoldBodyBuilder: (_) => ProductsList(
              onFetchPage: (_) async => ProductFetchingResult(
                products: products,
                last: true,
              ),
              onProductTapBuilder: (productId) {
                productTappedMap[productId] = true;
              },
            ),
            mockNetworkImage: true,
            (helper) async {
              for (var product in products) {
                await helper.tapWithValueKey(
                  'ProductItem#${product.id}',
                  ensureVisible: true,
                );

                expect(productTappedMap[product.id], true);
              }
            },
          )(widgetTester);
        },
      );

      testWidgets(
        'should build trailing',
        (widgetTester) async {
          final products = MockData.products.take(2).toList();

          final productTrailingTappedMap = Map.fromIterables(
            products.map((e) => e.id),
            List.filled(products.length, false),
          );

          await testWidget(
            scaffoldBodyBuilder: (_) => ProductsList(
              onFetchPage: (_) async => ProductFetchingResult(
                products: products,
                last: true,
              ),
              productTrailingBuilder: (productId) => IconButton(
                key: ValueKey('trailing#$productId'),
                onPressed: () {
                  productTrailingTappedMap[productId] = true;
                },
                icon: const Icon(Icons.abc),
              ),
            ),
            mockNetworkImage: true,
            (helper) async {
              for (var product in products) {
                await helper.tapWithValueKey(
                  'trailing#${product.id}',
                  ensureVisible: true,
                );

                expect(productTrailingTappedMap[product.id], true);
              }
            },
          )(widgetTester);
        },
      );
    });

    group('View -', () {
      setUpAll(() {
        testWidgetSetUpAll(
          screenBuilder: (_) => HomeView(),
          setUpDialogUi: true,
        );
      });

      tearDownAll(testWidgetReset);

      setUp(() {
        setUpServices(
          mockCartService: true,
          mockNavigationService: true,
          mockProductService: true,
        );
      });

      tearDown(tearDownServices);

      testWidgets(
        'should display components',
        (widgetTester) async {
          final products = MockData.products.take(10).toList();

          await testWidget(
            mockNetworkImage: true,
            setUp: () {
              final ProductService productService = getService();

              when(productService.getProducts(
                limit: productsLimit,
                skip: 0 * productsLimit,
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
                  data: products,
                  limit: productsLimit,
                  skip: 0 * productsLimit,
                  total: products.length,
                ),
              );

              when(productService.getCategories()).thenAnswer(
                (_) async => SuccessApiResponse(
                  data: MockData.categories,
                ),
              );

              final CartService cartService = getService();

              when(cartService.count).thenReturn(MockData.cartCount);
            },
            (helper) async {
              final ShoppingCartAppBarButton shoppingCartAppBarButton =
                  helper.widgetByType();

              expect(shoppingCartAppBarButton.count, MockData.cartCount);

              final AppTabBar appTabBar = helper.widgetByType();

              expect(appTabBar.loading, false);
              expect(appTabBar.tabsLabels, [
                allCategories,
                ...MockData.categories.map((e) => e.capitalize())
              ]);

              helper.widgetByType<ProductsList>();

              for (var product in products) {
                await helper.ensureVisible('ProductItem#${product.id}');
              }
            },
          )(widgetTester);
        },
      );
    });
  });
}
