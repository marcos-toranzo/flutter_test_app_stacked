import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';
import 'package:flutter_app_test_stacked/ui/common/ui_helpers.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_icon.dart';

class HomeAppBar extends AppBar {
  HomeAppBar(
      {super.key,
      TabController? tabController,
      required bool tabsLoading,
      required tabsLabels})
      : super(
          backgroundColor: kcAppBarColor,
          shadowColor: kcAccentColor.withAlpha(150),
          elevation: 10,
          title: const SearchBar(),
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                right: 20.0,
                top: 5,
                bottom: 5,
              ),
              child: ShoppingCartAppBarButton(onPressed: () {}),
            ),
          ],
          bottom: AppTabBar(
            controller: tabController,
            loading: tabsLoading,
            tabsLabels: tabsLabels,
          ),
        );
}

class AppTabBar extends StatelessWidget with PreferredSizeWidget {
  final List<String> tabsLabels;
  final bool loading;
  final TabController? controller;

  const AppTabBar({
    super.key,
    required this.tabsLabels,
    this.loading = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final tabBar = TabBar(
      labelColor: kcTextColor,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      labelPadding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 10,
      ),
      controller: controller,
      splashBorderRadius: circularBorderRadius,
      isScrollable: true,
      physics: const BouncingScrollPhysics(),
      indicator: const DotIndicator(),
      tabs: tabsLabels.map((e) => Text(e)).toList(),
    );

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 14.0,
          ),
          child: CustomIcon.categoriesMenu(),
        ),
        ...(loading
            ? [
                tabBar,
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: LinearProgressIndicator(),
                    ),
                  ),
                ),
              ]
            : [Expanded(child: tabBar)]),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class DotIndicator extends Decoration {
  const DotIndicator({
    this.color = kcTextColor,
    this.radius = 3.0,
  });
  final Color color;
  final double radius;
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DotPainter(
      color: color,
      radius: radius,
      onChange: onChanged,
    );
  }
}

class _DotPainter extends BoxPainter {
  final Paint _paint;
  final Color color;
  final double radius;

  _DotPainter({
    required this.color,
    required this.radius,
    VoidCallback? onChange,
  })  : _paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill,
        super(onChange);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);

    final Rect rect = offset & configuration.size!;

    canvas.drawCircle(
      Offset(rect.centerLeft.dx + radius, rect.centerLeft.dy),
      radius,
      _paint,
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 60,
      ),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
          ),
          hintStyle: const TextStyle(
            color: kcTextColor,
            fontSize: 16,
          ),
          isDense: true,
          filled: true,
          hintText: 'Search product',
          fillColor: kcAccentColor,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: circularBorderRadius,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: kcBlueGray,
            size: 23,
          ),
        ),
      ),
    );
  }
}

class ShoppingCartAppBarButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ShoppingCartAppBarButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: CustomIcon.shoppingCart(size: 22),
      style: TextButton.styleFrom(
        backgroundColor: kcAccentColor,
        visualDensity: VisualDensity.compact,
        shape: const CircleBorder(),
        padding: const EdgeInsets.only(right: 5),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
