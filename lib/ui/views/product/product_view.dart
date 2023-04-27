import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app_test_stacked/ui/common/ui_helpers.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_header.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_price_and_discount.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_app_bar.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_images_carousel.dart';
import 'package:flutter_app_test_stacked/ui/views/product/product_stock_status.dart';
import 'package:stacked/stacked.dart';

import 'product_viewmodel.dart';

class ProductView extends StackedView<ProductViewModel> {
  final int productId;

  const ProductView({
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
      floatingActionButton: product == null ? null : const _AddToCartFab(),
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

class _AddToCartFab extends StatelessWidget {
  const _AddToCartFab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF47858A),
            shape: RoundedRectangleBorder(borderRadius: circularBorderRadius),
          ),
          onPressed: () {},
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              'Add to cart',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
