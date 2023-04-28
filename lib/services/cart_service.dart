import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/app/utils/iterable_utils.dart';
import 'package:flutter_app_test_stacked/app/utils/types.dart';
import 'package:flutter_app_test_stacked/models/cart_entry.dart';
import 'package:flutter_app_test_stacked/models/database_model.dart';
import 'package:flutter_app_test_stacked/services/database_service.dart';
import 'package:flutter_app_test_stacked/services/network_service.dart';
import 'package:stacked/stacked.dart';

class CartService with ListenableServiceMixin {
  final _databaseService = locator<DatabaseService>();

  CartService() {
    listenToReactiveValues([_entries]);
    getEntries();
  }

  int get count =>
      entries.reduceAndCompute((acc, element) => acc + element.count, 0);

  List<CartEntry> _entries = [];
  List<CartEntry> get entries => [..._entries];

  void _update(List<CartEntry> cartEntries) async {
    _entries = cartEntries;
    notifyListeners();
  }

  void _updateEntry(CartEntry entry) async {
    _update(_entries.mapList((e) => e.id == entry.id ? entry : e));
  }

  void _updateNewEntry(CartEntry entry) async {
    _update([..._entries, entry]);
  }

  void _updateDeleteEntry(CartEntry entry) async {
    _update(_entries.whereList((e) => e.id != entry.id));
  }

  Future<ApiResponse<List<CartEntry>>> getEntries() async {
    try {
      final result = await _databaseService.get(tableName: CartEntry.tableName);

      final cartEntries = result.mapList(CartEntry.fromMap);

      _update(cartEntries);

      return SuccessApiResponse(data: cartEntries);
    } on Exception catch (e) {
      return ErrorApiResponse(errorMessage: e.toString());
    }
  }

  Future<ApiResponse<CartEntry>> addProduct(Id productId) async {
    final entryQuery = await _databaseService.get(
      tableName: CartEntry.tableName,
      whereClauses: [
        WhereEqualClause(column: CartEntry.columnProductId, value: productId),
      ],
    );

    final entry =
        entryQuery.isEmpty ? null : CartEntry.fromMap(entryQuery.first);

    if (entry != null) {
      final editedEntry = entry.copyWithCount(entry.count + 1);

      final updateCount = await _databaseService.update(
        tableName: CartEntry.tableName,
        model: editedEntry,
        whereClauses: [
          WhereEqualClause(column: DatabaseModel.columnId, value: entry.id),
        ],
      );

      if (updateCount != 1) {
        return const ErrorApiResponse();
      }

      _updateEntry(editedEntry);

      return SuccessApiResponse(
        data: editedEntry,
      );
    }

    final id = await _databaseService.insert(
      tableName: CartEntry.tableName,
      model: CartEntry(
        productId: productId,
      ),
    );

    if (id == 0) {
      return const ErrorApiResponse();
    }

    final newEntry = CartEntry(
      id: id,
      productId: productId,
    );

    _updateNewEntry(newEntry);

    return SuccessApiResponse(
      data: newEntry,
    );
  }

  Future<ApiResponse<CartEntry>> removeProduct(Id productId) async {
    final entryQuery = await _databaseService.get(
      tableName: CartEntry.tableName,
      whereClauses: [
        WhereEqualClause(column: CartEntry.columnProductId, value: productId),
      ],
    );

    if (entryQuery.length != 1) {
      return const ErrorApiResponse();
    }

    final entry = CartEntry.fromMap(entryQuery.first);

    if (entry.count == 1) {
      final deleteCount = await _databaseService.delete(
        tableName: CartEntry.tableName,
        whereClauses: [
          WhereEqualClause(column: DatabaseModel.columnId, value: entry.id),
        ],
      );

      if (deleteCount != 1) {
        return const ErrorApiResponse();
      }

      _updateDeleteEntry(entry);

      return const SuccessApiResponse();
    }

    final editedEntry = entry.copyWithCount(entry.count - 1);

    final updateCount = await _databaseService.update(
      tableName: CartEntry.tableName,
      model: editedEntry,
      whereClauses: [
        WhereEqualClause(column: DatabaseModel.columnId, value: entry.id),
      ],
    );

    if (updateCount != 1) {
      return const ErrorApiResponse();
    }

    _updateEntry(editedEntry);

    return SuccessApiResponse(data: editedEntry);
  }

  Future<ApiResponse<Never>> empty() async {
    final deleteCount = await _databaseService.delete(
      tableName: CartEntry.tableName,
    );

    if (deleteCount != entries.length) {
      return const ErrorApiResponse();
    }

    _update([]);

    return const SuccessApiResponse();
  }
}
