import 'package:flutter/material.dart';
import 'models/assignment.dart';
import 'models/flashcard.dart';
import 'models/study_session.dart';
import 'screens/main_shell.dart';
import 'services/storage_service.dart';

class StudyFlowApp extends StatefulWidget {
  const StudyFlowApp({super.key, required this.storage});
  final StorageService storage;

  @override
  State<StudyFlowApp> createState() => _StudyFlowAppState();
}

class _StudyFlowAppState extends State<StudyFlowApp> {
  late List<Assignment> _assignments;
  late List<StudySession> _sessions;
  late List<FlashcardDeck> _decks;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _assignments = widget.storage.loadAssignments();
    _sessions = widget.storage.loadSessions();
    _decks = widget.storage.loadDecks();
    _darkMode = widget.storage.loadDarkMode();
  }

  void _setAssignments(List<Assignment> value) {
    setState(() => _assignments = value);
    widget.storage.saveAssignments(value);
  }

  void _setSessions(List<StudySession> value) {
    setState(() => _sessions = value);
    widget.storage.saveSessions(value);
  }

  void _setDecks(List<FlashcardDeck> value) {
    setState(() => _decks = value);
    widget.storage.saveDecks(value);
  }

  void _setDarkMode(bool value) {
    setState(() => _darkMode = value);
    widget.storage.saveDarkMode(value);
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6658C8);
    return MaterialApp(
      title: 'StudyFlow',
      debugShowCheckedModeBanner: false,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF7F6FC),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF7F6FC), surfaceTintColor: Colors.transparent),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      ),
      home: MainShell(
        assignments: _assignments,
        sessions: _sessions,
        decks: _decks,
        onAssignmentsChanged: _setAssignments,
        onSessionsChanged: _setSessions,
        onDecksChanged: _setDecks,
        darkMode: _darkMode,
        onDarkModeChanged: _setDarkMode,
      ),
    );
  }
}
