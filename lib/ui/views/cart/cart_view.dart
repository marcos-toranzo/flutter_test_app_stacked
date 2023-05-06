import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app_test_stacked/app/app.bottomsheets.dart';
import 'package:flutter_app_test_stacked/app/app.dialogs.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/ui/views/cart/add_remove_cart_product.dart';
import 'package:flutter_app_test_stacked/ui/views/cart/cart_checkout_modal.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_app_bar.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_fab.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_icon.dart';
import 'package:flutter_app_test_stacked/ui/widgets/product_item.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'cart_viewmodel.dart';

class CartView extends StackedView<CartViewModel> {
  final _bottomSheetService = locator<BottomSheetService>();
  final _dialogService = locator<DialogService>();

  CartView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CartViewModel viewModel,
    Widget? child,
  ) {
    final products = viewModel.products;

    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Cart',
        subtitleText: viewModel.count == 0
            ? 'No products'
            : '${viewModel.count} product${viewModel.count != 1 ? 's' : ''}',
        buttons: [
          CustomAppBarButton(
            key: const ValueKey('cartViewEmptyCartButton'),
            icon: CustomIcon.trash(),
            onPressed: () {
              viewModel.onEmptyCart().then(
                (success) {
                  if (!success) {
                    _dialogService.showCustomDialog(
                      variant: DialogType.infoAlert,
                      data: false,
                      description: 'Something went wrong trying to clear cart.',
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: products?.isEmpty != false
          ? null
          : CustomFab(
              text: 'Checkout',
              onPressed: () {
                _bottomSheetService.showCustomSheet(
                  variant: BottomSheetType.custom,
                  data: CartCheckoutModal(
                    onConfirmPressed: () {},
                    onDiscountCouponPressed: () {},
                    total: viewModel.total,
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: viewModel.busy(fetchingProducts)
          ? const Center(child: CircularProgressIndicator())
          : products == null
              ? const Center(child: Text('Error fetching cart products'))
              : products.isEmpty
                  ? const Center(child: Text('Empty'))
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 100),
                      separatorBuilder: (_, __) => const Divider(
                        endIndent: 10,
                        indent: 10,
                        thickness: 0.8,
                        height: 0,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, index) {
                        final product = products[index];

                        return ProductItem(
                          key: ValueKey('CartProduct#${product.id}'),
                          horizontalPadding: 18,
                          product: product,
                          showDiscount: false,
                          onTap: () {
                            viewModel.onProductTap(product.id);
                          },
                          trailing: AddRemoveCartProduct(
                            busy: viewModel.busy(product.id),
                            count: viewModel.getProductCount(product.id),
                            onAdd: () {
                              viewModel.onAddProduct(product.id).then(
                                (success) {
                                  if (!success) {
                                    _dialogService.showCustomDialog(
                                      variant: DialogType.infoAlert,
                                      data: false,
                                      description:
                                          'Something went wrong trying to add product.',
                                    );
                                  }
                                },
                              );
                            },
                            onRemove: () {
                              viewModel.onRemoveProduct(product.id).then(
                                (success) {
                                  if (!success) {
                                    _dialogService.showCustomDialog(
                                      variant: DialogType.infoAlert,
                                      data: false,
                                      description:
                                          'Something went wrong trying to remove product.',
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }

  @override
  CartViewModel viewModelBuilder(BuildContext context) => CartViewModel();

  @override
  void onViewModelReady(CartViewModel viewModel) {
    SchedulerBinding.instance.addPostFrameCallback((_) => viewModel.init());
  }
}
