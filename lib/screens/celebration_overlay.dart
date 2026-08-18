import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memo_granja/app/app_theme.dart';
import 'package:memo_granja/models/card_pair.dart';

class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({required this.pair, super.key});

  final CardPair pair;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  Timer? _closeTimer;

  @override
  void initState() {
    super.initState();
    _closeTimer = Timer(AppMotion.celebration, _close);
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    super.dispose();
  }

  void _close() {
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Material(
          color: AppColors.canvas,
          elevation: 12,
          borderRadius: BorderRadius.circular(AppRadii.panel),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.extraLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('✦  ⭐  ✦', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 12),
                  Text(widget.pair.emoji, style: const TextStyle(fontSize: 96)),
                  const SizedBox(height: 16),
                  _LanguageBubble(
                    language: 'ES',
                    name: widget.pair.spanishName,
                  ),
                  const SizedBox(height: 12),
                  _LanguageBubble(
                    language: 'EN',
                    name: widget.pair.englishName,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageBubble extends StatelessWidget {
  const _LanguageBubble({required this.language, required this.name});

  final String language;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$language: $name',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                language,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
