class Flashcard {
  const Flashcard({required this.id, required this.front, required this.back});

  final String id;
  final String front;
  final String back;

  Map<String, dynamic> toJson() => {'id': id, 'front': front, 'back': back};

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'] as String,
    front: json['front'] as String? ?? '',
    back: json['back'] as String? ?? '',
  );
}

class FlashcardDeck {
  const FlashcardDeck({required this.id, required this.title, required this.subject, required this.cards});

  final String id;
  final String title;
  final String subject;
  final List<Flashcard> cards;

  FlashcardDeck copyWith({String? title, String? subject, List<Flashcard>? cards}) =>
      FlashcardDeck(id: id, title: title ?? this.title, subject: subject ?? this.subject, cards: cards ?? this.cards);

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'cards': cards.map((card) => card.toJson()).toList(),
  };

  factory FlashcardDeck.fromJson(Map<String, dynamic> json) => FlashcardDeck(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    subject: json['subject'] as String? ?? 'General',
    cards: (json['cards'] as List<dynamic>? ?? [])
        .map((item) => Flashcard.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(),
  );

}
