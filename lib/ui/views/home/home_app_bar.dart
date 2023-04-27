import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';
import 'package:flutter_app_test_stacked/ui/common/ui_helpers.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_button.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_icon.dart';

class HomeAppBar extends AppBar {
  HomeAppBar({
    super.key,
    TabController? tabController,
    void Function(String searchText)? onSearchTextChanged,
    GlobalKey<FormFieldState>? searchFieldKey,
    required bool tabsLoading,
    required List<String> tabsLabels,
    required VoidCallback onCartButtonPressed,
  }) : super(
          backgroundColor: kcAppBarColor,
          shadowColor: kcAccentColor.withAlpha(120),
          elevation: 10,
          title: Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              right: 60,
            ),
            child: SearchBar(
              onSearchTextChanged: onSearchTextChanged,
              searchFieldKey: searchFieldKey,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShoppingCartAppBarButton(
                    onPressed: onCartButtonPressed,
                    count: 4,
                  ),
                ],
              ),
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
  final void Function(String searchText)? onSearchTextChanged;
  final GlobalKey<FormFieldState>? searchFieldKey;

  const SearchBar({
    super.key,
    this.onSearchTextChanged,
    this.searchFieldKey,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: searchFieldKey,
      onChanged: onSearchTextChanged,
      decoration: InputDecoration(
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
    );
  }
}

class ShoppingCartAppBarButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const ShoppingCartAppBarButton({
    super.key,
    required this.onPressed,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: CustomButton(
            icon: CustomIcon.shoppingCart(),
            onPressed: onPressed,
          ),
        ),
        if (count > 0)
          Padding(
            padding: const EdgeInsets.only(right: 0.0),
            child: Container(
              decoration: BoxDecoration(
                color: kcAccentColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: kcTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
