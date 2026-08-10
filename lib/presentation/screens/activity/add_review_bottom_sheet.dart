import 'package:flutter/material.dart';
import 'activity_state_provider.dart';

/// "Wanna Rate Us ?" bottom sheet with 5-star rating + comment field.
class AddReviewBottomSheet extends StatefulWidget {
  final BookingItem booking;
  final ValueChanged<int> onSubmitted;

  const AddReviewBottomSheet({
    super.key,
    required this.booking,
    required this.onSubmitted,
  });

  @override
  State<AddReviewBottomSheet> createState() => _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends State<AddReviewBottomSheet> {
  int _selectedStars = 4;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Title ──
          const Text(
            'Wanna Rate Us ?',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // ── Subtitle ──
          const Text(
            'Your input is valuable in helping us better understand your needs and tailor our service accordingly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // ── Star Rating ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _selectedStars;
              return GestureDetector(
                onTap: () => setState(() => _selectedStars = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    filled ? Icons.star : Icons.star_border,
                    size: 40,
                    color: filled
                        ? const Color(0xFF9BEC00) // lime green
                        : const Color(0xFFD1D5DB),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // ── Comment Field ──
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Add a Comment . . .',
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Submit Button ──
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                widget.onSubmitted(_selectedStars);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC4FF00),
                foregroundColor: const Color(0xFF1F2937),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Add Review'),
            ),
          ),
        ],
      ),
    );
  }
}