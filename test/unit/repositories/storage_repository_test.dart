import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/repositories/storage_repository.dart';

/// ストレージリポジトリのテスト用モック
class MockStorageRepository implements StorageRepository {
  final Map<String, String> _files = {};
  bool _shouldThrowError = false;

  void setShouldThrowError(bool value) {
    _shouldThrowError = value;
  }

  @override
  Future<void> uploadFile(String fileName, String content) async {
    if (_shouldThrowError) {
      throw Exception('Upload failed');
    }
    _files[fileName] = content;
  }

  @override
  Future<String> downloadFile(String fileName) async {
    if (_shouldThrowError) {
      throw Exception('Download failed');
    }
    if (!_files.containsKey(fileName)) {
      throw Exception('File not found');
    }
    return _files[fileName]!;
  }

  @override
  Future<List<String>> getFileList() async {
    if (_shouldThrowError) {
      throw Exception('Get file list failed');
    }
    return _files.keys.toList();
  }

  @override
  Future<void> deleteFile(String fileName) async {
    if (_shouldThrowError) {
      throw Exception('Delete failed');
    }
    _files.remove(fileName);
  }

  @override
  Future<bool> fileExists(String fileName) async {
    if (_shouldThrowError) {
      throw Exception('File exists check failed');
    }
    return _files.containsKey(fileName);
  }
}

void main() {
  group('StorageRepository Tests', () {
    late MockStorageRepository repository;

    setUp(() {
      repository = MockStorageRepository();
    });

    test('ファイルのアップロードが正常に動作する', () async {
      const fileName = 'test.txt';
      const content = 'test content';

      await repository.uploadFile(fileName, content);

      expect(await repository.fileExists(fileName), isTrue);
      expect(await repository.downloadFile(fileName), equals(content));
    });

    test('ファイルのダウンロードが正常に動作する', () async {
      const fileName = 'test.txt';
      const content = 'test content';

      await repository.uploadFile(fileName, content);
      final downloadedContent = await repository.downloadFile(fileName);

      expect(downloadedContent, equals(content));
    });

    test('ファイル一覧の取得が正常に動作する', () async {
      await repository.uploadFile('file1.txt', 'content1');
      await repository.uploadFile('file2.txt', 'content2');

      final fileList = await repository.getFileList();

      expect(fileList, contains('file1.txt'));
      expect(fileList, contains('file2.txt'));
      expect(fileList.length, equals(2));
    });

    test('ファイルの削除が正常に動作する', () async {
      const fileName = 'test.txt';
      const content = 'test content';

      await repository.uploadFile(fileName, content);
      expect(await repository.fileExists(fileName), isTrue);

      await repository.deleteFile(fileName);
      expect(await repository.fileExists(fileName), isFalse);
    });

    test('存在しないファイルのダウンロードでエラーが発生する', () async {
      expect(
        () => repository.downloadFile('nonexistent.txt'),
        throwsA(isA<Exception>()),
      );
    });

    test('エラー発生時に適切に例外が投げられる', () async {
      repository.setShouldThrowError(true);

      expect(
        () => repository.uploadFile('test.txt', 'content'),
        throwsA(isA<Exception>()),
      );
      expect(
        () => repository.downloadFile('test.txt'),
        throwsA(isA<Exception>()),
      );
      expect(
        () => repository.getFileList(),
        throwsA(isA<Exception>()),
      );
      expect(
        () => repository.deleteFile('test.txt'),
        throwsA(isA<Exception>()),
      );
      expect(
        () => repository.fileExists('test.txt'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
