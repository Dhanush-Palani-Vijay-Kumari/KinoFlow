import 'package:flutter_test/flutter_test.dart';
import 'package:kinoflow/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const KinoFlowApp());
    // Verify app initializes without crashing
    expect(find.byType(KinoFlowApp), findsOneWidget);
  });
}
