import 'package:flutter/material.dart';
import '../models/assignment.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/priority_chip.dart';
import 'assignment_form_screen.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key, required this.assignments, required this.onChanged});
  final List<Assignment> assignments;
  final ValueChanged<List<Assignment>> onChanged;

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final _search = TextEditingController();
  String _filter = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _addOrEdit([Assignment? item]) async {
    final result = await Navigator.of(context).push<Assignment>(
      MaterialPageRoute(builder: (_) => AssignmentFormScreen(assignment: item)),
    );
    if (result == null) return;
    final list = [...widget.assignments];
    final index = list.indexWhere((a) => a.id == result.id);
    if (index < 0) {
      list.add(result);
    } else {
      list[index] = result;
    }
    widget.onChanged(list);
  }

  Future<void> _delete(Assignment item) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete assignment?'),
        content: Text('Delete "${item.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (yes == true) widget.onChanged(widget.assignments.where((a) => a.id != item.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final filtered = widget.assignments.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(query) || item.subject.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        'Open' => !item.isCompleted,
        'Completed' => item.isCompleted,
        'Overdue' => item.isOverdue,
        _ => true,
      };
      return matchesSearch && matchesFilter;
    }).toList()..sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return a.dueDate.compareTo(b.dueDate);
    });

    return SafeArea(child: ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      children: [
        Row(children: [
          Expanded(child: Text('Assignments', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900))),
          IconButton.filled(onPressed: () => _addOrEdit(), icon: const Icon(Icons.add), tooltip: 'Add assignment'),
        ]),
        const SizedBox(height: 5),
        Text('${widget.assignments.where((a) => !a.isCompleted).length} tasks remaining', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: 'Search assignments or subjects', prefixIcon: const Icon(Icons.search), suffixIcon: query.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.close))),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: ['All', 'Open', 'Completed', 'Overdue'].map((value) => ChoiceChip(label: Text(value), selected: _filter == value, onSelected: (_) => setState(() => _filter = value))).toList()),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          EmptyState(icon: Icons.assignment_outlined, title: 'No assignments found', message: query.isEmpty ? 'Add an assignment and give yourself a clear next step.' : 'Try another search or filter.', action: FilledButton.tonal(onPressed: () => _addOrEdit(), child: const Text('Add assignment')))
        else
          ...filtered.map((item) => Card(
            color: Theme.of(context).colorScheme.surface,
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Checkbox(value: item.isCompleted, onChanged: (value) => widget.onChanged(widget.assignments.map((a) => a.id == item.id ? a.copyWith(isCompleted: value ?? false) : a).toList())),
                const SizedBox(width: 2),
                Expanded(child: InkWell(
                  onTap: () => _addOrEdit(item),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w800, decoration: item.isCompleted ? TextDecoration.lineThrough : null)),
                    const SizedBox(height: 5),
                    Text(item.subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      PriorityChip(priority: item.priority),
                      Text(dueLabel(item.dueDate), style: TextStyle(fontSize: 11, color: item.isOverdue ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant)),
                    ]),
                    if (item.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(item.notes, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ])),
                )),
                PopupMenuButton<String>(
                  onSelected: (value) => value == 'edit' ? _addOrEdit(item) : _delete(item),
                  itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))],
                ),
              ]),
            ),
          )),
      ],
    ));
  }
}
