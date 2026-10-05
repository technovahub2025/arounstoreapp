import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/screen/loginscreen.dart';
import 'package:arunstore/screen/registerscreen.dart';
import 'package:arunstore/screen/settings/app_preferences.dart';
import 'package:arunstore/screen/widgets/checkout_widgets.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget harness(AppPreferences prefs, Widget screen) {
  return ChangeNotifierProvider.value(
    value: prefs,
    child: Consumer<AppPreferences>(
      builder: (_, preferences, _) => MaterialApp(
        theme: AppTheme.lightTheme,
        locale: Locale(preferences.isTamil ? 'ta' : 'en'),
        supportedLocales: const [Locale('en'), Locale('ta')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: screen,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'translates dynamic copy while preserving names and transaction IDs',
    () {
      expect(
        translate('Added Green Tea to cart', tamil: true),
        'Green Tea கூடையில் சேர்க்கப்பட்டது',
      );
      expect(
        translate('Order ID: order_ABC123', tamil: true),
        'ஆர்டர் எண்: order_ABC123',
      );
      expect(
        translate('2 products found', tamil: true),
        '2 பொருட்கள் கிடைத்தன',
      );
      expect(
        translate('Full Name is required.', tamil: true),
        'முழுப் பெயர் கட்டாயம்.',
      );
      expect(translate('Green Tea', tamil: true), 'Green Tea');
      expect(translate('Home', tamil: false), 'Home');
    },
  );

  test(
    'migrates previous language preference and restores app-wide choice',
    () async {
      SharedPreferences.setMockInitialValues({'policy_language': 'ta'});
      final storage = await SharedPreferences.getInstance();
      final preferences = AppPreferences(storage);
      expect(preferences.isTamil, isTrue);
      await preferences.setLanguage(false);
      expect(storage.getString('app_language'), 'en');
      expect(AppPreferences(storage).isTamil, isFalse);
    },
  );

  testWidgets(
    'checkout labels and existing validation errors update without clearing input',
    (tester) async {
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        harness(
          prefs,
          Scaffold(
            body: Form(
              key: formKey,
              child: CheckoutTextField(
                controller: controller,
                label: 'Full Name',
                hintText: 'Enter your full name',
                validator: (_) => 'Please enter your name',
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), 'Kumar');
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Please enter your name'), findsOneWidget);
      await prefs.setLanguage(true);
      await tester.pumpAndSettle();
      expect(find.text('உங்கள் பெயரை உள்ளிடவும்'), findsOneWidget);
      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.controller!.text, 'Kumar');
      expect(find.text('முழுப் பெயர்'), findsOneWidget);
      expect(
        Localizations.localeOf(tester.element(find.byType(Form))).languageCode,
        'ta',
      );
      await prefs.setLanguage(false);
      await tester.pumpAndSettle();
      expect(find.text('Please enter your name'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );

  testWidgets('login and reset-password dialog translate on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final prefs = AppPreferences(await SharedPreferences.getInstance());
    await tester.pumpWidget(harness(prefs, const LoginScreen()));
    await tester.pumpAndSettle();
    await prefs.setLanguage(true);
    await tester.pumpAndSettle();
    expect(find.text('மீண்டும் வருக!'), findsOneWidget);
    final forgot = find.text('கடவுச்சொல் மறந்துவிட்டதா?');
    await tester.ensureVisible(forgot);
    await tester.tap(forgot);
    await tester.pumpAndSettle();
    expect(find.text('கடவுச்சொல்லை மீட்டமைக்கவும்'), findsOneWidget);
    await prefs.setLanguage(false);
    await tester.pumpAndSettle();
    expect(find.text('Reset password'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'registration labels and validation are Tamil on a narrow screen',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      await prefs.setLanguage(true);
      await tester.pumpWidget(harness(prefs, const RegisterScreen()));
      await tester.pumpAndSettle();
      final form = tester.state<FormState>(find.byType(Form));
      form.validate();
      await tester.pumpAndSettle();
      expect(find.text('உங்கள் பெயரை உள்ளிடவும்'), findsOneWidget);
      expect(find.text('உங்கள் தொலைபேசி எண்ணை உள்ளிடவும்'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );
}
