import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assignment.dart';
import '../models/flashcard.dart';
import '../models/study_session.dart';

class StorageService {
  static const _legacyDemoAssignments = {
    'a1': 'Chapter 4 problem set',
    'a2': 'Research outline',
    'a3': 'Vocabulary review',
  };

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _removeLegacyDemoAssignments();
  }

  Future<void> _removeLegacyDemoAssignments() async {
    final raw = _store.getString('assignments');
    if (raw == null) return;

    try {
      final saved = jsonDecode(raw) as List<dynamic>;
      final assignments = saved.where((item) {
        if (item is! Map) return true;
        return _legacyDemoAssignments[item['id']] != item['title'];
      }).toList();
      if (assignments.length != saved.length) {
        await _store.setString('assignments', jsonEncode(assignments));
      }
    } on FormatException catch (error, stackTrace) {
      developer.log('Could not migrate saved assignments.',
          error: error, stackTrace: stackTrace);
    }
  }

  SharedPreferences get _store {
    final value = _prefs;
    if (value == null) {
      throw StateError('StorageService.initialize() must be called first.');
    }
    return value;
  }

  List<Assignment> loadAssignments() {
    final raw = _store.getString('assignments');
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((item) =>
              Assignment.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on FormatException catch (error, stackTrace) {
      developer.log('Could not decode saved assignments.',
          error: error, stackTrace: stackTrace);
      return [];
    }
  }

  List<StudySession> loadSessions() {
    final raw = _store.getString('sessions');
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((item) =>
              StudySession.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on FormatException catch (error, stackTrace) {
      developer.log('Could not decode saved schedule items.',
          error: error, stackTrace: stackTrace);
      return [];
    }
  }

  List<FlashcardDeck> loadDecks() {
    final raw = _store.getString('decks');
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((item) =>
              FlashcardDeck.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on FormatException catch (error, stackTrace) {
      developer.log('Could not decode saved flashcard decks.',
          error: error, stackTrace: stackTrace);
      return [];
    }
  }

  bool loadDarkMode() => _store.getBool('darkMode') ?? false;

  Future<void> saveAssignments(List<Assignment> items) => _store.setString(
      'assignments', jsonEncode(items.map((item) => item.toJson()).toList()));

  Future<void> saveSessions(List<StudySession> items) => _store.setString(
      'sessions', jsonEncode(items.map((item) => item.toJson()).toList()));

  Future<void> saveDecks(List<FlashcardDeck> items) => _store.setString(
      'decks', jsonEncode(items.map((item) => item.toJson()).toList()));

  Future<void> saveDarkMode(bool value) => _store.setBool('darkMode', value);
}
