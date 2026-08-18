import 'package:memo_granja/models/card_pair.dart';

class CardPack {
  const CardPack({
    required this.id,
    required this.included,
    required this.pairs,
  });

  factory CardPack.fromJson(Map<String, Object?> json) {
    final pairsJson = json['pairs']! as List<Object?>;
    return CardPack(
      id: json['id']! as String,
      included: json['included']! as bool,
      pairs: pairsJson
          .map((item) => CardPair.fromJson(item! as Map<String, Object?>))
          .toList(growable: false),
    );
  }

  final String id;
  final bool included;
  final List<CardPair> pairs;
}
