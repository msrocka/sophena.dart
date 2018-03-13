import 'package:sophena/model.dart';
import 'package:test/test.dart';

void main() {

  // this is how we convert enums to strings and back again
  test('getProductType', () {
    for (ProductType expected in ProductType.values) {
      String s = expected.toString().split('\.')[1];
      ProductType actual = getProductType(s);
      expect(actual, expected);
    }
  });
}
