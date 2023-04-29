import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_app_test_stacked/utils/types.dart';
import 'package:flutter_app_test_stacked/models/cart_entry.dart';
import 'package:flutter_app_test_stacked/models/database_model.dart';

const String _databaseName = 'database.db';
Database? database;

class DatabaseService {
  Future<Id> insert({
    required String tableName,
    required DatabaseModel model,
  }) async {
    if (database == null) {
      throw Exception('Database has not been opened.'
          '`DatabaseService.open()` was not called');
    }

    return await database!.insert(
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
    if (database == null) {
      throw Exception('Database has not been opened.'
          '`DatabaseService.open()` was not called');
    }

    final whereClausesParsed = parseWhereClauses(whereClauses);

    if (whereClauses != null) {
      for (var whereClause in whereClauses) {
        if (whereClause is WhereInClause) {}
      }
    }

    return await database!.update(
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
    if (database == null) {
      throw Exception('Database has not been opened.'
          '`DatabaseService.open()` was not called');
    }

    final whereClausesParsed = parseWhereClauses(whereClauses);

    return await database!.delete(
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
    if (database == null) {
      throw Exception('Database has not been opened.'
          '`DatabaseService.open()` was not called');
    }

    final whereClausesParsed = parseWhereClauses(whereClauses);

    final result = await database!.query(
      tableName,
      columns: columns,
      where: whereClausesParsed.where,
      whereArgs: whereClausesParsed.whereArgs,
    );

    return result;
  }

  Future<void> open() async {
    database = await openDatabase(
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

@visibleForTesting
class WhereClauseParsingResult {
  final String? where;
  final List<Object?>? whereArgs;

  const WhereClauseParsingResult({
    this.where,
    this.whereArgs,
  });
}

@visibleForTesting
WhereClauseParsingResult parseWhereClauses(List<WhereClause>? whereClauses) {
  if (whereClauses == null) {
    return const WhereClauseParsingResult();
  }

  final List<Object?> whereArgs = [];

  final List<String> wheres = [];

  for (var whereClause in whereClauses) {
    switch (whereClause.runtimeType) {
      case WhereEqualClause:
        wheres.add('${whereClause.column} = ?');
        whereArgs.add(whereClause.value);
        break;
      case WhereInClause:
        final whereInClause = whereClause as WhereInClause;

        wheres.add(
          '${whereClause.column} IN '
          '(${List.filled(whereInClause.value.length, '?').join(', ')})',
        );
        whereArgs.addAll(whereClause.value);
        break;
    }
  }

  return WhereClauseParsingResult(
    where: wheres.join(' AND '),
    whereArgs: whereArgs,
  );
}
