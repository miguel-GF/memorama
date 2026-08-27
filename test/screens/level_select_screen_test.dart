import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_granja/app/app_theme.dart';
import 'package:memo_granja/models/card_pack.dart';
import 'package:memo_granja/models/card_pair.dart';
import 'package:memo_granja/repositories/pack_repository.dart';
import 'package:memo_granja/screens/game_screen.dart';
import 'package:memo_granja/screens/level_select_screen.dart';

const _pack = CardPack(
  id: 'farm',
  included: true,
  pairs: [
    CardPair(id: 'cow', emoji: 'C', spanishName: 'Vaca', englishName: 'Cow'),
    CardPair(id: 'pig', emoji: 'P', spanishName: 'Cerdo', englishName: 'Pig'),
    CardPair(id: 'cat', emoji: 'T', spanishName: 'Gato', englishName: 'Cat'),
    CardPair(id: 'dog', emoji: 'D', spanishName: 'Perro', englishName: 'Dog'),
    CardPair(
      id: 'horse',
      emoji: 'H',
      spanishName: 'Caballo',
      englishName: 'Horse',
    ),
    CardPair(
      id: 'sheep',
      emoji: 'S',
      spanishName: 'Borrego',
      englishName: 'Sheep',
    ),
    CardPair(id: 'duck', emoji: 'U', spanishName: 'Pato', englishName: 'Duck'),
    CardPair(
      id: 'rabbit',
      emoji: 'R',
      spanishName: 'Conejo',
      englishName: 'Rabbit',
    ),
  ],
);

void main() {
  testWidgets('catalog failure offers a retry without technical details', (
    tester,
  ) async {
    final repository = _FlakyPackRepository();
    await tester.pumpWidget(_app(LevelSelectScreen(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar las cartitas.'), findsOneWidget);
    expect(find.text('REINTENTAR'), findsOneWidget);
    expect(find.textContaining('catalog internals'), findsNothing);

    await tester.tap(find.text('REINTENTAR'));
    await tester.pumpAndSettle();

    expect(repository.attempts, 2);
    expect(find.textContaining('8 cartitas'), findsOneWidget);
  });

  testWidgets('selecting a level navigates to the game', (tester) async {
    final repository = _SuccessfulPackRepository();
    await tester.pumpWidget(_app(LevelSelectScreen(repository: repository)));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('8 cartitas'));
    await tester.pumpAndSettle();

    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('Encuentra las parejas'), findsOneWidget);
  });

  testWidgets('invalid catalog data can be retried', (tester) async {
    final repository = _InvalidThenValidPackRepository();
    await tester.pumpWidget(_app(LevelSelectScreen(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar las cartitas.'), findsOneWidget);
    await tester.tap(find.text('REINTENTAR'));
    await tester.pumpAndSettle();

    expect(repository.attempts, 2);
    expect(find.textContaining('8 cartitas'), findsOneWidget);
  });
}

Widget _app(Widget home) {
  return MaterialApp(theme: AppTheme.light, home: home);
}

class _FlakyPackRepository extends PackRepository {
  int attempts = 0;

  @override
  Future<List<CardPack>> loadPacks() async {
    attempts++;
    if (attempts == 1) {
      throw StateError('catalog internals');
    }
    return const [_pack];
  }
}

class _SuccessfulPackRepository extends PackRepository {
  @override
  Future<List<CardPack>> loadPacks() async => const [_pack];
}

class _InvalidThenValidPackRepository extends PackRepository {
  int attempts = 0;

  @override
  Future<List<CardPack>> loadPacks() async {
    attempts++;
    return attempts == 1 ? const [] : const [_pack];
  }
}
