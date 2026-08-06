import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ok_book/main.dart'; 

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OkBookApp()));
    expect(find.text('OK Book'), findsWidgets);
  });
}
