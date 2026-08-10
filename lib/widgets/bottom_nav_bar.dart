import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared bottom navigation bar used by Home, Courts, Activity, and Profile screens.
class BottomNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const BottomNavBar({super.key, required this.index, required this.onTap});

  static const _items = [
    ('Courts', Icons.sports_tennis),
    ('Explore', Icons.explore_outlined),
    ('Home', Icons.home_filled),
    ('Activity', Icons.receipt_long_outlined),
    ('Profile', Icons.person_outline),
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
                      // Top indicator bar for active item
                      Container(
                        height: 3,
                        width: 28,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.neonGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Icon(
                        _items[i].$2,
                        size: 24,
                        color: active
                            ? const Color(0xFF7CB800)
                            : AppColors.lightMuted,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _items[i].$1,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: active
                              ? AppColors.lightText
                              : AppColors.lightMuted,
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