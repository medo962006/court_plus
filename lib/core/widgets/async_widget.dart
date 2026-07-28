import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Standardized async state wrapper for all screens.
/// Shows [loading], [error], or [data] based on state.
class AsyncWidget<T> extends StatelessWidget {
  final AsyncSnapshot<T> snapshot;
  final Widget Function(T data) onData;
  final Widget Function()? onLoading;
  final Widget Function(String message)? onError;
  final Widget Function()? onEmpty;

  const AsyncWidget({
    super.key,
    required this.snapshot,
    required this.onData,
    this.onLoading,
    this.onError,
    this.onEmpty,
  });

  @override
  Widget build(BuildContext context) {
    if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
      return onLoading?.call() ?? const _DefaultLoading();
    }
    if (snapshot.hasError) {
      return onError?.call(snapshot.error.toString()) ??
          _DefaultError(message: snapshot.error.toString());
    }
    final data = snapshot.data;
    if (data == null) {
      return onEmpty?.call() ?? const _DefaultEmpty();
    }
    return onData(data);
  }
}

class _DefaultLoading extends StatelessWidget {
  const _DefaultLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.neonGreen),
          SizedBox(height: 16),
          Text('Loading...', style: TextStyle(color: AppColors.lightMuted)),
        ],
      ),
    );
  }
}

class _DefaultError extends StatelessWidget {
  final String message;
  const _DefaultError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            const Text('Something went wrong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.lightMuted)),
          ],
        ),
      ),
    );
  }
}

class _DefaultEmpty extends StatelessWidget {
  const _DefaultEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Nothing here yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText)),
          ],
        ),
      ),
    );
  }
}

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerPlaceholder({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightField,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}