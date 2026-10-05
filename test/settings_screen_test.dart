import 'package:arunstore/screen/settings/app_preferences.dart';
import 'package:arunstore/screen/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('language and theme persist and apply to both policy pages', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await SharedPreferences.getInstance();
    final preferences = AppPreferences(storage);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: preferences,
        child: Consumer<AppPreferences>(
          builder: (context, prefs, _) => MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: prefs.isDark ? ThemeMode.dark : ThemeMode.light,
            home: const SettingsScreen(),
          ),
        ),
      ),
    );
    await tester.tap(find.text('தமிழ்'));
    await tester.pumpAndSettle();
    expect(find.text('அமைப்புகள்'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(SettingsScreen))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.text('தனியுரிமைக் கொள்கை'));
    await tester.pumpAndSettle();
    expect(find.text('இந்தக் கொள்கை பற்றி'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('விதிமுறைகள் மற்றும் நிபந்தனைகள்'));
    await tester.pumpAndSettle();
    expect(find.text('எங்கள் சேவையைப் பயன்படுத்துதல்'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final restored = AppPreferences(storage);
    expect(restored.isTamil, isTrue);
    expect(restored.isDark, isTrue);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(SettingsScreen))).brightness,
      Brightness.light,
    );
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.text('About this policy'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terms & Conditions'));
    await tester.pumpAndSettle();
    expect(find.text('Using our service'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
