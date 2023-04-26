import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIcon extends StatelessWidget {
  final double? size;

  late final String _name;

  CustomIcon.shoppingCart({super.key, this.size}) {
    _name = 'shopping_cart';
  }

  CustomIcon.categoriesMenu({super.key, this.size}) {
    _name = 'categories_menu';
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$_name.svg',
      height: size,
      width: size,
    );
  }
}
