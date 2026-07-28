import 'package:get_it/get_it.dart';
import '../services/supabase_service.dart';

/// Service locator for dependency injection.
final GetIt sl = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // ─── Services (singletons) ───
  sl.registerLazySingleton<SupabaseService>(() => SupabaseService());
}