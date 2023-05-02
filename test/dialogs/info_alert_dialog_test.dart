import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/app/app.dialogs.dart';
import 'package:flutter_app_test_stacked/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('InfoAlertDialog Tests- ', () {
    setUpAll(() {
      testWidgetSetUpAll(
        setUpDialogUi: true,
        onAppPumped: (helper) async {
          await helper.tap(TextButton);
        },
      );
    });

    setUp(setUpServices);

    tearDown(tearDownServices);

    testWidgets(
      'should display default behavior',
      testWidget(
        scaffoldBodyBuilder: (context) => TextButton(
          onPressed: () {
            final DialogService dialogService = getService();

            dialogService.showCustomDialog(
              variant: DialogType.infoAlert,
              title: 'title',
              description: 'description',
            );
          },
          child: const Text('button'),
        ),
        (helper) async {
          helper.widgetByType<InfoAlertDialog>();

          helper.descendantTextByType(
            ofType: GestureDetector,
            text: 'Got it',
          );

          helper.text('title');
          helper.text('description');
          helper.text('❕');
        },
      ),
    );

    testWidgets(
      'should display success',
      testWidget(
        scaffoldBodyBuilder: (context) => TextButton(
          onPressed: () {
            final DialogService dialogService = getService();

            dialogService.showCustomDialog(
              variant: DialogType.infoAlert,
              data: true,
              description: 'description',
            );
          },
          child: const Text('button'),
        ),
        (helper) async {
          helper.text('Hooray!');
          helper.text('description');
          helper.text('🎉');
        },
      ),
    );

    testWidgets(
      'should display error',
      testWidget(
        scaffoldBodyBuilder: (context) => TextButton(
          onPressed: () {
            final DialogService dialogService = getService();

            dialogService.showCustomDialog(
              variant: DialogType.infoAlert,
              data: false,
              description: 'description',
            );
          },
          child: const Text('button'),
        ),
        (helper) async {
          helper.text('Oops!');
          helper.text('description');
          helper.text('💥');
        },
      ),
    );
  });
}
