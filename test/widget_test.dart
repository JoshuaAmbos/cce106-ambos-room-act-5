import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ambos_navigation_app/main.dart';
import 'package:ambos_navigation_app/demo_auth.dart';
import 'package:ambos_navigation_app/social_media/create_post_sheet.dart';

void main() {
  setUp(() {
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
    DemoAuth.currentUsername = null;
  });

  Future<void> loginAsAdmin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentApp());
    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
  }

  Future<void> openSocialMedia(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(NavigationDestination, 'Social Media'));
    await tester.pumpAndSettle();
  }

  testWidgets('Test 1: Log in using the default admin account opens MainScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StudentApp());

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome Back!'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome, Student!'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('Bottom navigation switches tabs and preserves calculator state',
      (WidgetTester tester) async {
    await loginAsAdmin(tester);

    // 1. Home tab is active
    expect(find.text('Welcome, Student!'), findsOneWidget);

    // 2. Switch to Calculator tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Calculator'));
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
    await tester.tap(find.widgetWithText(NavigationDestination, 'Profile'));
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);

    // 4. Switch back to Calculator tab and verify preserved state (15.0)
    await tester.tap(find.widgetWithText(NavigationDestination, 'Calculator'));
    await tester.pumpAndSettle();

    expect(find.text('15.0'), findsOneWidget);
  });

  testWidgets('Test 2: Open Social Media and sample posts appear',
      (WidgetTester tester) async {
    await loginAsAdmin(tester);
    await openSocialMedia(tester);

    expect(find.text('Social Media'), findsWidgets);
    expect(find.text('JohnDoe'), findsOneWidget);
    expect(find.text('Enjoying the sunny weather!'), findsOneWidget);
  });

  testWidgets('Test 3: Submit a post with empty fields shows validation message',
      (WidgetTester tester) async {
    await loginAsAdmin(tester);
    await openSocialMedia(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Create Post'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pump();

    expect(
      find.text('Complete both fields before submitting!'),
      findsOneWidget,
    );
  });

  testWidgets('Test 4: Submit a post with an invalid URL shows URL validation message',
      (WidgetTester tester) async {
    await loginAsAdmin(tester);
    await openSocialMedia(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final fields = find.descendant(
      of: find.byType(CreatePostSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'My caption');
    await tester.enterText(fields.at(1), 'invalid_url');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pump();

    expect(
      find.text('Enter a valid HTTP or HTTPS image URL.'),
      findsOneWidget,
    );
  });

  testWidgets('Test 5: Submit a valid post appears at the top with logged-in username',
      (WidgetTester tester) async {
    await loginAsAdmin(tester);
    await openSocialMedia(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final fields = find.descendant(
      of: find.byType(CreatePostSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'My first Flutter social media post!');
    await tester.enterText(fields.at(1), 'https://picsum.photos/id/20/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    expect(find.text('My first Flutter social media post!'), findsOneWidget);
    expect(find.text('admin'), findsOneWidget);
  });

  testWidgets('Test 6: Tap Like twice toggles liked state',
      (WidgetTester tester) async {
    await loginAsAdmin(tester);
    await openSocialMedia(tester);

    // Initial state: Like
    final likeButton = find.widgetWithText(TextButton, 'Like').first;
    expect(likeButton, findsOneWidget);

    // First tap -> Liked
    await tester.tap(likeButton);
    await tester.pump();
    expect(find.widgetWithText(TextButton, 'Liked').first, findsOneWidget);

    // Second tap -> Like
    await tester.tap(find.widgetWithText(TextButton, 'Liked').first);
    await tester.pump();
    expect(find.widgetWithText(TextButton, 'Like').first, findsOneWidget);
  });

  testWidgets('Test 7: Add a nonempty comment increases count and displays comment',
      (WidgetTester tester) async {
    await loginAsAdmin(tester);
    await openSocialMedia(tester);

    expect(find.text('0 Comments').first, findsOneWidget);

    // Scroll up slightly so the bottom of the first card is fully visible
    await tester.drag(find.byType(ListView).last, const Offset(0, -120));
    await tester.pumpAndSettle();

    final commentField = find.widgetWithText(TextField, 'Add a comment...').first;
    final sendButton = find.byTooltip('Send comment').first;

    await tester.enterText(commentField, 'Awesome picture!');
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    expect(find.text('1 Comments'), findsOneWidget);
    expect(find.text('Awesome picture!'), findsOneWidget);
  });

  testWidgets('Test 8: Submit a blank comment does not add a comment',
      (WidgetTester tester) async {
    await loginAsAdmin(tester);
    await openSocialMedia(tester);

    expect(find.text('0 Comments').first, findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -120));
    await tester.pumpAndSettle();

    final commentField = find.widgetWithText(TextField, 'Add a comment...').first;
    final sendButton = find.byTooltip('Send comment').first;

    await tester.enterText(commentField, '   ');
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    expect(find.text('0 Comments').first, findsOneWidget);
  });

  testWidgets('Test 9: Like a sample post, then create another post preserves liked state',
      (WidgetTester tester) async {
    await loginAsAdmin(tester);
    await openSocialMedia(tester);

    // Like first post
    await tester.tap(find.widgetWithText(TextButton, 'Like').first);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextButton, 'Liked'), findsOneWidget);

    // Create a new post
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final fields = find.descendant(
      of: find.byType(CreatePostSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'Brand New Post');
    await tester.enterText(fields.at(1), 'https://picsum.photos/id/30/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    // Check that the liked state on the original post is retained
    expect(find.widgetWithText(TextButton, 'Liked'), findsOneWidget);
  });

  testWidgets('Test 10: Switch to Home and return preserves feed state',
      (WidgetTester tester) async {
    await loginAsAdmin(tester);
    await openSocialMedia(tester);

    // Like first post and add a comment
    await tester.tap(find.widgetWithText(TextButton, 'Like').first);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).last, const Offset(0, -120));
    await tester.pumpAndSettle();

    final commentField = find.widgetWithText(TextField, 'Add a comment...').first;
    final sendButton = find.byTooltip('Send comment').first;
    await tester.enterText(commentField, 'Preserved comment');
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    // Switch to Home
    await tester.tap(find.widgetWithText(NavigationDestination, 'Home'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Student!'), findsOneWidget);

    // Return to Social Media
    await tester.tap(find.widgetWithText(NavigationDestination, 'Social Media'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextButton, 'Liked'), findsOneWidget);
    expect(find.text('Preserved comment'), findsOneWidget);
    expect(find.text('1 Comments'), findsOneWidget);
  });

  testWidgets('Test 11: Log out, register, and log in with a new account uses new username',
      (WidgetTester tester) async {
    await loginAsAdmin(tester);

    // Navigate to Profile and tap Logout in AppBar
    await tester.tap(find.widgetWithText(NavigationDestination, 'Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);

    // Register a new user
    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();

    final regFields = find.byType(TextFormField);
    await tester.enterText(regFields.at(0), 'joshua123');
    await tester.enterText(regFields.at(1), 'secret456');
    await tester.enterText(regFields.at(2), 'secret456');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Log in with new account
    final loginFields = find.byType(TextFormField);
    await tester.enterText(loginFields.at(0), 'joshua123');
    await tester.enterText(loginFields.at(1), 'secret456');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome, Student!'), findsOneWidget);

    // Create a post and verify it has username 'joshua123'
    await openSocialMedia(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final fields = find.descendant(
      of: find.byType(CreatePostSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'My new account post!');
    await tester.enterText(fields.at(1), 'https://picsum.photos/id/50/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    expect(find.text('My new account post!'), findsOneWidget);
    expect(find.text('joshua123'), findsOneWidget);
  });
}
