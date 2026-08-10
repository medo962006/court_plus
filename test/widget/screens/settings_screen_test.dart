import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:court_plus/screens/settings_screen.dart';
import 'package:court_plus/presentation/providers/auth_provider.dart';
import 'package:court_plus/presentation/providers/settings_provider.dart';
import 'package:court_plus/services/supabase_service.dart';

void main() {
  setUp(() {
    // Initialize SharedPreferences with test values
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsScreen renders with ProviderScope', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(SupabaseService.test() as dynamic),
          ),
          settingsProvider.overrideWith(
            (ref) => SettingsNotifier(),
          ),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.byType(SettingsScreen), findsOneWidget);
    // Verify core UI elements exist
    expect(find.text('Settings and activity'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Legal information'), findsOneWidget);
    expect(find.text('log out'), findsOneWidget);
  });

  testWidgets('SettingsScreen toggles notifications', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(SupabaseService.test() as dynamic),
          ),
          settingsProvider.overrideWith(
            (ref) => SettingsNotifier(),
          ),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // Find the notification switch
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);

    // Initially notifications are enabled
    final switchWidget = tester.widget<Switch>(switchFinder);
    expect(switchWidget.value, isTrue);

    // Tap the switch to toggle
    await tester.tap(switchFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // Verify it toggled off
    final switchWidgetAfter = tester.widget<Switch>(switchFinder);
    expect(switchWidgetAfter.value, isFalse);
  });
}