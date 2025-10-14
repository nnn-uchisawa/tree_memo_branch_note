import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tree/src/services/firebase/firebase_auth_service.dart';
import 'package:tree/src/services/firebase/firebase_storage_service.dart';
import 'package:tree/src/util/app_utils.dart';
import 'package:tree/src/view/pages/home/home_state.dart';
import 'package:tree/src/view/pages/memo/memo_line_state.dart';
import 'package:tree/src/view/pages/memo/memo_state.dart';

part 'home_notifier.g.dart';

@riverpod
class HomeNotifier extends _$HomeNotifier {
  @override
  HomeState build() {
    updateFileNames();
    return HomeState();
  }

  /// ファイル名リストを更新する
  Future<void> updateFileNames() async {
    final fileNames = await getFileNameList();
    state = state.copyWith(fileNames: fileNames);
  }

  /// txtファイルの内容をMemoStateに変換する（プライベート）
  MemoState _parseTextFileToMemoState(String content, String fileName) {
    final lines = content.split('\n');
    final List<MemoLineState> memoLines = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      int indent = 0;
      String text = line;
      double fontSize = 14;
      bool isReadOnly = false;

      // 先頭の空白文字を計算（基本インデント）
      final leadingSpaces = line.length - line.trimLeft().length;
      final baseIndent = (leadingSpaces / 2).round();
      final trimmedLine = line.trimLeft();

      // マークダウンの解析
      if (trimmedLine.startsWith('#')) {
        // ヘッダー（# ## ### #### ##### ######）
        final headerMatch = RegExp(r'^(#{1,6})\s*(.*)').firstMatch(trimmedLine);
        if (headerMatch != null) {
          indent = baseIndent + (headerMatch.group(1)!.length - 1);
          text = headerMatch.group(2)!;
          fontSize = 14 + (6 - headerMatch.group(1)!.length) * 2.0;
          isReadOnly = true;
        }
      } else if (RegExp(r'^[-*+]\s').hasMatch(trimmedLine)) {
        // リスト項目（ネストも考慮）
        indent = baseIndent + 1;

        // タスクリスト（チェックボックス）の検出
        final taskMatch = RegExp(
          r'^[-*+]\s*\[([ xX])\]\s*(.*)',
        ).firstMatch(trimmedLine);
        if (taskMatch != null) {
          final isChecked = taskMatch.group(1)!.toLowerCase() == 'x';
          text = '${isChecked ? '✓' : '○'} ${taskMatch.group(2)!}';
        } else {
          text = trimmedLine.substring(2);
        }
      } else if (trimmedLine.startsWith('> ')) {
        // 引用（ネストした引用も考慮）
        var quoteLevel = 0;
        var quoteLine = trimmedLine;
        while (quoteLine.startsWith('> ')) {
          quoteLevel++;
          quoteLine = quoteLine.substring(2);
        }
        indent = baseIndent + quoteLevel;
        text = quoteLine;
        isReadOnly = true;
      } else if (RegExp(r'^\d+\.\s').hasMatch(trimmedLine)) {
        // 番号付きリスト（ネストも考慮）
        indent = baseIndent + 1;
        text = trimmedLine.replaceFirst(RegExp(r'^\d+\.\s'), '');
      } else if (RegExp(r'^```').hasMatch(trimmedLine)) {
        // コードブロック開始/終了
        indent = baseIndent;
        text = trimmedLine;
        isReadOnly = true;
        // コードブロックの中身を次行から抽出
        int codeStart = i + 1;
        while (codeStart < lines.length &&
            !lines[codeStart].startsWith('```')) {
          memoLines.add(
            MemoLineState(
              index: memoLines.length,
              text: lines[codeStart],
              indent: baseIndent + 1,
              fontSize: fontSize,
              isReadOnly: true,
            ),
          );
          codeStart++;
        }
        i = codeStart; // コードブロック終了行までスキップ
        continue;
      } else if (RegExp(r'^`[^`]+`').hasMatch(trimmedLine)) {
        // インラインコード
        indent = baseIndent;
        text = trimmedLine;
        // インラインコードの中身を抽出
        final inlineCodeMatch = RegExp(r'^`([^`]+)`').firstMatch(trimmedLine);
        if (inlineCodeMatch != null) {
          memoLines.add(
            MemoLineState(
              index: memoLines.length,
              text: inlineCodeMatch.group(1)!,
              indent: baseIndent + 1,
              fontSize: fontSize,
              isReadOnly: true,
            ),
          );
        }
        isReadOnly = true;
      } else if (RegExp(r'^---+$|^\*\*\*+$|^___+$').hasMatch(trimmedLine)) {
        // 水平線
        indent = baseIndent;
        text = trimmedLine;
        isReadOnly = true;
      } else if (RegExp(r'^\|.+\|').hasMatch(trimmedLine)) {
        // テーブル行
        indent = baseIndent;
        text = trimmedLine;
      } else if (RegExp(r'^!\[.*\]\(.*\)').hasMatch(trimmedLine)) {
        // 画像
        indent = baseIndent;
        text = trimmedLine;
        isReadOnly = true;
      } else if (RegExp(r'^\[.*\]\(.*\)').hasMatch(trimmedLine)) {
        // リンク
        indent = baseIndent;
        text = trimmedLine;
      } else if (RegExp(r'^\s*$').hasMatch(line)) {
        // 空行
        indent = 0;
        text = '';
      } else {
        // 通常のテキスト
        indent = baseIndent;
        text = trimmedLine;
      }

      // 太字、斜体の検出（表示用、編集は可能）
      if (RegExp(r'\*\*.*\*\*|\__.*\__').hasMatch(text)) {
        // 太字が含まれている
      }
      if (RegExp(r'\*.*\*|\_.*\_').hasMatch(text)) {
        // 斜体が含まれている
      }

      // 空行の場合もMemoLineStateとして追加
      memoLines.add(
        MemoLineState(
          index: i,
          text: text,
          indent: indent,
          fontSize: fontSize,
          isReadOnly: isReadOnly,
        ),
      );
    }

    return MemoState(
      list: memoLines,
      oneIndent: 20.0,
      focusedIndex: -1,
      visibleList: memoLines
          .asMap()
          .entries
          .map(
            (entry) => MemoLineState(
              index: entry.key,
              text: entry.value.text,
              indent: entry.value.indent,
              fontSize: entry.value.fontSize,
              isReadOnly: entry.value.isReadOnly,
            ),
          )
          .toList(),
      fileName: fileName,
    );
  }

  Future<MemoState> getMemoState(String fileName) async {
    var dir = await getApplicationDocumentsDirectory();

    File file = dir.listSync().whereType<File>().where((File f) {
      return f.uri.pathSegments.last == '$fileName.tmson';
    }).first;
    String jsonString = await file.readAsString();
    Map<String, dynamic> j = json.decode(jsonString);
    var memoState = MemoState.fromJson(j);
    return memoState;
  }

  Future<List<String>> getFileNameList() async {
    var dir = await getApplicationDocumentsDirectory();

    List<String> fileNames = dir
        .listSync()
        .whereType<File>()
        .map((File f) => f.uri.pathSegments.last)
        .where((String s) {
          return s.split('.').last == "tmson";
        })
        .map((String s) => s.split('.').first)
        .toList();
    return fileNames;
  }

  void saveFileToDocuments(File file) async {
    var dir = await getApplicationDocumentsDirectory();
    final fileName = file.path.split('/').last;
    final fileNameWithoutExt = fileName.split('.').first;
    final fileExtension = fileName.split('.').last;

    String contentToSave;
    String targetFileName;

    try {
      // ファイルサイズチェック（1000KB = 1MB制限）
      const int maxFileSize = 1000 * 1024; // 1000KB in bytes
      final fileSize = await file.length();

      if (fileSize > maxFileSize) {
        final fileSizeKB = (fileSize / 1024).toStringAsFixed(1);
        AppUtils.showSnackBar(
          'ファイルサイズが制限を超えています: ${fileSizeKB}KB (制限: 1000KB)',
        );
        return;
      }

      final fileContent = await file.readAsString();

      if (fileExtension == 'txt') {
        // txtファイルの場合、パースしてMemoStateに変換
        final memoState = _parseTextFileToMemoState(
          fileContent,
          fileNameWithoutExt,
        );
        contentToSave = json.encode(memoState.toJson());
        targetFileName = '$fileNameWithoutExt.tmson';
      } else if (fileExtension == 'tmson') {
        // tmsonファイルの場合、そのままコピー
        contentToSave = fileContent;
        targetFileName = fileName;
      } else {
        AppUtils.showSnackBar('サポートされていないファイル形式です');
        return;
      }

      var targetPath = '${dir.path}/$targetFileName';
      var newFile = File(targetPath);
      await newFile.writeAsString(contentToSave);
      await updateFileNames();

      // 成功時にファイルサイズも表示
      final finalFileSizeKB = (fileSize / 1024).toStringAsFixed(1);
      AppUtils.showSnackBar(
        'ファイルをインポートしました: $targetFileName (${finalFileSizeKB}KB)',
      );
    } catch (e) {
      AppUtils.showSnackBar('ファイルの読み込みに失敗しました: $e');
    }
  }

  void setMemoState(MemoState? memoState) {
    state = state.copyWith(memoState: memoState);
  }

  Future<void> deleteFileFromName(String fileName) async {
    var dir = await getApplicationDocumentsDirectory();
    var path = '${dir.path}/$fileName.tmson';
    var file = File(path);
    await file.delete();
    // ファイルリストを更新
    await updateFileNames();
  }

  Future<void> copyFile(String fileName) async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      var originalPath = '${dir.path}/$fileName.tmson';
      var originalFile = File(originalPath);

      if (!await originalFile.exists()) {
        AppUtils.showSnackBar('コピー元のファイルが存在しません');
        return;
      }

      // 新しいファイル名を生成（重複チェック付き）
      String newFileName = await _generateUniqueFileName(fileName);
      var newPath = '${dir.path}/$newFileName.tmson';
      var newFile = File(newPath);

      // ファイルの内容を読み取ってコピー
      String content = await originalFile.readAsString();
      await newFile.writeAsString(content);

      // ファイルリストを更新
      await updateFileNames();

      AppUtils.showSnackBar('ファイルをコピーしました: $newFileName');
      log('ファイルコピー成功: $fileName -> $newFileName');
    } catch (e) {
      log('copyFile エラー: $e');
      AppUtils.showSnackBar('ファイルのコピーに失敗しました');
    }
  }

  /// ユニークなファイル名を生成する（プライベート）
  Future<String> _generateUniqueFileName(String originalFileName) async {
    String baseFileName = originalFileName;
    String newFileName = baseFileName;
    int counter = 1;

    // 既存のファイル名をすべて取得
    List<String> existingFileNames = await getFileNameList();

    // 元のファイル名に(n)が既に付いている場合の処理
    RegExp regExp = RegExp(r'^(.+)\((\d+)\)$');
    Match? match = regExp.firstMatch(originalFileName);
    if (match != null) {
      baseFileName = match.group(1)!;
      // 既存の番号は無視して、新しい番号を付ける
    }

    // ユニークなファイル名を生成
    while (existingFileNames.contains(newFileName)) {
      newFileName = '$baseFileName($counter)';
      counter++;
    }

    return newFileName;
  }

  /// ファイル名からMemoStateを読み込む共通処理
  Future<MemoState> _loadMemoStateFromFile(String fileName) async {
    var dir = await getApplicationDocumentsDirectory();
    var filePath = '${dir.path}/$fileName.tmson';
    var file = File(filePath);

    if (!await file.exists()) {
      throw Exception('ファイルが存在しません');
    }

    String jsonString = await file.readAsString();
    Map<String, dynamic> j = json.decode(jsonString);
    return MemoState.fromJson(j);
  }

  /// MemoStateをテキスト形式に変換する共通処理
  /// インデントはスペースで表現、改行ごとにインデント付与、各MemoLineStateごとに空行を追加
  String _convertMemoStateToText(MemoState memoState) {
    StringBuffer buffer = StringBuffer();
    for (final line in memoState.list) {
      if (line.text.trim().isEmpty) continue;
      final indentStr = '  ' * (line.indent);
      final splitLines = line.text.split('\n');
      for (final l in splitLines) {
        buffer.writeln('$indentStr$l');
      }
      buffer.writeln(); // ここで空行を追加
    }
    return buffer.toString();
  }

  /// ファイル名からテキスト形式に変換する共通処理
  Future<String> _convertFileToText(String fileName) async {
    final memoState = await _loadMemoStateFromFile(fileName);
    return _convertMemoStateToText(memoState);
  }

  Future<void> exportFileAsTxt(String fileName) async {
    try {
      // ファイルをテキストに変換
      String txtContent = await _convertFileToText(fileName);

      // tmpディレクトリにtxtファイル作成
      final tmpDir = await getTemporaryDirectory();
      final txtPath = '${tmpDir.path}/$fileName.txt';
      final txtFile = File(txtPath);
      await txtFile.writeAsString(txtContent);

      // Share起動
      await AppUtils.shareFile(txtFile.path, fileName: '$fileName.txt');
    } on Exception catch (e) {
      log('exportFileAsTxt エラー: $e');
      AppUtils.showSnackBar('エクスポート元のファイルが存在しません');
    } catch (e) {
      log('exportFileAsTxt エラー: $e');
      AppUtils.showSnackBar('エクスポートに失敗しました');
    }
  }

  Future<void> copyToClipboard(String fileName) async {
    try {
      // ファイルをテキストに変換
      String txtContent = await _convertFileToText(fileName);

      // クリップボードにコピー
      await AppUtils.copyToClipboard(txtContent);
      AppUtils.showSnackBar('クリップボードにコピーしました');
    } on Exception catch (e) {
      log('copyToClipboard エラー: $e');
      AppUtils.showSnackBar('ファイルが存在しません');
    } catch (e) {
      log('copyToClipboard エラー: $e');
      AppUtils.showSnackBar('クリップボードへのコピーに失敗しました');
    }
  }

  // ===== Cloud (Firebase Storage) =====

  /// クラウド上のメモ一覧を取得
  Future<List<String>> fetchCloudMemoNames() async {
    try {
      final names = await FirebaseStorageService.getMemoFileNames();
      return names;
    } catch (e) {
      AppUtils.showSnackBar('クラウド一覧の取得に失敗しました: $e');
      return [];
    }
  }

  /// 単一メモをクラウドからダウンロードしてローカルへ保存後、一覧更新
  Future<void> downloadMemoFromCloud(String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final localPath = '${dir.path}/$fileName.tmson';
      await FirebaseStorageService.downloadMemo(fileName, localPath);
      await updateFileNames();
      AppUtils.showSnackBar('ダウンロードしました: $fileName');
    } catch (e) {
      AppUtils.showSnackBar('ダウンロードに失敗しました: $e');
    }
  }

  /// すべてのメモをクラウドからダウンロードしてローカルへ保存後、一覧更新
  Future<void> downloadAllMemosFromCloud(List<String> fileNames) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      for (final name in fileNames) {
        final localPath = '${dir.path}/$name.tmson';
        await FirebaseStorageService.downloadMemo(name, localPath);
      }
      await updateFileNames();
      AppUtils.showSnackBar('一括ダウンロードが完了しました');
    } catch (e) {
      AppUtils.showSnackBar('一括ダウンロードに失敗しました: $e');
    }
  }

  /// クラウド上のメモを削除
  Future<void> deleteMemoInCloud(String fileName) async {
    try {
      await FirebaseStorageService.deleteMemo(fileName);
      AppUtils.showSnackBar('クラウドから削除しました: $fileName');
    } catch (e) {
      AppUtils.showSnackBar('クラウド削除に失敗しました: $e');
    }
  }

  /// ローカルのメモをクラウドへアップロード
  Future<void> uploadMemoToCloud(String fileName) async {
    try {
      if (!FirebaseAuthService.isSignedIn) {
        AppUtils.showSnackBar('ログインが必要です');
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName.tmson');

      if (!await file.exists()) {
        AppUtils.showSnackBar('ファイルが見つかりません');
        return;
      }

      await FirebaseStorageService.uploadMemo(fileName, file);
      AppUtils.showSnackBar('クラウドに保存しました');
    } catch (e) {
      AppUtils.showSnackBar('クラウド保存に失敗しました: $e');
    }
  }

  /// ファイル選択と情報取得のみ（UI部品はViewで生成）
  Future<Map<String, dynamic>?> pickFileAndGetInfo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty || result.files.length > 1) {
      return null;
    }
    final filePath = result.files.single.path!;
    final fileExtension = filePath.split('/').last.split('.').last;
    final fileName = filePath.split('/').last.replaceAll(".$fileExtension", "");
    if (!(fileExtension == 'tmson' || fileExtension == 'txt')) {
      return null;
    }
    final file = File(filePath);
    final fileSize = await file.length();
    final fileSizeKB = (fileSize / 1024).toStringAsFixed(1);
    return {
      'file': file,
      'fileName': fileName,
      'fileExtension': fileExtension,
      'fileSize': fileSize,
      'fileSizeKB': fileSizeKB,
    };
  }
}
