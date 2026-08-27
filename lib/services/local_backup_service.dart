import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:memo_granja/models/progress_snapshot.dart';
import 'package:memo_granja/repositories/progress_repository.dart';

class BackupResult {
  const BackupResult({required this.completedLevels});

  final int completedLevels;
}

class BackupExportCanceled implements Exception {
  const BackupExportCanceled();
}

/// File boundary for portable backups. The codec remains testable without a
/// platform picker or saver.
abstract interface class BackupFileGateway {
  Future<String?> save({required String name, required Uint8List bytes});

  Future<Uint8List?> pick();
}

class PlatformBackupFileGateway implements BackupFileGateway {
  const PlatformBackupFileGateway();

  @override
  Future<String?> save({required String name, required Uint8List bytes}) {
    return FileSaver.instance.saveAs(
      name: name.replaceFirst(RegExp(r'\.json$'), ''),
      bytes: bytes,
      fileExtension: 'json',
      mimeType: MimeType.json,
    );
  }

  @override
  Future<Uint8List?> pick() async {
    final selection = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    return selection?.files.single.bytes;
  }
}

class MemoBackupCodec {
  static const appId = 'memo_granja';
  static const schemaVersion = 1;

  static String encode(ProgressSnapshot progress) {
    return jsonEncode({
      'app': appId,
      'schema_version': schemaVersion,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'progress': progress.toJson(),
    });
  }

  static ProgressSnapshot decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<Object?, Object?> || decoded['app'] != appId) {
      throw const FormatException('Unsupported Memo Granja backup');
    }
    if (decoded['schema_version'] != schemaVersion) {
      throw const FormatException('Unsupported Memo Granja backup version');
    }
    return ProgressSnapshot.fromJson(decoded['progress']);
  }
}

class LocalBackupService {
  LocalBackupService({
    ProgressRepository? progressRepository,
    BackupFileGateway? files,
  })  : _progressRepository = progressRepository ?? ProgressRepository(),
        _files = files ?? const PlatformBackupFileGateway();

  final ProgressRepository _progressRepository;
  final BackupFileGateway _files;

  Future<BackupResult> exportBackup() async {
    final progress = await _progressRepository.load();
    final bytes = Uint8List.fromList(
      utf8.encode(MemoBackupCodec.encode(progress)),
    );
    final fileName =
        'memo_granja_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final savedPath = await _files.save(name: fileName, bytes: bytes);
    if (savedPath == null || savedPath.isEmpty) {
      throw const BackupExportCanceled();
    }
    return BackupResult(completedLevels: progress.completedLevels.length);
  }

  Future<BackupResult?> importBackup() async {
    final bytes = await _files.pick();
    if (bytes == null) return null;
    final progress = MemoBackupCodec.decode(utf8.decode(bytes));
    await _progressRepository.save(progress);
    return BackupResult(completedLevels: progress.completedLevels.length);
  }

  Future<ProgressSnapshot> restoreDocument(String source) async {
    final progress = MemoBackupCodec.decode(source);
    await _progressRepository.save(progress);
    return progress;
  }
}
