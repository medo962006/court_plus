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

/// Search filters for court search
class CourtSearchFilters {
  final String? sportType;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final double? lat;
  final double? lng;
  final double? radiusKm;
  final String? searchTerm;

  const CourtSearchFilters({
    this.sportType,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.lat,
    this.lng,
    this.radiusKm,
    this.searchTerm,
  });

  CourtSearchFilters copyWith({
    String? sportType,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    double? lat,
    double? lng,
    double? radiusKm,
    String? searchTerm,
    bool clearSearch = false,
  }) => CourtSearchFilters(
    sportType: sportType ?? this.sportType,
    minPrice: minPrice ?? this.minPrice,
    maxPrice: maxPrice ?? this.maxPrice,
    minRating: minRating ?? this.minRating,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    radiusKm: radiusKm ?? this.radiusKm,
    searchTerm: clearSearch ? null : (searchTerm ?? this.searchTerm),
  );
}

/// Provider that holds the current search filters state.
final courtSearchFiltersProvider = StateProvider<CourtSearchFilters>((ref) {
  return const CourtSearchFilters();
});

/// Provider that searches courts using the `search_courts` RPC with current filters.
final searchCourtsProvider = FutureProvider<List<Court>>((ref) async {
  final filters = ref.watch(courtSearchFiltersProvider);
  final service = ref.read(supabaseServiceProvider);
  final result = await service.searchCourts(
    sportType: filters.sportType,
    minPrice: filters.minPrice,
    maxPrice: filters.maxPrice,
    minRating: filters.minRating,
    lat: filters.lat,
    lng: filters.lng,
    radiusKm: filters.radiusKm,
    searchTerm: filters.searchTerm,
  );
  return result.fold(
    (courts) => courts,
    (e) => throw e,
  );
});