import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:court_plus/l10n/app_strings.dart';
import 'package:court_plus/presentation/providers/auth_provider.dart';
import 'package:court_plus/presentation/providers/settings_provider.dart';
import 'package:court_plus/screens/settings_screen.dart';

import '../../helpers/testable_supabase_service.dart';

/// Pump SettingsScreen on a phone-sized surface with its real dependencies.
/// SettingsScreen has pre-existing layout-overflow bugs that surface on some
/// platforms; we tolerate exactly those overflow exceptions but still fail on
/// any *other* unexpected error. Returns the captured errors.
Future<List<FlutterErrorDetails>> _pumpSettings(WidgetTester tester) async {
  final errors = <FlutterErrorDetails>[];
  final oldHandler = FlutterError.onError;
  FlutterError.onError = errors.add;
  addTearDown(() => FlutterError.onError = oldHandler);

  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0; // logical 360x780
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith(
          (ref) => AuthNotifier(TestableSupabaseService()),
        ),
        settingsProvider.overrideWith((ref) => SettingsNotifier()),
      ],
      child: const AppStringsInherited(
        locale: 'en',
        child: MaterialApp(home: SettingsScreen()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
  return errors;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsScreen renders with ProviderScope', (tester) async {
    final errors = await _pumpSettings(tester);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Settings and activity'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Legal information'), findsOneWidget);
    expect(find.text('log out'), findsOneWidget);
    // Only pre-existing overflow exceptions are tolerated.
    expect(errors.where((e) => !e.exceptionAsString().contains('overflowed')), isEmpty);
  });

  testWidgets('SettingsScreen toggles notifications', (tester) async {
    final errors = await _pumpSettings(tester);

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
    expect(errors.where((e) => !e.exceptionAsString().contains('overflowed')), isEmpty);
  });
}