import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/repositories/storage_repository.dart';

/// テスト用のモックStorageRepository
class TestStorageRepository implements StorageRepository {
  final Map<String, String> _files = {};

  @override
  Future<void> uploadFile(String fileName, String content) async {
    _files[fileName] = content;
  }

  @override
  Future<String> downloadFile(String fileName) async {
    if (!_files.containsKey(fileName)) {
      throw Exception('File not found: $fileName');
    }
    return _files[fileName]!;
  }

  @override
  Future<List<String>> getFileList() async {
    return _files.keys.toList();
  }

  @override
  Future<void> deleteFile(String fileName) async {
    _files.remove(fileName);
  }

  @override
  Future<bool> fileExists(String fileName) async {
    return _files.containsKey(fileName);
  }
}

void main() {
  group('StorageRepository Tests', () {
    late StorageRepository storageRepository;

    setUp(() {
      storageRepository = TestStorageRepository();
    });

    test('uploadFile stores content correctly', () async {
      await storageRepository.uploadFile('test_file.tmson', 'test content');

      expect(await storageRepository.fileExists('test_file.tmson'), isTrue);
      expect(
        await storageRepository.downloadFile('test_file.tmson'),
        equals('test content'),
      );
    });

    test('downloadFile returns correct content', () async {
      await storageRepository.uploadFile('test_file.tmson', 'file content');

      final content = await storageRepository.downloadFile('test_file.tmson');

      expect(content, equals('file content'));
    });

    test('downloadFile throws exception for non-existent file', () async {
      expect(
        () async => await storageRepository.downloadFile('non_existent_file'),
        throwsA(isA<Exception>()),
      );
    });

    test('getFileList returns list of uploaded files', () async {
      await storageRepository.uploadFile('file1.tmson', 'content1');
      await storageRepository.uploadFile('file2.tmson', 'content2');

      final fileList = await storageRepository.getFileList();

      expect(fileList, contains('file1.tmson'));
      expect(fileList, contains('file2.tmson'));
      expect(fileList.length, equals(2));
    });

    test('deleteFile removes file correctly', () async {
      await storageRepository.uploadFile('test_file.tmson', 'content');
      expect(await storageRepository.fileExists('test_file.tmson'), isTrue);

      await storageRepository.deleteFile('test_file.tmson');
      expect(await storageRepository.fileExists('test_file.tmson'), isFalse);
    });

    test('fileExists returns correct status', () async {
      expect(await storageRepository.fileExists('non_existent_file'), isFalse);

      await storageRepository.uploadFile('existing_file.tmson', 'content');
      expect(await storageRepository.fileExists('existing_file.tmson'), isTrue);
    });

    test('multiple operations work together correctly', () async {
      // 複数ファイルのアップロード
      await storageRepository.uploadFile('file1.tmson', 'content1');
      await storageRepository.uploadFile('file2.tmson', 'content2');

      // ファイル一覧の確認
      final fileList = await storageRepository.getFileList();
      expect(fileList.length, equals(2));

      // ファイルの存在確認
      expect(await storageRepository.fileExists('file1.tmson'), isTrue);
      expect(await storageRepository.fileExists('file2.tmson'), isTrue);

      // ファイルのダウンロード
      final content1 = await storageRepository.downloadFile('file1.tmson');
      final content2 = await storageRepository.downloadFile('file2.tmson');
      expect(content1, equals('content1'));
      expect(content2, equals('content2'));

      // ファイルの削除
      await storageRepository.deleteFile('file1.tmson');
      expect(await storageRepository.fileExists('file1.tmson'), isFalse);
      expect(await storageRepository.fileExists('file2.tmson'), isTrue);

      // 最終的なファイル一覧
      final finalFileList = await storageRepository.getFileList();
      expect(finalFileList.length, equals(1));
      expect(finalFileList, contains('file2.tmson'));
    });

    test('empty file list returns empty list', () async {
      final fileList = await storageRepository.getFileList();
      expect(fileList, isEmpty);
    });

    test('uploading same file overwrites content', () async {
      await storageRepository.uploadFile('test_file.tmson', 'original content');
      expect(
        await storageRepository.downloadFile('test_file.tmson'),
        equals('original content'),
      );

      await storageRepository.uploadFile('test_file.tmson', 'updated content');
      expect(
        await storageRepository.downloadFile('test_file.tmson'),
        equals('updated content'),
      );
    });
  });
}
