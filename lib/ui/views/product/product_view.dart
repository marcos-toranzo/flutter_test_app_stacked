import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app_test_stacked/app/app.dialogs.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_header.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_price_and_discount.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_app_bar.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_images_carousel.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_stock_status.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_fab.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'product_viewmodel.dart';

class ProductView extends StackedView<ProductViewModel> {
  final _dialogService = locator<DialogService>();

  final int productId;

  ProductView({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ProductViewModel viewModel,
    Widget? child,
  ) {
    final product = viewModel.product;

    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Product',
        buttons: [
          CustomAppBarButton(
            iconData: Icons.refresh,
            onPressed: viewModel.onRefresh,
          ),
        ],
      ),
      floatingActionButton: product == null
          ? null
          : CustomFab(
              text: 'Add to Cart',
              onPressed: viewModel.busy(addingToCart)
                  ? null
                  : () {
                      viewModel.onAddToCartPressed().then(
                        (success) {
                          if (!success) {
                            _dialogService.showCustomDialog(
                              variant: DialogType.infoAlert,
                              data: false,
                              title: 'Oops!',
                              description:
                                  'Something went wrong trying to add product to cart.',
                            );
                          } else {
                            _dialogService.showCustomDialog(
                              variant: DialogType.infoAlert,
                              data: true,
                              title: 'Hooray!',
                              description: 'Product added to cart.',
                            );
                          }
                        },
                      );
                    },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: viewModel.busy(fetchingProduct)
          ? const Center(child: CircularProgressIndicator())
          : product == null
              ? const Center(child: Text('Error fetching product'))
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        top: 20.0,
                        bottom: 40.0,
                      ),
                      child: ProductHeader(
                        brand: product.brand,
                        description: product.description,
                        rating: product.rating,
                        title: product.title,
                      ),
                    ),
                    ProductImagesCarousel(images: product.images),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        top: 30.0,
                        bottom: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProductStockStatus(stock: product.stock),
                          const SizedBox(height: 10),
                          ProductPriceAndDiscount(
                            price: product.price,
                            discount: product.discountPercentage,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  @override
  ProductViewModel viewModelBuilder(BuildContext context) =>
      ProductViewModel(productId);

  @override
  void onViewModelReady(ProductViewModel viewModel) {
    SchedulerBinding.instance.addPostFrameCallback((_) => viewModel.init());
  }
}
