import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_app_test_stacked/app/utils/types.dart';
import 'package:flutter_app_test_stacked/models/cart_entry.dart';
import 'package:flutter_app_test_stacked/models/database_model.dart';

const String _databaseName = 'database.db';

class DatabaseService {
  Database? _database;

  Future<Id> insert({
    required String tableName,
    required DatabaseModel model,
  }) async {
    if (_database == null) {
      throw Exception('Database has not been opened.'
          '`DatabaseService.open()` was not called');
    }

    return await _database!.insert(
      tableName,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update({
    required String tableName,
    required DatabaseModel model,
    List<WhereClause>? whereClauses,
  }) async {
    if (_database == null) {
      throw Exception('Database has not been opened.'
          '`DatabaseService.open()` was not called');
    }

    final whereClausesParsed = _parseWhereClauses(whereClauses);

    if (whereClauses != null) {
      for (var whereClause in whereClauses) {
        if (whereClause is WhereInClause) {}
      }
    }

    return await _database!.update(
      tableName,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
      where: whereClausesParsed.where,
      whereArgs: whereClausesParsed.whereArgs,
    );
  }

  Future<int> delete({
    required String tableName,
    List<WhereClause>? whereClauses,
  }) async {
    if (_database == null) {
      throw Exception('Database has not been opened.'
          '`DatabaseService.open()` was not called');
    }

    final whereClausesParsed = _parseWhereClauses(whereClauses);

    return await _database!.delete(
      tableName,
      where: whereClausesParsed.where,
      whereArgs: whereClausesParsed.whereArgs,
    );
  }

  Future<List<Map<String, dynamic>>> get({
    required String tableName,
    List<String>? columns,
    List<WhereClause>? whereClauses,
  }) async {
    if (_database == null) {
      throw Exception('Database has not been opened.'
          '`DatabaseService.open()` was not called');
    }

    final whereClausesParsed = _parseWhereClauses(whereClauses);

    final result = await _database!.query(
      tableName,
      columns: columns,
      where: whereClausesParsed.where,
      whereArgs: whereClausesParsed.whereArgs,
    );

    return result;
  }

  Future<void> open() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
      onCreate: (db, version) async {
        await db.execute('''
            CREATE TABLE ${CartEntry.tableName}(
              ${DatabaseModel.columnId} integer PRIMARY KEY AUTOINCREMENT,
              ${CartEntry.columnProductId} integer NOT NULL UNIQUE,
              ${CartEntry.columnCount} integer NOT NULL
              )
            ''');
      },
      version: 1,
    );
  }
}

abstract class WhereClause<T> {
  final String column;
  final T value;

  const WhereClause({required this.column, required this.value});

  @override
  bool operator ==(covariant WhereClause<T> other) {
    if (identical(this, other)) return true;

    return other.column == column && other.value == value;
  }

  @override
  int get hashCode => column.hashCode ^ value.hashCode;
}

class WhereEqualClause extends WhereClause<Object> {
  const WhereEqualClause({required super.column, required super.value});
}

class WhereInClause extends WhereClause<List<Object>> {
  const WhereInClause({required super.column, required super.value});
}

class _WhereClauseParsingResult {
  final String? where;
  final List<Object?>? whereArgs;

  const _WhereClauseParsingResult({
    this.where,
    this.whereArgs,
  });
}

_WhereClauseParsingResult _parseWhereClauses(List<WhereClause>? whereClauses) {
  if (whereClauses == null) {
    return const _WhereClauseParsingResult();
  }

  final List<Object?> whereArgs = [];

  final List<String> wheres = [];

  for (var whereClause in whereClauses) {
    switch (whereClause.runtimeType) {
      case WhereEqualClause:
        wheres.add('${whereClause.column} = ?');
        break;
      case WhereInClause:
        final whereInClause = whereClause as WhereInClause;

        wheres.add(
          '${whereClause.column} IN'
          '(${List.filled(whereInClause.value.length, '?').join(', ')})',
        );
        break;
    }

    whereArgs.add(whereClause.value);
  }

  return _WhereClauseParsingResult(
    where: wheres.join(' AND '),
    whereArgs: whereArgs,
  );
}
