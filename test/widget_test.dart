import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyflow/app.dart';
import 'package:studyflow/models/assignment.dart';
import 'package:studyflow/services/storage_service.dart';

void main() {
  testWidgets('new study spaces are empty and settings has no sample loader',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.initialize();

    await tester.pumpWidget(StudyFlowApp(storage: storage));
    await tester.pumpAndSettle();

    expect(find.text('0% complete'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('No study blocks planned'), 300);
    expect(find.text('No study blocks planned'), findsOneWidget);
    expect(find.text('Chapter 4 problem set'), findsNothing);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    expect(find.text('Load sample study data'), findsNothing);
  });

  testWidgets('a scheduled block starts a timer for its duration',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.initialize();

    await tester.pumpWidget(StudyFlowApp(storage: storage));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add study block'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Reading');
    await tester.tap(find.text('Save study block'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start timer'));
    await tester.pumpAndSettle();

    expect(find.text('30:00'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
  });

  testWidgets('previously loaded demo assignments are removed on launch',
      (WidgetTester tester) async {
    final oldExample = Assignment(
      id: 'a1',
      title: 'Chapter 4 problem set',
      subject: 'Mathematics',
      dueDate: DateTime(2026, 10, 29),
      priority: AssignmentPriority.high,
      notes: 'Complete questions 1–12',
      createdAt: DateTime(2026, 10, 28),
    );
    SharedPreferences.setMockInitialValues({
      'assignments': jsonEncode([oldExample.toJson()]),
    });
    final storage = StorageService();
    await storage.initialize();

    await tester.pumpWidget(StudyFlowApp(storage: storage));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();

    expect(find.text('Chapter 4 problem set'), findsNothing);
    expect(find.text('No assignments found'), findsOneWidget);
  });
}
