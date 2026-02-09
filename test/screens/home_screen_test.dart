import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openright/screens/home_screen.dart';
import 'package:openright/main.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('displays app title and input field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Verify app title is displayed
      expect(find.text('OpenRight'), findsOneWidget);
      
      // Verify subtitle
      expect(find.textContaining('Smart link'), findsOneWidget);
      
      // Verify input field placeholder
      expect(find.textContaining('Paste YouTube URL'), findsOneWidget);
      
      // Verify create button exists
      expect(find.text('Create Smart Link'), findsOneWidget);
    });

    testWidgets('paste button triggers clipboard paste', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Find paste button icon
      final pasteButton = find.byIcon(Icons.content_paste);
      expect(pasteButton, findsOneWidget);
      
      // Tap paste button
      await tester.tap(pasteButton);
      await tester.pump();
      
      // Note: Actual clipboard interaction requires platform channels
      // This test just verifies the button exists and can be tapped
    });

    testWidgets('clear button appears after text input', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Enter some text
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'https://youtube.com/watch?v=test');
      await tester.pump();

      // Clear button should appear
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);
      
      // Tap clear button
      await tester.tap(clearButton);
      await tester.pump();
      
      // Text field should be empty
      final TextField textFieldWidget = tester.widget(textField);
      expect(textFieldWidget.controller?.text, isEmpty);
    });

    testWidgets('shows error for invalid URL', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Enter invalid URL
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'https://google.com');
      await tester.pump();

      // Tap create button
      final createButton = find.text('Create Smart Link');
      await tester.tap(createButton);
      await tester.pump();

      // Error message should appear
      expect(find.textContaining('Invalid YouTube URL'), findsOneWidget);
    });

    testWidgets('create button is disabled when empty', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Find the create button
      final createButton = find.widgetWithText(FilledButton, 'Create Smart Link');
      expect(createButton, findsOneWidget);

      // Button should exist (we can't easily test if it's disabled without tapping)
      final FilledButton button = tester.widget(createButton);
      expect(button.onPressed, isNull); // Disabled buttons have null onPressed
    });

    testWidgets('shows loading indicator when creating link', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Enter valid URL
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'https://youtube.com/watch?v=dQw4w9WgXcQ');
      await tester.pump();

      // Tap create button
      final createButton = find.text('Create Smart Link');
      await tester.tap(createButton);
      await tester.pump(); // Start of async operation

      // Loading indicator should appear
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Note: The actual API call will happen, so we need to wait or mock
      await tester.pumpAndSettle();
    }, skip: true); // Requires API mocking
  });
}
