import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/repositories/file_repository.dart';
import 'package:tree/src/view/pages/memo/memo_state.dart';
import 'package:tree/src/view/pages/memo/memo_line_state.dart';

/// ファイルリポジトリのテスト用モック
class MockFileRepository implements FileRepository {
  final Map<String, MemoState> _files = {};
  bool _shouldThrowError = false;

  void setShouldThrowError(bool value) {
    _shouldThrowError = value;
  }

  @override
  Future<List<String>> getAllDisplayNames() async {
    if (_shouldThrowError) {
      throw Exception('Get display names failed');
    }
    return _files.keys.toList();
  }

  @override
  Future<void> saveMemoStateWithDisplayName(
    MemoState memoState,
    String displayName, {
    bool updateLastModified = true,
  }) async {
    if (_shouldThrowError) {
      throw Exception('Save failed');
    }
    _files[displayName] = memoState;
  }

  @override
  Future<MemoState?> loadMemoStateFromDisplayName(String displayName) async {
    if (_shouldThrowError) {
      throw Exception('Load failed');
    }
    return _files[displayName];
  }

  @override
  Future<void> deleteFileByDisplayName(String displayName) async {
    if (_shouldThrowError) {
      throw Exception('Delete failed');
    }
    _files.remove(displayName);
  }

  @override
  Future<void> copyFileByDisplayName(String displayName) async {
    if (_shouldThrowError) {
      throw Exception('Copy failed');
    }
    final original = _files[displayName];
    if (original != null) {
      final copied = original.copyWith(
        fileName: '${original.fileName}_copy',
      );
      _files['${displayName}_copy'] = copied;
    }
  }

  @override
  Future<String?> getPhysicalFileName(String displayName) async {
    if (_shouldThrowError) {
      throw Exception('Get physical file name failed');
    }
    return _files.containsKey(displayName) ? '${displayName}.tmson' : null;
  }

  @override
  Future<void> ensureFileNameInJson(String physicalFileName) async {
    if (_shouldThrowError) {
      throw Exception('Ensure file name in JSON failed');
    }
    // モック実装では何もしない
  }

  @override
  Future<void> migrateExistingFiles() async {
    if (_shouldThrowError) {
      throw Exception('Migrate existing files failed');
    }
    // モック実装では何もしない
  }
}

void main() {
  group('FileRepository Tests', () {
    late MockFileRepository repository;

    setUp(() {
      repository = MockFileRepository();
    });

    test('MemoStateの保存と読み込みが正常に動作する', () async {
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

      await repository.saveMemoStateWithDisplayName(memoState, 'test_file');
      final loaded = await repository.loadMemoStateFromDisplayName('test_file');

      expect(loaded, isNotNull);
      expect(loaded!.fileName, equals('test_file'));
      expect(loaded.list.length, equals(1));
      expect(loaded.list.first.text, equals('Test content'));
    });

    test('ファイル一覧の取得が正常に動作する', () async {
      final memoState1 = MemoState(fileName: 'file1');
      final memoState2 = MemoState(fileName: 'file2');

      await repository.saveMemoStateWithDisplayName(memoState1, 'file1');
      await repository.saveMemoStateWithDisplayName(memoState2, 'file2');

      final displayNames = await repository.getAllDisplayNames();

      expect(displayNames, contains('file1'));
      expect(displayNames, contains('file2'));
      expect(displayNames.length, equals(2));
    });

    test('ファイルの削除が正常に動作する', () async {
      final memoState = MemoState(fileName: 'test_file');
      await repository.saveMemoStateWithDisplayName(memoState, 'test_file');

      expect(await repository.loadMemoStateFromDisplayName('test_file'), isNotNull);

      await repository.deleteFileByDisplayName('test_file');
      expect(await repository.loadMemoStateFromDisplayName('test_file'), isNull);
    });

    test('ファイルのコピーが正常に動作する', () async {
      final memoState = MemoState(fileName: 'original');
      await repository.saveMemoStateWithDisplayName(memoState, 'original');

      await repository.copyFileByDisplayName('original');

      final original = await repository.loadMemoStateFromDisplayName('original');
      final copied = await repository.loadMemoStateFromDisplayName('original_copy');

      expect(original, isNotNull);
      expect(copied, isNotNull);
      expect(copied!.fileName, equals('original_copy'));
    });

    test('物理ファイル名の取得が正常に動作する', () async {
      final memoState = MemoState(fileName: 'test_file');
      await repository.saveMemoStateWithDisplayName(memoState, 'test_file');

      final physicalFileName = await repository.getPhysicalFileName('test_file');
      expect(physicalFileName, equals('test_file.tmson'));

      final nonExistent = await repository.getPhysicalFileName('nonexistent');
      expect(nonExistent, isNull);
    });

    test('存在しないファイルの読み込みでnullが返される', () async {
      final result = await repository.loadMemoStateFromDisplayName('nonexistent');
      expect(result, isNull);
    });

    test('エラー発生時に適切に例外が投げられる', () async {
      repository.setShouldThrowError(true);

      final memoState = MemoState(fileName: 'test');

      expect(
        () => repository.saveMemoStateWithDisplayName(memoState, 'test'),
        throwsA(isA<Exception>()),
      );
      expect(
        () => repository.loadMemoStateFromDisplayName('test'),
        throwsA(isA<Exception>()),
      );
      expect(
        () => repository.getAllDisplayNames(),
        throwsA(isA<Exception>()),
      );
      expect(
        () => repository.deleteFileByDisplayName('test'),
        throwsA(isA<Exception>()),
      );
      expect(
        () => repository.copyFileByDisplayName('test'),
        throwsA(isA<Exception>()),
      );
      expect(
        () => repository.getPhysicalFileName('test'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
