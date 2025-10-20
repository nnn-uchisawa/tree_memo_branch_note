/// ストレージ操作のリポジトリインターフェース
abstract class StorageRepository {
  /// ファイルをアップロード
  Future<void> uploadFile(String fileName, String content);
  
  /// ファイルをダウンロード
  Future<String> downloadFile(String fileName);
  
  /// ファイル一覧を取得
  Future<List<String>> getFileList();
  
  /// ファイルを削除
  Future<void> deleteFile(String fileName);
  
  /// ファイルの存在確認
  Future<bool> fileExists(String fileName);
}
