import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/repositories/local_file_repository.dart';
import 'package:tree/src/repositories/repository_providers.dart';
import 'package:tree/src/view/pages/home/home_notifier.dart';
import 'package:tree/src/view/pages/home/home_state.dart';
import 'package:tree/src/view/pages/memo/memo_notifier.dart';
import 'package:tree/src/view/pages/memo/memo_state.dart';

class _Home extends HomeNotifier {
  @override
  HomeState build() => HomeState();
}

class _Files extends LocalFileRepository {
  MemoState? saved;

  @override
  Future<List<String>> getAllDisplayNames() async =>
      saved == null ? [] : [saved!.fileName];

  @override
  Future<void> migrateExistingFiles() async {}

  @override
  Future<void> saveMemoStateWithDisplayName(
    MemoState memo,
    String name, {
    bool updateLastModified = true,
  }) async {
    saved = memo.copyWith(fileName: name);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('saving refreshes home files without resetting the visible memo or baseline', () async {
    final files = _Files();
    final container = ProviderContainer(
      overrides: [
        homeProvider.overrideWith(_Home.new),
        fileRepositoryProvider.overrideWithValue(files),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(memoProvider, (_, _) {});
    addTearDown(subscription.close);
    final notifier = container.read(memoProvider.notifier);
    notifier.onTextChange(0)('keep this text');
    notifier.onTextChangeEnd();
    notifier.attachImage('aW1hZ2U=', index: 0);
    notifier.resizeImage(0, 0.5);
    final controller = TextEditingController(text: 'saved memo');
    addTearDown(controller.dispose);
    await notifier.saveYes(controller, '', () {});
    await container.pump();
    final memo = container.read(memoProvider);
    expect(container.read(homeProvider).fileNames, ['saved memo']);
    expect(memo.list.single.text, 'keep this text');
    expect(memo.visibleList.single.imageBase64, 'aW1hZ2U=');
    expect(memo.list.single.imageScale, 1.5);
    expect(memo.fileName, 'saved memo');
    expect(notifier.isEditing(), isFalse);
    expect(files.saved!.list, memo.list);
    await container.read(homeProvider.notifier).updateFileNames();
    await container.pump();
    expect(container.read(memoProvider).list, memo.list);
  });
}
