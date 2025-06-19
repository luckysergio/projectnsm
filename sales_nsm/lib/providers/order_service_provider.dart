import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_nsm/services/order_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  final service = OrderService(ref);
  service.startPolling();
  return service;
});
