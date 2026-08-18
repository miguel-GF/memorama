class CardPair {
  const CardPair({
    required this.id,
    required this.emoji,
    required this.spanishName,
    required this.englishName,
  });

  factory CardPair.fromJson(Map<String, Object?> json) {
    return CardPair(
      id: json['id']! as String,
      emoji: json['emoji']! as String,
      spanishName: json['es']! as String,
      englishName: json['en']! as String,
    );
  }

  final String id;
  final String emoji;
  final String spanishName;
  final String englishName;
}
