import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('NetworkServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
