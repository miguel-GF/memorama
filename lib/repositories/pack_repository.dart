import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:memo_granja/models/card_pack.dart';

class PackRepository {
  const PackRepository();

  Future<List<CardPack>> loadPacks() async {
    final source = await rootBundle.loadString('assets/data/packs.json');
    final document = jsonDecode(source) as Map<String, Object?>;
    final packsJson = document['packs']! as List<Object?>;
    return packsJson
        .map((item) => CardPack.fromJson(item! as Map<String, Object?>))
        .toList(growable: false);
  }
}
