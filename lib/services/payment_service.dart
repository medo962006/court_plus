import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../core/config.dart';
import '../core/logger.dart';
import '../core/result.dart';

/// Payment service wrapping Stripe Payment Intents via Supabase Edge Functions.
final class PaymentService {
  static final PaymentService _instance = PaymentService._();
  factory PaymentService() => _instance;
  PaymentService._();

  /// Initialize Stripe with the publishable key.
  Future<void> init() async {
    // Stripe native SDK only works on Android/iOS. Skip on desktop/web.
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      AppLogger.info('Stripe init skipped (desktop/web)');
      return;
    }
    try {
      Stripe.publishableKey = AppConfig.stripePublishableKey;
      Stripe.merchantIdentifier = 'merchant.com.courtplus';
      await Stripe.instance.applySettings();
      AppLogger.info('Stripe initialized');
    } catch (e) {
      AppLogger.error('Stripe init deferred', error: e);
    }
  }

  /// Get the Supabase Edge Function URL for payment operations.
  String get _functionUrl => '${AppConfig.supabaseUrl}/functions/v1';

  /// Create a payment intent via Supabase Edge Function.
  Future<Result<Map<String, dynamic>>> createPaymentIntent({
    required String bookingId,
    required double amount,
    String currency = 'sar',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_functionUrl/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'booking_id': bookingId,
          'amount': amount,
          'currency': currency,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Result.success(data);
      }

      final error = jsonDecode(response.body)['error'] as String? ?? 'Payment failed';
      return Result.failure(ServerException(error));
    } catch (e, s) {
      AppLogger.error('createPaymentIntent failed', error: e, stack: s);
      return Result.failure(ServerException('Failed to create payment: $e'));
    }
  }

  /// Present the Stripe payment sheet and confirm payment.
  Future<Result<Map<String, dynamic>>> confirmPayment({
    required String bookingId,
    required double amount,
  }) async {
    try {
      // 1. Create payment intent
      final piResult = await createPaymentIntent(
        bookingId: bookingId,
        amount: amount,
      );

      return piResult.fold(
        (data) async {
          final clientSecret = data['clientSecret'] as String?;
          if (clientSecret == null) {
            return Result.failure(
              ServerException('No client secret returned'),
            );
          }

          // 2. Initialize payment sheet
          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              merchantDisplayName: 'Court+',
              paymentIntentClientSecret: clientSecret,
              returnURL: 'com.courtplus.court_plus://stripe-callback',
            ),
          );

          // 3. Present payment sheet
          await Stripe.instance.presentPaymentSheet();

          AppLogger.info('Payment succeeded for booking $bookingId');
          return Result.success({'booking_id': bookingId, 'status': 'completed'});
        },
        (e) => Result.failure(e),
      );
    } catch (e, s) {
      if (e is StripeException) {
        AppLogger.error('Stripe payment failed', error: e.error);
        return Result.failure(
          ServerException(e.error.localizedMessage ?? 'Payment cancelled'),
        );
      }
      AppLogger.error('Payment failed', error: e, stack: s);
      return Result.failure(ServerException('Payment failed: $e'));
    }
  }
}