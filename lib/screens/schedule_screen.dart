import 'dart:async';

import 'package:flutter/material.dart';
import '../models/study_session.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen(
      {super.key, required this.sessions, required this.onChanged});
  final List<StudySession> sessions;
  final ValueChanged<List<StudySession>> onChanged;

  Future<void> _add(BuildContext context) async {
    final result = await showDialog<StudySession>(
        context: context, builder: (_) => const _SessionDialog());
    if (result != null) onChanged([...sessions, result]);
  }

  Future<void> _startTimer(BuildContext context, StudySession session) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _StudyTimerDialog(
          title: session.title, durationMinutes: session.durationMinutes),
    );
  }

  Future<void> _delete(BuildContext context, StudySession session) async {
    final yes = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Delete study block?'),
              content: Text('Delete "${session.title}"?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete')),
              ],
            ));
    if (yes == true) {
      onChanged(sessions.where((s) => s.id != session.id).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...sessions]
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return SafeArea(
        child: ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      children: [
        Row(children: [
          Expanded(
              child: Text('Study schedule',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w900))),
          IconButton.filled(
              onPressed: () => _add(context),
              icon: const Icon(Icons.add),
              tooltip: 'Add study block'),
        ]),
        const SizedBox(height: 5),
        const Text('Make time for focused learning.'),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            const Icon(Icons.timelapse_outlined, size: 30),
            const SizedBox(width: 13),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      '${sessions.where((s) => !s.isCompleted).length} scheduled study blocks',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  Text(
                      '${sessions.where((s) => !s.isCompleted).fold<int>(0, (sum, s) => sum + s.durationMinutes)} minutes of planned study'),
                ])),
          ]),
        ),
        const SizedBox(height: 18),
        if (sorted.isEmpty)
          EmptyState(
              icon: Icons.calendar_month_outlined,
              title: 'Your schedule is open',
              message: 'Add a study block when you are ready.',
              action: FilledButton.tonal(
                  onPressed: () => _add(context),
                  child: const Text('Add study block')))
        else
          ...sorted.map((session) => Card(
                color: Theme.of(context).colorScheme.surface,
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 62,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 5),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              borderRadius: BorderRadius.circular(14)),
                          child: Column(children: [
                            Text(session.startsAt.day.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w900)),
                            Text(DateFormatMonth.month(session.startsAt.month),
                                style: Theme.of(context).textTheme.labelMedium),
                          ]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(session.title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text(session.subject,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 7),
                              Wrap(spacing: 8, runSpacing: 4, children: [
                                Text(prettyTime(session.startsAt),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium),
                                Text('${session.durationMinutes} min',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium),
                              ]),
                              if (session.notes.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(session.notes,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodySmall)
                              ],
                              const SizedBox(height: 8),
                              Wrap(spacing: 8, children: [
                                FilledButton.tonalIcon(
                                  onPressed: () =>
                                      _startTimer(context, session),
                                  icon: const Icon(Icons.timer_outlined),
                                  label: const Text('Start timer'),
                                ),
                                OutlinedButton(
                                  onPressed: () => onChanged(sessions
                                      .map((s) => s.id == session.id
                                          ? s.copyWith(
                                              isCompleted: !s.isCompleted)
                                          : s)
                                      .toList()),
                                  child: Text(session.isCompleted
                                      ? 'Mark planned'
                                      : 'Complete'),
                                ),
                                IconButton(
                                    onPressed: () => _delete(context, session),
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: 'Delete study block'),
                              ]),
                            ])),
                      ]),
                ),
              )),
      ],
    ));
  }
}

class DateFormatMonth {
  static String month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}

class _SessionDialog extends StatefulWidget {
  const _SessionDialog();

  @override
  State<_SessionDialog> createState() => _SessionDialogState();
}

class _SessionDialogState extends State<_SessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _subject = TextEditingController();
  final _notes = TextEditingController();
  DateTime _dateTime = DateTime.now().add(const Duration(hours: 1));
  int _duration = 30;

  @override
  void dispose() {
    _title.dispose();
    _subject.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (date == null || !mounted) return;
    final time = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_dateTime));
    if (time != null) {
      setState(() => _dateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute));
    } else {
      setState(() => _dateTime = DateTime(
          date.year, date.month, date.day, _dateTime.hour, _dateTime.minute));
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Schedule study block'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                  controller: _title,
                  maxLength: 100,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter a title' : null,
                  decoration: const InputDecoration(labelText: 'Study block')),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _subject,
                  maxLength: 50,
                  decoration: const InputDecoration(labelText: 'Subject')),
              const SizedBox(height: 10),
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event),
                  title: const Text('Date and time'),
                  subtitle:
                      Text('${shortDay(_dateTime)} • ${prettyTime(_dateTime)}'),
                  onTap: _pickDateTime),
              DropdownButtonFormField<int>(
                initialValue: _duration,
                decoration: const InputDecoration(labelText: 'Duration'),
                items: const [15, 25, 30, 45, 60, 90, 120]
                    .map((n) =>
                        DropdownMenuItem(value: n, child: Text('$n minutes')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _duration = value);
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _notes,
                  maxLength: 250,
                  maxLines: 2,
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)')),
            ])),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                Navigator.pop(
                    context,
                    StudySession(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      title: _title.text.trim(),
                      subject: _subject.text.trim().isEmpty
                          ? 'General'
                          : _subject.text.trim(),
                      startsAt: _dateTime,
                      durationMinutes: _duration,
                      notes: _notes.text.trim(),
                    ));
              },
              child: const Text('Save study block')),
        ],
      );
}

class _StudyTimerDialog extends StatefulWidget {
  const _StudyTimerDialog({required this.title, required this.durationMinutes});

  final String title;
  final int durationMinutes;

  @override
  State<_StudyTimerDialog> createState() => _StudyTimerDialogState();
}

class _StudyTimerDialogState extends State<_StudyTimerDialog> {
  late final int _totalSeconds = widget.durationMinutes * 60;
  late int _remainingSeconds = _totalSeconds;
  Timer? _timer;
  DateTime? _deadline;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _isRunning = true;
    _beginTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() => _isRunning = true);
    _beginTimer();
  }

  void _beginTimer() {
    _deadline = DateTime.now().add(Duration(seconds: _remainingSeconds));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = _deadline!.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
        });
      } else {
        setState(() => _remainingSeconds = remaining);
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    final remaining = _deadline!.difference(DateTime.now()).inSeconds;
    setState(() {
      _remainingSeconds = remaining < 0 ? 0 : remaining;
      _isRunning = false;
    });
    _deadline = null;
  }

  String get _timeLabel {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _remainingSeconds == 0;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _timeLabel,
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(isComplete
              ? 'Study block complete'
              : _isRunning
                  ? 'Timer is running'
                  : 'Timer paused'),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _totalSeconds == 0
                ? 0
                : 1 - (_remainingSeconds / _totalSeconds),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
        if (!isComplete)
          FilledButton.icon(
            onPressed: _isRunning ? _pause : _start,
            icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
            label: Text(_isRunning ? 'Pause' : 'Resume'),
          ),
      ],
    );
  }
}
