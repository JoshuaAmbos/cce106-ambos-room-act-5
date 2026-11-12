import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ambos_navigation_app/main.dart';
import 'package:ambos_navigation_app/demo_auth.dart';

void main() {
  setUp(() {
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
  });

  testWidgets('App starts at LoginScreen and allows admin login',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StudentApp());

    // Verify Login Screen is displayed
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Try logging in with admin credentials
    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Now in MainScreen with Home page
    expect(find.text('Welcome, Student!'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('Bottom navigation switches tabs and preserves calculator state',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StudentApp());

    // Login
    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // 1. Home tab is active
    expect(find.text('Welcome, Student!'), findsOneWidget);

    // 2. Switch to Calculator tab
    await tester.tap(find.text('Calculator').last);
    await tester.pumpAndSettle();

    expect(find.text('BASIC CALCULATOR'), findsOneWidget);

    // Enter numbers into calculator: 10 + 5 = 15
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), '10');
    await tester.enterText(textFields.at(1), '5');
    await tester.tap(find.widgetWithText(ElevatedButton, '+'));
    await tester.pumpAndSettle();

    expect(find.text('15.0'), findsOneWidget);

    // 3. Switch to Profile tab
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Joshua Ambos'), findsOneWidget);
    expect(find.text('554298'), findsOneWidget);

    // 4. Switch to Social Media tab
    await tester.tap(find.text('Social Media').last);
    await tester.pumpAndSettle();

    expect(find.text('Connect With Me'), findsOneWidget);
    expect(find.text('Facebook'), findsOneWidget);

    // Tap Facebook card and verify SnackBar
    await tester.tap(find.text('Facebook'));
    await tester.pump();
    expect(find.text('Selected account: Facebook: student.sample'), findsOneWidget);

    // 5. Switch back to Calculator tab and verify preserved state (15.0)
    await tester.tap(find.text('Calculator').last);
    await tester.pumpAndSettle();

    expect(find.text('15.0'), findsOneWidget);
  });

  testWidgets('User registration and login flow', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentApp());

    // Navigate to register screen
    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();

    expect(find.text('Create an Account'), findsOneWidget);

    // Fill registration form
    final regFields = find.byType(TextFormField);
    await tester.enterText(regFields.at(0), 'student1');
    await tester.enterText(regFields.at(1), 'password123');
    await tester.enterText(regFields.at(2), 'password123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    // Returned to Login screen
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Log in with newly created account
    final loginFields = find.byType(TextFormField);
    await tester.enterText(loginFields.at(0), 'student1');
    await tester.enterText(loginFields.at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Verify MainScreen reached
    expect(find.text('Welcome, Student!'), findsOneWidget);
  });
}
