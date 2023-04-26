// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';

import 'package:flutter_app_test_stacked/app/utils/formatting.dart';
import 'package:flutter_app_test_stacked/models/product.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';
import 'package:flutter_app_test_stacked/ui/common/ui_helpers.dart';
import 'package:flutter_app_test_stacked/ui/views/home/home_app_bar.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_icon.dart';

import 'home_viewmodel.dart';

final _tabBarViewScreenKey = GlobalKey<_TabBarViewScreenState>();
final _productsListKey = GlobalKey<_ProductsListState>();

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return TabBarViewScreen(
      key: _tabBarViewScreenKey,
      tabsLoading: viewModel.busy(busyFetchingCategories),
      tabsLabels: viewModel.categories,
      views: viewModel.categories
          .map(
            (category) => ProductsList(
              key: category == allCategories
                  ? _productsListKey
                  : ValueKey('ProductsList@$category'),
              fetchPage: (page) =>
                  viewModel.getCategoryProducts(category, page),
            ),
          )
          .toList(),
      onTabChanged: viewModel.onTabChanged,
      onSearchTextChanged: (searchText) {
        viewModel.onSearchTextChanged(searchText);
        _tabBarViewScreenKey.currentState!.goToView(0);
        _productsListKey.currentState!.refresh();
      },
      onCartButtonPressed: () {},
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  @override
  void onViewModelReady(HomeViewModel viewModel) {
    SchedulerBinding.instance.addPostFrameCallback((_) => viewModel.init());
  }
}

class TabBarViewScreen extends StatefulWidget {
  final List<String> tabsLabels;
  final List<Widget> views;
  final bool tabsLoading;
  final void Function(int index) onTabChanged;
  final void Function(String searchText)? onSearchTextChanged;
  final GlobalKey<FormFieldState>? searchFieldKey;
  final VoidCallback onCartButtonPressed;

  const TabBarViewScreen({
    super.key,
    required this.tabsLabels,
    required this.views,
    required this.tabsLoading,
    required this.onTabChanged,
    required this.onCartButtonPressed,
    this.onSearchTextChanged,
    this.searchFieldKey,
  });

  @override
  State<TabBarViewScreen> createState() => _TabBarViewScreenState();
}

class _TabBarViewScreenState extends State<TabBarViewScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  void _initController() {
    _tabController = TabController(
      length: widget.tabsLabels.length,
      vsync: this,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.onTabChanged(_tabController.index);
      }
    });
  }

  void goToView(int index) {
    _tabController.animateTo(index);
  }

  void update() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant TabBarViewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tabsLabels.length != widget.tabsLabels.length) {
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
        onSearchTextChanged: widget.onSearchTextChanged,
        searchFieldKey: widget.searchFieldKey,
        onCartButtonPressed: widget.onCartButtonPressed,
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.views,
      ),
    );
  }
}

class ProductsList extends StatefulWidget {
  final Future<ProductFetchingResult> Function(int page) fetchPage;

  const ProductsList({
    required this.fetchPage,
    super.key,
  });

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  late final PagingController<int, Product> _pagingController;
  bool _controllerDisposed = false;

  @override
  void initState() {
    _pagingController = PagingController<int, Product>(firstPageKey: 0);
    _pagingController.addPageRequestListener(_fetchPage);

    super.initState();
  }

  @override
  void dispose() {
    _pagingController.removePageRequestListener(_fetchPage);
    _pagingController.dispose();
    _controllerDisposed = true;
    super.dispose();
  }

  void refresh() {
    _pagingController.refresh();
  }

  Future<void> _fetchPage(int page) async {
    final result = await widget.fetchPage(page);

    if (!_controllerDisposed) {
      final products = result.products;

      if (products == null) {
        _pagingController.error = 'error';

        return;
      }

      if (result.last) {
        _pagingController.appendLastPage(products);

        return;
      }

      _pagingController.appendPage(products, page + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Product>.separated(
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, __) => const Divider(
        endIndent: 10,
        indent: 10,
        thickness: 0.8,
        height: 0,
      ),
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate(
        animateTransitions: true,
        itemBuilder: (_, item, __) => ProductItem(
          item,
          key: ValueKey('ProductItem#${item.id}'),
        ),
        noItemsFoundIndicatorBuilder: (_) => const Center(
          child: Text('No products found'),
        ),
        noMoreItemsIndicatorBuilder: (_) {
          final length = _pagingController.itemList?.length;

          return Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Center(
              child: Text(
                length != null
                    ? '$length product${length > 1 ? 's' : ''}'
                    : 'No more products',
              ),
            ),
          );
        },
      ),
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
