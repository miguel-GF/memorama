import 'dart:math';

import 'package:memo_granja/models/card_pair.dart';
import 'package:memo_granja/models/memory_card.dart';

enum GamePhase { idle, oneRevealed, resolving, celebrating, complete }

enum RevealResult { ignored, firstCard, pairReady }

class PairResolution {
  const PairResolution({required this.pair, required this.isMatch});

  final CardPair pair;
  final bool isMatch;
}

class GameState {
  GameState({required List<CardPair> pairs, Random? random})
      : assert(pairs.isNotEmpty),
        _cards = _buildDeck(pairs, random ?? Random());

  final List<MemoryCard> _cards;
  GamePhase _phase = GamePhase.idle;

  List<MemoryCard> get cards => List.unmodifiable(_cards);
  GamePhase get phase => _phase;
  bool get isResolving => _phase == GamePhase.resolving;
  bool get isComplete => _phase == GamePhase.complete;

  List<MemoryCard> get revealedCards => _cards
      .where((card) => card.status == MemoryCardStatus.revealed)
      .toList(growable: false);

  RevealResult reveal(String instanceId) {
    if (_phase != GamePhase.idle && _phase != GamePhase.oneRevealed) {
      return RevealResult.ignored;
    }

    final index = _cards.indexWhere((card) => card.instanceId == instanceId);
    if (index < 0 || _cards[index].status != MemoryCardStatus.hidden) {
      return RevealResult.ignored;
    }

    _cards[index] = _cards[index].copyWith(status: MemoryCardStatus.revealed);
    if (_phase == GamePhase.idle) {
      _phase = GamePhase.oneRevealed;
      return RevealResult.firstCard;
    }

    _phase = GamePhase.resolving;
    return RevealResult.pairReady;
  }

  PairResolution? resolvePair() {
    final openCards = revealedCards;
    if (_phase != GamePhase.resolving || openCards.length != 2) return null;

    final pair = openCards.first.pair;
    final isMatch = pair.id == openCards.last.pair.id;
    final nextStatus =
        isMatch ? MemoryCardStatus.matched : MemoryCardStatus.hidden;
    for (final openCard in openCards) {
      final index = _cards.indexWhere(
        (card) => card.instanceId == openCard.instanceId,
      );
      _cards[index] = _cards[index].copyWith(status: nextStatus);
    }
    _phase = isMatch ? GamePhase.celebrating : GamePhase.idle;
    return PairResolution(pair: pair, isMatch: isMatch);
  }

  bool finishCelebration() {
    if (_phase != GamePhase.celebrating) return false;
    final allMatched = _cards.every(
      (card) => card.status == MemoryCardStatus.matched,
    );
    _phase = allMatched ? GamePhase.complete : GamePhase.idle;
    return true;
  }

  static List<MemoryCard> _buildDeck(List<CardPair> pairs, Random random) {
    final deck = <MemoryCard>[
      for (final pair in pairs)
        for (var copy = 0; copy < 2; copy++)
          MemoryCard(instanceId: '${pair.id}-$copy', pair: pair),
    ];
    deck.shuffle(random);
    return deck;
  }
}
