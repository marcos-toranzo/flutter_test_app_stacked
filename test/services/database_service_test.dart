import 'package:flutter_app_test_stacked/models/database_model.dart';
import 'package:flutter_app_test_stacked/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/data.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  final db = MockDatabase();
  database = db;

  group('DatabaseServiceTest -', () {
    setUp(() => TestHelper.initApp());

    tearDown(() => locator.reset());

    group('WhereClause -', () {
      test('should parse WhereEqualClause correctly', () {
        const whereEqualClause = WhereEqualClause(
          column: 'a',
          value: 'b',
        );

        final result = parseWhereClauses([whereEqualClause]);

        expect(result.where, 'a = ?');
        expect(result.whereArgs, ['b']);
      });

      test('should parse WhereInClause correctly', () {
        const whereEqualClause = WhereInClause(
          column: 'a',
          value: ['b', 'c'],
        );

        final result = parseWhereClauses([whereEqualClause]);

        expect(result.where, 'a IN (?, ?)');
        expect(result.whereArgs, ['b', 'c']);
      });

      test('should parse WhereClauses correctly', () {
        const whereClauses = <WhereClause>[
          WhereEqualClause(column: 'a', value: 'b'),
          WhereInClause(column: 'h', value: ['i', 'j', 'k']),
          WhereEqualClause(column: 'c', value: 'd'),
          WhereInClause(column: 'e', value: ['f', 'g']),
        ];

        final result = parseWhereClauses(whereClauses);

        expect(
            result.where, 'a = ? AND h IN (?, ?, ?) AND c = ? AND e IN (?, ?)');
        expect(result.whereArgs, ['b', 'i', 'j', 'k', 'd', 'f', 'g']);
      });
    });

    group('Insert -', () {
      test('should insert', () async {
        final databaseService = locator<DatabaseService>();

        final model = MockDatabaseModel(a: 'a', b: 2);

        when(db.insert(
          'table',
          model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        )).thenAnswer((_) async => 1);

        final result = await databaseService.insert(
          tableName: 'table',
          model: model,
        );

        expect(result, 1);
      });
    });

    group('Update -', () {
      test('should update', () async {
        final databaseService = locator<DatabaseService>();

        final model = MockDatabaseModel(id: 1, a: 'a', b: 2);

        when(db.update(
          'table',
          model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        )).thenAnswer((_) async => 1);

        final result = await databaseService.update(
          tableName: 'table',
          model: model,
        );

        expect(result, 1);
      });

      test('should update with where clauses', () async {
        final databaseService = locator<DatabaseService>();

        final model = MockDatabaseModel(id: 1, a: 'a', b: 2);
        const whereClause = WhereEqualClause(
          column: 'column',
          value: 'value',
        );

        final whereClausesParsed = parseWhereClauses([whereClause]);

        when(db.update(
          'table',
          model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
          where: whereClausesParsed.where,
          whereArgs: whereClausesParsed.whereArgs,
        )).thenAnswer((_) async => 1);

        final result = await databaseService.update(
          tableName: 'table',
          model: model,
          whereClauses: [whereClause],
        );

        expect(result, 1);
      });
    });

    group('Delete -', () {
      test('should delete', () async {
        final databaseService = locator<DatabaseService>();

        when(db.delete('table')).thenAnswer((_) async => 1);

        final result = await databaseService.delete(tableName: 'table');

        expect(result, 1);
      });

      test('should delete with where clauses', () async {
        final databaseService = locator<DatabaseService>();

        const whereClause = WhereEqualClause(
          column: 'column',
          value: 'value',
        );

        final whereClausesParsed = parseWhereClauses([whereClause]);

        when(db.delete(
          'table',
          where: whereClausesParsed.where,
          whereArgs: whereClausesParsed.whereArgs,
        )).thenAnswer((_) async => 1);

        final result = await databaseService.delete(
          tableName: 'table',
          whereClauses: [whereClause],
        );

        expect(result, 1);
      });
    });

    group('Get -', () {
      test('should get', () async {
        final databaseService = locator<DatabaseService>();

        when(db.query('table'))
            .thenAnswer((_) async => [MockData.cartEntry1.toMap()]);

        final result = await databaseService.get(tableName: 'table');

        expect(result, [MockData.cartEntry1.toMap()]);
      });

      test('should get with columns', () async {
        final databaseService = locator<DatabaseService>();

        const columns = ['a', 'b'];

        when(db.query(
          'table',
          columns: columns,
        )).thenAnswer((_) async => [MockData.cartEntry1.toMap()]);

        final result = await databaseService.get(
          tableName: 'table',
          columns: columns,
        );

        expect(result, [MockData.cartEntry1.toMap()]);
      });

      test('should get with where clauses', () async {
        final databaseService = locator<DatabaseService>();

        const columns = ['a', 'b'];

        const whereClause = WhereEqualClause(
          column: 'column',
          value: 'value',
        );

        final whereClausesParsed = parseWhereClauses([whereClause]);

        when(db.query(
          'table',
          columns: columns,
          where: whereClausesParsed.where,
          whereArgs: whereClausesParsed.whereArgs,
        )).thenAnswer((_) async => [MockData.cartEntry1.toMap()]);

        final result = await databaseService.get(
          tableName: 'table',
          columns: columns,
          whereClauses: [whereClause],
        );

        expect(result, [MockData.cartEntry1.toMap()]);
      });
    });
  });
}

class MockDatabaseModel extends DatabaseModel {
  final String a;
  final int b;

  MockDatabaseModel({
    super.id,
    required this.a,
    required this.b,
  });

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'a': a,
        'b': b,
      };
}
