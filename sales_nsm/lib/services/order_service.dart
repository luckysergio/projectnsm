import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sales_nsm/providers/order_count_provider.dart';
import 'package:sales_nsm/providers/jwt_token_provider.dart';

class OrderService {
  final Ref ref;

  OrderService(this.ref);

  void startPolling() {
    Timer.periodic(const Duration(seconds: 10), (_) {
      fetchOrderCount();
    });
    fetchOrderCount();
  }

  Future<void> fetchOrderCount() async {
    final token = await ref.read(jwtTokenProvider.future);

    if (token == null) {
      return;
    }

    final response = await http.get(
      Uri.parse("http://192.168.1.104:8000/api/orders/active"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final count = data['count'] ?? 0;
      ref.read(orderCountProvider.notifier).state = count;
    } else {
      // print("❌ Gagal ambil data order: ${response.statusCode}");
      // Untuk production gunakan logger jika perlu
    }
  }
}
