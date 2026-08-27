import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memo_granja/models/card_pack.dart';

void main() {
  test('farm catalog contains twelve unique bilingual pairs', () async {
    final source = await File('assets/data/packs.json').readAsString();
    final document = jsonDecode(source) as Map<String, Object?>;
    final packs = (document['packs']! as List<Object?>)
        .map((item) => CardPack.fromJson(item! as Map<String, Object?>))
        .toList();
    final farm = packs.singleWhere((pack) => pack.id == 'farm');

    expect(farm.included, isTrue);
    expect(farm.pairs, hasLength(12));
    expect(farm.pairs.map((pair) => pair.id).toSet(), hasLength(12));
    expect(
      farm.pairs.every(
        (pair) => pair.spanishName.isNotEmpty && pair.englishName.isNotEmpty,
      ),
      isTrue,
    );
  });
}
