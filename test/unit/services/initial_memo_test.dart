import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/services/file/file_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'existing memo files prevent first-run seeding without modifying data',
    () async {
      final directory = await Directory.systemTemp.createTemp('tree-initial-');
      addTearDown(() => directory.delete(recursive: true));
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => directory.path);
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );

      expect(await FileService.hasExistingMemos(), isFalse);
      await File('${directory.path}/unrelated.txt').writeAsString('keep');
      expect(await FileService.hasExistingMemos(), isFalse);
      final memo = File('${directory.path}/existing.tmson');
      await memo.writeAsString('{"fileName":"existing","list":[]}');
      final original = await memo.readAsBytes();
      expect(await FileService.hasExistingMemos(), isTrue);
      expect(await memo.readAsBytes(), original);
    },
  );
}
