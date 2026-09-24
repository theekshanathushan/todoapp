// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todoapp/main.dart';

void main() {
  testWidgets('ToDo App renders items and handles add, search, and delete', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Initial items are present
    expect(find.text('ALL TODOS'), findsOneWidget);
    expect(find.text('Evening Gym'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);

    // 2. Add a new item "hi"
    await tester.enterText(find.widgetWithText(TextField, 'Add New To Do'), 'hi');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // "hi" should now be in the list
    expect(find.text('hi'), findsOneWidget);

    // 3. Search for "Lunch"
    await tester.enterText(find.widgetWithText(TextField, 'Search'), 'Lunch');
    await tester.pumpAndSettle();

    // Only "Lunch" should be displayed in the list
    expect(find.widgetWithText(ListTile, 'Lunch'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Evening Gym'), findsNothing);

    // Clear search
    await tester.enterText(find.widgetWithText(TextField, 'Search'), '');
    await tester.pumpAndSettle();
    expect(find.text('Evening Gym'), findsOneWidget);

    // 4. Toggle check status
    final gymFinder = find.widgetWithText(ListTile, 'Evening Gym');
    await tester.tap(gymFinder);
    await tester.pumpAndSettle();

    // 5. Delete "Lunch"
    final lunchFinder = find.widgetWithText(ListTile, 'Lunch');
    final deleteBtn = find.descendant(of: lunchFinder, matching: find.byIcon(Icons.delete));
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Lunch'), findsNothing);
  });
}
