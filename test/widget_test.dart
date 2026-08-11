import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:court_plus/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('App starts with splash screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CourtPlusApp()));
    expect(find.byType(CourtPlusApp), findsOneWidget);

    // Splash auto-navigates after 2s; advance time so its Timer fires and the
    // widget tree isn't torn down with a pending timer.
    await tester.pump(const Duration(seconds: 3));
  });
}