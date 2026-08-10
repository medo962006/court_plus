import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_theme.dart';
import '../routes.dart';
import '../services/models.dart';
import '../presentation/providers/courts_provider.dart';
import '../presentation/providers/coach_provider.dart';
import '../core/logger.dart';
import '../l10n/app_strings.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchCtrl = TextEditingController();
  int _navIndex = 1;
  int _selectedFilter = 0; // 0=All, 1=Nearby, 2=Top Rated
  LatLng _cameraCenter = _riyadh;
  Court? _nearestCourt;
  Coach? _nearestCoach;
  bool _showCoachCard = false;
  bool _showCourtCard = false;

  static const _riyadh = LatLng(24.7136, 46.6753);
  static const _filterChips = ['All', 'Nearby', 'Top Rated'];

  void _onCameraMove(CameraPosition position) {
      setState(() => _cameraCenter = position.target);
    }

    String _distanceLabel(Court court) {
      final d = court.distance;
      if (d <= 0) return 'Distance unavailable';
      return '${d.toStringAsFixed(1)} km away';
    }

    @override
  Widget build(BuildContext context) {
    final courtsAsync = ref.watch(courtsProvider);
    final coachesAsync = ref.watch(coachesProvider);
    final t = AppStrings.of(context).t;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: true,
                title: Text(t('explore'),
            style: const TextStyle(color: AppColors.lightText, fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Iconify(Ph.bell, size: 22, color: AppColors.lightText),
                onPressed: () => Navigator.of(context).pushNamed(Routes.notifications),
              ),
              Positioned(
                right: 10, top: 8,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map layer — always fills the screen
          SizedBox.expand(
            child: _MapLayer(
              courtsAsync: courtsAsync,
              coachesAsync: coachesAsync,
              cameraCenter: _cameraCenter,
              onCameraMove: _onCameraMove,
              onNearestCourt: (c) {
                if (c != _nearestCourt) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() { _nearestCourt = c; _showCourtCard = true; _showCoachCard = false; });
                  });
                }
              },
              onNearestCoach: (c) {
                if (c != _nearestCoach) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() { _nearestCoach = c; _showCoachCard = true; _showCourtCard = false; });
                  });
                }
              },
              onMapTap: () { /* map tap keeps cards visible */ },
            ),
          ),

          // Search bar overlay — typeable
                    Positioned(
                                          top: 16, left: 20, right: 20,
                                          child: Container(
                                            height: 50,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.lightBorder),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onSubmitted: (q) {
                            if (q.trim().isNotEmpty) {
                              Navigator.of(context).pushNamed(Routes.recentSearch, arguments: q.trim());
                            }
                          },
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: t('findCourtsCoaches'),
                            hintStyle: TextStyle(color: AppColors.lightMuted, fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                            prefixIcon: Iconify(Ph.magnifying_glass, size: 20, color: AppColors.lightMuted),
                            prefixIconConstraints: BoxConstraints(minWidth: 24, minHeight: 24),
                            contentPadding: EdgeInsets.only(top: 14),
                          ),
                        ),
                      ),
                    ),

          // Filter chips
          Positioned(
            top: 72, left: 20, right: 20,
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filterChips.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                                itemBuilder: (context, i) {
                  final active = i == _selectedFilter;
                  final labels = [t('all'), t('nearby'), t('topRated')];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: active ? AppColors.neonGreen : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: active ? AppColors.neonGreen : AppColors.lightBorder),
                      ),
                      child: Center(
                        child: Text(
                          labels[i],
                          style: TextStyle(
                            color: active ? Colors.black : AppColors.lightText,
                            fontSize: 13,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom card - coach, court, or none
          if (_showCoachCard && _nearestCoach != null)
            Positioned(
              left: 20, right: 20, bottom: 80,
              child: _CoachCard(
                coach: _nearestCoach!,
                onClose: () => setState(() { _showCoachCard = false; _showCourtCard = false; }),
                onTap: () => Navigator.of(context).pushNamed('/coach-detail', arguments: _nearestCoach!.id),
              ),
            )
          else if (_showCourtCard && _nearestCourt != null)
            Positioned(
              left: 20, right: 20, bottom: 80,
              child: _buildCourtCard(courtsAsync, t),
            ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        index: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          if (i == 0) Navigator.of(context).pushReplacementNamed(Routes.courts);
          if (i == 2) Navigator.of(context).pushReplacementNamed(Routes.home);
          if (i == 3) Navigator.of(context).pushReplacementNamed(Routes.activity);
          if (i == 4) Navigator.of(context).pushReplacementNamed(Routes.profile);
        },
      ),
    );
  }

  Widget _buildCourtCard(AsyncValue<List<Court>> courtsAsync, String Function(String) t) {
    return courtsAsync.when(
      loading: () => _CourtCardContent(
        icon: Ph.map_pin,
        name: t('loadingPleaseWait'),
        subtitle: '...',
        distance: '',
        onClose: () {},
      ),
      error: (_, _) => _CourtCardContent(
        icon: Ph.warning_circle,
        name: t('couldNotLoadCourts'),
        subtitle: t('tapToRetry'),
        distance: '',
        onClose: () {},
      ),
      data: (courts) {
        final court = _nearestCourt ?? (courts.isNotEmpty ? courts.first : null);
        if (court == null) {
          return _CourtCardContent(
            icon: Ph.map_pin,
            name: t('noCourtsNearby'),
            subtitle: t('zoomOutToSeeMore'),
            distance: '',
            onClose: () {},
          );
        }
        return _CourtCardContent(
          icon: Ph.tennis_ball,
          name: court.name,
          subtitle: '${court.center} · ⭐ ${court.rating}',
          distance: _distanceLabel(court),
          onClose: () => setState(() { _showCourtCard = false; _showCoachCard = false; }),
                    onTap: () => Navigator.of(context).pushNamed(Routes.courtDetails, arguments: court.id),
        );
      },
    );
  }

}

// ─── Court Bottom Card ───

class _CourtCardContent extends StatelessWidget {
  final String icon, name, subtitle, distance;
  final VoidCallback onClose;
  final VoidCallback? onTap;

  const _CourtCardContent({
    required this.icon, required this.name, required this.subtitle,
    required this.distance, required this.onClose, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.darkSlate,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Iconify(icon, size: 28, color: AppColors.lightMuted)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: AppColors.lightText, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.lightMuted, fontSize: 13)),
                  if (distance.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Iconify(Ph.map_pin, size: 12, color: AppColors.lightMuted),
                        const SizedBox(width: 2),
                        Text(distance, style: const TextStyle(color: AppColors.lightMuted, fontSize: 11)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: const Iconify(Ph.x_circle_fill, size: 20, color: AppColors.lightMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Coach Bottom Card ───

class _CoachCard extends StatelessWidget {
  final Coach coach;
  final VoidCallback onClose;
  final VoidCallback? onTap;

  const _CoachCard({required this.coach, required this.onClose, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.darkSlate,
              backgroundImage: coach.avatarUrl != null ? NetworkImage(coach.avatarUrl!) : null,
              child: coach.avatarUrl == null
                  ? Text(coach.fullName.isNotEmpty ? coach.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coach.fullName,
                      style: const TextStyle(color: AppColors.lightText, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('${coach.sportType} Coach · ⭐ ${coach.rating}',
                      style: const TextStyle(color: AppColors.lightMuted, fontSize: 13)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Iconify(Ph.map_pin, size: 12, color: AppColors.lightMuted),
                      const SizedBox(width: 2),
                      Text('${coach.experience} years exp',
                          style: const TextStyle(color: AppColors.lightMuted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: const Iconify(Ph.x_circle_fill, size: 20, color: AppColors.lightMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Map Layer (with error fallback) ───

class _MapLayer extends StatelessWidget {
  final AsyncValue<List<Court>> courtsAsync;
  final AsyncValue<List<Coach>> coachesAsync;
  final LatLng cameraCenter;
  final void Function(CameraPosition) onCameraMove;
  final void Function(Court?) onNearestCourt;
  final void Function(Coach?) onNearestCoach;
  final VoidCallback onMapTap;

  const _MapLayer({
    required this.courtsAsync,
    required this.coachesAsync,
    required this.cameraCenter,
    required this.onCameraMove,
    required this.onNearestCourt,
    required this.onNearestCoach,
    required this.onMapTap,
  });

  static const _riyadh = LatLng(24.7136, 46.6753);

  @override
  Widget build(BuildContext context) {
    try {
      return courtsAsync.when(
        loading: () => _buildMap([], []),
        error: (_, _) => _buildMap([], []),
        data: (courts) {
          return coachesAsync.when(
            loading: () => _buildMap(courts, []),
            error: (_, _) => _buildMap(courts, []),
            data: (coaches) => _buildMap(courts, coaches),
          );
        },
      );
    } catch (e) {
      // Google Maps unavailable (desktop or missing API key)
      AppLogger.error('Google Maps unavailable', error: e);
      return Container(
        color: const Color(0xFFF0F2F5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Iconify(Ph.map_pin, size: 48, color: AppColors.lightMuted),
              const SizedBox(height: 12),
              const Text('Map view requires Android/iOS',
                  style: TextStyle(color: AppColors.lightMuted, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('Explore courts and coaches below',
                  style: TextStyle(color: AppColors.lightMuted, fontSize: 13)),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildMap(List<Court> courts, List<Coach> coaches) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(target: _riyadh, zoom: 12),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      markers: _buildMarkers(courts, coaches),
      onCameraMove: onCameraMove,
      onTap: (_) => onMapTap(),
    );
  }

  Set<Marker> _buildMarkers(List<Court> courts, List<Coach> coaches) {
    final markers = <Marker>{};
    for (final court in courts) {
      if (court.latitude != null && court.longitude != null) {
        final c = court;
        markers.add(Marker(
          markerId: MarkerId('court_${c.id}'),
          position: LatLng(c.latitude!, c.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: c.name, snippet: '${c.center} · ⭐ ${c.rating}'),
          onTap: () { onNearestCourt(c); },
        ));
      }
    }
    for (final coach in coaches) {
      if (coach.latitude != null && coach.longitude != null) {
        final c = coach;
        markers.add(Marker(
          markerId: MarkerId('coach_${c.id}'),
          position: LatLng(c.latitude!, c.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: c.fullName, snippet: '${c.sportType} Coach · ⭐ ${c.rating}'),
          onTap: () { onNearestCoach(c); },
        ));
      }
    }
    return markers;
  }
}

// ─── Bottom Navigation ───

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.index, required this.onTap});

  static const _items = [
    ('Courts', Ph.tennis_ball),
    ('Explore', Ph.compass),
    ('Home', Ph.house_fill),
    ('Activity', Ph.receipt),
    ('Profile', Ph.user_circle),
  ];

  static String _key(String label) {
    const keys = {
      'Courts': 'courts',
      'Explore': 'explore',
      'Home': 'home',
      'Activity': 'activity',
      'Profile': 'profile',
    };
    return keys[label] ?? label;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE1E4E8))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) {
              final active = i == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 3, width: 28,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: active ? AppColors.neonGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Iconify(_items[i].$2, size: 24,
                          color: active ? const Color(0xFF7CB800) : AppColors.lightMuted),
                      const SizedBox(height: 2),
                      Text(AppStrings.of(context).t(_key(_items[i].$1)), style: TextStyle(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? AppColors.lightText : AppColors.lightMuted,
                      )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}