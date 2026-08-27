import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_granja/app/app_theme.dart';
import 'package:memo_granja/models/card_pair.dart';
import 'package:memo_granja/screens/game_screen.dart';
import 'package:memo_granja/widgets/memory_card_tile.dart';

const _pairs = <CardPair>[
  CardPair(id: 'cow', emoji: 'C', spanishName: 'Vaca', englishName: 'Cow'),
  CardPair(id: 'pig', emoji: 'P', spanishName: 'Cerdo', englishName: 'Pig'),
];

void main() {
  testWidgets('a double tap does not reveal the same card twice', (
    tester,
  ) async {
    await tester.pumpWidget(_gameApp());
    final cards = find.byType(MemoryCardTile);

    await tester.tap(cards.at(0));
    await tester.pump(AppMotion.cardFlip);
    await tester.tap(cards.at(0));
    await tester.pump(AppMotion.cardFlip);

    expect(find.text('?'), findsNWidgets(3));
  });

  testWidgets('a third rapid tap stays blocked during pair comparison', (
    tester,
  ) async {
    await tester.pumpWidget(_gameApp());
    final cards = find.byType(MemoryCardTile);

    await tester.tap(cards.at(0));
    await tester.pump(AppMotion.cardFlip);
    await tester.tap(cards.at(1));
    await tester.pump(AppMotion.cardFlip);
    await tester.tap(cards.at(2));
    await tester.pump(AppMotion.cardFlip);

    expect(find.text('?'), findsNWidgets(2));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('disposing during pair comparison does not update the widget', (
    tester,
  ) async {
    await tester.pumpWidget(_gameApp());
    final cards = find.byType(MemoryCardTile);

    await tester.tap(cards.at(0));
    await tester.pump(AppMotion.cardFlip);
    await tester.tap(cards.at(1));
    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 751));

    expect(find.byType(GameScreen), findsNothing);
  });
}

Widget _gameApp() {
  return MaterialApp(
    theme: AppTheme.light,
    home: GameScreen(pairs: _pairs, random: Random(7)),
  );
}
