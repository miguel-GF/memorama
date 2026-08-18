import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memo_granja/app/app_theme.dart';
import 'package:memo_granja/models/memory_card.dart';

class MemoryCardTile extends StatelessWidget {
  const MemoryCardTile({required this.card, required this.onTap, super.key});

  final MemoryCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isHidden = card.status == MemoryCardStatus.hidden;
    final isMatched = card.status == MemoryCardStatus.matched;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Semantics(
      button: isHidden,
      enabled: isHidden,
      label: isHidden ? 'Carta boca abajo' : card.pair.spanishName,
      child: AnimatedOpacity(
        duration: reduceMotion ? AppMotion.reduced : AppMotion.fade,
        opacity: isMatched ? 0.45 : 1,
        child: reduceMotion
            ? AnimatedSwitcher(
                duration: AppMotion.reduced,
                child: _CardFace(
                  key: ValueKey(isHidden),
                  card: card,
                  showBack: isHidden,
                  onTap: isHidden ? onTap : null,
                ),
              )
            : TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: isHidden ? 1 : 0,
                  end: isHidden ? 1 : 0,
                ),
                duration: AppMotion.cardFlip,
                curve: Curves.easeInOut,
                builder: (context, turn, child) {
                  final showBack = turn > 0.5;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0015)
                      ..rotateY(pi * turn),
                    child: _CardFace(
                      card: card,
                      showBack: showBack,
                      mirrorBack: true,
                      onTap: isHidden ? onTap : null,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.card,
    required this.showBack,
    required this.onTap,
    this.mirrorBack = false,
    super.key,
  });

  final MemoryCard card;
  final bool showBack;
  final bool mirrorBack;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = showBack
        ? const Text(
            '?',
            style: TextStyle(
              color: AppColors.surface,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          )
        : Text(card.pair.emoji, style: const TextStyle(fontSize: 48));
    if (showBack && mirrorBack) {
      content = Transform.flip(flipX: true, child: content);
    }
    return Material(
      color: showBack ? AppColors.primary : AppColors.surface,
      elevation: showBack ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Center(child: content)),
    );
  }
}
