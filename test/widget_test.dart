import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/main.dart';

void main() {
  testWidgets('Kasim Coffee login screen smoke test', (tester) async {
    await tester.pumpWidget(const KasimCoffeeApp());
    expect(find.text('Welcome to Kasim Coffee'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
