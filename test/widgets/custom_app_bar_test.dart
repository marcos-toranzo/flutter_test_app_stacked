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
        screen: () => Scaffold(
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
        screen: () => Scaffold(
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
        int count1 = 0;
        int count2 = 0;

        await testWidget(
          screen: () => Scaffold(
            appBar: CustomAppBar(
              titleText: 'title',
              buttons: [
                CustomAppBarButton(
                  key: const ValueKey('button1'),
                  onPressed: () {
                    count1 = 1;
                  },
                  iconData: Icons.abc,
                ),
                CustomAppBarButton(
                  key: const ValueKey('button2'),
                  onPressed: () {
                    count2 = 1;
                  },
                  icon: CustomIcon.trash(),
                ),
              ],
            ),
          ),
          (helper) async {
            await helper.tapWithValueKey('button1');

            expect(count1, 1);

            await helper.tapWithValueKey('button2');

            expect(count2, 1);
          },
        )(widgetTester);
      },
    );
  });
}
