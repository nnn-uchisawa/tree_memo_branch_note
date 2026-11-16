import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/app_router.dart';
import 'package:tree/src/view/pages/home/home_notifier.dart';
import 'package:tree/src/view/pages/home/home_state.dart';
import 'package:tree/src/view/pages/memo/memo_line_state.dart';
import 'package:tree/src/view/pages/memo/memo_line_view.dart';
import 'package:tree/src/view/pages/memo/memo_notifier.dart';
import 'package:tree/src/view/pages/memo/memo_state.dart';

void main() {
  testWidgets('thumbnail and font sizes share the slider dialog with reset', (
    tester,
  ) async {
    final line = MemoLineState(imageBase64: 'aW1hZ2U=');
    final container = ProviderContainer(
      overrides: [
        homeProvider.overrideWithValue(
          HomeState(
            memoState: MemoState(
              list: [line],
              visibleList: [line],
              focusedIndex: 0,
            ),
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
          home: const Scaffold(),
        ),
      ),
    );
    final subscription = container.listen(memoProvider, (_, _) {});
    addTearDown(subscription.close);
    final notifier = container.read(memoProvider.notifier);
    notifier.showSliderImageSizeChangeDialog();
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOneWidget);
    tester.widget<Slider>(find.byType(Slider)).onChanged!(1.5);
    await tester.pump();
    expect(find.text('150%'), findsOneWidget);
    expect(container.read(memoProvider).list.single.imageScale, 1.5);
    await tester.tap(find.text('reset'));
    await tester.pump();
    expect(find.text('100%'), findsOneWidget);
    AppRouter.navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    notifier.showSliderFontSizeChangeDialog();
    await tester.pumpAndSettle();
    tester.widget<Slider>(find.byType(Slider)).onChanged!(20);
    await tester.pump();
    expect(container.read(memoProvider).list.single.fontSize, 20);
    await tester.tap(find.text('reset'));
    await tester.pump();
    expect(container.read(memoProvider).list.single.fontSize, 14);
    expect(container.read(memoProvider).list.single.imageScale, 1);
  });

  testWidgets('image tap opens a pinchable overlay and close returns to memo', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final line = MemoLineState(
      imageBase64: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
    );
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
    final focusNode = FocusNode();
    final subscription = container.listen(memoProvider, (_, _) {});
    addTearDown(subscription.close);
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: MemoLineView(
              oneIndent: 20,
              memoLineState: line,
              focusNode: focusNode,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final imageRect = tester.getRect(find.byType(Image));
    await tester.tapAt(Offset(imageRect.right + 100, imageRect.center.dy));
    await tester.pumpAndSettle();
    expect(container.read(memoProvider).focusedIndex, 0);
    expect(focusNode.hasFocus, isTrue);
    expect(find.byType(InteractiveViewer), findsNothing);
    await tester.tap(find.byType(Image));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(container.read(memoProvider).focusedIndex, 0);
    final center = tester.getCenter(find.byType(InteractiveViewer));
    final first = await tester.startGesture(
      center - const Offset(40, 0),
      pointer: 1,
    );
    final second = await tester.startGesture(
      center + const Offset(40, 0),
      pointer: 2,
    );
    await tester.pump();
    await first.moveTo(center - const Offset(100, 0));
    await second.moveTo(center + const Offset(100, 0));
    await tester.pump();
    final transform = tester.widget<Transform>(
      find
          .descendant(
            of: find.byType(InteractiveViewer),
            matching: find.byType(Transform),
          )
          .first,
    );
    expect(transform.transform.getMaxScaleOnAxis(), greaterThan(1));
    await first.up();
    await second.up();
    await tester.tap(find.byTooltip('閉じる'));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
    await tester.longPress(find.byType(Image));
    await tester.pumpAndSettle();
    expect(find.text('この画像を削除しますか？'), findsOneWidget);
    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();
    expect(container.read(memoProvider).list.single.imageBase64, isNotNull);
    await tester.longPress(find.byType(Image));
    await tester.pumpAndSettle();
    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();
    expect(container.read(memoProvider).list.single.imageBase64, isNull);
    expect(container.read(memoProvider).list.single.imageScale, 1);
    expect(container.read(memoProvider).visibleList.single.imageBase64, isNull);
  });

  test('image and thumbnail size survive saving and old memos still load', () {
    final oldLine = MemoLineState.fromJson({'text': 'old memo'});
    expect(oldLine.imageBase64, isNull);
    expect(oldLine.imageScale, 1);
    final line = oldLine.copyWith(imageBase64: 'aW1hZ2U=', imageScale: 1.5);
    final memo = MemoState(list: [line]);
    expect(MemoState.fromJson(jsonDecode(jsonEncode(memo))).list.single, line);
  });

  test(
    'attachment preserves text and thumbnail resizing respects limits and lock',
    () {
      final line = MemoLineState(text: 'caption');
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
      final notifier = container.read(memoProvider.notifier);
      notifier.attachImage('aW1hZ2U=', index: 0);
      expect(container.read(memoProvider).list.single.text, 'caption');
      notifier.resizeImage(0, 10);
      expect(container.read(memoProvider).list.single.imageScale, 2);
      notifier.resizeImage(0, -10);
      expect(container.read(memoProvider).list.single.imageScale, 0.25);
      notifier.toggleReadOnlyStatus(0)();
      notifier.resizeImage(0, 1);
      notifier.attachImage('replacement', index: 0);
      notifier.removeImage(0);
      expect(container.read(memoProvider).list.single.imageScale, 0.25);
      expect(container.read(memoProvider).list.single.imageBase64, 'aW1hZ2U=');
      notifier.toggleReadOnlyStatus(0)();
      notifier.removeImage(0);
      expect(container.read(memoProvider).list.single.imageBase64, isNull);
      expect(container.read(memoProvider).list.single.text, 'caption');
      notifier.attachImage('new image', index: -1);
      expect(container.read(memoProvider).list.length, 2);
      expect(container.read(memoProvider).focusedIndex, 1);
      expect(
        container.read(memoProvider).visibleList.last.imageBase64,
        'new image',
      );
    },
  );
}
