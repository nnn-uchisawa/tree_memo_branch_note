import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/view/pages/walk_through/walk_through_view.dart';

void main() {
  testWidgets('walkthrough can skip to the final page', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: WalkThroughView())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tree'), findsOneWidget);

    await tester.tap(find.text('skip'));
    await tester.pumpAndSettle();

    expect(find.text('さあ、始めましょう！'), findsOneWidget);
    expect(find.text('使用を開始する'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
