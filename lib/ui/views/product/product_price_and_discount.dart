import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/app/utils/formatting.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';

class ProductPriceAndDiscount extends StatelessWidget {
  final double price;
  final double discount;

  const ProductPriceAndDiscount({
    super.key,
    required this.price,
    required this.discount,
  });

  @override
  Widget build(BuildContext context) {
    final integralPrice = price.asCurrency().split('.')[0];
    final decimal = price.asCurrency().split('.')[1];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$integralPrice.',
                style: const TextStyle(
                  color: kcTextColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 34,
                  fontFamily: 'Mulish',
                ),
              ),
              TextSpan(
                text: decimal,
                style: const TextStyle(
                  color: kcTextColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  fontFamily: 'Mulish',
                ),
              ),
            ],
          ),
        ),
        if (discount > 0)
          Row(
            children: [
              const SizedBox(width: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DISC.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    '-${discount.toStringAsFixed(0)}%',
                    style: const TextStyle(color: kcOrange, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PVPR',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    (price * 100 / (100 - discount)).asCurrency(),
                    style: const TextStyle(
                      color: kcTextColor,
                      fontSize: 18,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
