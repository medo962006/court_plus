import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/deep_link_service.dart';
import '../../services/payment_service.dart';

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService();
});

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});