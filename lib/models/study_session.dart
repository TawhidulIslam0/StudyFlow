class StudySession {
  const StudySession({
    required this.id,
    required this.title,
    required this.subject,
    required this.startsAt,
    required this.durationMinutes,
    this.notes = '',
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String subject;
  final DateTime startsAt;
  final int durationMinutes;
  final String notes;
  final bool isCompleted;

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));

  StudySession copyWith({
    String? title,
    String? subject,
    DateTime? startsAt,
    int? durationMinutes,
    String? notes,
    bool? isCompleted,
  }) => StudySession(
    id: id,
    title: title ?? this.title,
    subject: subject ?? this.subject,
    startsAt: startsAt ?? this.startsAt,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    notes: notes ?? this.notes,
    isCompleted: isCompleted ?? this.isCompleted,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'startsAt': startsAt.toIso8601String(),
    'durationMinutes': durationMinutes,
    'notes': notes,
    'isCompleted': isCompleted,
  };

  factory StudySession.fromJson(Map<String, dynamic> json) => StudySession(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    subject: json['subject'] as String? ?? 'General',
    startsAt: DateTime.tryParse(json['startsAt'] as String? ?? '') ?? DateTime.now(),
    durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 30,
    notes: json['notes'] as String? ?? '',
    isCompleted: json['isCompleted'] as bool? ?? false,
  );

}
