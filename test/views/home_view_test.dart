import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/ui/views/home/home_app_bar.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_icon.dart';
import 'package:flutter_test/flutter_test.dart';

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
            wait: false,
            settle: false,
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
          wait: false,
          settle: false,
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
  });
}
