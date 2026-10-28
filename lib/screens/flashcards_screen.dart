import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../widgets/empty_state.dart';

class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key, required this.decks, required this.onChanged});
  final List<FlashcardDeck> decks;
  final ValueChanged<List<FlashcardDeck>> onChanged;

  Future<void> _createDeck(BuildContext context) async {
    final result = await showDialog<FlashcardDeck>(context: context, builder: (_) => const _DeckDialog());
    if (result != null) onChanged([...decks, result]);
  }

  Future<void> _openDeck(BuildContext context, FlashcardDeck deck) async {
    final updated = await Navigator.of(context).push<FlashcardDeck>(MaterialPageRoute(builder: (_) => _DeckStudyScreen(deck: deck)));
    if (updated != null) onChanged(decks.map((d) => d.id == updated.id ? updated : d).toList());
  }

  Future<void> _deleteDeck(BuildContext context, FlashcardDeck deck) async {
    final yes = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Delete deck?'),
      content: Text('Delete "${deck.title}" and its cards?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
      ],
    ));
    if (yes == true) onChanged(decks.where((d) => d.id != deck.id).toList());
  }

  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(
    padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
    children: [
      Row(children: [
        Expanded(child: Text('Flashcards', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900))),
        IconButton.filled(onPressed: () => _createDeck(context), icon: const Icon(Icons.add), tooltip: 'Create deck'),
      ]),
      const SizedBox(height: 5),
      const Text('Practice active recall, one card at a time.'),
      const SizedBox(height: 18),
      if (decks.isEmpty)
        EmptyState(icon: Icons.style_outlined, title: 'No decks yet', message: 'Create a deck and add your first question.', action: FilledButton.tonal(onPressed: () => _createDeck(context), child: const Text('Create deck')))
      else
        ...decks.map((deck) => Card(
          color: Theme.of(context).colorScheme.surface,
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _openDeck(context, deck),
            borderRadius: BorderRadius.circular(18),
            child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(15)),
                child: const Icon(Icons.style_outlined, size: 25),
              ),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(deck.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${deck.subject} • ${deck.cards.length} cards', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
              ])),
              PopupMenuButton<String>(
                onSelected: (value) => value == 'study' ? _openDeck(context, deck) : _deleteDeck(context, deck),
                itemBuilder: (_) => const [PopupMenuItem(value: 'study', child: Text('Study deck')), PopupMenuItem(value: 'delete', child: Text('Delete deck'))],
              ),
            ])),
          ),
        )),
    ],
  ));
}

class _DeckDialog extends StatefulWidget {
  const _DeckDialog();

  @override
  State<_DeckDialog> createState() => _DeckDialogState();
}

class _DeckDialogState extends State<_DeckDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _subject = TextEditingController();
  final _cardsText = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _subject.dispose();
    _cardsText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create flashcard deck'),
    content: SizedBox(
      width: 440,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: _title, maxLength: 80, validator: (v) => v == null || v.trim().isEmpty ? 'Enter a deck name' : null, decoration: const InputDecoration(labelText: 'Deck name')),
          const SizedBox(height: 10),
          TextFormField(controller: _subject, maxLength: 50, decoration: const InputDecoration(labelText: 'Subject')),
          const SizedBox(height: 10),
          TextFormField(
            controller: _cardsText,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Cards (optional)',
              alignLabelWithHint: true,
              hintText: 'One card per line: question | answer',
              helperText: 'Example: What is 2+2? | 4',
            ),
          ),
        ])),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: () {
        if (!_formKey.currentState!.validate()) return;
        final cards = <Flashcard>[];
        for (final line in _cardsText.text.split('\n')) {
          final split = line.split('|');
          if (split.length >= 2 && split.first.trim().isNotEmpty && split.sublist(1).join('|').trim().isNotEmpty) {
            cards.add(Flashcard(id: '${DateTime.now().microsecondsSinceEpoch}-${cards.length}', front: split.first.trim(), back: split.sublist(1).join('|').trim()));
          }
        }
        Navigator.pop(context, FlashcardDeck(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: _title.text.trim(),
          subject: _subject.text.trim().isEmpty ? 'General' : _subject.text.trim(),
          cards: cards,
        ));
      }, child: const Text('Create deck')),
    ],
  );
}

class _DeckStudyScreen extends StatefulWidget {
  const _DeckStudyScreen({required this.deck});
  final FlashcardDeck deck;

  @override
  State<_DeckStudyScreen> createState() => _DeckStudyScreenState();
}

class _DeckStudyScreenState extends State<_DeckStudyScreen> {
  late FlashcardDeck _deck;
  int _index = 0;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _deck = widget.deck;
  }

  Future<void> _addCard() async {
    final card = await showDialog<Flashcard>(context: context, builder: (_) => const _CardDialog());
    if (card != null) setState(() => _deck = _deck.copyWith(cards: [..._deck.cards, card]));
  }

  void _finish() => Navigator.pop(context, _deck);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final card = _deck.cards.isEmpty ? null : _deck.cards[_index.clamp(0, _deck.cards.length - 1)];
    return Scaffold(
      appBar: AppBar(
        title: Text(_deck.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [IconButton(onPressed: _addCard, icon: const Icon(Icons.add), tooltip: 'Add card')],
      ),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
        child: Column(children: [
          if (card != null) Text('Card ${_index + 1} of ${_deck.cards.length}', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 14),
          Expanded(child: card == null
            ? EmptyState(icon: Icons.style_outlined, title: 'This deck is empty', message: 'Add a question and answer to start studying.', action: FilledButton.tonal(onPressed: _addCard, child: const Text('Add first card')))
            : GestureDetector(
              onTap: () => setState(() => _showAnswer = !_showAnswer),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [scheme.primary, scheme.tertiary]),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: scheme.primary.withValues(alpha: 0.16), blurRadius: 22, offset: const Offset(0, 9))],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_showAnswer ? Icons.lightbulb_outline : Icons.help_outline_rounded, size: 36, color: Colors.white70),
                  const SizedBox(height: 20),
                  Text(_showAnswer ? 'ANSWER' : 'QUESTION', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.4)),
                  const SizedBox(height: 18),
                  Flexible(child: SingleChildScrollView(child: Center(child: Text(_showAnswer ? card.back : card.front, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800))))),
                  const SizedBox(height: 18),
                  const Text('Tap card to flip', style: TextStyle(color: Colors.white70)),
                ]),
              ),
            ),
          ),
          if (card != null) ...[
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: _index > 0 ? () => setState(() { _index--; _showAnswer = false; }) : null, icon: const Icon(Icons.chevron_left), label: const Text('Previous'))),
              const SizedBox(width: 10),
              Expanded(child: FilledButton.icon(onPressed: _index < _deck.cards.length - 1 ? () => setState(() { _index++; _showAnswer = false; }) : _addCard, icon: Icon(_index < _deck.cards.length - 1 ? Icons.chevron_right : Icons.add), label: Text(_index < _deck.cards.length - 1 ? 'Next card' : 'Add card'))),
            ]),
          ],
          const SizedBox(height: 10),
          TextButton(onPressed: _finish, child: const Text('Done studying')),
        ]),
      )),
    );
  }
}

class _CardDialog extends StatefulWidget {
  const _CardDialog();

  @override
  State<_CardDialog> createState() => _CardDialogState();
}

class _CardDialogState extends State<_CardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _front = TextEditingController();
  final _back = TextEditingController();

  @override
  void dispose() {
    _front.dispose();
    _back.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add flashcard'),
    content: SizedBox(
      width: 420,
      child: Form(key: _formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: _front, maxLength: 300, maxLines: 3, validator: (v) => v == null || v.trim().isEmpty ? 'Enter a question' : null, decoration: const InputDecoration(labelText: 'Front / question', alignLabelWithHint: true)),
        const SizedBox(height: 10),
        TextFormField(controller: _back, maxLength: 500, maxLines: 4, validator: (v) => v == null || v.trim().isEmpty ? 'Enter an answer' : null, decoration: const InputDecoration(labelText: 'Back / answer', alignLabelWithHint: true)),
      ]))),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: () {
        if (!_formKey.currentState!.validate()) return;
        Navigator.pop(context, Flashcard(id: DateTime.now().microsecondsSinceEpoch.toString(), front: _front.text.trim(), back: _back.text.trim()));
      }, child: const Text('Add card')),
    ],
  );
}
