import 'package:apex_dropdown/src/models/selection_model.dart';
import 'package:flutter_test/flutter_test.dart';

class TestCar {
  TestCar(this.id, this.name);
  final int id;
  final String name;
}

void main() {
  group('ApexSelectionModel', () {
    test('normalizes null when value not in items', () {
      final model = ApexSelectionModel<TestCar>(
        items: [TestCar(1, 'Tesla'), TestCar(2, 'BMW')],
        value: TestCar(3, 'Audi'),
        compareFn: (a, b) => a.id == b.id,
      );

      expect(model.normalizeSingle(), isNull);
    });

    test('matches by compareFn, not instance', () {
      final items = [TestCar(1, 'Tesla')];
      final value = TestCar(1, 'Tesla');

      final model = ApexSelectionModel<TestCar>(
        items: items,
        value: value,
        compareFn: (a, b) => a.id == b.id,
      );

      expect(model.normalizeSingle(), isNotNull);
      expect(model.isSelected(items[0]), isTrue);
    });

    test('normalizeMulti filters stale values', () {
      final items = [TestCar(1, 'Tesla'), TestCar(2, 'BMW')];
      final values = [TestCar(1, 'Tesla'), TestCar(3, 'Audi')];

      final model = ApexSelectionModel<TestCar>(
        items: items,
        value: null,
        compareFn: (a, b) => a.id == b.id,
      );

      final normalized = model.normalizeMulti(values);
      expect(normalized.length, equals(1));
      expect(normalized[0].id, equals(1));
    });

    test('isSelectedInList respects compareFn', () {
      final items = [TestCar(1, 'Tesla')];
      final model = ApexSelectionModel<TestCar>(
        items: items,
        value: null,
        compareFn: (a, b) => a.id == b.id,
      );
      final values = [TestCar(1, 'Other name')];
      expect(model.isSelectedInList(values, items[0]), isTrue);
      expect(model.isSelectedInList(values, TestCar(2, 'BMW')), isFalse);
    });
  });
}

