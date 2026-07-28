import 'package:flutter_test/flutter_test.dart';
import 'package:court_plus/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CourtPlusApp());
    expect(find.byType(CourtPlusApp), findsOneWidget);
  });
}