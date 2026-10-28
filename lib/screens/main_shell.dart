import 'package:flutter/material.dart';
import '../models/assignment.dart';
import '../models/flashcard.dart';
import '../models/study_session.dart';
import 'dashboard_screen.dart';
import 'assignments_screen.dart';
import 'schedule_screen.dart';
import 'flashcards_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.assignments,
    required this.sessions,
    required this.decks,
    required this.onAssignmentsChanged,
    required this.onSessionsChanged,
    required this.onDecksChanged,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  final List<Assignment> assignments;
  final List<StudySession> sessions;
  final List<FlashcardDeck> decks;
  final ValueChanged<List<Assignment>> onAssignmentsChanged;
  final ValueChanged<List<StudySession>> onSessionsChanged;
  final ValueChanged<List<FlashcardDeck>> onDecksChanged;
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(
        assignments: widget.assignments,
        sessions: widget.sessions,
        decks: widget.decks,
        onNavigate: (index) => setState(() => _index = index),
      ),
      AssignmentsScreen(assignments: widget.assignments, onChanged: widget.onAssignmentsChanged),
      ScheduleScreen(sessions: widget.sessions, onChanged: widget.onSessionsChanged),
      FlashcardsScreen(decks: widget.decks, onChanged: widget.onDecksChanged),
      SettingsScreen(darkMode: widget.darkMode, onDarkModeChanged: widget.onDarkModeChanged),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment_rounded), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.style_outlined), selectedIcon: Icon(Icons.style), label: 'Cards'),
          NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune), label: 'Settings'),
        ],
      ),
    );
  }
}
