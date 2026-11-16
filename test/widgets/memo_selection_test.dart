import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/app_router.dart';
import 'package:tree/src/view/pages/home/home_notifier.dart';
import 'package:tree/src/view/pages/home/home_state.dart';
import 'package:tree/src/view/pages/memo/memo_line_state.dart';
import 'package:tree/src/view/pages/memo/memo_notifier.dart';
import 'package:tree/src/view/pages/memo/memo_state.dart';
import 'package:tree/src/view/pages/memo/memo_view.dart';

void main() {
  testWidgets('tapping below rows clears selection and text input focus', (
    tester,
  ) async {
    final line = MemoLineState(text: 'keep text');
    final container = ProviderContainer(
      overrides: [
        homeProvider.overrideWithValue(
          HomeState(
            memoState: MemoState(list: [line], visibleList: [line]),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: AppRouter.navigatorKey,
          home: const MemoView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    final notifier = container.read(memoProvider.notifier);
    expect(notifier.focusNodes.single.hasFocus, isTrue);
    expect(container.read(memoProvider).focusedIndex, 0);
    await tester.enterText(find.byType(TextField), 'edited text');
    final listRect = tester.getRect(find.byType(ListView));
    await tester.tapAt(Offset(listRect.center.dx, listRect.bottom - 20));
    await tester.pumpAndSettle();
    expect(container.read(memoProvider).focusedIndex, -1);
    expect(notifier.focusNodes.single.hasFocus, isFalse);
    expect(tester.testTextInput.isVisible, isFalse);
    expect(container.read(memoProvider).list.single.text, 'edited text');
  });
}
