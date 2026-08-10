import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/models.dart';
import 'supabase_provider.dart';

final momentsProvider = FutureProvider<List<Moment>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  final result = await service.getMoments();
  return result.fold(
    (moments) => moments,
    (e) => throw e,
  );
});