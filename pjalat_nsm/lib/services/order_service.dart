import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:pjalat_nsm/providers/jwt_token_provider.dart';
import 'package:pjalat_nsm/providers/order_count_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    if (token == null) return;

    final prefs = await SharedPreferences.getInstance();
    final jabatan = prefs.getString('jabatan')?.toLowerCase();
    final idKaryawan = prefs.getInt('id_karyawan');

    Uri url;

    if (jabatan == 'operator alat' && idKaryawan != null) {
      url = Uri.parse(
        "http://192.168.1.105:8000/api/orders/active/operator/$idKaryawan",
      );
    } else {
      url = Uri.parse("http://192.168.1.105:8000/api/orders/active/public");
    }

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final count = data['count'] ?? 0;
      ref.read(orderCountProvider.notifier).state = count;
    } else {}
  }
}
