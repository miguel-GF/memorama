import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:memo_granja/models/progress_snapshot.dart';
import 'package:memo_granja/repositories/progress_repository.dart';
import 'package:memo_granja/services/local_backup_service.dart';

void main() {
  test('exports progress without entitlements or purchase tokens', () async {
    final progressStore = _MemoryProgressStore();
    final files = _MemoryBackupFiles();
    final repository = ProgressRepository(store: progressStore);
    await repository.save(
      ProgressSnapshot(completedLevels: const ['farm:4']),
    );
    final service = LocalBackupService(
      progressRepository: repository,
      files: files,
    );

    final result = await service.exportBackup();
    final exported = utf8.decode(files.savedBytes!);

    expect(result.completedLevels, 1);
    expect(exported, contains('memo_granja'));
    expect(exported, contains('farm:4'));
    expect(exported, isNot(contains('full_access_lifetime')));
    expect(exported, isNot(contains('purchaseToken')));
  });

  test('imports a valid backup and replaces local progress', () async {
    final progressStore = _MemoryProgressStore();
    final files = _MemoryBackupFiles(
      pickedBytes: Uint8List.fromList(
        utf8.encode(
          MemoBackupCodec.encode(
            ProgressSnapshot(completedLevels: const ['farm:8']),
          ),
        ),
      ),
    );
    final repository = ProgressRepository(store: progressStore);
    final service = LocalBackupService(
      progressRepository: repository,
      files: files,
    );

    final result = await service.importBackup();

    expect(result?.completedLevels, 1);
    expect((await repository.load()).isCompleted('farm', 8), isTrue);
  });

  test('rejects an incompatible backup before writing it', () async {
    final progressStore = _MemoryProgressStore();
    final repository = ProgressRepository(store: progressStore);
    await repository.save(
      ProgressSnapshot(completedLevels: const ['farm:4']),
    );
    final service = LocalBackupService(progressRepository: repository);

    expect(
      service.restoreDocument(
        '{"app":"other_app","schema_version":1,"progress":{}}',
      ),
      throwsA(isA<FormatException>()),
    );
    expect((await repository.load()).isCompleted('farm', 4), isTrue);
  });
}

class _MemoryBackupFiles implements BackupFileGateway {
  _MemoryBackupFiles({this.pickedBytes});

  final Uint8List? pickedBytes;
  Uint8List? savedBytes;

  @override
  Future<Uint8List?> pick() async => pickedBytes;

  @override
  Future<String?> save({required String name, required Uint8List bytes}) async {
    savedBytes = bytes;
    return 'memory://$name';
  }
}

class _MemoryProgressStore implements ProgressStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String next) async {
    value = next;
  }
}
