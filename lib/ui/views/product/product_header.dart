import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_rating.dart';

class ProductHeader extends StatelessWidget {
  final String title;
  final String description;
  final double rating;
  final String brand;

  const ProductHeader({
    super.key,
    required this.title,
    required this.description,
    required this.rating,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: kcTextColor,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                brand,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kcTextColor,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ProductRating(rating: rating),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          description,
          style: const TextStyle(
            color: kcTextColor,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
