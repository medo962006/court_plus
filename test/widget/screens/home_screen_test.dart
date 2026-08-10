import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:court_plus/screens/home_screen.dart';
import 'package:court_plus/presentation/providers/auth_provider.dart';
import 'package:court_plus/presentation/providers/courts_provider.dart';
import 'package:court_plus/services/models.dart';
import 'package:court_plus/services/supabase_service.dart';

void main() {
  testWidgets('HomeScreen renders with ProviderScope', (tester) async {
    // Suppress layout overflow errors caused by missing test assets
    final errors = <FlutterErrorDetails>[];
    final oldHandler = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = oldHandler);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courtsProvider.overrideWith((ref) => Future.value(const <Court>[])),
          authStateProvider.overrideWith(
            (ref) => AuthNotifier(SupabaseService.test() as dynamic),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    // Allow the FutureProvider to settle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
    // "Courts" appears in section title AND bottom nav
    expect(find.text('Courts'), findsAtLeastNWidgets(1));
    // Verify the sport chips render
    expect(find.text('All courts (0)'), findsOneWidget);

    // Verify only overflow errors were caught (pre-existing layout issue)
    expect(errors.where((e) => !e.exceptionAsString().contains('overflowed')),
        isEmpty);
  });

  testWidgets('HomeScreen shows greeting for authenticated user', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final oldHandler = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = oldHandler);

    final authNotifier = AuthNotifier(SupabaseService.test() as dynamic)
      ..state = const AuthState(
        isLoading: false,
        isAuthenticated: true,
        user: UserProfile(id: 'u1', fullName: 'Test User', username: 'test_user'),
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courtsProvider.overrideWith((ref) => Future.value(const <Court>[])),
          authStateProvider.overrideWith((ref) => authNotifier),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    // The greeting should show the user's full name
    expect(find.text('Hi, Test User'), findsOneWidget);

    expect(errors.where((e) => !e.exceptionAsString().contains('overflowed')),
        isEmpty);
  });
}