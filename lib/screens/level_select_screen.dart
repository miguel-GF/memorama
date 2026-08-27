import 'package:flutter/material.dart';
import 'package:memo_granja/models/card_pack.dart';
import 'package:memo_granja/repositories/pack_repository.dart';
import 'package:memo_granja/screens/game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen(
      {super.key, this.repository = const PackRepository()});

  final PackRepository repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('¿Con cuántas cartas jugamos?')),
      body: FutureBuilder<List<CardPack>>(
        future: repository.loadPacks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('No pudimos cargar las cartitas.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final farmPack = snapshot.data!.firstWhere(
            (pack) => pack.id == 'farm',
          );
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
}
