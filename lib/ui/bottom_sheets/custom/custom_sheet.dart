import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

class CustomSheet extends StatelessWidget {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;

  const CustomSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return request.data;
  }
}
