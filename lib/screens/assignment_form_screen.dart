import 'package:flutter/material.dart';
import '../models/assignment.dart';
import '../utils/formatters.dart';

class AssignmentFormScreen extends StatefulWidget {
  const AssignmentFormScreen({super.key, this.assignment});
  final Assignment? assignment;

  @override
  State<AssignmentFormScreen> createState() => _AssignmentFormScreenState();
}

class _AssignmentFormScreenState extends State<AssignmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _subject;
  late final TextEditingController _notes;
  late DateTime _dueDate;
  late AssignmentPriority _priority;

  @override
  void initState() {
    super.initState();
    final item = widget.assignment;
    _title = TextEditingController(text: item?.title ?? '');
    _subject = TextEditingController(text: item?.subject ?? '');
    _notes = TextEditingController(text: item?.notes ?? '');
    _dueDate = item?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _priority = item?.priority ?? AssignmentPriority.medium;
  }

  @override
  void dispose() {
    _title.dispose();
    _subject.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: _dueDate.isBefore(DateTime(2000)) ? DateTime.now() : _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (chosen != null) setState(() => _dueDate = DateTime(chosen.year, chosen.month, chosen.day, 23, 59));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final old = widget.assignment;
    Navigator.pop(context, Assignment(
      id: old?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      subject: _subject.text.trim().isEmpty ? 'General' : _subject.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
      notes: _notes.text.trim(),
      isCompleted: old?.isCompleted ?? false,
      createdAt: old?.createdAt ?? DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.assignment == null ? 'New assignment' : 'Edit assignment')),
    body: Form(
      key: _formKey,
      child: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 28), children: [
        Text('What do you need to get done?', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 18),
        TextFormField(controller: _title, maxLength: 100, validator: (v) => v == null || v.trim().isEmpty ? 'Enter an assignment title' : null, decoration: const InputDecoration(labelText: 'Assignment title', prefixIcon: Icon(Icons.assignment_outlined))),
        const SizedBox(height: 10),
        TextFormField(controller: _subject, maxLength: 50, decoration: const InputDecoration(labelText: 'Subject or class', prefixIcon: Icon(Icons.menu_book_outlined))),
        const SizedBox(height: 14),
        DropdownButtonFormField<AssignmentPriority>(
          value: _priority,
          decoration: const InputDecoration(labelText: 'Priority', prefixIcon: Icon(Icons.flag_outlined)),
          items: AssignmentPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name[0].toUpperCase() + p.name.substring(1)))).toList(),
          onChanged: (value) { if (value != null) setState(() => _priority = value); },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: _chooseDate, icon: const Icon(Icons.calendar_month_outlined), label: Text('Due: ${prettyDate(_dueDate)}')),
        const SizedBox(height: 12),
        TextFormField(controller: _notes, maxLines: 4, maxLength: 500, decoration: const InputDecoration(labelText: 'Notes (optional)', alignLabelWithHint: true, prefixIcon: Icon(Icons.notes_outlined))),
        const SizedBox(height: 20),
        FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check), label: const Text('Save assignment'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15))),
      ]),
    ),
  );
}
