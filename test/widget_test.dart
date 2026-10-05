import 'package:arunstore/authmanager.dart';
import 'package:arunstore/main.dart';
import 'package:arunstore/screen/loginscreen.dart';
import 'package:arunstore/screen/settings/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'app restores Tamil and changes language without replacing the open route',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({'app_language': 'ta'});
      final preferences = AppPreferences(await SharedPreferences.getInstance());
      final auth = AuthManager();
      await auth.initialize();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: preferences),
            ChangeNotifierProvider.value(value: auth),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('மீண்டும் வருக!'), findsOneWidget);
      final loginState = tester.state(find.byType(LoginScreen));
      final loginContext = tester.element(find.byType(LoginScreen));
      expect(Localizations.localeOf(loginContext).languageCode, 'ta');
      final tamilBackLabel = MaterialLocalizations.of(
        loginContext,
      ).backButtonTooltip;
      await preferences.setLanguage(false);
      await tester.pumpAndSettle();
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(tester.state(find.byType(LoginScreen)), same(loginState));
      expect(Localizations.localeOf(loginContext).languageCode, 'en');
      expect(
        MaterialLocalizations.of(loginContext).backButtonTooltip,
        isNot(tamilBackLabel),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
