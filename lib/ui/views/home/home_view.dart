import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/app/utils/formatting.dart';
import 'package:flutter_app_test_stacked/models/product.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_icon.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onViewModelReady: (viewModel) {
        viewModel.init();
      },
      builder: (_, viewModel, __) {
        return DefaultTabController(
          length: viewModel.busy(busyFetchingCategories)
              ? 1
              : viewModel.categories.length,
          child: Builder(builder: (context) {
            final TabController controller = DefaultTabController.of(context);

            if (!viewModel.listenerAdded) {
              controller.addListener(() {
                viewModel.onTabChanged(controller.index);
              });
            }

            final List<Widget> tabs = [];

            for (var i = 0; i < viewModel.categories.length; i++) {
              tabs.add(CategoryTab(
                text: viewModel.categories[i],
                selected: i == controller.index,
              ));
            }

            return Scaffold(
              appBar: AppBar(
                backgroundColor: kcAppBarColor,
                shadowColor: kcAccentColor.withAlpha(150),
                elevation: 10,
                title: const SearchBar(),
                actions: [
                  ShoppingCartAppBarButton(onPressed: () {}),
                ],
                bottom: AppTabBar(
                  loading: viewModel.busy(busyFetchingCategories),
                  tabs: tabs,
                ),
              ),
              body: TabBarView(
                children: viewModel.categories
                    .map((category) => viewModel.busy(category)
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ProductsList(viewModel.getCategoryProducts(category)))
                    .toList(),
              ),
            );
          }),
        );
      },
    );
  }
}

class AppTabBar extends StatelessWidget with PreferredSizeWidget {
  final List<Widget> tabs;
  final bool loading;

  const AppTabBar({super.key, required this.tabs, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final tabBar = TabBar(
      splashBorderRadius: BorderRadius.circular(10),
      isScrollable: true,
      physics: const BouncingScrollPhysics(),
      indicator: const DotIndicator(),
      tabs: tabs,
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
            borderRadius: BorderRadius.circular(8),
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

  const ShoppingCartAppBarButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 20.0,
        top: 5,
        bottom: 5,
      ),
      child: TextButton(
        onPressed: onPressed,
        child: CustomIcon.shoppingCart(size: 20),
        style: TextButton.styleFrom(
          backgroundColor: kcAccentColor,
          visualDensity: VisualDensity.compact,
          shape: const CircleBorder(),
          padding: const EdgeInsets.only(right: 5),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class ProductsList extends StatelessWidget {
  final List<Product> products;

  const ProductsList(
    this.products, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (_, index) => ProductItem(products[index]),
    );
  }
}

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem(
    this.product, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(product.thumbnail),
      title: Text(product.description),
      subtitle: Text(product.price.asCurrency()),
      trailing: const Icon(Icons.shopping_cart),
    );
  }
}

class CategoryTab extends StatelessWidget {
  final String text;
  final bool selected;

  const CategoryTab({super.key, required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: kcTextColor,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
          fontSize: 16,
        ),
      ),
    );
  }
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
      Offset(rect.centerLeft.dx + 4 + radius, rect.centerLeft.dy),
      radius,
      _paint,
    );
  }
}
