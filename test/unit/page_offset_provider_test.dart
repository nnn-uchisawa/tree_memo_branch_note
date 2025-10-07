import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/libraries/on_boarding_slider/page_offset_provider.dart';

void main() {
  group('PageOffsetNotifier Tests', () {
    late PageController pageController;
    late PageOffsetNotifier notifier;

    setUp(() {
      pageController = PageController();
      notifier = PageOffsetNotifier(pageController);
    });

    tearDown(() {
      pageController.dispose();
      notifier.dispose();
    });

    test('should initialize with zero offset and page', () {
      expect(notifier.offset, 0.0);
      expect(notifier.page, 0.0);
    });

    test('should be a ChangeNotifier', () {
      expect(notifier, isA<ChangeNotifier>());
    });

    test('should have correct getters', () {
      expect(notifier.offset, isA<double>());
      expect(notifier.page, isA<double>());
    });

    // Note: Testing actual page changes requires a widget test environment
    // where PageController can be properly initialized and used
  });
}
