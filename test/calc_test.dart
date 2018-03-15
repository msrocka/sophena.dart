import 'package:test/test.dart';

import 'package:sophena/sophena.dart';

void main() {
  test('Calculate calorific value for wood fuels', () {
    double cv = CalorificValue.forWood(
        woodMass: 1.0, waterContent: 0.2, calorificValue: 5000.0);
    expect(cv, 3864.0);
  });
}
