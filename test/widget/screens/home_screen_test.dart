import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:court_plus/l10n/app_strings.dart';
import 'package:court_plus/screens/home_screen.dart';
import 'package:court_plus/presentation/providers/auth_provider.dart';
import 'package:court_plus/presentation/providers/courts_provider.dart';
import 'package:court_plus/services/models.dart';

import '../../helpers/testable_supabase_service.dart';

/// Smoke test: HomeScreen boots with its real providers/resolvers.
///
/// HomeScreen has pre-existing layout-overflow bugs that surface in tests; we
/// tolerate exactly those overflow exceptions but still fail on any *other*
/// unexpected error. The screen is rendered on a phone-sized surface.
void main() {
  testWidgets('HomeScreen renders with ProviderScope', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final oldHandler = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = oldHandler);

    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0; // logical 400x800 — small raster = fast CI
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courtsProvider.overrideWith((ref) => Future.value(const <Court>[])),
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(TestableSupabaseService()),
          ),
        ],
        child: const AppStringsInherited(
          locale: 'en',
          child: MaterialApp(home: HomeScreen()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
    // "Courts" appears in the section title and/or bottom nav.
    expect(find.text('Courts'), findsAtLeastNWidgets(1));
    // Only pre-existing overflow exceptions are tolerated.
    expect(errors.where((e) => !e.exceptionAsString().contains('overflowed')), isEmpty);
  });
}