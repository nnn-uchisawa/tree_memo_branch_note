import 'package:tree/src/repositories/file_repository.dart';
import 'package:tree/src/services/file/file_service.dart';
import 'package:tree/src/view/pages/memo/memo_state.dart';

/// ローカルファイル リポジトリ実装
class LocalFileRepository implements FileRepository {
  @override
  Future<List<String>> getAllDisplayNames() async {
    return await FileService.getAllDisplayNames();
  }

  @override
  Future<void> saveMemoStateWithDisplayName(
    MemoState memoState,
    String displayName, {
    bool updateLastModified = true,
  }) async {
    await FileService.saveMemoStateWithDisplayName(
      memoState,
      displayName,
      updateLastModified: updateLastModified,
    );
  }

  @override
  Future<MemoState?> loadMemoStateFromDisplayName(String displayName) async {
    return await FileService.loadMemoStateFromDisplayName(displayName);
  }

  @override
  Future<void> deleteFileByDisplayName(String displayName) async {
    await FileService.deleteFileByDisplayName(displayName);
  }

  @override
  Future<void> copyFileByDisplayName(String displayName) async {
    await FileService.copyFileByDisplayName(displayName);
  }

  @override
  Future<String?> getPhysicalFileName(String displayName) async {
    return await FileService.getPhysicalFileName(displayName);
  }

  @override
  Future<void> ensureFileNameInJson(String physicalFileName) async {
    await FileService.ensureFileNameInJson(physicalFileName);
  }

  @override
  Future<void> migrateExistingFiles() async {
    await FileService.migrateExistingFiles();
  }
}
