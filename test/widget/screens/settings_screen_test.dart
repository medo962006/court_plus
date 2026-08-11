import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:court_plus/l10n/app_strings.dart';
import 'package:court_plus/presentation/providers/auth_provider.dart';
import 'package:court_plus/presentation/providers/settings_provider.dart';
import 'package:court_plus/screens/settings_screen.dart';
import 'package:court_plus/services/supabase_service.dart';

/// Build the SettingsScreen with its real dependencies (auth + settings
/// notifiers) and the app-localization wrapper it needs to render.
Widget _testApp() {
  return ProviderScope(
    overrides: [
      authStateProvider.overrideWith(
        (ref) => AuthNotifier(SupabaseService.test() as dynamic),
      ),
      settingsProvider.overrideWith((ref) => SettingsNotifier()),
    ],
    child: const AppStringsInherited(
      locale: 'en',
      child: MaterialApp(home: SettingsScreen()),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsScreen renders with ProviderScope', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Settings and activity'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Legal information'), findsOneWidget);
    expect(find.text('log out'), findsOneWidget);
  });

  testWidgets('SettingsScreen toggles notifications', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);

    final switchWidget = tester.widget<Switch>(switchFinder);
    expect(switchWidget.value, isTrue);

    await tester.tap(switchFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    final switchWidgetAfter = tester.widget<Switch>(switchFinder);
    expect(switchWidgetAfter.value, isFalse);
  });
}