import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/models.dart';
import 'supabase_provider.dart';

final coachesProvider = FutureProvider<List<Coach>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  final result = await service.getCoaches();
  return result.fold(
    (coaches) => coaches,
    (e) => throw e,
  );
});

final coachesBySportProvider = FutureProvider.family<List<Coach>, String>((ref, sport) async {
  final service = ref.read(supabaseServiceProvider);
  final result = await service.getCoaches(sportType: sport);
  return result.fold(
    (coaches) => coaches,
    (e) => throw e,
  );
});
