import 'package:flutter_app_test_stacked/app/utils/iterable_utils.dart';
import 'package:flutter_app_test_stacked/models/cart_entry.dart';
import 'package:flutter_app_test_stacked/models/database_model.dart';
import 'package:flutter_app_test_stacked/services/cart_service.dart';
import 'package:flutter_app_test_stacked/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:mockito/mockito.dart';

import '../helpers/data.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('CartServiceTest -', () {
    setUp(() {
      TestHelper.initApp(
        mockDatabaseService: true,
        onDatabaseServiceRegistered: () {
          final _databaseService = locator<DatabaseService>();

          when(_databaseService.get(tableName: CartEntry.tableName)).thenAnswer(
            (_) async {
              return MockData.cartEntries.mapList((p0) => p0.toMap());
            },
          );
        },
      );
    });

    tearDown(() => locator.reset());

    group('Get entries -', () {
      test('should get entries', () async {
        final _cartService = locator<CartService>();

        final result = await _cartService.getEntries();

        expect(result.success, true);
        expect(result.data, isNotNull);
        expect(result.data!, MockData.cartEntries);
        expect(_cartService.count, MockData.cartCount);
        expect(_cartService.entries, MockData.cartEntries);
      });
    });

    group('Add product -', () {
      test('should add new entry', () async {
        final _databaseService = locator<DatabaseService>();
        final _cartService = locator<CartService>();

        final productId = MockData.product4.id;
        const cartId = 4;

        when(_databaseService.insert(
          tableName: CartEntry.tableName,
          model: CartEntry(productId: productId),
        )).thenAnswer((_) async {
          return cartId;
        });

        final result = await _cartService.addProduct(productId);

        final newCartEntry = CartEntry(
          productId: productId,
          id: cartId,
          count: 1,
        );

        expect(result.success, true);
        expect(result.data, isNotNull);
        expect(result.data!, newCartEntry);

        expect(_cartService.count, MockData.cartCount + 1);
        expect(_cartService.entries, [...MockData.cartEntries, newCartEntry]);
      });

      test('should increase entry count', () async {
        final _databaseService = locator<DatabaseService>();
        final _cartService = locator<CartService>();

        final cartEntry = MockData.cartEntry1;

        when(_databaseService.get(
          tableName: CartEntry.tableName,
          whereClauses: [
            WhereEqualClause(
                column: CartEntry.columnProductId, value: cartEntry.productId),
          ],
        )).thenAnswer(
          (_) async {
            return [cartEntry.toMap()];
          },
        );

        final editedEntry = cartEntry.copyWithCount(cartEntry.count + 1);

        when(_databaseService.update(
          tableName: CartEntry.tableName,
          model: editedEntry,
          whereClauses: [
            WhereEqualClause(
                column: DatabaseModel.columnId, value: cartEntry.id),
          ],
        )).thenAnswer((_) async {
          return 1;
        });

        final result = await _cartService.addProduct(cartEntry.productId);

        expect(result.success, true);
        expect(result.data, isNotNull);
        expect(result.data!, editedEntry);

        expect(_cartService.count, MockData.cartCount + 1);
        expect(
          _cartService.entries,
          MockData.cartEntries
              .mapList((p0) => p0.id == editedEntry.id ? editedEntry : p0),
        );
      });
    });

    group('Remove product -', () {
      test('should remove entry', () async {
        final _databaseService = locator<DatabaseService>();
        final _cartService = locator<CartService>();

        final cartEntry = MockData.cartEntry1;

        when(_databaseService.get(
          tableName: CartEntry.tableName,
          whereClauses: [
            WhereEqualClause(
                column: CartEntry.columnProductId, value: cartEntry.productId),
          ],
        )).thenAnswer(
          (_) async {
            return [cartEntry.toMap()];
          },
        );

        when(_databaseService.delete(
          tableName: CartEntry.tableName,
          whereClauses: [
            WhereEqualClause(
                column: DatabaseModel.columnId, value: cartEntry.id),
          ],
        )).thenAnswer((_) async {
          return 1;
        });

        final response = await _cartService.removeProduct(cartEntry.productId);

        expect(response.success, true);
        expect(response.data, isNull);

        expect(_cartService.count, MockData.cartCount - 1);
        expect(
          _cartService.entries,
          MockData.cartEntries.whereList((p0) => p0.id != cartEntry.id),
        );
      });

      test('should decrease entry count', () async {
        final _databaseService = locator<DatabaseService>();
        final _cartService = locator<CartService>();

        final cartEntry = MockData.cartEntry2;

        when(_databaseService.get(
          tableName: CartEntry.tableName,
          whereClauses: [
            WhereEqualClause(
                column: CartEntry.columnProductId, value: cartEntry.productId),
          ],
        )).thenAnswer(
          (_) async {
            return [cartEntry.toMap()];
          },
        );

        final editedEntry = cartEntry.copyWithCount(cartEntry.count - 1);

        when(_databaseService.update(
          tableName: CartEntry.tableName,
          model: editedEntry,
          whereClauses: [
            WhereEqualClause(
                column: DatabaseModel.columnId, value: cartEntry.id),
          ],
        )).thenAnswer((_) async {
          return 1;
        });

        final result = await _cartService.removeProduct(cartEntry.productId);

        expect(result.success, true);
        expect(result.data, isNotNull);
        expect(result.data!, editedEntry);

        expect(_cartService.count, MockData.cartCount - 1);
        expect(
          _cartService.entries,
          MockData.cartEntries
              .mapList((p0) => p0.id == editedEntry.id ? editedEntry : p0),
        );
      });
    });

    group('Empty -', () {
      test('should empty entries', () async {
        final _cartService = locator<CartService>();
        final _databaseService = locator<DatabaseService>();

        when(_databaseService.delete(tableName: CartEntry.tableName))
            .thenAnswer(
          (_) async {
            return MockData.cartEntries.length;
          },
        );

        final result = await _cartService.empty();

        expect(result.success, true);
        expect(result.data, isNull);
        expect(_cartService.count, 0);
        expect(_cartService.entries.isEmpty, true);
      });
    });
  });
}
