import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../routes.dart';
import '../presentation/providers/courts_provider.dart';
import '../services/models.dart';
import '../widgets/bottom_nav_bar.dart';

class CourtsScreen extends ConsumerStatefulWidget {
  const CourtsScreen({super.key});

  @override
  ConsumerState<CourtsScreen> createState() => _CourtsScreenState();
}

class _CourtsScreenState extends ConsumerState<CourtsScreen> {
  int _navIndex = 0; // Courts tab active
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All courts';
  String _filterRating = 'All';
  final TextEditingController _filterLocationController = TextEditingController();
  String _filterSurface = 'Any';

  static const _categories = [
    ('All courts', Ph.circles_four),
    ('Tennis', Ph.tennis_ball),
    ('Football', Ph.soccer_ball),
  ];

  static const _surfaceOptions = ['Any', 'Clay', 'Grass', 'Hard'];
  static const _ratingOptions = ['All', '4+', '4.5+', '5'];

  double? _parseRatingFilter(String rating) {
    switch (rating) {
      case '4+':
        return 4.0;
      case '4.5+':
        return 4.5;
      case '5':
        return 5.0;
      default:
        return null;
    }
  }

  String _imageForCourt(Court court) {
    const images = {
      'c1': 'assets/images/court1.jpg',
      'c2': 'assets/images/court2.jpg',
      'c3': 'assets/images/banner1.jpg',
      'c4': 'assets/images/court1.jpg',
      'c5': 'assets/images/court2.jpg',
      'c6': 'assets/images/banner1.jpg',
    };
    return images[court.id] ?? 'assets/images/court1.jpg';
  }

  String _formatDistance(double km) {
    if (km <= 0) return 'Distance unavailable';
    if (km < 1.0) {
      return '${(km * 1000).round()}m away';
    }
    return '${km.toStringAsFixed(1)}km away';
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starValue = i + 1;
        if (rating >= starValue) {
          return const Iconify(
            Ph.star_fill,
            size: 14,
            color: Color(0xFFFFB800),
          );
        } else if (rating >= starValue - 0.5) {
          return const Iconify(
            Ph.star_half_fill,
            size: 14,
            color: Color(0xFFFFB800),
          );
        } else {
          return Iconify(Ph.star, size: 14, color: AppColors.lightBorder);
        }
      }),
    );
  }

  void _showFilterBottomSheet() {
    String tempRating = _filterRating;
    final tempLocationController = TextEditingController(
      text: _filterLocationController.text,
    );
    String tempSurface = _filterSurface;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          color: AppColors.lightText,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.lightField,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Iconify(
                              Ph.x,
                              size: 18,
                              color: AppColors.lightText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Rating',
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: _ratingOptions.map((r) {
                      final active = tempRating == r;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setSheetState(() => tempRating = r),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.neonGreen
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active
                                    ? AppColors.neonGreen
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: Text(
                              r,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: active
                                    ? Colors.black
                                    : AppColors.lightText,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Location',
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: Row(
                      children: [
                        const Iconify(
                          Ph.map_pin,
                          size: 18,
                          color: AppColors.lightMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: tempLocationController,
                            decoration: const InputDecoration(
                              hintText: 'Enter location',
                              hintStyle: TextStyle(
                                color: AppColors.lightMuted,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Surface',
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: tempSurface,
                        isExpanded: true,
                        icon: const Iconify(
                          Ph.caret_down_bold,
                          size: 16,
                          color: AppColors.lightText,
                        ),
                        items: _surfaceOptions.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: const TextStyle(
                                color: AppColors.lightText,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setSheetState(() => tempSurface = v);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonGreen,
                        foregroundColor: AppColors.darkText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _filterRating = tempRating;
                          _filterLocationController.text =
                              tempLocationController.text;
                          _filterSurface = tempSurface;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courtsAsync = ref.watch(courtsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'Courts',
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(Routes.notifications),
                    child: Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.lightBorder),
                          ),
                          child: const Center(
                            child: Iconify(
                              Ph.bell,
                              size: 22,
                              color: AppColors.lightText,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 12,
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
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: 'Search courts...',
                    hintStyle: TextStyle(
                      color: AppColors.lightMuted,
                      fontSize: 14,
                    ),
                    prefixIcon: Iconify(
                      Ph.magnifying_glass,
                      size: 20,
                      color: AppColors.lightMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _categories.map((c) {
                  final active = _selectedCategory == c.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = c.$1),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? AppColors.neonGreen : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                active ? AppColors.neonGreen : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Iconify(
                              c.$2,
                              size: 14,
                              color: active ? Colors.black : AppColors.lightText,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              c.$1,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: active
                                    ? Colors.black
                                    : AppColors.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Filter row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Iconify(
                            Ph.sliders_horizontal,
                            size: 16,
                            color: AppColors.lightText,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Filter',
                            style: TextStyle(
                              color: AppColors.lightText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: courtsAsync.when(
                data: (courts) {
                  var filtered = courts;

                  final sportType = _selectedCategory == 'All courts'
                      ? null
                      : _selectedCategory;
                  final minRating = _parseRatingFilter(_filterRating);
                  final location = _filterLocationController.text;

                  if (sportType != null) {
                    filtered = filtered
                        .where((c) => c.sportType.toLowerCase() == sportType.toLowerCase())
                        .toList();
                  }
                  if (minRating != null) {
                    filtered = filtered.where((c) => c.rating >= minRating).toList();
                  }
                  if (location.isNotEmpty) {
                    filtered = filtered
                        .where((c) =>
                            c.location.toLowerCase().contains(location.toLowerCase()) ||
                            c.center.toLowerCase().contains(location.toLowerCase()))
                        .toList();
                  }
                  if (_filterSurface != 'Any') {
                    filtered = filtered.where((c) => c.sportType == _filterSurface).toList();
                  }
                  if (_searchQuery.isNotEmpty) {
                    filtered = filtered
                        .where((c) =>
                            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            c.center.toLowerCase().contains(_searchQuery.toLowerCase()))
                        .toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Iconify(
                            Ph.magnifying_glass,
                            size: 48,
                            color: AppColors.lightMuted,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No courts found',
                            style: TextStyle(
                              color: AppColors.lightMuted,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final court = filtered[index];
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(
                          Routes.courtDetails,
                          arguments: court.id,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.lightBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(16)),
                                child: Image.asset(
                                  _imageForCourt(court),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        court.name,
                                        style: const TextStyle(
                                          color: AppColors.lightText,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        court.center,
                                        style: const TextStyle(
                                          color: AppColors.lightMuted,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildRatingStars(court.rating),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Iconify(
                                            Ph.map_pin,
                                            size: 12,
                                            color: AppColors.lightMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDistance(court.distance),
                                            style: const TextStyle(
                                              color: AppColors.lightMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.neonGreen),
                  ),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Iconify(
                        Ph.warning_circle,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load courts',
                        style: const TextStyle(
                          color: AppColors.lightText,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.toString(),
                        style: const TextStyle(
                          color: AppColors.lightMuted,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        index: _navIndex,
        onTap: (i) {
          if (i == 1) {
            Navigator.of(context).pushNamed(Routes.explore);
          } else if (i == 2) {
            Navigator.of(context).pushNamed(Routes.home);
          } else if (i == 3) {
            Navigator.of(context).pushNamed(Routes.activity);
          } else if (i == 4) {
            Navigator.of(context).pushNamed(Routes.profile);
          } else {
            setState(() => _navIndex = i);
          }
        },
      ),
    );
  }
}