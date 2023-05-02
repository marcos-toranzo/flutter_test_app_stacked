import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/app/app.router.dart';
import 'package:flutter_app_test_stacked/models/cart_entry.dart';
import 'package:flutter_app_test_stacked/models/database_model.dart';
import 'package:flutter_app_test_stacked/services/database_service.dart';
import 'package:flutter_app_test_stacked/services/network_service.dart';
import 'package:flutter_app_test_stacked/services/product_service.dart';
import 'package:flutter_app_test_stacked/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:flutter_app_test_stacked/ui/views/home/home_app_bar.dart';
import 'package:flutter_app_test_stacked/ui/views/home/home_view.dart';
import 'package:flutter_app_test_stacked/ui/views/home/home_viewmodel.dart';
import 'package:flutter_app_test_stacked/ui/views/home/product_fetching_result.dart';
import 'package:flutter_app_test_stacked/ui/views/home/products_list.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_button.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_icon.dart';
import 'package:flutter_app_test_stacked/ui/widgets/product_item.dart';
import 'package:flutter_app_test_stacked/utils/formatting.dart';
import 'package:flutter_app_test_stacked/utils/iterable_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';

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
      final products = MockData.products.take(10).toList();

      setUpAll(() {
        testWidgetSetUpAll(
          screenBuilder: (_) => HomeView(),
          setUpDialogUi: true,
          mockNetworkImage: true,
        );
      });

      tearDownAll(testWidgetReset);

      setUp(() {
        setUpServices(
          mockNavigationService: true,
          mockProductService: true,
          mockDatabaseService: true,
          onProductServiceRegistered: (productService) {
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
          },
          onDatabaseServiceRegistered: (databaseService) {
            when(databaseService.get(tableName: CartEntry.tableName))
                .thenAnswer(
              (_) async => MockData.cartEntries.mapList((p0) => p0.toMap()),
            );

            final cartEntry = MockData.cartEntry1;

            when(databaseService.get(
              tableName: CartEntry.tableName,
              whereClauses: [
                WhereEqualClause(
                    column: CartEntry.columnProductId,
                    value: cartEntry.productId),
              ],
            )).thenAnswer(
              (_) async => [cartEntry.toMap()],
            );

            final editedEntry = cartEntry.copyWithCount(cartEntry.count + 1);

            when(databaseService.update(
              tableName: CartEntry.tableName,
              model: editedEntry,
              whereClauses: [
                WhereEqualClause(
                    column: DatabaseModel.columnId, value: cartEntry.id),
              ],
            )).thenAnswer((_) async => 1);
          },
        );
      });

      tearDown(tearDownServices);

      testWidgets(
        'should display components',
        testWidget(
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
        ),
      );

      testWidgets(
        'should display error on init viewmodel',
        testWidget(
          setUp: () {
            final ProductService productService = getService();

            when(productService.getCategories()).thenAnswer(
              (_) async => const ErrorApiResponse(),
            );
          },
          (helper) async {
            final InfoAlertDialog infoAlertDialog = helper.widgetByType();

            expect(infoAlertDialog.request.data, false);
            expect(
              infoAlertDialog.request.description,
              'Something went wrong trying to fetch the categories.',
            );
          },
        ),
      );

      testWidgets(
        'should show error on refresh and refresh',
        testWidget(
          setUp: () {
            final ProductService productService = getService();

            when(productService.getCategories()).thenAnswer(
              (_) async => const ErrorApiResponse(),
            );
          },
          (helper) async {
            AppTabBar appTabBar = helper.widgetByType();

            expect(
              appTabBar.tabsLabels,
              [allCategories],
            );

            Text text = helper.text('Got it');

            await helper.tapWidget(text);

            await helper.tapWithValueKey('appTabBarRefreshButton');

            final InfoAlertDialog infoAlertDialog = helper.widgetByType();

            expect(infoAlertDialog.request.data, false);
            expect(
              infoAlertDialog.request.description,
              'Something went wrong trying to fetch the categories.',
            );

            text = helper.text('Got it');

            await helper.tapWidget(text);

            final ProductService productService = getService();

            when(productService.getCategories()).thenAnswer(
              (_) async => SuccessApiResponse(
                data: MockData.categories,
              ),
            );
            final categoryProducts =
                MockData.getCategoryProducts(MockData.category1);
            final category = MockData.category1.capitalize();

            when(productService.getCategoryProducts(
              category,
              limit: productsLimit,
              skip: 0 * productsLimit,
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
                skip: 0 * productsLimit,
                total: categoryProducts.length,
              ),
            );

            await helper.tapWithValueKey('appTabBarRefreshButton');

            appTabBar = helper.widgetByType();

            expect(
              appTabBar.tabsLabels,
              [
                allCategories,
                ...MockData.categories.map((e) => e.capitalize())
              ],
            );
          },
        ),
      );

      testWidgets(
        'should go to cart view',
        (widgetTester) async {
          bool wentToCartView = false;

          await testWidget(
            setUp: () {
              final NavigationService navigationService = getService();

              when(navigationService.navigateToCartView())
                  .thenAnswer((_) async {
                wentToCartView = true;
              });
            },
            (helper) async {
              await helper.tap(ShoppingCartAppBarButton);

              assert(wentToCartView);
            },
          )(widgetTester);
        },
      );

      testWidgets(
        'should go to product view',
        (widgetTester) async {
          bool wentToProductView = false;
          final productId = products[0].id;

          await testWidget(
            setUp: () {
              final NavigationService navigationService = getService();

              when(navigationService.navigateToProductView(
                      productId: productId))
                  .thenAnswer((_) async {
                wentToProductView = true;
              });
            },
            (helper) async {
              await helper.tapWithValueKey('ProductItem#$productId');

              assert(wentToProductView);
            },
          )(widgetTester);
        },
      );

      testWidgets(
        'should add product to cart',
        (widgetTester) async {
          final productId = products[0].id;

          await testWidget(
            (helper) async {
              final ProductItem productItem =
                  helper.widgetByValueKey('ProductItem#$productId');

              final CustomButton addToCartButton =
                  helper.descendant(productItem);

              await helper.tapWidget(addToCartButton);

              final ShoppingCartAppBarButton shoppingCartAppBarButton =
                  helper.widgetByType();

              expect(shoppingCartAppBarButton.count, MockData.cartCount + 1);

              final InfoAlertDialog dialog = helper.widgetByType();

              expect(dialog.request.data, true);
              expect(dialog.request.description, 'Product added to cart.');
            },
          )(widgetTester);
        },
      );

      testWidgets(
        'should show error on adding product to cart',
        (widgetTester) async {
          final productId = products[0].id;

          await testWidget(
            setUp: () {
              final DatabaseService databaseService = getService();

              when(databaseService.update(
                tableName: CartEntry.tableName,
                model: MockData.cartEntry1.copyWithCount(2),
                whereClauses: [
                  WhereEqualClause(
                      column: DatabaseModel.columnId,
                      value: MockData.cartEntry1.id),
                ],
              )).thenAnswer((_) async => 0);
            },
            (helper) async {
              final ProductItem productItem =
                  helper.widgetByValueKey('ProductItem#$productId');

              final CustomButton addToCartButton =
                  helper.descendant(productItem);

              await helper.tapWidget(addToCartButton);

              final InfoAlertDialog dialog = helper.widgetByType();

              expect(dialog.request.data, false);
              expect(
                dialog.request.description,
                'Something went wrong trying to add product to cart.',
              );
            },
          )(widgetTester);
        },
      );

      testWidgets(
        'should switch categories',
        (widgetTester) async {
          final categoryProducts =
              MockData.getCategoryProducts(MockData.category1);
          final category = MockData.category1.capitalize();

          await testWidget(
            setUp: () {
              final ProductService productService = getService();

              when(productService.getCategoryProducts(
                category,
                limit: productsLimit,
                skip: 0 * productsLimit,
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
                  skip: 0 * productsLimit,
                  total: categoryProducts.length,
                ),
              );
            },
            (helper) async {
              final AppTabBar appTabBar = helper.widgetByType();

              final Text categoryText = helper.descendantText(
                of: appTabBar,
                text: category,
                skipOffstage: false,
              );

              await helper.tapWidget(categoryText, ensureVisible: true);

              for (var product in categoryProducts) {
                await helper.ensureVisible('ProductItem#${product.id}');
              }

              helper.text(
                '${categoryProducts.length} products',
                skipOffstage: false,
              );
            },
          )(widgetTester);
        },
      );

      testWidgets(
        'should search',
        (widgetTester) async {
          const product = MockData.product1;

          final category1Products =
              MockData.getCategoryProducts(MockData.category1);

          final category2Products =
              MockData.getCategoryProducts(MockData.category2).whereList(
            (p) => p.title.contains(product.title),
          );

          final category1 = MockData.category1.capitalize();
          final category2 = MockData.category2.capitalize();

          await testWidget(
            setUp: () {
              final ProductService productService = getService();

              when(productService.getProducts(
                limit: productsLimit,
                skip: 0 * productsLimit,
                search: product.title,
                select: [
                  ProductField.id,
                  ProductField.price,
                  ProductField.thumbnail,
                  ProductField.title,
                  ProductField.discountPercentage,
                ],
              )).thenAnswer(
                (_) async => const SuccessApiResponse(
                  data: [product],
                  limit: productsLimit,
                  skip: 0 * productsLimit,
                  total: 1,
                ),
              );

              when(productService.getCategoryProducts(
                category1,
                limit: productsLimit,
                skip: 0 * productsLimit,
                select: [
                  ProductField.id,
                  ProductField.price,
                  ProductField.thumbnail,
                  ProductField.title,
                  ProductField.discountPercentage,
                ],
              )).thenAnswer(
                (_) async => SuccessApiResponse(
                  data: category1Products,
                  limit: productsLimit,
                  skip: 0 * productsLimit,
                  total: category1Products.length,
                ),
              );

              when(productService.getCategoryProducts(
                category2,
                limit: productsLimit,
                skip: 0 * productsLimit,
                select: [
                  ProductField.id,
                  ProductField.price,
                  ProductField.thumbnail,
                  ProductField.title,
                  ProductField.discountPercentage,
                ],
              )).thenAnswer(
                (_) async => SuccessApiResponse(
                  data: category2Products,
                  limit: productsLimit,
                  skip: 0 * productsLimit,
                  total: category2Products.length,
                ),
              );
            },
            (helper) async {
              Text category1Text = helper.descendantTextByType(
                ofType: AppTabBar,
                text: category1,
                skipOffstage: false,
              );

              await helper.tapWidget(category1Text, ensureVisible: true);

              await helper.enterTextByType(
                SearchBar,
                product.title,
              );

              final context = helper.getBuildContext(SearchBar);

              final tabController = DefaultTabController.of(context);

              expect(tabController.index, 0);

              await helper.ensureVisible('ProductItem#${product.id}');

              helper.text('1 product', skipOffstage: false);

              category1Text = helper.descendantTextByType(
                ofType: AppTabBar,
                text: category1,
                skipOffstage: false,
              );

              await helper.tapWidget(category1Text, ensureVisible: true);

              await helper.ensureVisible('ProductItem#${product.id}');

              helper.text('1 product', skipOffstage: false);

              final Text category2Text = helper.descendantTextByType(
                ofType: AppTabBar,
                text: category2,
                skipOffstage: false,
              );

              await helper.tapWidget(category2Text, ensureVisible: true);

              helper.noWidgetByType(ProductItem);

              helper.text('No products found', skipOffstage: false);

              await helper.enterTextByType(
                SearchBar,
                '',
              );

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
