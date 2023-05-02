import 'package:flutter_app_test_stacked/utils/iterable_utils.dart';
import 'package:flutter_app_test_stacked/models/cart_entry.dart';
import 'package:flutter_app_test_stacked/models/database_model.dart';
import 'package:flutter_app_test_stacked/services/cart_service.dart';
import 'package:flutter_app_test_stacked/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/data.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('CartService Tests -', () {
    setUp(() {
      setUpServices(
        mockDatabaseService: true,
        onDatabaseServiceRegistered: (databaseService) {
          when(databaseService.get(tableName: CartEntry.tableName)).thenAnswer(
            (_) async => MockData.cartEntries.mapList((p0) => p0.toMap()),
          );
        },
      );
    });

    tearDown(tearDownServices);

    group('Get entries -', () {
      test('should get entries', () async {
        final CartService cartService = getService();

        final result = await cartService.getEntries();

        expect(result.success, true);
        expect(result.data, isNotNull);
        expect(result.data!, MockData.cartEntries);
        expect(cartService.count, MockData.cartCount);
        expect(cartService.entries, MockData.cartEntries);
      });
    });

    group('Add product -', () {
      test('should add new entry', () async {
        final DatabaseService databaseService = getService();
        final CartService cartService = getService();

        final productId = MockData.product4.id;
        const cartId = 4;

        when(databaseService.insert(
          tableName: CartEntry.tableName,
          model: CartEntry(productId: productId),
        )).thenAnswer((_) async => cartId);

        final result = await cartService.addProduct(productId);

        final newCartEntry = CartEntry(
          productId: productId,
          id: cartId,
          count: 1,
        );

        expect(result.success, true);
        expect(result.data, isNotNull);
        expect(result.data!, newCartEntry);

        expect(cartService.count, MockData.cartCount + 1);
        expect(cartService.entries, [...MockData.cartEntries, newCartEntry]);
      });

      test('should increase entry count', () async {
        final DatabaseService databaseService = getService();
        final CartService cartService = getService();

        final cartEntry = MockData.cartEntry1;

        when(databaseService.get(
          tableName: CartEntry.tableName,
          whereClauses: [
            WhereEqualClause(
                column: CartEntry.columnProductId, value: cartEntry.productId),
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

        final result = await cartService.addProduct(cartEntry.productId);

        expect(result.success, true);
        expect(result.data, isNotNull);
        expect(result.data!, editedEntry);

        expect(cartService.count, MockData.cartCount + 1);
        expect(
          cartService.entries,
          MockData.cartEntries
              .mapList((p0) => p0.id == editedEntry.id ? editedEntry : p0),
        );
      });
    });

    group('Remove product -', () {
      test('should remove entry', () async {
        final DatabaseService databaseService = getService();
        final CartService cartService = getService();

        final cartEntry = MockData.cartEntry1;

        when(databaseService.get(
          tableName: CartEntry.tableName,
          whereClauses: [
            WhereEqualClause(
                column: CartEntry.columnProductId, value: cartEntry.productId),
          ],
        )).thenAnswer(
          (_) async => [cartEntry.toMap()],
        );

        when(databaseService.delete(
          tableName: CartEntry.tableName,
          whereClauses: [
            WhereEqualClause(
                column: DatabaseModel.columnId, value: cartEntry.id),
          ],
        )).thenAnswer((_) async => 1);

        final response = await cartService.removeProduct(cartEntry.productId);

        expect(response.success, true);
        expect(response.data, isNull);

        expect(cartService.count, MockData.cartCount - 1);
        expect(
          cartService.entries,
          MockData.cartEntries.whereList((p0) => p0.id != cartEntry.id),
        );
      });

      test('should decrease entry count', () async {
        final DatabaseService databaseService = getService();
        final CartService cartService = getService();

        final cartEntry = MockData.cartEntry2;

        when(databaseService.get(
          tableName: CartEntry.tableName,
          whereClauses: [
            WhereEqualClause(
                column: CartEntry.columnProductId, value: cartEntry.productId),
          ],
        )).thenAnswer(
          (_) async => [cartEntry.toMap()],
        );

        final editedEntry = cartEntry.copyWithCount(cartEntry.count - 1);

        when(databaseService.update(
          tableName: CartEntry.tableName,
          model: editedEntry,
          whereClauses: [
            WhereEqualClause(
                column: DatabaseModel.columnId, value: cartEntry.id),
          ],
        )).thenAnswer((_) async => 1);

        final result = await cartService.removeProduct(cartEntry.productId);

        expect(result.success, true);
        expect(result.data, isNotNull);
        expect(result.data!, editedEntry);

        expect(cartService.count, MockData.cartCount - 1);
        expect(
          cartService.entries,
          MockData.cartEntries
              .mapList((p0) => p0.id == editedEntry.id ? editedEntry : p0),
        );
      });
    });

    group('Empty -', () {
      test('should empty entries', () async {
        final CartService cartService = getService();
        final DatabaseService databaseService = getService();

        when(databaseService.delete(tableName: CartEntry.tableName)).thenAnswer(
          (_) async => MockData.cartEntries.length,
        );

        final result = await cartService.empty();

        expect(result.success, true);
        expect(result.data, isNull);
        expect(cartService.count, 0);
        expect(cartService.entries.isEmpty, true);
      });
    });
  });
}
