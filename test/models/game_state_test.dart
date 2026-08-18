import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memo_granja/models/card_pair.dart';
import 'package:memo_granja/models/game_state.dart';
import 'package:memo_granja/models/memory_card.dart';

void main() {
  const cow = CardPair(
    id: 'cow',
    emoji: '🐄',
    spanishName: 'Vaca',
    englishName: 'Cow',
  );
  const pig = CardPair(
    id: 'pig',
    emoji: '🐖',
    spanishName: 'Cerdo',
    englishName: 'Pig',
  );

  test('builds exactly two cards per pair', () {
    final game = GameState(pairs: const [cow, pig], random: Random(1));

    expect(game.cards, hasLength(4));
    expect(game.cards.where((card) => card.pair.id == 'cow'), hasLength(2));
    expect(game.cards.where((card) => card.pair.id == 'pig'), hasLength(2));
    expect(game.phase, GamePhase.idle);
  });

  test('moves through explicit phases and blocks a third reveal', () {
    final game = GameState(pairs: const [cow, pig], random: Random(1));

    expect(game.reveal(game.cards[0].instanceId), RevealResult.firstCard);
    expect(game.phase, GamePhase.oneRevealed);
    expect(game.reveal(game.cards[1].instanceId), RevealResult.pairReady);
    expect(game.phase, GamePhase.resolving);
    expect(game.reveal(game.cards[2].instanceId), RevealResult.ignored);
  });

  test('ignores a second tap on the same card', () {
    final game = GameState(pairs: const [cow, pig], random: Random(1));
    final cardId = game.cards.first.instanceId;

    expect(game.reveal(cardId), RevealResult.firstCard);
    expect(game.reveal(cardId), RevealResult.ignored);
    expect(game.phase, GamePhase.oneRevealed);
    expect(game.revealedCards, hasLength(1));
  });

  test('matching pair celebrates before completing', () {
    final game = GameState(pairs: const [cow], random: Random(1));

    game.reveal(game.cards[0].instanceId);
    game.reveal(game.cards[1].instanceId);
    final resolution = game.resolvePair();

    expect(resolution?.isMatch, isTrue);
    expect(resolution?.pair, cow);
    expect(game.phase, GamePhase.celebrating);
    expect(game.isComplete, isFalse);
    expect(
      game.cards.every((card) => card.status == MemoryCardStatus.matched),
      isTrue,
    );

    expect(game.finishCelebration(), isTrue);
    expect(game.phase, GamePhase.complete);
    expect(game.isComplete, isTrue);
    expect(game.finishCelebration(), isFalse);
  });

  test('a mismatch returns both cards to hidden and idle', () {
    final game = GameState(pairs: const [cow, pig], random: Random(1));
    final cowCard = game.cards.firstWhere((card) => card.pair.id == 'cow');
    final pigCard = game.cards.firstWhere((card) => card.pair.id == 'pig');

    game.reveal(cowCard.instanceId);
    game.reveal(pigCard.instanceId);
    final resolution = game.resolvePair();

    expect(resolution?.isMatch, isFalse);
    expect(game.phase, GamePhase.idle);
    expect(game.revealedCards, isEmpty);
    expect(
      game.cards.every((card) => card.status == MemoryCardStatus.hidden),
      isTrue,
    );
  });

  test('cannot resolve or finish from the wrong phase', () {
    final game = GameState(pairs: const [cow], random: Random(1));

    expect(game.resolvePair(), isNull);
    expect(game.finishCelebration(), isFalse);
    expect(game.phase, GamePhase.idle);
  });
}
