import 'dart:io';

import 'package:tree/src/repositories/storage_repository.dart';
import 'package:tree/src/services/firebase/firebase_storage_service.dart';

/// Firebase Storage リポジトリ実装
class FirebaseStorageRepository implements StorageRepository {
  @override
  Future<void> uploadFile(String fileName, String content) async {
    // 一時ファイルを作成してアップロード
    final tempFile = File('${Directory.systemTemp.path}/$fileName');
    await tempFile.writeAsString(content);
    await FirebaseStorageService.uploadMemo(fileName, tempFile);
    await tempFile.delete();
  }

  @override
  Future<String> downloadFile(String fileName) async {
    // 一時ファイルにダウンロードして内容を読み取り
    final tempFile = File('${Directory.systemTemp.path}/$fileName');
    await FirebaseStorageService.downloadMemo(fileName, tempFile.path);
    final content = await tempFile.readAsString();
    await tempFile.delete();
    return content;
  }

  @override
  Future<List<String>> getFileList() async {
    return await FirebaseStorageService.getMemoFileNames();
  }

  @override
  Future<void> deleteFile(String fileName) async {
    await FirebaseStorageService.deleteMemo(fileName);
  }

  @override
  Future<bool> fileExists(String fileName) async {
    try {
      final tempFile = File('${Directory.systemTemp.path}/$fileName');
      await FirebaseStorageService.downloadMemo(fileName, tempFile.path);
      await tempFile.delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
