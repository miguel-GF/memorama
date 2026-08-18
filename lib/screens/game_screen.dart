import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memo_granja/app/app_theme.dart';
import 'package:memo_granja/controllers/game_controller.dart';
import 'package:memo_granja/models/card_pair.dart';
import 'package:memo_granja/models/game_state.dart';
import 'package:memo_granja/screens/celebration_overlay.dart';
import 'package:memo_granja/widgets/memory_card_tile.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({required this.pairs, super.key});

  final List<CardPair> pairs;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _game;

  @override
  void initState() {
    super.initState();
    _game = GameController(pairs: widget.pairs)..addListener(_refresh);
  }

  @override
  void dispose() {
    _game
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _onCardTap(String instanceId) async {
    final revealResult = _game.reveal(instanceId);
    if (revealResult != RevealResult.pairReady) return;
    await Future<void>.delayed(AppMotion.pairInspection);
    if (!mounted) return;
    final resolution = _game.resolvePair();
    if (resolution == null) return;
    if (resolution.isMatch) {
      final reduceMotion = MediaQuery.of(context).disableAnimations;
      await showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black38,
        transitionDuration:
            reduceMotion ? AppMotion.reduced : AppMotion.overlayEntrance,
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return CelebrationOverlay(pair: resolution.pair);
        },
      );
      if (!mounted) return;
      _game.finishCelebration();
    }
    if (!mounted) return;
    if (_game.isComplete) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('¡Muy bien! ⭐'),
          content: const Text('Completaste todas las parejas.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CONTINUAR'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 700 ? 6 : 4;
    return Scaffold(
      appBar: AppBar(title: const Text('Encuentra las parejas')),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.medium),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.82,
        ),
        itemCount: _game.cards.length,
        itemBuilder: (context, index) {
          final card = _game.cards[index];
          return MemoryCardTile(
            card: card,
            onTap: () => unawaited(_onCardTap(card.instanceId)),
          );
        },
      ),
    );
  }
}
