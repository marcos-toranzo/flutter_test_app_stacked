import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/utils/formatting.dart';
import 'package:flutter_app_test_stacked/models/product.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';
import 'package:flutter_app_test_stacked/ui/common/ui_helpers.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDiscount;
  final double horizontalPadding;

  const ProductItem({
    required this.product,
    this.onTap,
    this.trailing,
    this.showDiscount = true,
    this.horizontalPadding = 25,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: SizedBox(
          height: 120,
          child: Row(
            children: [
              Material(
                borderRadius: circularBorderRadius,
                elevation: 4,
                child: SizedBox.square(
                  dimension: 85,
                  child: ClipRRect(
                    borderRadius: circularBorderRadius,
                    child: Image.network(
                      product.thumbnail,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 27),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: kcTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            product.price.asCurrency(),
                            style: const TextStyle(
                              color: kcTextColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          if (showDiscount && product.discountPercentage > 0)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                bottom: 1.0,
                              ),
                              child: Text(
                                (product.price *
                                        100 /
                                        (100 - product.discountPercentage))
                                    .asCurrency(),
                                style: const TextStyle(
                                  color: kcOrange,
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
