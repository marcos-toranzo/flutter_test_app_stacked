import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/models/cart_entry.dart';
import 'package:flutter_app_test_stacked/models/database_model.dart';
import 'package:flutter_app_test_stacked/services/database_service.dart';
import 'package:flutter_app_test_stacked/services/network_service.dart';
import 'package:flutter_app_test_stacked/services/product_service.dart';
import 'package:flutter_app_test_stacked/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:flutter_app_test_stacked/ui/views/cart/add_remove_cart_product.dart';
import 'package:flutter_app_test_stacked/ui/views/cart/cart_view.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_app_bar.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_button.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_fab.dart';
import 'package:flutter_app_test_stacked/ui/widgets/product_item.dart';
import 'package:flutter_app_test_stacked/utils/iterable_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/data.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('CartView Tests -', () {
    setUp(() {
      setUpServices(
        mockNavigationService: true,
        mockDatabaseService: true,
        mockProductService: true,
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
          ).thenAnswer(
            (_) async => SuccessApiResponse(data: MockData.cartProducts),
          );
        },
        onDatabaseServiceRegistered: (databaseService) {
          when(databaseService.get(tableName: CartEntry.tableName)).thenAnswer(
            (_) async => MockData.cartEntries.mapList((e) => e.toMap()),
          );
        },
      );

      testWidgetSetUpAll(
        screenBuilder: (_) => CartView(),
        mockNetworkImage: true,
      );
    });

    tearDown(tearDownServices);

    testWidgets(
      'should display components',
      testWidget(
        (helper) async {
          helper.descendantTextByType(
            ofType: CustomAppBar,
            text: '${MockData.cartCount} products',
          );

          helper.descendantTextByType(
            ofType: CustomFab,
            text: 'Checkout',
          );

          for (var cartEntry in MockData.cartEntries) {
            await helper.ensureVisible('CartProduct#${cartEntry.productId}');

            final ProductItem productItem =
                helper.widgetByValueKey('CartProduct#${cartEntry.productId}');

            final AddRemoveCartProduct addRemoveCartProduct =
                helper.descendant(productItem);

            expect(addRemoveCartProduct.count, cartEntry.count);
          }
        },
      ),
    );

    testWidgets(
      'should empty cart',
      testWidget(
        (helper) async {
          final DatabaseService databaseService = getService();

          when(databaseService.delete(tableName: CartEntry.tableName))
              .thenAnswer((_) async => MockData.cartEntries.length);

          await helper.tapWithValueKey('cartViewEmptyCartButton');

          helper.descendantTextByType(
            ofType: CustomAppBar,
            text: 'No products',
          );

          helper.descendantTextByType(
            ofType: Center,
            text: 'Empty',
          );

          helper.noWidgetByType(CustomFab);
        },
      ),
    );

    testWidgets(
      'should show error on empty cart',
      testWidget(
        setUpDialogUi: true,
        (helper) async {
          final DatabaseService databaseService = getService();

          when(databaseService.delete(tableName: CartEntry.tableName))
              .thenAnswer((_) async => 0);

          await helper.tapWithValueKey('cartViewEmptyCartButton');

          final InfoAlertDialog infoAlertDialog = helper.widgetByType();

          expect(infoAlertDialog.request.data, false);
          expect(infoAlertDialog.request.description,
              'Something went wrong trying to clear cart.');
        },
      ),
    );

    testWidgets(
      'should show error on fetching products',
      testWidget(
        setUp: () {
          final ProductService productService = getService();

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
          ).thenAnswer((_) async => const ErrorApiResponse());
        },
        (helper) async {
          helper.descendantTextByType(
            ofType: Center,
            text: 'Error fetching cart products',
          );

          helper.noWidgetByType(CustomFab);
        },
      ),
    );

    testWidgets(
      'should add product',
      testWidget(
        (helper) async {
          final DatabaseService databaseService = getService();

          final cartEntryToIncrease = MockData.cartEntry1;

          when(databaseService.get(
            tableName: CartEntry.tableName,
            whereClauses: [
              WhereEqualClause(
                column: CartEntry.columnProductId,
                value: cartEntryToIncrease.productId,
              ),
            ],
          )).thenAnswer(
            (_) async => [cartEntryToIncrease.toMap()],
          );

          final editedEntry =
              cartEntryToIncrease.copyWithCount(cartEntryToIncrease.count + 1);

          when(databaseService.update(
            tableName: CartEntry.tableName,
            model: editedEntry,
            whereClauses: [
              WhereEqualClause(
                column: DatabaseModel.columnId,
                value: cartEntryToIncrease.id,
              ),
            ],
          )).thenAnswer((_) async => 1);

          ProductItem productItem = helper
              .widgetByValueKey('CartProduct#${cartEntryToIncrease.productId}');

          AddRemoveCartProduct addRemoveCartProduct =
              helper.descendant(productItem);

          final Row row = helper.descendant(addRemoveCartProduct);

          final CustomButton addButton = row.children[2] as CustomButton;

          await helper.tapWidget(addButton);

          helper.descendantTextByType(
            ofType: CustomAppBar,
            text: '${MockData.cartCount + 1} products',
          );

          productItem = helper
              .widgetByValueKey('CartProduct#${cartEntryToIncrease.productId}');

          addRemoveCartProduct = helper.descendant(productItem);

          expect(addRemoveCartProduct.count, editedEntry.count);
        },
      ),
    );

    testWidgets(
      'should show error adding product',
      testWidget(
        setUpDialogUi: true,
        (helper) async {
          final DatabaseService databaseService = getService();

          final cartEntryToIncrease = MockData.cartEntry1;

          when(databaseService.get(
            tableName: CartEntry.tableName,
            whereClauses: [
              WhereEqualClause(
                column: CartEntry.columnProductId,
                value: cartEntryToIncrease.productId,
              ),
            ],
          )).thenAnswer(
            (_) async => [cartEntryToIncrease.toMap()],
          );

          final editedEntry =
              cartEntryToIncrease.copyWithCount(cartEntryToIncrease.count + 1);

          when(databaseService.update(
            tableName: CartEntry.tableName,
            model: editedEntry,
            whereClauses: [
              WhereEqualClause(
                column: DatabaseModel.columnId,
                value: cartEntryToIncrease.id,
              ),
            ],
          )).thenAnswer((_) async => 0);

          ProductItem productItem = helper
              .widgetByValueKey('CartProduct#${cartEntryToIncrease.productId}');

          AddRemoveCartProduct addRemoveCartProduct =
              helper.descendant(productItem);

          final Row row = helper.descendant(addRemoveCartProduct);

          final CustomButton addButton = row.children[2] as CustomButton;

          await helper.tapWidget(addButton);

          final InfoAlertDialog infoAlertDialog = helper.widgetByType();

          expect(infoAlertDialog.request.data, false);
          expect(infoAlertDialog.request.description,
              'Something went wrong trying to add product.');

          helper.descendantTextByType(
            ofType: CustomAppBar,
            text: '${MockData.cartCount} products',
          );

          productItem = helper
              .widgetByValueKey('CartProduct#${cartEntryToIncrease.productId}');

          addRemoveCartProduct = helper.descendant(productItem);

          expect(addRemoveCartProduct.count, cartEntryToIncrease.count);
        },
      ),
    );

    testWidgets(
      'should remove product',
      testWidget(
        (helper) async {
          final DatabaseService databaseService = getService();

          final cartEntryToDecrease = MockData.cartEntry2;

          when(databaseService.get(
            tableName: CartEntry.tableName,
            whereClauses: [
              WhereEqualClause(
                column: CartEntry.columnProductId,
                value: cartEntryToDecrease.productId,
              ),
            ],
          )).thenAnswer(
            (_) async => [cartEntryToDecrease.toMap()],
          );

          final editedEntry =
              cartEntryToDecrease.copyWithCount(cartEntryToDecrease.count - 1);

          when(databaseService.update(
            tableName: CartEntry.tableName,
            model: editedEntry,
            whereClauses: [
              WhereEqualClause(
                column: DatabaseModel.columnId,
                value: cartEntryToDecrease.id,
              ),
            ],
          )).thenAnswer((_) async => 1);

          ProductItem productItem = helper
              .widgetByValueKey('CartProduct#${cartEntryToDecrease.productId}');

          AddRemoveCartProduct addRemoveCartProduct =
              helper.descendant(productItem);

          final Row row = helper.descendant(addRemoveCartProduct);

          final CustomButton removeButton = row.children[0] as CustomButton;

          await helper.tapWidget(removeButton);

          helper.descendantTextByType(
            ofType: CustomAppBar,
            text: '${MockData.cartCount - 1} products',
          );

          productItem = helper
              .widgetByValueKey('CartProduct#${cartEntryToDecrease.productId}');

          addRemoveCartProduct = helper.descendant(productItem);

          expect(addRemoveCartProduct.count, editedEntry.count);
        },
      ),
    );

    testWidgets(
      'should show error removing product',
      testWidget(
        setUpDialogUi: true,
        (helper) async {
          final DatabaseService databaseService = getService();

          final cartEntryToDecrease = MockData.cartEntry2;

          when(databaseService.get(
            tableName: CartEntry.tableName,
            whereClauses: [
              WhereEqualClause(
                column: CartEntry.columnProductId,
                value: cartEntryToDecrease.productId,
              ),
            ],
          )).thenAnswer(
            (_) async => [cartEntryToDecrease.toMap()],
          );

          final editedEntry =
              cartEntryToDecrease.copyWithCount(cartEntryToDecrease.count - 1);

          when(databaseService.update(
            tableName: CartEntry.tableName,
            model: editedEntry,
            whereClauses: [
              WhereEqualClause(
                column: DatabaseModel.columnId,
                value: cartEntryToDecrease.id,
              ),
            ],
          )).thenAnswer((_) async => 0);

          ProductItem productItem = helper
              .widgetByValueKey('CartProduct#${cartEntryToDecrease.productId}');

          AddRemoveCartProduct addRemoveCartProduct =
              helper.descendant(productItem);

          final Row row = helper.descendant(addRemoveCartProduct);

          final CustomButton addButton = row.children[0] as CustomButton;

          await helper.tapWidget(addButton);

          final InfoAlertDialog infoAlertDialog = helper.widgetByType();

          expect(infoAlertDialog.request.data, false);
          expect(infoAlertDialog.request.description,
              'Something went wrong trying to remove product.');

          helper.descendantTextByType(
            ofType: CustomAppBar,
            text: '${MockData.cartCount} products',
          );

          productItem = helper
              .widgetByValueKey('CartProduct#${cartEntryToDecrease.productId}');

          addRemoveCartProduct = helper.descendant(productItem);

          expect(addRemoveCartProduct.count, cartEntryToDecrease.count);
        },
      ),
    );

    testWidgets(
      'should remove cart entry on product removal',
      testWidget(
        setUpDialogUi: true,
        (helper) async {
          final DatabaseService databaseService = getService();

          final cartEntryToDecrease = MockData.cartEntry1;

          when(databaseService.get(
            tableName: CartEntry.tableName,
            whereClauses: [
              WhereEqualClause(
                column: CartEntry.columnProductId,
                value: cartEntryToDecrease.productId,
              ),
            ],
          )).thenAnswer(
            (_) async => [cartEntryToDecrease.toMap()],
          );

          final editedEntry =
              cartEntryToDecrease.copyWithCount(cartEntryToDecrease.count - 1);

          when(databaseService.delete(
            tableName: CartEntry.tableName,
            whereClauses: [
              WhereEqualClause(
                column: DatabaseModel.columnId,
                value: editedEntry.id,
              ),
            ],
          )).thenAnswer((_) async => 1);

          final ProductItem productItem = helper
              .widgetByValueKey('CartProduct#${cartEntryToDecrease.productId}');

          final AddRemoveCartProduct addRemoveCartProduct =
              helper.descendant(productItem);

          final Row row = helper.descendant(addRemoveCartProduct);

          final CustomButton addButton = row.children[0] as CustomButton;

          await helper.tapWidget(addButton);

          helper.descendantTextByType(
            ofType: CustomAppBar,
            text: '${MockData.cartCount - 1} products',
          );

          helper.noWidgetByValueKey(
              'CartProduct#${cartEntryToDecrease.productId}');
        },
      ),
    );
  });
}
