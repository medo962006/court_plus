import 'package:flutter/material.dart';

/// "Thank You!" modal shown after review submission.
void showThankYouSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ThankYouSheet(),
  );
}

class _ThankYouSheet extends StatelessWidget {
  const _ThankYouSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Close (X) button ──
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9), // light green
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Giant lime green star badge ──
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              size: 60,
              color: Color(0xFFC4FF00),
            ),
          ),
          const SizedBox(height: 20),

          // ── Confetti detail (small stars around badge) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('✨', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text('🌟', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 4),
              Text('✨', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),

          // ── Title ──
          const Text(
            'Thank You !',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // ── Subtitle ──
          const Text(
            'Your review has been submitted, your feedback is important to us as to the doctors and the community.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}