import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';
import 'package:stacked_services/stacked_services.dart';

class CustomAppBarButton extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onPressed;

  const CustomAppBarButton({
    super.key,
    required this.iconData,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      height: 44,
      width: 44,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(100),
          child: Icon(
            iconData,
            color: kcTextColor,
            size: 25,
          ),
        ),
      ),
    );
  }
}

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
                  iconData: Icons.navigate_before,
                  onPressed: () {
                    locator<NavigationService>().back();
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      titleText,
                      style: const TextStyle(
                        color: kcTextColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                buttons.isEmpty
                    ? Container(width: 48)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: buttons
                            .map((button) => Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: button,
                                ))
                            .toList(),
                      )
              ],
            ),
          ),
          titleTextStyle: const TextStyle(),
          automaticallyImplyLeading: false,
        );
}
