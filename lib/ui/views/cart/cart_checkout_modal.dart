import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/utils/formatting.dart';
import 'package:flutter_app_test_stacked/ui/common/app_colors.dart';
import 'package:flutter_app_test_stacked/ui/common/ui_helpers.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_icon.dart';

class CartCheckoutModal extends StatelessWidget {
  final VoidCallback onConfirmPressed;
  final VoidCallback onDiscountCouponPressed;
  final double total;

  const CartCheckoutModal({
    super.key,
    required this.onConfirmPressed,
    required this.onDiscountCouponPressed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(35),
        topRight: Radius.circular(35),
      ),
      child: Container(
        padding: const EdgeInsets.only(
          right: 30,
          left: 40,
          top: 30,
          bottom: 30,
        ),
        height: 200,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: CustomIcon.receipt(
                    size: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                InkWell(
                  borderRadius: circularBorderRadius,
                  onTap: onDiscountCouponPressed,
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 3.0,
                          right: 14.0,
                          left: 10.0,
                        ),
                        child: Text(
                          'Discount coupon',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.navigate_next,
                        color: Colors.black54,
                        size: 30,
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      total.asCurrency(),
                      style: const TextStyle(
                        color: Color(0xFFD89A23),
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: circularBorderRadius,
                      ),
                    ),
                    onPressed: onConfirmPressed,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
