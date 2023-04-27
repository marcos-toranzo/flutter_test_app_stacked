import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductRating extends StatelessWidget {
  final double rating;

  const ProductRating({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          maxRating: 5,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemBuilder: (_, __) => const Icon(
            Icons.star,
            color: kcOrange,
          ),
          itemSize: 16,
          onRatingUpdate: (_) {},
          ignoreGestures: true,
        ),
        const SizedBox(width: 5),
        Text(rating.toString()),
      ],
    );
  }
}
