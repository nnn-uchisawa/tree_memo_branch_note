import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tree/src/repositories/file_repository.dart';
import 'package:tree/src/repositories/local_file_repository.dart';
import 'package:tree/src/repositories/storage_repository.dart';

part 'repository_providers.g.dart';

/// ファイルリポジトリプロバイダー
@riverpod
FileRepository fileRepository(Ref ref) {
  return LocalFileRepository();
}

/// ストレージリポジトリプロバイダー
@riverpod
StorageRepository storageRepository(Ref ref) {
  return DisabledStorageRepository();
}

class DisabledStorageRepository implements StorageRepository {
  const DisabledStorageRepository();

  Never _unsupported() {
    throw UnsupportedError('Cloud storage is omitted.');
  }

  @override
  Future<void> uploadFile(String fileName, String content) async =>
      _unsupported();

  @override
  Future<String> downloadFile(String fileName) async => _unsupported();

  @override
  Future<List<String>> getFileList() async => _unsupported();

  @override
  Future<void> deleteFile(String fileName) async => _unsupported();

  @override
  Future<bool> fileExists(String fileName) async => false;
}
