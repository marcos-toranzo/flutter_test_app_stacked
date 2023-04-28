import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_button.dart';

class AddRemoveCartProduct extends StatelessWidget {
  final int count;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final bool busy;

  const AddRemoveCartProduct({
    super.key,
    required this.count,
    this.onAdd,
    this.onRemove,
    this.busy = false,
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
          onPressed: busy ? null : onRemove,
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
          onPressed: busy ? null : onAdd,
          size: 28,
        ),
      ],
    );
  }
}
