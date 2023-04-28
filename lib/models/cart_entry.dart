import 'package:flutter_app_test_stacked/models/model.dart';

class CartEntry extends DatabaseModel {
  static const String tableName = 'cartEntries';
  static const String columnProductId = 'productId';
  static const String columnCount = 'count';

  late final int productId;
  late final int count;

  CartEntry({
    super.id,
    required this.productId,
    this.count = 1,
  });

  CartEntry.fromMap(Map<String, dynamic> map) : super.fromMap(map) {
    productId = map['productId'];
    count = map['count'];
  }

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'productId': productId,
        'count': count,
      };

  CartEntry copyWithCount(int count) {
    return CartEntry(
      id: id,
      productId: productId,
      count: count,
    );
  }
}
