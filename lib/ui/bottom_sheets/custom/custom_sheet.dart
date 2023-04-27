import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'custom_sheet_model.dart';

class CustomSheet extends StackedView<CustomSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;

  const CustomSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CustomSheetModel viewModel,
    Widget? child,
  ) {
    return request.data;
  }

  @override
  CustomSheetModel viewModelBuilder(BuildContext context) => CustomSheetModel();
}
