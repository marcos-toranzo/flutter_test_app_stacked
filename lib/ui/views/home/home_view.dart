import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/app/utils/formatting.dart';
import 'package:flutter_app_test_stacked/models/product.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';
import 'package:flutter_app_test_stacked/ui/common/ui_helpers.dart';
import 'package:flutter_app_test_stacked/ui/views/home/home_app_bar.dart';
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
        return TabBarViewScreen(
          tabsLoading: viewModel.busy(busyFetchingCategories),
          tabsLabels: viewModel.categories,
          length: viewModel.categories.length,
          views: viewModel.categories
              .map(
                (category) => viewModel.busy(category)
                    ? const Center(child: CircularProgressIndicator())
                    : ProductsList(viewModel.getCategoryProducts(category)),
              )
              .toList(),
          onTabChanged: viewModel.onTabChanged,
        );
      },
    );
  }
}

class TabBarViewScreen extends StatefulWidget {
  final List<String> tabsLabels;
  final List<Widget> views;
  final int length;
  final bool tabsLoading;
  final void Function(int index) onTabChanged;

  const TabBarViewScreen({
    super.key,
    required this.tabsLabels,
    required this.views,
    required this.length,
    required this.tabsLoading,
    required this.onTabChanged,
  });

  @override
  State<TabBarViewScreen> createState() => _TabBarViewScreenState();
}

class _TabBarViewScreenState extends State<TabBarViewScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  void _initController() {
    _tabController = TabController(
      length: widget.length,
      vsync: this,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.onTabChanged(_tabController.index);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant TabBarViewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.length != widget.length) {
      _tabController.dispose();
      _initController();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        tabController: _tabController,
        tabsLoading: widget.tabsLoading,
        tabsLabels: widget.tabsLabels,
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.views,
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
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, __) => const Divider(
        endIndent: 10,
        indent: 10,
        thickness: 0.8,
        height: 0,
      ),
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
    return Padding(
      padding: const EdgeInsets.only(
        left: 30,
        right: 25,
      ),
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
                        if (product.discountPercentage > 0)
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
                                color: Color(0xFFF76030),
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
            ShoppingCartButton(
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}

class ShoppingCartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ShoppingCartButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kcAccentColor,
        borderRadius: circularBorderRadius,
      ),
      height: 45,
      width: 45,
      child: Material(
        color: kcAccentColor,
        borderRadius: circularBorderRadius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: circularBorderRadius,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomIcon.shoppingCart(),
          ),
        ),
      ),
    );
  }
}
