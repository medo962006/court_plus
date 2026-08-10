import 'package:flutter/material.dart';

/// A shimmer placeholder that cycles a gradient overlay left-to-right.
/// Wrap your skeleton shapes in [SkeletonContainer] to get the shimmer effect.
class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const ShimmerWidget({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final baseColor = Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A3744)
            : const Color(0xFFE5E7EB);
        final highlightColor = Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF3A4754)
            : const Color(0xFFF3F4F6);

        final begin = Alignment(-1 + _controller.value * 2, 0);
        final end = Alignment(1 + _controller.value * 2, 0);

        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: [baseColor, highlightColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}

/// A skeleton court card matching the home screen court card shape.
class CourtCardSkeleton extends StatelessWidget {
  const CourtCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A313A)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerWidget(height: 120, borderRadius: 16),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerWidget(width: 140, height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                const ShimmerWidget(width: 100, height: 12, borderRadius: 4),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const ShimmerWidget(width: 60, height: 12, borderRadius: 4),
                    const Spacer(),
                    const ShimmerWidget(width: 40, height: 12, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A reusable shimmer list for coaches, moments, or any card-based list.
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerList({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 90,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: itemCount,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            const ShimmerWidget(width: 80, height: 80, borderRadius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget(width: 160, height: 14, borderRadius: 4),
                  const SizedBox(height: 8),
                  ShimmerWidget(width: 120, height: 12, borderRadius: 4),
                  const SizedBox(height: 6),
                  ShimmerWidget(width: 80, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}