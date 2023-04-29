import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/utils/iterable_utils.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';
import 'package:flutter_app_test_stacked/ui/common/ui_helpers.dart';

class ProductImagesCarousel extends StatefulWidget {
  final List<String> images;

  const ProductImagesCarousel({
    super.key,
    required this.images,
  });

  @override
  State<ProductImagesCarousel> createState() => ProductImagesCarouselState();
}

@visibleForTesting
class ProductImagesCarouselState extends State<ProductImagesCarousel> {
  int current = 0;
  final _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider(
          items: widget.images.mapList(
            (image) => Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Material(
                elevation: 2,
                borderRadius: circularBorderRadius,
                child: ClipRRect(
                  borderRadius: circularBorderRadius,
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          carouselController: _controller,
          options: CarouselOptions(
            autoPlay: true,
            enableInfiniteScroll: widget.images.length > 1,
            enlargeCenterPage: true,
            aspectRatio: 2.0,
            onPageChanged: (index, _) {
              setState(() {
                current = index;
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.images.asMap().entries.mapList((entry) {
            final selected = current == entry.key;

            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: selected ? 12.0 : 8.0,
                height: selected ? 12.0 : 8.0,
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? kcTeal.withOpacity(0.9)
                      : kcTextColor.withOpacity(0.3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
