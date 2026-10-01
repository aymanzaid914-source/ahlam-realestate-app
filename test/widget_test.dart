// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';

import 'package:ahlam_real_estate/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AhlamApp());
    expect(find.byType(AhlamApp), findsOneWidget);
  });
}
