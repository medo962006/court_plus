import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_theme.dart';
import '../routes.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _navIndex = 1; // Explore active
  bool _showBottomCard = true;

  static const _sfCenter = LatLng(37.7749, -122.4194);

  final Set<Marker> _markers = {
    // Green pins for courts
    Marker(
      markerId: const MarkerId('court1'),
      position: const LatLng(37.7849, -122.4094),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: 'Tennis Court A'),
    ),
    Marker(
      markerId: const MarkerId('court2'),
      position: const LatLng(37.7649, -122.4294),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: 'Tennis Court B'),
    ),
    Marker(
      markerId: const MarkerId('court3'),
      position: const LatLng(37.7549, -122.4094),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: 'Football Pitch 1'),
    ),
    // Blue pins for coaches
    Marker(
      markerId: const MarkerId('coach1'),
      position: const LatLng(37.7749, -122.3994),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Coach Donald'),
    ),
    Marker(
      markerId: const MarkerId('coach2'),
      position: const LatLng(37.7849, -122.4394),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Coach Sarah'),
    ),
    // Red dot for user location
    Marker(
      markerId: const MarkerId('userLocation'),
      position: const LatLng(37.7719, -122.4154),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: const InfoWindow(title: 'You are here'),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Iconify(Ph.chats_circle, size: 22, color: AppColors.lightText),
          onPressed: () {},
        ),
        title: const Text('Explore',
            style: TextStyle(color: AppColors.lightText, fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Iconify(Ph.bell, size: 22, color: AppColors.lightText),
                onPressed: () => Navigator.of(context).pushNamed(Routes.notifications),
              ),
              Positioned(
                right: 10,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Google Maps ──
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _sfCenter,
              zoom: 13,
            ),
            markers: _markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (controller) {},
          ),

          // ── Search bar overlay ──
          Positioned(
            top: 12,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(Routes.recentSearch),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Iconify(Ph.magnifying_glass, size: 20, color: AppColors.lightMuted),
                    SizedBox(width: 10),
                    Text('Find a courts, coaches + more',
                        style: TextStyle(color: AppColors.lightMuted, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom card ──
          if (_showBottomCard)
            Positioned(
              left: 20,
              right: 20,
              bottom: 80,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Profile pic placeholder
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.darkSlate,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Iconify(Ph.user_circle, size: 28, color: AppColors.lightMuted),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Donald Khalid',
                              style: TextStyle(
                                  color: AppColors.lightText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          const Text('Tennis Coach',
                              style: TextStyle(color: AppColors.lightMuted, fontSize: 13)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Iconify(Ph.map_pin, size: 12, color: AppColors.lightMuted),
                              const SizedBox(width: 2),
                              const Text('3km away',
                                  style: TextStyle(color: AppColors.lightMuted, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showBottomCard = false),
                      child: const Iconify(Ph.x_circle_fill, size: 20, color: AppColors.lightMuted),
                    ),
                  ],
                ),
              ),
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
}

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
                        height: 3,
                        width: 28,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: active ? AppColors.neonGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Iconify(
                        _items[i].$2,
                        size: 24,
                        color: active ? const Color(0xFF7CB800) : AppColors.lightMuted,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _items[i].$1,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? AppColors.lightText : AppColors.lightMuted,
                        ),
                      ),
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