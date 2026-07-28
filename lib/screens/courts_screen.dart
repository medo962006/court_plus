import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../routes.dart';
import '../services/models.dart';
import '../services/mock_data_service.dart';

class CourtsScreen extends StatefulWidget {
  const CourtsScreen({super.key});

  @override
  State<CourtsScreen> createState() => _CourtsScreenState();
}

class _CourtsScreenState extends State<CourtsScreen> {
  // ─── Search ───
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ─── Category tabs ───
  String _selectedCategory = 'All courts';

  // ─── Sort ───
  String _sortBy = 'Nearest';

  // ─── Filter state ───
  String _filterRating = 'All';
  final TextEditingController _filterLocationController =
      TextEditingController();
  String _filterSurface = 'Any';

  // ─── Results ───
  List<Court> _courts = MockDataService.courts;

  // ─── Category tabs config ───
  static const _categories = [
    ('All courts', Ph.circles_four),
    ('Tennis', Ph.tennis_ball),
    ('Football', Ph.soccer_ball),
  ];

  // ─── Sort options ───
  static const _sortOptions = [
    'Nearest',
    'Highest Rated',
    'Price Low',
    'Price High',
  ];

  // ─── Surface options ───
  static const _surfaceOptions = ['Any', 'Clay', 'Grass', 'Hard'];

  // ─── Rating options ───
  static const _ratingOptions = ['All', '4+', '4.5+', '5'];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterLocationController.dispose();
    super.dispose();
  }

  // ─── Core filter + sort pipeline ───
  void _applyFilters() {
    final sportType = _selectedCategory == 'All courts'
        ? null
        : _selectedCategory;
    final minRating = _parseRatingFilter(_filterRating);
    final location = _filterLocationController.text;

    var results = MockDataService.filter(
      sportType: sportType,
      minRating: minRating,
      location: location.isNotEmpty ? location : null,
      surface: _filterSurface,
      query: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    // Client-side sort
    switch (_sortBy) {
      case 'Nearest':
        results.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case 'Highest Rated':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Price Low':
        results.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
        break;
      case 'Price High':
        results.sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
        break;
    }

    setState(() => _courts = results);
  }

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

  // ─── Default image per court id ───
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

  // ─── Format distance ───
  String _formatDistance(double km) {
    if (km < 1.0) {
      return '${(km * 1000).round()}m away';
    }
    return '${km.toStringAsFixed(1)}km away';
  }

  // ─── Build rating stars ───
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

  // ─── Open filter bottom sheet ───
  void _showFilterBottomSheet() {
    // Local copies so changes only apply on "Apply"
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
                  // ── Header ──
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

                  // ── Rating ──
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

                  // ── Location ──
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

                  // ── Surface ──
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

                  // ── Apply button ──
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
                        _filterRating = tempRating;
                        _filterLocationController.text =
                            tempLocationController.text;
                        _filterSurface = tempSurface;
                        _applyFilters();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: "Courts" title + location dropdown + bell ──
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
                  // Location dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Iconify(
                          Ph.map_pin_fill,
                          size: 16,
                          color: AppColors.lightText,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Riyadh',
                          style: TextStyle(
                            color: AppColors.lightText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Iconify(
                          Ph.caret_down_bold,
                          size: 14,
                          color: AppColors.lightText,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Bell icon
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
            const SizedBox(height: 14),

            // ── Search bar + filter button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
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
                            Ph.magnifying_glass,
                            size: 20,
                            color: AppColors.lightMuted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                _searchQuery = value;
                                _applyFilters();
                              },
                              decoration: const InputDecoration(
                                hintText: 'Find a courts, coaches + more',
                                hintStyle: TextStyle(
                                  color: AppColors.lightMuted,
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _searchQuery = '';
                                _applyFilters();
                              },
                              child: const Iconify(
                                Ph.x_circle,
                                size: 18,
                                color: AppColors.lightMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.darkSlate,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Iconify(
                          Ph.sliders_horizontal,
                          size: 20,
                          color: AppColors.neonGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Category tabs ──
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final label = _categories[i].$1;
                  final icon = _categories[i].$2;
                  final active = _selectedCategory == label;
                  return GestureDetector(
                    onTap: () {
                      _selectedCategory = label;
                      _applyFilters();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: active ? AppColors.neonGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active
                              ? AppColors.neonGreen
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Iconify(
                            icon,
                            size: 16,
                            color: active ? Colors.black : AppColors.lightMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            label,
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
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // ── Results count + sort ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    '${_courts.length} courts found',
                    style: const TextStyle(
                      color: AppColors.lightMuted,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        isDense: true,
                        icon: const Iconify(
                          Ph.caret_down_bold,
                          size: 14,
                          color: AppColors.lightText,
                        ),
                        items: _sortOptions.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: const TextStyle(
                                color: AppColors.lightText,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            _sortBy = v;
                            _applyFilters();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Court feed ──
            Expanded(
              child: _courts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Iconify(
                            Ph.tennis_ball,
                            size: 56,
                            color: AppColors.lightMuted,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No courts found',
                            style: TextStyle(
                              color: AppColors.lightMuted,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Try adjusting your filters',
                            style: TextStyle(
                              color: AppColors.lightMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: _courts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, i) {
                        final court = _courts[i];
                        return _CourtFeedCard(
                          image: _imageForCourt(court),
                          court: court,
                          distanceText: _formatDistance(court.distance),
                          ratingStars: _buildRatingStars(court.rating),
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed(Routes.courtDetails, arguments: court.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Court feed card
// ─────────────────────────────────────────────────────────────────────────────
class _CourtFeedCard extends StatelessWidget {
  final String image;
  final Court court;
  final String distanceText;
  final Widget ratingStars;
  final VoidCallback onTap;

  const _CourtFeedCard({
    required this.image,
    required this.court,
    required this.distanceText,
    required this.ratingStars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image + heart ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.asset(
                    image,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: AppColors.lightField,
                      child: Center(
                        child: Iconify(
                          Ph.image,
                          size: 40,
                          color: AppColors.lightMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Iconify(
                        Ph.heart,
                        size: 18,
                        color: AppColors.lightText,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Body ──
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          court.name,
                          style: const TextStyle(
                            color: AppColors.lightText,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        court.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.lightText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      ratingStars,
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Center + distance
                  Row(
                    children: [
                      Text(
                        court.center,
                        style: const TextStyle(
                          color: AppColors.lightMuted,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      const Iconify(
                        Ph.map_pin,
                        size: 14,
                        color: AppColors.lightMuted,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        distanceText,
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
          ],
        ),
      ),
    );
  }
}
