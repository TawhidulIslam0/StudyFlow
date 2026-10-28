import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyflow/models/assignment.dart';
import 'package:studyflow/models/flashcard.dart';
import 'package:studyflow/models/study_session.dart';
import 'package:studyflow/services/storage_service.dart';

void main() {
  test('new storage starts with empty user data', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.initialize();

    expect(storage.loadAssignments(), isEmpty);
    expect(storage.loadSessions(), isEmpty);
    expect(storage.loadDecks(), isEmpty);
  });

  test('storage removes old built-in assignments but preserves user assignments',
      () async {
    SharedPreferences.setMockInitialValues({
      'assignments': jsonEncode([
        {
          'id': 'a1',
          'title': 'Chapter 4 problem set',
          'subject': 'Mathematics',
          'dueDate': '2026-10-29T00:00:00.000',
          'priority': 'high',
          'notes': 'Complete questions 1–12',
          'isCompleted': false,
          'createdAt': '2026-10-28T00:00:00.000',
        },
        {
          'id': 'custom-id',
          'title': 'My assignment',
          'subject': 'Biology',
          'dueDate': '2026-10-30T00:00:00.000',
          'priority': 'medium',
          'notes': '',
          'isCompleted': false,
          'createdAt': '2026-10-28T00:00:00.000',
        },
      ]),
    });
    final storage = StorageService();
    await storage.initialize();

    expect(storage.loadAssignments().map((item) => item.title), ['My assignment']);
    final preferences = await SharedPreferences.getInstance();
    expect(jsonDecode(preferences.getString('assignments')!), hasLength(1));
  });

  test('assignment JSON round trip preserves completion and priority', () {
    final assignment = Assignment(
      id: 'a1',
      title: 'Read chapter',
      subject: 'Biology',
      dueDate: DateTime(2026, 10, 30),
      priority: AssignmentPriority.high,
      notes: 'Take notes',
      isCompleted: true,
      createdAt: DateTime(2026, 10, 20),
    );
    expect(
        Assignment.fromJson(assignment.toJson()).toJson(), assignment.toJson());
  });

  test('study session calculates end time', () {
    final session = StudySession(
      id: 's1',
      title: 'Revision',
      subject: 'Math',
      startsAt: DateTime(2026, 10, 20, 10),
      durationMinutes: 45,
    );
    expect(session.endsAt, DateTime(2026, 10, 20, 10, 45));
  });

  test('flashcard deck JSON round trip preserves cards', () {
    const deck = FlashcardDeck(
      id: 'd1',
      title: 'Science',
      subject: 'Science',
      cards: [Flashcard(id: 'c1', front: 'Question', back: 'Answer')],
    );
    expect(FlashcardDeck.fromJson(deck.toJson()).toJson(), deck.toJson());
  });
}
