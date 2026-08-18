import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:memo_granja/models/card_pair.dart';
import 'package:memo_granja/models/game_state.dart';
import 'package:memo_granja/models/memory_card.dart';

class GameController extends ChangeNotifier {
  GameController({required List<CardPair> pairs, Random? random})
      : _state = GameState(pairs: pairs, random: random);

  final GameState _state;

  List<MemoryCard> get cards => _state.cards;
  GamePhase get phase => _state.phase;
  bool get isComplete => _state.isComplete;

  RevealResult reveal(String instanceId) {
    final result = _state.reveal(instanceId);
    if (result != RevealResult.ignored) notifyListeners();
    return result;
  }

  PairResolution? resolvePair() {
    final result = _state.resolvePair();
    if (result != null) notifyListeners();
    return result;
  }

  bool finishCelebration() {
    final changed = _state.finishCelebration();
    if (changed) notifyListeners();
    return changed;
  }
}
