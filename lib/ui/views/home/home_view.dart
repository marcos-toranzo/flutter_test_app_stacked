// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app_test_stacked/ui/views/home/products_list.dart';
import 'package:stacked/stacked.dart';

import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';
import 'package:flutter_app_test_stacked/ui/common/ui_helpers.dart';
import 'package:flutter_app_test_stacked/ui/views/home/home_app_bar.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_icon.dart';

import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  final _productsListKey = GlobalKey<ProductsListState>();

  HomeView({super.key});

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return DefaultTabController(
      length: viewModel.categories.length,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: HomeAppBar(
              tabsLoading: viewModel.busy(fetchingCategories),
              tabsLabels: viewModel.categories,
              onSearchTextChanged: (searchText) {
                viewModel.onSearchTextChanged(searchText);
                DefaultTabController.of(context).animateTo(0);
                _productsListKey.currentState?.refresh();
              },
              onCartButtonPressed: viewModel.onCartButtonPressed,
            ),
            body: TabBarView(
              children: viewModel.categories.map((category) {
                return ProductsList(
                  onProductTap: viewModel.onProductTap,
                  key: category == allCategories ? _productsListKey : null,
                  fetchPage: (page) =>
                      viewModel.getCategoryProducts(category, page),
                  trailingBuilder: (productId) => _ShoppingCartButton(
                    onPressed: () {
                      viewModel.onProductShoppingCartTap(productId);
                    },
                  ),
                );
              }).toList(),
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

class _ShoppingCartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ShoppingCartButton({required this.onPressed});

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
