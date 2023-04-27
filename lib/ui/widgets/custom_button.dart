import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';
import 'package:flutter_app_test_stacked/ui/common/ui_helpers.dart';

class CustomButton extends StatelessWidget {
  final Color backgroundColor;
  final bool circular;
  final Widget icon;
  final VoidCallback? onPressed;
  final double size;

  const CustomButton({
    super.key,
    this.backgroundColor = kcAccentColor,
    this.circular = true,
    this.size = 45,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final boxDecoration = circular
        ? const BoxDecoration(shape: BoxShape.circle)
        : BoxDecoration(borderRadius: circularBorderRadius);

    return Container(
      decoration: boxDecoration.copyWith(color: backgroundColor),
      height: size,
      width: size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius:
              circular ? BorderRadius.circular(100) : circularBorderRadius,
          child: icon,
        ),
      ),
    );
  }
}
