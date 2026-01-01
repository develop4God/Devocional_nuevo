import 'package:devocional_nuevo/config/devotional_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DevotionalConfig', () {
    test('BASE_YEAR should be 2025', () {
      expect(DevotionalConfig.BASE_YEAR, equals(2025));
    });

    test('BASE_YEAR should be a valid year', () {
      expect(DevotionalConfig.BASE_YEAR, greaterThan(2020));
      expect(
          DevotionalConfig.BASE_YEAR, lessThanOrEqualTo(DateTime.now().year));
    });

    test('ON_DEMAND_THRESHOLD should be less than 365', () {
      expect(DevotionalConfig.ON_DEMAND_THRESHOLD, lessThan(365));
      expect(DevotionalConfig.ON_DEMAND_THRESHOLD, greaterThan(0));
    });

    test('ON_DEMAND_THRESHOLD should be 350', () {
      expect(DevotionalConfig.ON_DEMAND_THRESHOLD, equals(350));
    });

    test('Constants should not be modifiable at runtime', () {
      // This test verifies that BASE_YEAR is a const
      // If it compiles, the test passes (const values can't be changed)
      const baseYear = DevotionalConfig.BASE_YEAR;
      const threshold = DevotionalConfig.ON_DEMAND_THRESHOLD;

      expect(baseYear, equals(2025));
      expect(threshold, equals(350));
    });
  });
}
