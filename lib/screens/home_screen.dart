import 'package:flutter/material.dart';
import 'package:memo_granja/screens/adult_zone_screen.dart';
import 'package:memo_granja/screens/level_select_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🐄', style: TextStyle(fontSize: 112)),
                    const SizedBox(height: 16),
                    Text(
                      'Memo Granja',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 280,
                      height: 88,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const LevelSelectScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 48),
                        label: const Text(
                          'JUGAR',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filledTonal(
                tooltip: 'Zona de adultos',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AdultZoneScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
