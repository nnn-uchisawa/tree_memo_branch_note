import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tree/src/repositories/file_repository.dart';
import 'package:tree/src/repositories/firebase_storage_repository.dart';
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
  return FirebaseStorageRepository();
}
