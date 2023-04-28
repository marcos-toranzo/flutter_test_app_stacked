import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/app/utils/iterable_utils.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_button.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_icon.dart';
import 'package:stacked_services/stacked_services.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({
    super.key,
    required String titleText,
    String? subtitleText,
    List<CustomAppBarButton> buttons = const [],
  }) : super(
          backgroundColor: kcAppBarColor,
          shadowColor: kcAccentColor.withAlpha(120),
          elevation: 10,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomAppBarButton(
                  icon: CustomIcon.back(),
                  onPressed: () {
                    locator<NavigationService>().back();
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        titleText,
                        style: const TextStyle(
                          color: kcTextColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitleText != null)
                        Text(
                          subtitleText,
                          style: const TextStyle(
                            color: kcTextColor,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                buttons.isEmpty
                    ? Container(width: 48)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: buttons.mapList(
                          (button) => Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: button,
                          ),
                        ),
                      )
              ],
            ),
          ),
          titleTextStyle: const TextStyle(),
          automaticallyImplyLeading: false,
        );
}

class CustomAppBarButton extends StatelessWidget {
  final CustomIcon? icon;
  final IconData? iconData;
  final VoidCallback onPressed;

  const CustomAppBarButton({
    super.key,
    this.icon,
    this.iconData,
    required this.onPressed,
  }) : assert(icon != null || iconData != null);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      backgroundColor: Colors.white,
      icon: icon ??
          Icon(
            iconData,
            color: kcTextColor,
            size: 22,
          ),
      onPressed: onPressed,
    );
  }
}
