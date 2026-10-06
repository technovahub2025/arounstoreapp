import 'package:arunstore/screen/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('recovery explains SMS verification and validates phone', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
    expect(find.textContaining('six-digit SMS code'), findsOneWidget);
    await tester.tap(find.text('Send SMS code'));
    await tester.pump();
    expect(find.text('Enter a valid Indian mobile number'), findsOneWidget);
    expect(find.text('Update password'), findsNothing);
  });
}
