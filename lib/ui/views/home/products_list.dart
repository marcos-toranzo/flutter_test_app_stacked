import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/models/product.dart';
import 'package:flutter_app_test_stacked/ui/views/home/product_fetching_result.dart';
import 'package:flutter_app_test_stacked/ui/widgets/product_item.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ProductsList extends StatefulWidget {
  final Future<ProductFetchingResult> Function(int page) onFetchPage;
  final void Function(int productId)? onProductTapBuilder;
  final Widget Function(int productId)? productTrailingBuilder;

  const ProductsList({
    required this.onFetchPage,
    this.onProductTapBuilder,
    this.productTrailingBuilder,
    super.key,
  });

  @override
  State<ProductsList> createState() => ProductsListState();
}

class ProductsListState extends State<ProductsList> {
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
    final result = await widget.onFetchPage(page);

    if (_controllerDisposed) {
      return;
    }

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
          key: ValueKey('ProductItem#${item.id}'),
          product: item,
          onTap: () {
            widget.onProductTapBuilder?.call(item.id);
          },
          trailing: widget.productTrailingBuilder?.call(item.id),
        ),
        noItemsFoundIndicatorBuilder: (_) => const Center(
          child: Text('No products found'),
        ),
        newPageProgressIndicatorBuilder: (_) => Column(
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: SizedBox.square(
                child: CircularProgressIndicator(
                  key: ValueKey('productsListNewPageProgressIndicator'),
                ),
              ),
            ),
          ],
        ),
        noMoreItemsIndicatorBuilder: (_) {
          final length = _pagingController.itemList?.length;

          return Padding(
            padding: const EdgeInsets.only(
              top: 12.0,
              bottom: 30.0,
            ),
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
