import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/models.dart';
import 'supabase_provider.dart';

final courtsProvider = FutureProvider<List<Court>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  final result = await service.getCourts();
  return result.fold(
    (courts) => courts,
    (e) => throw e,
  );
});

final courtsBySportProvider = FutureProvider.family<List<Court>, String>((ref, sport) async {
  final service = ref.read(supabaseServiceProvider);
  final result = await service.getCourts(sportType: sport);
  return result.fold(
    (courts) => courts,
    (e) => throw e,
  );
});