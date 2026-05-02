import 'package:flutter_test/flutter_test.dart';
import 'package:hero_battle/main.dart';

void main() {
  testWidgets('App builds successfully smoke test', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const HeroBattleApp());

    // 4. Verify the app mounted
    expect(find.byType(HeroBattleApp), findsOneWidget);
  });
}