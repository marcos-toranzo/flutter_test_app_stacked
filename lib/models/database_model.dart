import 'package:flutter_app_test_stacked/utils/types.dart';

abstract class DatabaseModel {
  static const String columnId = 'id';

  late final Id id;

  DatabaseModel({this.id = 0});

  DatabaseModel.fromMap(Map<String, dynamic> map) {
    id = map[columnId] as Id;
  }

  Map<String, dynamic> toMap() {
    return id != 0 ? {columnId: id} : {};
  }
}
