import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';

class ProductStockStatus extends StatelessWidget {
  final int stock;

  const ProductStockStatus({
    super.key,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final Color color;

    if (stock == 0) {
      text = 'Not in stock';
      color = Colors.red;
    } else if (stock < 10) {
      text = 'Few in stock';
      color = kcOrange;
    } else {
      text = 'In stock';
      color = Colors.green;
    }

    return Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w500,
        fontSize: 18,
      ),
    );
  }
}
