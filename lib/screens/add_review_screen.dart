import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';

class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({super.key});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Iconify(Ph.arrow_left, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add Review',
            style: TextStyle(color: AppColors.lightText, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Court info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/images/court1.jpg', width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tennis Outdoor Court A', style: TextStyle(color: AppColors.lightText, fontSize: 15, fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text('Eagle Sport Center · 15 Apr 2024', style: TextStyle(color: AppColors.lightMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Rate your experience',
                style: TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            // Star rating
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Iconify(
                        i < _rating ? Ph.star_fill : Ph.star,
                        size: 40,
                        color: const Color(0xFFFFB800),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _rating == 0 ? 'Tap to rate' : _rating <= 2 ? 'Poor' : _rating == 3 ? 'Good' : _rating == 4 ? 'Very Good' : 'Excellent',
                style: TextStyle(color: _rating > 0 ? AppColors.lightText : AppColors.lightMuted, fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Write your review',
                style: TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: TextField(
                controller: _reviewController,
                maxLines: 5,
                maxLength: 300,
                style: const TextStyle(color: AppColors.lightText, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Share your experience...',
                  hintStyle: TextStyle(color: AppColors.lightMuted, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _rating > 0
                    ? () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            content: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Iconify(Ph.check_circle, size: 60, color: AppColors.neonGreen),
                                SizedBox(height: 16),
                                Text('Thank you!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text('Your review has been submitted.', textAlign: TextAlign.center),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                                child: const Text('Back to Home'),
                              ),
                            ],
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _rating > 0 ? AppColors.lightText : AppColors.lightField,
                  foregroundColor: _rating > 0 ? AppColors.neonGreen : AppColors.lightMuted,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}