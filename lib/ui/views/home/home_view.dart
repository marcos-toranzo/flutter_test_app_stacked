// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app_test_stacked/app/app.dialogs.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/utils/iterable_utils.dart';
import 'package:flutter_app_test_stacked/ui/views/home/products_list.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_button.dart';
import 'package:stacked/stacked.dart';

import 'package:flutter_app_test_stacked/ui/views/home/home_app_bar.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_icon.dart';
import 'package:stacked_services/stacked_services.dart';

import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  final _productsListKey = GlobalKey<ProductsListState>();
  final _dialogService = locator<DialogService>();

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
              cartCount: viewModel.cartCount,
              onCategoriesRefresh: () {
                viewModel.refreshCategories().then(
                  (success) {
                    if (!success) {
                      _dialogService.showCustomDialog(
                        variant: DialogType.infoAlert,
                        data: false,
                        description:
                            'Something went wrong trying to fetch the categories.',
                      );
                    }
                  },
                );
              },
            ),
            body: TabBarView(
              children: viewModel.categories.mapList((category) {
                return ProductsList(
                  onProductTapBuilder: viewModel.onProductTap,
                  key: category == allCategories ? _productsListKey : null,
                  onFetchPage: (page) =>
                      viewModel.getCategoryProducts(category, page),
                  productTrailingBuilder: (productId) => CustomButton(
                    icon: CustomIcon.shoppingCart(),
                    circular: false,
                    onPressed: viewModel.busy(productId)
                        ? null
                        : () {
                            viewModel.onProductShoppingCartTap(productId).then(
                              (success) {
                                if (!success) {
                                  _dialogService.showCustomDialog(
                                    variant: DialogType.infoAlert,
                                    data: false,
                                    description:
                                        'Something went wrong trying to add product to cart.',
                                  );
                                } else {
                                  _dialogService.showCustomDialog(
                                    variant: DialogType.infoAlert,
                                    data: true,
                                    description: 'Product added to cart.',
                                  );
                                }
                              },
                            );
                          },
                  ),
                );
              }),
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
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => viewModel.init().then(
        (success) {
          if (!success) {
            _dialogService.showCustomDialog(
              variant: DialogType.infoAlert,
              data: false,
              description:
                  'Something went wrong trying to fetch the categories.',
            );
          }
        },
      ),
    );
  }
}
