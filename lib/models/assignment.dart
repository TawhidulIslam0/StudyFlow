enum AssignmentPriority { low, medium, high }

class Assignment {
  const Assignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.priority,
    this.notes = '',
    this.isCompleted = false,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final AssignmentPriority priority;
  final String notes;
  final bool isCompleted;
  final DateTime createdAt;

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());

  Assignment copyWith({
    String? title,
    String? subject,
    DateTime? dueDate,
    AssignmentPriority? priority,
    String? notes,
    bool? isCompleted,
  }) => Assignment(
    id: id,
    title: title ?? this.title,
    subject: subject ?? this.subject,
    dueDate: dueDate ?? this.dueDate,
    priority: priority ?? this.priority,
    notes: notes ?? this.notes,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'dueDate': dueDate.toIso8601String(),
    'priority': priority.name,
    'notes': notes,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    subject: json['subject'] as String? ?? 'General',
    dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
    priority: AssignmentPriority.values.firstWhere(
      (p) => p.name == json['priority'],
      orElse: () => AssignmentPriority.medium,
    ),
    notes: json['notes'] as String? ?? '',
    isCompleted: json['isCompleted'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

}
