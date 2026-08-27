import 'package:flutter_test/flutter_test.dart';
import 'package:memo_granja/models/progress_snapshot.dart';
import 'package:memo_granja/repositories/progress_repository.dart';

void main() {
  test('records and reloads completed levels locally', () async {
    final store = _MemoryProgressStore();
    final repository = ProgressRepository(store: store);

    await repository.markLevelCompleted(packId: 'farm', pairCount: 4);
    final progress = await repository.load();

    expect(progress.isCompleted('farm', 4), isTrue);
    expect(progress.isCompleted('farm', 8), isFalse);
  });

  test('corrupt local progress falls back to an empty snapshot', () async {
    final store = _MemoryProgressStore('{not-json');
    final repository = ProgressRepository(store: store);

    final progress = await repository.load();

    expect(progress.completedLevels, isEmpty);
  });

  test('progress snapshots reject unknown shapes', () {
    expect(
      () => ProgressSnapshot.fromJson({'completed_levels': 'farm:4'}),
      throwsA(isA<FormatException>()),
    );
  });
}

class _MemoryProgressStore implements ProgressStore {
  _MemoryProgressStore([this.value]);

  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String next) async {
    value = next;
  }
}
