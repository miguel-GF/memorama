import 'dart:convert';

import 'package:memo_granja/models/progress_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ProgressStore {
  Future<String?> read();

  Future<void> write(String value);
}

class SharedPreferencesProgressStore implements ProgressStore {
  const SharedPreferencesProgressStore();

  static const key = 'memo_granja_progress_v1';

  @override
  Future<String?> read() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  }

  @override
  Future<void> write(String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, value);
  }
}

class ProgressRepository {
  ProgressRepository({ProgressStore? store})
      : _store = store ?? const SharedPreferencesProgressStore();

  final ProgressStore _store;

  Future<ProgressSnapshot> load() async {
    final encoded = await _store.read();
    if (encoded == null || encoded.isEmpty) return ProgressSnapshot();
    try {
      return ProgressSnapshot.fromJson(jsonDecode(encoded));
    } on FormatException {
      return ProgressSnapshot();
    }
  }

  Future<void> save(ProgressSnapshot progress) async {
    await _store.write(jsonEncode(progress.toJson()));
  }

  Future<ProgressSnapshot> markLevelCompleted({
    required String packId,
    required int pairCount,
  }) async {
    final progress = await load();
    final next = progress.markCompleted(packId, pairCount);
    await save(next);
    return next;
  }
}
