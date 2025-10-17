import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:tree/src/view/pages/memo/memo_state.dart';

/// ファイルI/O操作を管理するサービス
class FileService {
  /// 表示名（JSON内のfileName）から物理ファイル名を取得
  static Future<String?> getPhysicalFileName(String displayName) async {
    var dir = await getApplicationDocumentsDirectory();
    final tmsonFiles = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.uri.pathSegments.last.endsWith('.tmson'))
        .toList();
    
    for (File file in tmsonFiles) {
      try {
        final content = await file.readAsString();
        final jsonData = json.decode(content);
        if (jsonData['fileName'] == displayName) {
          return file.uri.pathSegments.last.replaceAll('.tmson', '');
        }
      } catch (_) {}
    }
    return null;
  }

  /// 物理ファイル名から表示名を取得
  static Future<String?> getDisplayName(String physicalFileName) async {
    var dir = await getApplicationDocumentsDirectory();
    var filePath = '${dir.path}/$physicalFileName.tmson';
    var file = File(filePath);

    if (!await file.exists()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      final jsonData = json.decode(content);
      return jsonData['fileName'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// JSON内のfileNameが正しく設定されているか確認・修正
  static Future<void> ensureFileNameInJson(String physicalFileName) async {
    var dir = await getApplicationDocumentsDirectory();
    var filePath = '${dir.path}/$physicalFileName.tmson';
    var file = File(filePath);

    if (!await file.exists()) {
      return;
    }

    try {
      final content = await file.readAsString();
      final jsonData = json.decode(content);
      
      // fileNameが存在しないか空の場合、物理ファイル名を設定
      if (!jsonData.containsKey('fileName') ||
          jsonData['fileName'] == null ||
          (jsonData['fileName'] as String).isEmpty) {
        jsonData['fileName'] = physicalFileName;
        await file.writeAsString(json.encode(jsonData));
      }
    } catch (_) {
      // JSONパースエラーの場合は何もしない
    }
  }

  /// 表示名からMemoStateを読み込む
  static Future<MemoState> loadMemoStateFromDisplayName(String displayName) async {
    final physicalFileName = await getPhysicalFileName(displayName);
    if (physicalFileName == null) {
      throw Exception('ファイルが見つかりません: $displayName');
    }
    return await loadMemoStateFromPhysicalName(physicalFileName);
  }

  /// 物理ファイル名からMemoStateを読み込む
  static Future<MemoState> loadMemoStateFromPhysicalName(String physicalFileName) async {
    var dir = await getApplicationDocumentsDirectory();
    var filePath = '${dir.path}/$physicalFileName.tmson';
    var file = File(filePath);

    if (!await file.exists()) {
      throw Exception('ファイルが存在しません');
    }

    String jsonString = await file.readAsString();
    Map<String, dynamic> j = json.decode(jsonString);
    return MemoState.fromJson(j);
  }

  /// MemoStateを表示名で保存
  static Future<void> saveMemoStateWithDisplayName(MemoState memoState, String displayName) async {
    var dir = await getApplicationDocumentsDirectory();
    var path = '${dir.path}/$displayName.tmson';
    var file = File(path);

    // 表示名をJSON内のfileNameとして設定
    var j = memoState.toJson();
    j['fileName'] = displayName;

    // JSONエンコードのチェック
    String jsonString;
    try {
      jsonString = json.encode(j);
    } catch (e) {
      throw Exception("データのJSONエンコードに失敗しました: $e");
    }

    // ファイル書き込み
    await file.writeAsString(jsonString);

    // ファイルが正常に書き込まれたかチェック
    if (!await file.exists()) {
      throw Exception("ファイルの作成に失敗しました");
    }

    log('ファイル保存成功: $path');
  }

  /// 表示名でファイルを削除
  static Future<void> deleteFileByDisplayName(String displayName) async {
    final physicalFileName = await getPhysicalFileName(displayName);
    if (physicalFileName == null) {
      throw Exception('ファイルが見つかりません: $displayName');
    }

    var dir = await getApplicationDocumentsDirectory();
    var path = '${dir.path}/$physicalFileName.tmson';
    var file = File(path);
    await file.delete();
  }

  /// 表示名でファイルをコピー
  static Future<String> copyFileByDisplayName(String displayName) async {
    final physicalFileName = await getPhysicalFileName(displayName);
    if (physicalFileName == null) {
      throw Exception('ファイルが見つかりません: $displayName');
    }

    var dir = await getApplicationDocumentsDirectory();
    var originalPath = '${dir.path}/$physicalFileName.tmson';
    var originalFile = File(originalPath);

    if (!await originalFile.exists()) {
      throw Exception('コピー元のファイルが存在しません');
    }

    // 新しいファイル名を生成（重複チェック付き）
    String newDisplayName = await generateUniqueDisplayName(displayName);
    String newPhysicalFileName = await generateUniquePhysicalFileName(physicalFileName);
    var newPath = '${dir.path}/$newPhysicalFileName.tmson';
    var newFile = File(newPath);

    // ファイルの内容を読み取ってコピー
    String content = await originalFile.readAsString();
    
    // JSONをパースしてfileNameを更新
    try {
      final jsonData = json.decode(content);
      jsonData['fileName'] = newDisplayName;
      content = json.encode(jsonData);
    } catch (_) {
      // JSONパースエラーの場合はそのままコピー
    }
    
    await newFile.writeAsString(content);
    return newDisplayName;
  }

  /// ユニークな表示名を生成
  static Future<String> generateUniqueDisplayName(String originalDisplayName) async {
    String baseFileName = originalDisplayName;
    String newFileName = baseFileName;
    int counter = 1;

    // 既存の表示名をすべて取得
    List<String> existingDisplayNames = await getAllDisplayNames();

    // 元のファイル名に(n)が既に付いている場合の処理
    RegExp regExp = RegExp(r'^(.+)\((\d+)\)$');
    Match? match = regExp.firstMatch(originalDisplayName);
    if (match != null) {
      baseFileName = match.group(1)!;
      // 既存の番号は無視して、新しい番号を付ける
    }

    // ユニークなファイル名を生成
    while (existingDisplayNames.contains(newFileName)) {
      newFileName = '$baseFileName($counter)';
      counter++;
    }

    return newFileName;
  }

  /// ユニークな物理ファイル名を生成
  static Future<String> generateUniquePhysicalFileName(String originalPhysicalFileName) async {
    String baseFileName = originalPhysicalFileName;
    String newFileName = baseFileName;
    int counter = 1;

    var dir = await getApplicationDocumentsDirectory();
    final existingFiles = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.uri.pathSegments.last.endsWith('.tmson'))
        .map((f) => f.uri.pathSegments.last.replaceAll('.tmson', ''))
        .toList();

    // 元のファイル名に(n)が既に付いている場合の処理
    RegExp regExp = RegExp(r'^(.+)\((\d+)\)$');
    Match? match = regExp.firstMatch(originalPhysicalFileName);
    if (match != null) {
      baseFileName = match.group(1)!;
      // 既存の番号は無視して、新しい番号を付ける
    }

    // ユニークなファイル名を生成
    while (existingFiles.contains(newFileName)) {
      newFileName = '$baseFileName($counter)';
      counter++;
    }

    return newFileName;
  }

  /// すべての表示名を取得
  static Future<List<String>> getAllDisplayNames() async {
    var dir = await getApplicationDocumentsDirectory();

    List<String> fileNames = [];

    // tmsonファイルを取得
    final tmsonFiles = dir
        .listSync()
        .whereType<File>()
        .where((File f) => f.uri.pathSegments.last.endsWith('.tmson'))
        .toList();

    for (File file in tmsonFiles) {
      try {
        // ファイルを読み込んでJSONをパース
        final content = await file.readAsString();
        final jsonData = json.decode(content);

        // fileNameアトリビュートを取得
        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('fileName')) {
          final fileName = jsonData['fileName'] as String?;
          if (fileName != null && fileName.isNotEmpty) {
            fileNames.add(fileName);
          }
        }
      } catch (e) {
        // JSONパースエラーの場合、ファイル名から拡張子を除いたものを使用
        final fileName = file.uri.pathSegments.last;
        if (fileName.endsWith('.tmson')) {
          fileNames.add(
            fileName.substring(0, fileName.length - 6),
          ); // .tmsonを除去
        }
      }
    }

    return fileNames;
  }

  /// 既存ファイルのマイグレーション処理
  static Future<void> migrateExistingFiles() async {
    var dir = await getApplicationDocumentsDirectory();
    final tmsonFiles = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.uri.pathSegments.last.endsWith('.tmson'))
        .toList();

    for (File file in tmsonFiles) {
      final physicalFileName = file.uri.pathSegments.last.replaceAll(
        '.tmson',
        '',
      );
      await ensureFileNameInJson(physicalFileName);
    }
  }
}
