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

class HomeView extends StackedView<HomeViewModel> {
  final _productsListKey = GlobalKey<_ProductsListState>();

  HomeView({super.key});

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return DefaultTabController(
      length: viewModel.categories.length,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: HomeAppBar(
              tabsLoading: viewModel.busy(busyFetchingCategories),
              tabsLabels: viewModel.categories,
              onSearchTextChanged: (searchText) {
                viewModel.onSearchTextChanged(searchText);
                DefaultTabController.of(context).animateTo(0);
                _productsListKey.currentState?.refresh();
              },
              onCartButtonPressed: viewModel.onCartButtonPressed,
            ),
            body: TabBarView(
              children: viewModel.categories
                  .map(
                    (category) => ProductsList(
                      onProductShoppingCartTap:
                          viewModel.onProductShoppingCartTap,
                      onProductTap: viewModel.onProductTap,
                      key: category == allCategories
                          ? _productsListKey
                          : ValueKey('ProductsList@$category'),
                      fetchPage: (page) =>
                          viewModel.getCategoryProducts(category, page),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  @override
  void onViewModelReady(HomeViewModel viewModel) {
    SchedulerBinding.instance.addPostFrameCallback((_) => viewModel.init());
  }
}

class ProductsList extends StatefulWidget {
  final Future<ProductFetchingResult> Function(int page) fetchPage;
  final void Function(int productId) onProductTap;
  final void Function(int productId) onProductShoppingCartTap;

  const ProductsList({
    required this.fetchPage,
    required this.onProductTap,
    required this.onProductShoppingCartTap,
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
          onTap: () {
            widget.onProductTap(item.id);
          },
          onShoppingCartPressed: () {
            widget.onProductShoppingCartTap(item.id);
          },
          product: item,
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
  final VoidCallback onTap;
  final VoidCallback onShoppingCartPressed;

  const ProductItem({
    required this.product,
    required this.onShoppingCartPressed,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
              ShoppingCartButton(onPressed: onShoppingCartPressed)
            ],
          ),
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
