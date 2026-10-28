import 'package:flutter/material.dart';
import '../models/assignment.dart';
import '../models/flashcard.dart';
import '../models/study_session.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.assignments,
    required this.sessions,
    required this.decks,
    required this.onNavigate,
  });

  final List<Assignment> assignments;
  final List<StudySession> sessions;
  final List<FlashcardDeck> decks;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final pending = assignments.where((a) => !a.isCompleted).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final completed = assignments.where((a) => a.isCompleted).length;
    final progress = assignments.isEmpty ? 0.0 : completed / assignments.length;
    final upcoming = sessions.where((s) => !s.isCompleted).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 25),
            ),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('StudyFlow', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
              Text('Small steps. Big progress.', style: theme.textTheme.bodySmall),
            ])),
            IconButton(onPressed: () => onNavigate(4), icon: const Icon(Icons.settings_outlined), tooltip: 'Settings'),
          ]),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.tertiary]),
              borderRadius: BorderRadius.circular(23),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('YOUR STUDY JOURNEY', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 11)),
              const SizedBox(height: 9),
              Text('${(progress * 100).round()}% complete', style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
              const SizedBox(height: 13),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.white24, color: Colors.white),
              ),
              const SizedBox(height: 9),
              Text('$completed of ${assignments.length} assignments completed', style: const TextStyle(color: Colors.white)),
            ]),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final width = (constraints.maxWidth - 10) / 2;
            return Wrap(spacing: 10, runSpacing: 10, children: [
              _SummaryCard(width: width, icon: Icons.assignment_outlined, title: 'Tasks left', value: '${pending.length}', color: const Color(0xFF6658C8), onTap: () => onNavigate(1)),
              _SummaryCard(width: width, icon: Icons.calendar_month_outlined, title: 'Scheduled blocks', value: '${upcoming.length}', color: const Color(0xFF16866B), onTap: () => onNavigate(2)),
              _SummaryCard(width: width, icon: Icons.style_outlined, title: 'Flashcard decks', value: '${decks.length}', color: const Color(0xFFCE7B26), onTap: () => onNavigate(3)),
              _SummaryCard(width: width, icon: Icons.check_circle_outline, title: 'Completed', value: '$completed', color: const Color(0xFF2777C7), onTap: () => onNavigate(1)),
            ]);
          }),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: Text('Coming up', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
            TextButton(onPressed: () => onNavigate(1), child: const Text('All tasks')),
          ]),
          const SizedBox(height: 8),
          if (pending.isEmpty)
            const EmptyState(icon: Icons.task_alt, title: 'You’re all caught up', message: 'Add an assignment when you have something to work on.')
          else
            ...pending.take(3).map((item) => Card(
              color: theme.colorScheme.surface,
              margin: const EdgeInsets.only(bottom: 9),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                leading: CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer, child: const Icon(Icons.assignment_outlined)),
                title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${item.subject} • ${dueLabel(item.dueDate)}', maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Icon(item.isOverdue ? Icons.warning_amber_rounded : Icons.chevron_right, color: item.isOverdue ? Colors.red : null),
              ),
            )),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: Text('Next study blocks', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
            TextButton(onPressed: () => onNavigate(2), child: const Text('Schedule')),
          ]),
          const SizedBox(height: 8),
          if (upcoming.isEmpty)
            const EmptyState(icon: Icons.event_available_outlined, title: 'No study blocks planned', message: 'Add a study block when you are ready.')
          else
            ...upcoming.take(2).map((session) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.timer_outlined),
              ),
              title: Text(session.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${shortDay(session.startsAt)} • ${prettyTime(session.startsAt)}'),
              trailing: Text('${session.durationMinutes}m', style: theme.textTheme.labelLarge),
            )),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.width, required this.icon, required this.title, required this.value, required this.color, required this.onTap});
  final double width;
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 13),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      ),
    ),
  );
}
