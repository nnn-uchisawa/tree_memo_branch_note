import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/view/pages/home/home_notifier.dart';
import 'package:tree/src/view/pages/home/home_state.dart';
import 'package:tree/src/view/pages/memo/memo_line_state.dart';
import 'package:tree/src/view/pages/memo/memo_notifier.dart';
import 'package:tree/src/view/pages/memo/memo_state.dart';

void main() {
  group('MemoNotifier folding', () {
    test('folded sibling blocks keep their children hidden', () {
      final memoState = MemoState(
        list: [
          MemoLineState(index: 0, indent: 0, text: 'root'),
          MemoLineState(index: 1, indent: 0, text: 'parent A'),
          MemoLineState(index: 2, indent: 1, text: 'child A'),
          MemoLineState(index: 3, indent: 0, text: 'parent B'),
          MemoLineState(index: 4, indent: 1, text: 'child B'),
        ],
        visibleList: [
          MemoLineState(index: 0, indent: 0, text: 'root'),
          MemoLineState(index: 1, indent: 0, text: 'parent A'),
          MemoLineState(index: 2, indent: 1, text: 'child A'),
          MemoLineState(index: 3, indent: 0, text: 'parent B'),
          MemoLineState(index: 4, indent: 1, text: 'child B'),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          homeProvider.overrideWithValue(HomeState(memoState: memoState)),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(memoProvider.notifier);
      notifier.toggleFoldingStatus(1)();
      notifier.toggleFoldingStatus(3)();

      final visibleIndexes = container
          .read(memoProvider)
          .visibleList
          .map((line) => line.index)
          .toList();

      expect(visibleIndexes, [0, 1, 3]);
    });
  });
}
