import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app_test_stacked/app/app.bottomsheets.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/ui/views/cart/cart_checkout_modal.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_app_bar.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_button.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_fab.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_icon.dart';
import 'package:flutter_app_test_stacked/ui/widgets/product_item.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'cart_viewmodel.dart';

class CartView extends StackedView<CartViewModel> {
  final _bottomSheetService = locator<BottomSheetService>();

  CartView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CartViewModel viewModel,
    Widget? child,
  ) {
    final products = viewModel.products;

    final countText = products == null
        ? null
        : '${products.length} product${products.length > 1 ? 's' : ''}';

    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Cart',
        subtitleText: countText,
        buttons: [
          CustomAppBarButton(
            icon: CustomIcon.trash(),
            onPressed: viewModel.onDeleteCart,
          ),
        ],
      ),
      floatingActionButton: products == null
          ? null
          : CustomFab(
              text: 'Checkout',
              onPressed: () {
                _bottomSheetService.showCustomSheet(
                  variant: BottomSheetType.custom,
                  data: CartCheckoutModal(
                    onConfirmPressed: () {},
                    onDiscountCouponPressed: () {},
                    total: 337.15,
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: viewModel.busy(fetchingProducts)
          ? const Center(child: CircularProgressIndicator())
          : viewModel.products == null
              ? const Center(child: Text('Error fetching cart products'))
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  separatorBuilder: (_, __) => const Divider(
                    endIndent: 10,
                    indent: 10,
                    thickness: 0.8,
                    height: 0,
                  ),
                  itemCount: viewModel.products!.length,
                  itemBuilder: (_, index) {
                    final product = viewModel.products![index];

                    return ProductItem(
                      horizontalPadding: 18,
                      product: product,
                      showDiscount: false,
                      onTap: () {
                        viewModel.onProductTap(product.id);
                      },
                      trailing: AddRemoveCartProduct(
                        count: 1,
                        onAdd: () {
                          viewModel.onAddProduct(product.id);
                        },
                        onRemove: () {
                          viewModel.onRemoveProduct(product.id);
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

class AddRemoveCartProduct extends StatelessWidget {
  final int count;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  const AddRemoveCartProduct({
    super.key,
    required this.count,
    this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButton(
          icon: const Icon(
            Icons.horizontal_rule,
            size: 15,
          ),
          onPressed: onAdd,
          size: 28,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9.0),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        CustomButton(
          icon: const Icon(
            Icons.add,
            size: 15,
          ),
          onPressed: onRemove,
          size: 28,
        ),
      ],
    );
  }
}
