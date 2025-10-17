import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/services/file/file_service.dart';
import 'package:tree/src/view/pages/memo/memo_state.dart';
import 'package:tree/src/view/pages/memo/memo_line_state.dart';

void main() {
  group('FileService Tests', () {
    late Directory tempDir;

    setUpAll(() async {
      // テスト用の一時ディレクトリを作成
      tempDir = await Directory.systemTemp.createTemp('file_service_test');
    });

    tearDownAll(() async {
      // テスト後に一時ディレクトリを削除
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
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

      await FileService.saveMemoStateWithDisplayName(memoState, 'test_file');
      final loaded = await FileService.loadMemoStateFromDisplayName('test_file');

      expect(loaded, isNotNull);
      expect(loaded!.fileName, equals('test_file'));
      expect(loaded.list.length, equals(1));
      expect(loaded.list.first.text, equals('Test content'));
    });

    test('ファイル一覧の取得が正常に動作する', () async {
      final memoState1 = MemoState(fileName: 'file1');
      final memoState2 = MemoState(fileName: 'file2');

      await FileService.saveMemoStateWithDisplayName(memoState1, 'file1');
      await FileService.saveMemoStateWithDisplayName(memoState2, 'file2');

      final displayNames = await FileService.getAllDisplayNames();

      expect(displayNames, contains('file1'));
      expect(displayNames, contains('file2'));
    });

    test('ファイルの削除が正常に動作する', () async {
      final memoState = MemoState(fileName: 'test_file');
      await FileService.saveMemoStateWithDisplayName(memoState, 'test_file');

      expect(await FileService.loadMemoStateFromDisplayName('test_file'), isNotNull);

      await FileService.deleteFileByDisplayName('test_file');
      expect(await FileService.loadMemoStateFromDisplayName('test_file'), isNull);
    });

    test('ファイルのコピーが正常に動作する', () async {
      final memoState = MemoState(fileName: 'original');
      await FileService.saveMemoStateWithDisplayName(memoState, 'original');

      await FileService.copyFileByDisplayName('original');

      final original = await FileService.loadMemoStateFromDisplayName('original');
      final copied = await FileService.loadMemoStateFromDisplayName('original_copy');

      expect(original, isNotNull);
      expect(copied, isNotNull);
      expect(copied!.fileName, equals('original_copy'));
    });

    test('物理ファイル名の取得が正常に動作する', () async {
      final memoState = MemoState(fileName: 'test_file');
      await FileService.saveMemoStateWithDisplayName(memoState, 'test_file');

      final physicalFileName = await FileService.getPhysicalFileName('test_file');
      expect(physicalFileName, isNotNull);
      expect(physicalFileName, isA<String>());

      final nonExistent = await FileService.getPhysicalFileName('nonexistent');
      expect(nonExistent, isNull);
    });

    test('存在しないファイルの読み込みでnullが返される', () async {
      final result = await FileService.loadMemoStateFromDisplayName('nonexistent');
      expect(result, isNull);
    });

    test('lastUpdatedの更新制御が正常に動作する', () async {
      final memoState = MemoState(
        fileName: 'test_file',
        lastUpdated: '2024-01-01T00:00:00.000Z',
      );

      // updateLastModified: false の場合、lastUpdatedは保持される
      await FileService.saveMemoStateWithDisplayName(
        memoState,
        'test_file',
        updateLastModified: false,
      );

      final loaded = await FileService.loadMemoStateFromDisplayName('test_file');
      expect(loaded!.lastUpdated, equals('2024-01-01T00:00:00.000Z'));

      // updateLastModified: true の場合、lastUpdatedは更新される
      await FileService.saveMemoStateWithDisplayName(
        memoState,
        'test_file',
        updateLastModified: true,
      );

      final updated = await FileService.loadMemoStateFromDisplayName('test_file');
      expect(updated!.lastUpdated, isNot(equals('2024-01-01T00:00:00.000Z')));
    });

    test('ファイル名のJSON設定が正常に動作する', () async {
      final memoState = MemoState(fileName: 'test_file');
      await FileService.saveMemoStateWithDisplayName(memoState, 'test_file');

      // 物理ファイル名を取得
      final physicalFileName = await FileService.getPhysicalFileName('test_file');
      expect(physicalFileName, isNotNull);

      // ensureFileNameInJsonを実行
      await FileService.ensureFileNameInJson(physicalFileName!);

      // ファイルが正しく保存されていることを確認
      final loaded = await FileService.loadMemoStateFromDisplayName('test_file');
      expect(loaded, isNotNull);
      expect(loaded!.fileName, equals('test_file'));
    });
  });
}
