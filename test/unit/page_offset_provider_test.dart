import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/view/widgets/libraries/on_boarding_slider/page_offset_notifier.dart';
import 'package:tree/src/view/widgets/libraries/on_boarding_slider/page_offset_state.dart';

void main() {
  group('PageOffsetNotifier Tests', () {
    late PageController pageController;
    late ProviderContainer container;

    setUp(() {
      pageController = PageController();
      container = ProviderContainer();
    });

    tearDown(() {
      pageController.dispose();
      container.dispose();
    });

    test('should initialize with zero offset and page', () {
      // Providerの構築をトリガーしつつ未使用警告を避ける
      expect(
        () => container.read(pageOffsetProvider(pageController).notifier),
        returnsNormally,
      );
      final state = container.read(pageOffsetProvider(pageController));

      expect(state.offset, 0.0);
      expect(state.page, 0.0);
    });

    test('should be a Notifier', () {
      final notifier =
          container.read(pageOffsetProvider(pageController).notifier);
      expect(notifier, isA<PageOffsetNotifier>());
    });

    test('should have correct state properties', () {
      final state = container.read(pageOffsetProvider(pageController));
      expect(state.offset, isA<double>());
      expect(state.page, isA<double>());
    });

    test('should create PageOffsetState with default values', () {
      const state = PageOffsetState();
      expect(state.offset, 0.0);
      expect(state.page, 0.0);
    });

    test('should create PageOffsetState with custom values', () {
      const state = PageOffsetState(offset: 1.5, page: 2.0);
      expect(state.offset, 1.5);
      expect(state.page, 2.0);
    });

    test('should copy PageOffsetState with new values', () {
      const originalState = PageOffsetState(offset: 1.0, page: 2.0);
      final copiedState = originalState.copyWith(offset: 3.0);

      expect(copiedState.offset, 3.0);
      expect(copiedState.page, 2.0); // unchanged
    });

    // Note: Testing actual page changes requires a widget test environment
    // where PageController can be properly initialized and used
  });
}
