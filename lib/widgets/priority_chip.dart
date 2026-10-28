import 'package:flutter/material.dart';
import '../models/assignment.dart';

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});
  final AssignmentPriority priority;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      AssignmentPriority.low => ('Low', const Color(0xFF27865C)),
      AssignmentPriority.medium => ('Medium', const Color(0xFFD97706)),
      AssignmentPriority.high => ('High', const Color(0xFFDC4C4C)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(30)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}
