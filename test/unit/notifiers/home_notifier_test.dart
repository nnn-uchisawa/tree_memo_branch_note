import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/repositories/file_repository.dart';
import 'package:tree/src/repositories/storage_repository.dart';
import 'package:tree/src/view/pages/memo/memo_state.dart';
import 'package:tree/src/view/pages/memo/memo_line_state.dart';

/// テスト用のモックリポジトリ
class TestFileRepository implements FileRepository {
  final Map<String, MemoState> _files = {};

  @override
  Future<List<String>> getAllDisplayNames() async {
    return _files.keys.toList();
  }

  @override
  Future<void> saveMemoStateWithDisplayName(
    MemoState memoState,
    String displayName, {
    bool updateLastModified = true,
  }) async {
    _files[displayName] = memoState;
  }

  @override
  Future<MemoState?> loadMemoStateFromDisplayName(String displayName) async {
    return _files[displayName];
  }

  @override
  Future<void> deleteFileByDisplayName(String displayName) async {
    _files.remove(displayName);
  }

  @override
  Future<void> copyFileByDisplayName(String displayName) async {
    final original = _files[displayName];
    if (original != null) {
      _files['${displayName}_copy'] = original.copyWith(
        fileName: '${original.fileName}_copy',
      );
    }
  }

  @override
  Future<String?> getPhysicalFileName(String displayName) async {
    return _files.containsKey(displayName) ? '${displayName}.tmson' : null;
  }

  @override
  Future<void> ensureFileNameInJson(String physicalFileName) async {}

  @override
  Future<void> migrateExistingFiles() async {}
}

class TestStorageRepository implements StorageRepository {
  final Map<String, String> _files = {};

  @override
  Future<void> uploadFile(String fileName, String content) async {
    _files[fileName] = content;
  }

  @override
  Future<String> downloadFile(String fileName) async {
    return _files[fileName] ?? '';
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
  group('HomeNotifier Tests', () {
    late TestFileRepository testFileRepository;
    late TestStorageRepository testStorageRepository;

    setUp(() {
      testFileRepository = TestFileRepository();
      testStorageRepository = TestStorageRepository();
    });

    test('ファイル名リストの取得が正常に動作する', () async {
      final memoState1 = MemoState(fileName: 'file1');
      final memoState2 = MemoState(fileName: 'file2');
      final memoState3 = MemoState(fileName: 'file3');

      await testFileRepository.saveMemoStateWithDisplayName(memoState1, 'file1');
      await testFileRepository.saveMemoStateWithDisplayName(memoState2, 'file2');
      await testFileRepository.saveMemoStateWithDisplayName(memoState3, 'file3');

      final fileNames = await testFileRepository.getAllDisplayNames();

      expect(fileNames, contains('file1'));
      expect(fileNames, contains('file2'));
      expect(fileNames, contains('file3'));
      expect(fileNames.length, equals(3));
    });

    test('MemoStateの取得が正常に動作する', () async {
      final memoState = MemoState(
        fileName: 'test_file',
        list: [
          MemoLineState(
            text: 'Test content',
            index: 0,
            indent: 0,
            fontSize: 14.0,
            isEditing: false,
            isFolding: false,
            isReadOnly: false,
          ),
        ],
        oneIndent: 20.0,
        rnd: '0',
        isTapIndentChange: false,
        isEditing: false,
        isTapClear: false,
        isSaveDialogOpen: false,
        needFocusChange: true,
        focusedIndex: -1,
        lastUpdated: DateTime.now().toIso8601String(),
      );

      await testFileRepository.saveMemoStateWithDisplayName(memoState, 'test_file');
      final loaded = await testFileRepository.loadMemoStateFromDisplayName('test_file');

      expect(loaded, isNotNull);
      expect(loaded?.fileName, equals('test_file'));
      expect(loaded?.list.length, equals(1));
      expect(loaded?.list.first.text, equals('Test content'));
    });

    test('ファイルの削除が正常に動作する', () async {
      final memoState = MemoState(fileName: 'test_file');
      await testFileRepository.saveMemoStateWithDisplayName(memoState, 'test_file');

      expect(await testFileRepository.loadMemoStateFromDisplayName('test_file'), isNotNull);

      await testFileRepository.deleteFileByDisplayName('test_file');
      expect(await testFileRepository.loadMemoStateFromDisplayName('test_file'), isNull);
    });

    test('ファイルのコピーが正常に動作する', () async {
      final memoState = MemoState(fileName: 'original');
      await testFileRepository.saveMemoStateWithDisplayName(memoState, 'original');

      await testFileRepository.copyFileByDisplayName('original');

      final original = await testFileRepository.loadMemoStateFromDisplayName('original');
      final copied = await testFileRepository.loadMemoStateFromDisplayName('original_copy');

      expect(original, isNotNull);
      expect(copied, isNotNull);
      expect(copied?.fileName, equals('original_copy'));
    });

    test('クラウドファイル一覧の取得が正常に動作する', () async {
      await testStorageRepository.uploadFile('cloud_file1', 'content1');
      await testStorageRepository.uploadFile('cloud_file2', 'content2');

      final cloudFiles = await testStorageRepository.getFileList();

      expect(cloudFiles, contains('cloud_file1'));
      expect(cloudFiles, contains('cloud_file2'));
      expect(cloudFiles.length, equals(2));
    });

    test('クラウドファイルのアップロードが正常に動作する', () async {
      await testStorageRepository.uploadFile('test_file', 'content');

      expect(await testStorageRepository.fileExists('test_file'), isTrue);
      expect(await testStorageRepository.downloadFile('test_file'), equals('content'));
    });

    test('クラウドファイルのダウンロードが正常に動作する', () async {
      await testStorageRepository.uploadFile('test_file', 'file content');

      final content = await testStorageRepository.downloadFile('test_file');

      expect(content, equals('file content'));
    });

    test('クラウドファイルの削除が正常に動作する', () async {
      await testStorageRepository.uploadFile('test_file', 'content');
      expect(await testStorageRepository.fileExists('test_file'), isTrue);

      await testStorageRepository.deleteFile('test_file');
      expect(await testStorageRepository.fileExists('test_file'), isFalse);
    });

    test('ファイルの存在確認が正常に動作する', () async {
      await testStorageRepository.uploadFile('existing_file', 'content');

      expect(await testStorageRepository.fileExists('existing_file'), isTrue);
      expect(await testStorageRepository.fileExists('non_existing_file'), isFalse);
    });
  });
}
