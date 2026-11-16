import 'package:tree/src/view/pages/memo/memo_state.dart';

/// ローカルファイル操作のリポジトリインターフェース
abstract class FileRepository {
  /// ファイル一覧を取得
  Future<List<String>> getAllDisplayNames();

  /// ファイルを保存
  Future<void> saveMemoStateWithDisplayName(
    MemoState memoState,
    String displayName, {
    bool updateLastModified = true,
  });

  /// ファイルを読み込み
  Future<MemoState?> loadMemoStateFromDisplayName(String displayName);

  /// ファイルを削除
  Future<void> deleteFileByDisplayName(String displayName);

  /// ファイルをコピー
  Future<void> copyFileByDisplayName(String displayName);

  /// 物理ファイル名を取得
  Future<String?> getPhysicalFileName(String displayName);

  /// ファイル名をJSONに追加
  Future<void> ensureFileNameInJson(String physicalFileName);

  /// 既存ファイルのマイグレーション
  Future<void> migrateExistingFiles();
}
