import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
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
void registerServices() {
  getAndRegisterNavigationService();
  getAndRegisterBottomSheetService();
  getAndRegisterDialogService();
  getAndRegisterProductService();
  getAndRegisterNetworkService();
  getAndRegisterCartService();
  getAndRegisterDatabaseService();
// @stacked-mock-register
}

MockNavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

MockBottomSheetService getAndRegisterBottomSheetService<T>({
  SheetResponse<T>? showCustomSheetResponse,
}) {
  _removeRegistrationIfExists<BottomSheetService>();
  final service = MockBottomSheetService();

  when(service.showCustomSheet<T, T>(
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

  locator.registerSingleton<BottomSheetService>(service);
  return service;
}

MockDialogService getAndRegisterDialogService() {
  _removeRegistrationIfExists<DialogService>();
  final service = MockDialogService();
  locator.registerSingleton<DialogService>(service);
  return service;
}

MockProductService getAndRegisterProductService() {
  _removeRegistrationIfExists<ProductService>();
  final service = MockProductService();
  locator.registerSingleton<ProductService>(service);
  return service;
}

MockNetworkService getAndRegisterNetworkService() {
  _removeRegistrationIfExists<NetworkService>();
  final service = MockNetworkService();
  locator.registerSingleton<NetworkService>(service);
  return service;
}

MockCartService getAndRegisterCartService() {
  _removeRegistrationIfExists<CartService>();
  final service = MockCartService();
  locator.registerSingleton<CartService>(service);
  return service;
}

MockDatabaseService getAndRegisterDatabaseService() {
  _removeRegistrationIfExists<DatabaseService>();
  final service = MockDatabaseService();
  locator.registerSingleton<DatabaseService>(service);
  return service;
}
// @stacked-mock-create

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}

Future<void> Function(TestHelper helper)? _setUpFn;
Widget Function()? _setUpScreen;
Widget Function(BuildContext)? _setUpScaffoldBody;
Future<void> Function(TestHelper helper)? _tearDownFn;

class InitialTestScreen extends StatelessWidget {
  final Widget Function()? screen;
  final Widget Function(BuildContext)? scaffoldBody;

  const InitialTestScreen({super.key, this.screen, this.scaffoldBody})
      : assert(screen != null || scaffoldBody != null);

  @override
  Widget build(BuildContext context) {
    return screen != null
        ? screen!()
        : Scaffold(
            body: scaffoldBody!(context),
          );
  }
}

Future<void> Function(WidgetTester) testWidget(
  Future<void> Function(TestHelper helper) callback, {
  FutureOr<void> Function()? setUp,
  Widget Function()? screen,
  Widget Function(BuildContext)? scaffoldBody,
  bool wait = true,
  bool settle = true,
}) {
  return (tester) async {
    await setUp?.call();

    final helper = TestHelper(tester);

    await helper.pumpApp(
      InitialTestScreen(
        screen: screen ?? _setUpScreen,
        scaffoldBody: scaffoldBody ?? _setUpScaffoldBody,
      ),
      wait: wait,
      settle: settle,
    );

    if (_setUpFn != null) {
      await _setUpFn!(helper);
    }

    await callback(helper);

    if (_tearDownFn != null) {
      await _tearDownFn!(helper);
    }
  };
}

class TestHelper {
  final WidgetTester tester;

  const TestHelper(this.tester);

  static void setUp({
    Future<void> Function(TestHelper helper)? onInit,
    Future<void> Function(TestHelper helper)? onTearDown,
    Widget Function()? screen,
    Widget Function(BuildContext)? scaffoldBody,
  }) {
    _setUpFn = onInit;
    _tearDownFn = onTearDown;
    _setUpScreen = screen;
    _setUpScaffoldBody = scaffoldBody;
  }

  static Future<void> initApp<T extends Object>({
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
    _removeRegistrationIfExists<NetworkService>();
    final networkService =
        mockNetworkService ? MockNetworkService() : NetworkService();
    locator.registerSingleton<NetworkService>(networkService);
    onNetworkServiceRegistered?.call(networkService);

    _removeRegistrationIfExists<DatabaseService>();
    final databaseService =
        mockDatabaseService ? MockDatabaseService() : DatabaseService();
    locator.registerSingleton<DatabaseService>(databaseService);
    onDatabaseServiceRegistered?.call(databaseService);

    _removeRegistrationIfExists<NavigationService>();
    final navigationService =
        mockNavigationService ? MockNavigationService() : NavigationService();
    locator.registerSingleton<NavigationService>(navigationService);
    onNavigationServiceRegistered?.call(navigationService);

    _removeRegistrationIfExists<BottomSheetService>();
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
    locator.registerSingleton<BottomSheetService>(bottomSheetService);
    onBottomSheetServiceRegistered?.call(bottomSheetService);

    _removeRegistrationIfExists<DialogService>();
    final dialogService =
        mockDialogService ? MockDialogService() : DialogService();
    locator.registerSingleton<DialogService>(dialogService);
    onDialogServiceRegistered?.call(dialogService);

    _removeRegistrationIfExists<ProductService>();
    final productService =
        mockProductService ? MockProductService() : ProductService();
    locator.registerSingleton<ProductService>(productService);
    onProductServiceRegistered?.call(productService);

    _removeRegistrationIfExists<CartService>();
    final cartService = mockCartService ? MockCartService() : CartService();
    locator.registerSingleton<CartService>(cartService);
    onCartServiceRegistered?.call(cartService);
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

  Future<void> pumpApp(
    Widget child, {
    bool wait = true,
    bool settle = true,
  }) async {
    await tester.pumpWidget(MockFlutterTestStackedApp(child: child));

    if (wait) {
      await this.wait(seconds: 20);
    }

    if (settle) {
      await this.settle();
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

class MockFlutterTestStackedApp extends StatelessWidget {
  final Widget child;

  const MockFlutterTestStackedApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Stacked',
      theme: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Mulish',
            ),
      ),
      home: child,
    );
  }
}
