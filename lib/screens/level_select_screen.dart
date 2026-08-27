import 'package:flutter/material.dart';
import 'package:memo_granja/models/card_pack.dart';
import 'package:memo_granja/repositories/pack_repository.dart';
import 'package:memo_granja/screens/game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({
    super.key,
    this.repository = const PackRepository(),
  });

  final PackRepository repository;

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  late Future<List<CardPack>> _packsFuture;

  @override
  void initState() {
    super.initState();
    _packsFuture = widget.repository.loadPacks();
  }

  @override
  void didUpdateWidget(covariant LevelSelectScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      setState(() {
        _packsFuture = widget.repository.loadPacks();
      });
    }
  }

  void _retry() {
    setState(() {
      _packsFuture = widget.repository.loadPacks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('¿Con cuántas cartas jugamos?')),
      body: FutureBuilder<List<CardPack>>(
        future: _packsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _CatalogError(onRetry: _retry);
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final farmPack = _findFarmPack(snapshot.data!);
          if (farmPack == null || farmPack.pairs.length < 8) {
            return _CatalogError(onRetry: _retry);
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              for (final pairCount in const [4, 6, 8])
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                    height: 96,
                    child: FilledButton.tonal(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => GameScreen(
                              pairs: farmPack.pairs.take(pairCount).toList(),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        '${pairCount * 2} cartitas  ${'▦' * pairCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  CardPack? _findFarmPack(List<CardPack> packs) {
    for (final pack in packs) {
      if (pack.id == 'farm') return pack;
    }
    return null;
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No pudimos cargar las cartitas.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('REINTENTAR'),
            ),
          ],
        ),
      ),
    );
  }
}
