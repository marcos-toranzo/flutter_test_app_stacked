import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIcon extends StatelessWidget {
  final double? size;
  final BoxFit? fit;

  late final String _name;

  CustomIcon.shoppingCart({
    super.key,
    this.size,
    this.fit,
  }) {
    _name = 'shopping_cart';
  }

  CustomIcon.categoriesMenu({
    super.key,
    this.size,
    this.fit,
  }) {
    _name = 'categories_menu';
  }

  CustomIcon.back({
    super.key,
    this.size,
    this.fit,
  }) {
    _name = 'back';
  }

  CustomIcon.trash({
    super.key,
    this.size,
    this.fit,
  }) {
    _name = 'trash';
  }

  CustomIcon.receipt({
    super.key,
    this.size,
    this.fit,
  }) {
    _name = 'receipt';
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$_name.svg',
      height: size,
      width: size,
      fit: fit ?? BoxFit.scaleDown,
    );
  }
}
