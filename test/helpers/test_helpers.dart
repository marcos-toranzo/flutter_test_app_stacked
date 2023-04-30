import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/app/app.bottomsheets.dart';
import 'package:flutter_app_test_stacked/app/app.dialogs.dart';
import 'package:flutter_app_test_stacked/app/app.router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter_app_test_stacked/services/product_service.dart';
import 'package:flutter_app_test_stacked/services/network_service.dart';
import 'package:flutter_app_test_stacked/services/cart_service.dart';
import 'package:flutter_app_test_stacked/services/database_service.dart';
import 'package:http/http.dart' as http;

// @stacked-import

import 'test_helpers.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<NavigationService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<BottomSheetService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<DialogService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<ProductService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<NetworkService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<CartService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<DatabaseService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<http.Client>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<sqflite.Database>(onMissingStub: OnMissingStub.returnDefault),
// @stacked-mock-spec
])
WidgetBuilder? _screenBuilderAll;
WidgetBuilder? _scaffoldBodyBuilderAll;
bool? _settleAfterPumpAll;
bool? _mockNetworkImageAll;
bool? _setUpDialogUiAll;
bool? _setUpBottomSheetUiAll;
Future<void> Function(TestHelper helper)? _onAppPumped;
Future<void> Function(TestHelper helper)? _onCallbackCalled;

void testWidgetSetUpAll({
  WidgetBuilder? screenBuilder,
  WidgetBuilder? scaffoldBodyBuilder,
  bool? settleAfterPump,
  bool? mockNetworkImage,
  bool? setUpDialogUi,
  bool? setUpBottomSheetUi,
  Future<void> Function(TestHelper helper)? onAppPumped,
  Future<void> Function(TestHelper helper)? onCallbackCalled,
}) {
  _screenBuilderAll = screenBuilder;
  _scaffoldBodyBuilderAll = scaffoldBodyBuilder;
  _settleAfterPumpAll = settleAfterPump;
  _mockNetworkImageAll = mockNetworkImage;
  _setUpDialogUiAll = setUpDialogUi;
  _setUpBottomSheetUiAll = setUpBottomSheetUi;
  _onAppPumped = onAppPumped;
  _onCallbackCalled = onCallbackCalled;
}

void testWidgetReset() {
  testWidgetSetUpAll();
}

void setUpServices<T extends Object>({
  bool mockNetworkService = false,
  bool mockDatabaseService = false,
  bool mockNavigationService = false,
  bool mockBottomSheetService = false,
  bool mockDialogService = false,
  bool mockProductService = false,
  bool mockCartService = false,
  void Function(NetworkService networkService)? onNetworkServiceRegistered,
  void Function(DatabaseService databaseService)? onDatabaseServiceRegistered,
  void Function(NavigationService navigationService)?
      onNavigationServiceRegistered,
  void Function(BottomSheetService bottomSheetService)?
      onBottomSheetServiceRegistered,
  void Function(DialogService dialogService)? onDialogServiceRegistered,
  void Function(ProductService productService)? onProductServiceRegistered,
  void Function(CartService cartService)? onCartServiceRegistered,
  SheetResponse<T>? showCustomSheetResponse,
}) async {
  _registerService<NetworkService>(
    mockNetworkService ? MockNetworkService() : NetworkService(),
    onNetworkServiceRegistered,
  );

  _registerService<DatabaseService>(
    mockDatabaseService ? MockDatabaseService() : DatabaseService(),
    onDatabaseServiceRegistered,
  );

  _registerService<NavigationService>(
    mockNavigationService ? MockNavigationService() : NavigationService(),
    onNavigationServiceRegistered,
  );

  late final BottomSheetService bottomSheetService;

  if (mockBottomSheetService) {
    bottomSheetService = MockBottomSheetService();

    when((bottomSheetService as MockBottomSheetService).showCustomSheet<T, T>(
      enableDrag: anyNamed('enableDrag'),
      enterBottomSheetDuration: anyNamed('enterBottomSheetDuration'),
      exitBottomSheetDuration: anyNamed('exitBottomSheetDuration'),
      ignoreSafeArea: anyNamed('ignoreSafeArea'),
      isScrollControlled: anyNamed('isScrollControlled'),
      barrierDismissible: anyNamed('barrierDismissible'),
      additionalButtonTitle: anyNamed('additionalButtonTitle'),
      variant: anyNamed('variant'),
      title: anyNamed('title'),
      hasImage: anyNamed('hasImage'),
      imageUrl: anyNamed('imageUrl'),
      showIconInMainButton: anyNamed('showIconInMainButton'),
      mainButtonTitle: anyNamed('mainButtonTitle'),
      showIconInSecondaryButton: anyNamed('showIconInSecondaryButton'),
      secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
      showIconInAdditionalButton: anyNamed('showIconInAdditionalButton'),
      takesInput: anyNamed('takesInput'),
      barrierColor: anyNamed('barrierColor'),
      barrierLabel: anyNamed('barrierLabel'),
      customData: anyNamed('customData'),
      data: anyNamed('data'),
      description: anyNamed('description'),
    )).thenAnswer((realInvocation) =>
        Future.value(showCustomSheetResponse ?? SheetResponse<T>()));
  } else {
    bottomSheetService = BottomSheetService();
  }

  _registerService<BottomSheetService>(
    bottomSheetService,
    onBottomSheetServiceRegistered,
  );

  _registerService<DialogService>(
    mockDialogService ? MockDialogService() : DialogService(),
    onDialogServiceRegistered,
  );

  _registerService<ProductService>(
    mockProductService ? MockProductService() : ProductService(),
    onProductServiceRegistered,
  );

  _registerService<CartService>(
    mockCartService ? MockCartService() : CartService(),
    onCartServiceRegistered,
  );
}

Future<void> tearDownServices() async {
  await locator.reset();
}

void _registerService<T extends Object>(
  T service,
  void Function(T)? onRegistered,
) {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }

  locator.registerSingleton<T>(service);

  onRegistered?.call(service);
}

Future<void> Function(WidgetTester) testWidget(
  Future<void> Function(TestHelper helper) callback, {
  FutureOr<void> Function()? setUp,
  WidgetBuilder? screenBuilder,
  WidgetBuilder? scaffoldBodyBuilder,
  bool? settleAfterPump,
  bool? mockNetworkImage,
  bool? setUpDialogUi,
  bool? setUpBottomSheetUi,
}) {
  return (tester) async {
    Future<void> f() async {
      await setUp?.call();

      final helper = TestHelper(tester);

      if (setUpDialogUi ?? _setUpDialogUiAll == true) {
        setupDialogUi();
      }

      if (setUpBottomSheetUi ?? _setUpBottomSheetUiAll == true) {
        setupBottomSheetUi();
      }

      await helper.pumpApp(
        InitialTestScreen(
          screenBuilder: screenBuilder ?? _screenBuilderAll,
          scaffoldBodyBuilder: scaffoldBodyBuilder ?? _scaffoldBodyBuilderAll,
        ),
        settle: settleAfterPump ?? _settleAfterPumpAll ?? true,
      );

      await _onAppPumped?.call(helper);

      await callback(helper);

      await _onCallbackCalled?.call(helper);
    }

    if (mockNetworkImage ?? _mockNetworkImageAll == true) {
      await mockNetworkImagesFor(f);
    } else {
      await f();
    }
  };
}

class TestHelper {
  final WidgetTester tester;

  const TestHelper(this.tester);

  Future<void> pumpApp(
    Widget child, {
    bool settle = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        title: 'Flutter Stacked Test',
        home: child,
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        navigatorObservers: [
          StackedService.routeObserver,
        ],
      ),
    );

    if (settle) {
      await tester.pumpAndSettle();
    }
  }

  Future<void> settle() async {
    await tester.pumpAndSettle();
  }

  Future<void> wait({
    int days = 0,
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
    int milliseconds = 0,
    int microseconds = 0,
  }) async {
    await tester.pump(Duration(seconds: seconds));
  }

  T widgetByType<T extends Widget>({
    bool skipOffstage = true,
    void Function(T widget)? expecting,
  }) {
    final widget = _getWidget<T>(
      _findWidgetByType(T, findsOneWidget, skipOffstage: skipOffstage),
    );

    expecting?.call(widget);

    return widget;
  }

  List<T> nWidgetsByType<T extends Widget>(
    int n, {
    bool skipOffstage = true,
  }) {
    return _getWidgets(
      _findWidgetByType(T, findsNWidgets(n), skipOffstage: skipOffstage),
    );
  }

  T widgetByKey<T extends Widget>(
    Key key, {
    bool skipOffstage = true,
    void Function(T widget)? expecting,
  }) {
    final widget = _getWidget<T>(
      _findWidgetByKey(key, findsOneWidget, skipOffstage: skipOffstage),
    );

    expecting?.call(widget);

    return widget;
  }

  T widgetByValueKey<T extends Widget>(
    String value, {
    bool skipOffstage = true,
  }) {
    return widgetByKey(ValueKey(value), skipOffstage: skipOffstage);
  }

  Text text(
    String text, {
    bool skipOffstage = false,
    void Function(Text textWidget)? expecting,
  }) {
    final textWidget = _getWidget<Text>(
      _findWidget(
        () => find.text(text, skipOffstage: skipOffstage),
        findsOneWidget,
      ),
    );

    expecting?.call(textWidget);

    return textWidget;
  }

  void noWidgetByType(Type type, {bool skipOffstage = true}) {
    _findWidgetByType(type, findsNothing, skipOffstage: skipOffstage);
  }

  void noWidgetByKey(Key key, {bool skipOffstage = true}) {
    _findWidgetByKey(key, findsNothing, skipOffstage: skipOffstage);
  }

  void noWidgetByValueKey(String value, {bool skipOffstage = true}) {
    noWidgetByKey(ValueKey(value), skipOffstage: skipOffstage);
  }

  void noText(String text, {bool skipOffstage = true}) {
    _findWidget(
      () => find.text(text, skipOffstage: skipOffstage),
      findsNothing,
    );
  }

  T widgetWithText<T extends Widget>(
    String text, {
    bool skipOffstage = true,
    void Function(T widget)? expecting,
  }) {
    final widget = _getWidget<T>(
      _findWidget(
        () => find.widgetWithText(T, text, skipOffstage: skipOffstage),
        findsOneWidget,
      ),
    );

    expecting?.call(widget);

    return widget;
  }

  T descendant<T extends Widget>(
    Widget of, {
    bool skipOffstage = true,
    void Function(T widget)? expecting,
  }) {
    final widget = _getWidget<T>(
      _findWidget(
        () => find.descendant(
          of: find.byWidget(of, skipOffstage: skipOffstage),
          matching: find.byType(T, skipOffstage: skipOffstage),
          skipOffstage: skipOffstage,
        ),
        findsOneWidget,
      ),
    );

    expecting?.call(widget);

    return widget;
  }

  Text descendantText({
    required Widget of,
    required String text,
    bool skipOffstage = true,
    void Function(Text textWidget)? expecting,
  }) {
    final textWidget = _getWidget<Text>(
      _findWidget(
        () => find.descendant(
          of: find.byWidget(of, skipOffstage: skipOffstage),
          matching: find.text(text, skipOffstage: skipOffstage),
          skipOffstage: skipOffstage,
        ),
        findsOneWidget,
      ),
    );

    expecting?.call(textWidget);

    return textWidget;
  }

  Future<void> tap(
    Type type, {
    bool skipOffstage = true,
    bool warnIfMissed = false,
    bool pumpAndSettle = true,
    bool ensureVisible = false,
  }) {
    final skipOff = ensureVisible ? false : skipOffstage;

    return _tap(
      find.byType(type, skipOffstage: skipOff),
      ensureVisible: ensureVisible,
      warnIfMissed: warnIfMissed,
      pumpAndSettle: pumpAndSettle,
    );
  }

  Future<void> tapWithValueKey(
    String value, {
    bool skipOffstage = true,
    bool warnIfMissed = false,
    bool pumpAndSettle = true,
    bool ensureVisible = false,
  }) {
    final skipOff = ensureVisible ? false : skipOffstage;

    return _tap(
      find.byKey(ValueKey(value), skipOffstage: skipOff),
      ensureVisible: ensureVisible,
      warnIfMissed: warnIfMissed,
      pumpAndSettle: pumpAndSettle,
    );
  }

  Future<void> tapWidget(
    Widget widget, {
    bool skipOffstage = true,
    bool warnIfMissed = false,
    bool pumpAndSettle = true,
    bool ensureVisible = false,
  }) {
    final skipOff = ensureVisible ? false : skipOffstage;

    return _tap(
      find.byWidget(widget, skipOffstage: skipOff),
      ensureVisible: ensureVisible,
      warnIfMissed: warnIfMissed,
      pumpAndSettle: pumpAndSettle,
    );
  }

  Future<void> enterText(
    Widget widget,
    String text, {
    bool skipOffstage = true,
    bool warnIfMissed = false,
    bool pumpAndSettle = true,
  }) async {
    await tester.enterText(
      find.byWidget(widget, skipOffstage: skipOffstage),
      text,
    );

    if (pumpAndSettle) {
      await tester.pumpAndSettle();
    }
  }

  Future<void> enterTextWithValueKey(
    String value,
    String text, {
    bool skipOffstage = true,
    bool warnIfMissed = false,
    bool pumpAndSettle = true,
  }) async {
    await tester.enterText(
      find.byKey(ValueKey(value), skipOffstage: skipOffstage),
      text,
    );

    if (pumpAndSettle) {
      await tester.pumpAndSettle();
    }
  }

  BuildContext getBuildContext(Type type) {
    return tester.element(find.byType(type));
  }

  ThemeData getTheme(Type type) {
    final context = getBuildContext(type);

    return Theme.of(context);
  }

  NavigatorState getNavigator() {
    return tester.state(find.byType(Navigator));
  }

  Future<void> ensureVisible(String keyValue) async {
    await tester.ensureVisible(find.byKey(ValueKey(keyValue)));
    await tester.pumpAndSettle();
  }

  Future<void> _tap(
    Finder finder, {
    bool warnIfMissed = true,
    bool pumpAndSettle = true,
    bool ensureVisible = true,
  }) async {
    if (ensureVisible) {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
    }

    await tester.tap(
      finder,
      warnIfMissed: warnIfMissed,
    );

    if (pumpAndSettle) {
      await tester.pumpAndSettle();
    }
  }

  Finder _findWidget(Finder Function() finderFn, Matcher matcher) {
    final widgetFinder = finderFn();
    expect(widgetFinder, matcher);

    return widgetFinder;
  }

  Finder _findWidgetByType(
    Type type,
    Matcher matcher, {
    bool skipOffstage = true,
  }) {
    return _findWidget(
      () => find.byType(type, skipOffstage: skipOffstage),
      matcher,
    );
  }

  Finder _findWidgetByKey(
    Key key,
    Matcher matcher, {
    bool skipOffstage = true,
  }) {
    return _findWidget(
      () => find.byKey(key, skipOffstage: skipOffstage),
      matcher,
    );
  }

  T _getWidget<T extends Widget>(Finder finder) {
    return tester.widget<T>(finder);
  }

  List<T> _getWidgets<T extends Widget>(Finder finder) {
    return tester.widgetList<T>(finder).toList();
  }
}

class InitialTestScreen extends StatelessWidget {
  final WidgetBuilder? screenBuilder;
  final WidgetBuilder? scaffoldBodyBuilder;

  const InitialTestScreen({
    super.key,
    this.screenBuilder,
    this.scaffoldBodyBuilder,
  })  : assert(screenBuilder != null || scaffoldBodyBuilder != null,
            'Must provide at leas one builder'),
        assert(screenBuilder == null || scaffoldBodyBuilder == null,
            'Only one builder must be provided');

  @override
  Widget build(BuildContext context) {
    return screenBuilder?.call(context) ??
        Scaffold(body: Builder(builder: scaffoldBodyBuilder!));
  }
}
