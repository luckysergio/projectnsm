import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:pjalat_nsm/providers/jwt_token_provider.dart';
import 'package:pjalat_nsm/providers/perawatan_count_provider.dart';

class PerawatanService {
  final Ref ref;

  PerawatanService(this.ref);

  void startPolling() {
    Timer.periodic(const Duration(seconds: 10), (_) {
      fetchPerawatanCount();
    });
    fetchPerawatanCount();
  }

  Future<void> fetchPerawatanCount() async {
    final token = await ref.read(jwtTokenProvider.future);

    if (token == null) {
      return;
    }

    final response = await http.get(
      Uri.parse("http://192.168.1.104:8000/api/Perawatans/active/public"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final count = data['count'] ?? 0;
      ref.read(perawatanCountProvider.notifier).state = count;
    } else {
      // print("❌ Gagal ambil data order: ${response.statusCode}");
      // Untuk production gunakan logger jika perlu
    }
  }
}
