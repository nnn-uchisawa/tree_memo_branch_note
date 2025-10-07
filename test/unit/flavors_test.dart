import 'package:flutter_test/flutter_test.dart';
import 'package:tree/flavors.dart';

void main() {
  group('Flavor Tests', () {
    test('should have correct flavor values', () {
      expect(Flavor.values.length, 2);
      expect(Flavor.values.contains(Flavor.dev), true);
      expect(Flavor.values.contains(Flavor.prod), true);
    });

    test('should have correct names', () {
      expect(Flavor.dev.name, 'dev');
      expect(Flavor.prod.name, 'prod');
    });

    test('F.appFlavor should be settable', () {
      F.appFlavor = Flavor.dev;
      expect(F.appFlavor, Flavor.dev);

      F.appFlavor = Flavor.prod;
      expect(F.appFlavor, Flavor.prod);
    });

    test('F.title should return correct title based on flavor', () {
      F.appFlavor = Flavor.dev;
      final devTitle = F.title;
      expect(devTitle, isA<String>());
      expect(devTitle.isNotEmpty, true);

      F.appFlavor = Flavor.prod;
      final prodTitle = F.title;
      expect(prodTitle, isA<String>());
      expect(prodTitle.isNotEmpty, true);
    });
  });
}
