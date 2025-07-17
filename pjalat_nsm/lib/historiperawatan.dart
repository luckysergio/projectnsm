import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HistoriPerawatanPage extends StatefulWidget {
  const HistoriPerawatanPage({super.key});

  @override
  State<HistoriPerawatanPage> createState() => _HistoriPerawatanPageState();
}

class _HistoriPerawatanPageState extends State<HistoriPerawatanPage> {
  late Future<List<Map<String, dynamic>>> _perawatanList;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _perawatanList = _fetchHistoryPerawatan();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchHistoryPerawatan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("Token tidak ditemukan");

      final response = await http.get(
        Uri.parse("http://192.168.1.105:8000/api/perawatan/selesai"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['perawatans'] ?? []);
      } else {
        throw Exception(
          "Gagal memuat data. Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _perawatanList = _fetchHistoryPerawatan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Histori Perawatan"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _perawatanList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Gagal memuat data",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              );
            }

            final perawatans = snapshot.data!;
            if (perawatans.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      color: Colors.grey,
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text("Belum ada histori perawatan"),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: perawatans.length,
              itemBuilder: (context, index) {
                final perawatan = perawatans[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => DetailPerawatanPage(perawatan: perawatan),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.history,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "PRW-${perawatan['id'].toString().padLeft(3, '0')}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Operator: ${perawatan['operator']?['nama'] ?? '-'}",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class DetailPerawatanPage extends StatelessWidget {
  final Map<String, dynamic> perawatan;
  const DetailPerawatanPage({super.key, required this.perawatan});

  String formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(dateStr));
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List detailPerawatans = perawatan["detail_perawatans"] ?? [];
    final operator = perawatan["operator"] ?? {};

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("PRW-${perawatan['id'].toString().padLeft(3, '0')}"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      icon: Icons.person,
                      title: "Operator",
                      value: operator['nama']?.toString() ?? '-',
                    ),
                    const Divider(height: 24),
                    const Center(
                      child: Text(
                        "Detail Perawatan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (detailPerawatans.isEmpty)
                      const Center(child: Text("Tidak ada detail perawatan")),
                    ...detailPerawatans.map((detail) {
                      final alat = detail["alat"] ?? {};
                      return Column(
                        children: [
                          _buildDetailCard(
                            alat: alat,
                            detail: Map<String, dynamic>.from(detail),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required Map<String, dynamic> alat,
    required Map<String, dynamic> detail,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                alat['nama']?.toString() ?? 'Alat Tidak Diketahui',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow("Status", detail['status']?.toString() ?? '-'),
            if (detail['catatan'] != null &&
                detail['catatan'].toString().isNotEmpty)
              _buildDetailRow("Catatan", detail['catatan'].toString()),
            _buildDetailRow("Tanggal Mulai", formatDate(detail['tgl_mulai'])),
            _buildDetailRow(
              "Tanggal Selesai",
              formatDate(detail['tgl_selesai']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
