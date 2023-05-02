import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/app/app.bottomsheets.dart';
import 'package:flutter_app_test_stacked/ui/bottom_sheets/custom/custom_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('CustomBottomSheet Tests- ', () {
    setUpAll(() {
      testWidgetSetUpAll(
        setUpBottomSheetUi: true,
      );
    });

    setUp(setUpServices);

    tearDown(tearDownServices);

    testWidgets(
      'should display data',
      testWidget(
        scaffoldBodyBuilder: (context) => TextButton(
          onPressed: () {
            final BottomSheetService bottomSheetService = getService();

            bottomSheetService.showCustomSheet(
              variant: BottomSheetType.custom,
              data: const Text('text'),
            );
          },
          child: const Text('button'),
        ),
        (helper) async {
          await helper.tap(TextButton);

          helper.widgetByType<CustomSheet>();

          helper.text('button');
        },
      ),
    );
  });
}
