import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/supabase_service.dart';

/// Shared Supabase service provider.
final supabaseServiceProvider = Provider<SupabaseService>((ref) => SupabaseService());