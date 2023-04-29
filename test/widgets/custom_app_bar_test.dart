import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_app_bar.dart';
import 'package:flutter_app_test_stacked/ui/widgets/custom_icon.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('CustomAppBar Tests -', () {
    testWidgets(
      'should display title and back button',
      testWidget(
        screenBuilder: (_) => Scaffold(
          appBar: CustomAppBar(titleText: 'title'),
        ),
        (helper) async {
          helper.text('title');
          helper.widgetByValueKey('customAppBarBackButton');
        },
      ),
    );

    testWidgets(
      'should display title and subtitle',
      testWidget(
        screenBuilder: (_) => Scaffold(
          appBar: CustomAppBar(
            titleText: 'title',
            subtitleText: 'subtitle',
          ),
        ),
        (helper) async {
          helper.text('title');
          helper.text('subtitle');
        },
      ),
    );

    testWidgets(
      'should show buttons',
      (widgetTester) async {
        bool button1Pressed = false;
        bool button2Pressed = false;

        await testWidget(
          screenBuilder: (_) => Scaffold(
            appBar: CustomAppBar(
              titleText: 'title',
              buttons: [
                CustomAppBarButton(
                  key: const ValueKey('button1'),
                  onPressed: () {
                    button1Pressed = true;
                  },
                  iconData: Icons.abc,
                ),
                CustomAppBarButton(
                  key: const ValueKey('button2'),
                  onPressed: () {
                    button2Pressed = true;
                  },
                  icon: CustomIcon.trash(),
                ),
              ],
            ),
          ),
          (helper) async {
            await helper.tapWithValueKey('button1');

            assert(button1Pressed);

            await helper.tapWithValueKey('button2');

            assert(button2Pressed);
          },
        )(widgetTester);
      },
    );
  });
}
