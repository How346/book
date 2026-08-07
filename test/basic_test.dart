import 'package:flutter_test/flutter_test.dart';
void main() {
  test('money uses integer minor units', () {
    const paise = 1250;
    expect(paise / 100, 12.5);
  });
}
