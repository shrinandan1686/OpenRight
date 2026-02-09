import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:openright/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End User Flow', () {
    testWidgets('Complete link creation and copy flow', (WidgetTester tester) async {
      // Launch app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify we're on the home screen
      expect(find.text('OpenRight'), findsOneWidget);
      expect(find.text('Create Smart Link'), findsOneWidget);

      // Find the text input field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter a valid YouTube URL
      const testUrl = 'https://youtube.com/watch?v=dQw4w9WgXcQ';
      await tester.enterText(textField, testUrl);
      await tester.pumpAndSettle();

      // Verify button is now enabled (find the filled button)
      final createButton = find.text('Create Smart Link');
      expect(createButton, findsOneWidget);

      // Tap the create button
      await tester.tap(createButton);
      await tester.pump();

      // Wait for loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for navigation to success screen (with timeout)
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verify we're on the success screen
      expect(find.text('Link Created!'), findsOneWidget);
      expect(find.text('Copy Link'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);

      // Verify a short URL is displayed
      final shortUrlFinder = find.textContaining('links.travelerstab.com');
      expect(shortUrlFinder, findsOneWidget);

      // Tap the copy button
      final copyButton = find.text('Copy Link');
      await tester.tap(copyButton);
      await tester.pump();

      // Verify copied feedback
      expect(find.text('Copied!'), findsOneWidget);
      expect(find.text('Link copied to clipboard!'), findsOneWidget);

      // Wait for copied state to reset
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Copy Link'), findsOneWidget);

      // Tap "Create Another Link" to go back
      final createAnotherButton = find.text('Create Another Link');
      await tester.tap(createAnotherButton);
      await tester.pumpAndSettle();

      // Verify we're back on home screen
      expect(find.text('OpenRight'), findsOneWidget);
      expect(find.text('Create Smart Link'), findsOneWidget);
    });

    testWidgets('Error handling for invalid URL', (WidgetTester tester) async {
      // Launch app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Find the text input field
      final textField = find.byType(TextField);

      // Enter an invalid URL
      await tester.enterText(textField, 'https://google.com');
      await tester.pumpAndSettle();

      // Tap the create button
      final createButton = find.text('Create Smart Link');
      await tester.tap(createButton);
      await tester.pump();

      // Verify error message appears
      expect(find.textContaining('valid YouTube URL'), findsOneWidget);

      // Verify we're still on home screen
      expect(find.text('OpenRight'), findsOneWidget);
    });

    testWidgets('Paste button functionality', (WidgetTester tester) async {
      // Launch app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Find paste button icon
      final pasteButton = find.byIcon(Icons.content_paste);
      expect(pasteButton, findsOneWidget);

      // Tap paste button
      await tester.tap(pasteButton);
      await tester.pumpAndSettle();

      // Note: Actual clipboard interaction requires platform channels
      // This test just verifies the button is tappable
    });
  });
}
