import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoriPerawatanPage extends StatefulWidget {
  const HistoriPerawatanPage({super.key});

  @override
  HistoriPerawatanPageState createState() => HistoriPerawatanPageState();
}

class HistoriPerawatanPageState extends State<HistoriPerawatanPage> {
  late Future<List<Map<String, dynamic>>> _perawatanFuture;
  String? _token;

  @override
  void initState() {
    super.initState();
    _perawatanFuture = _fetchPerawatan();
  }

  Future<List<Map<String, dynamic>>> _fetchPerawatan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    if (_token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali.");
    }

    final response = await http.get(
      Uri.parse("http://192.168.1.104:8000/api/perawatan/proses-selesai"),
      headers: {"Authorization": "Bearer $_token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data["perawatan"]);
    } else {
      throw Exception("Gagal mengambil data histori perawatan.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Histori Perawatan"),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _perawatanFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Tidak ada histori perawatan."));
            }

            final perawatan = snapshot.data!;
            return ListView.builder(
              itemCount: perawatan.length,
              itemBuilder: (context, index) {
                final item = perawatan[index];
                return _buildPerawatanCard(item);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPerawatanCard(Map<String, dynamic> perawatan) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ListTile(
        leading: const Icon(Icons.build, color: Colors.blue, size: 40),
        title: Text(
          "${perawatan['inventori_name']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Operator: ${perawatan['operator_name'] ?? '-'}"),
            Text("Tanggal Mulai: ${perawatan['tanggal_mulai'] ?? '-'}"),
            Text("Tanggal Selesai: ${perawatan['tanggal_selesai'] ?? '-'}"),
            Text(
              "Status: ${perawatan['status_perawatan']}",
              style: TextStyle(
                color:
                    perawatan['status_perawatan'] == "diproses"
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.blue,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPerawatanPage(perawatan: perawatan),
            ),
          );
        },
      ),
    );
  }
}

class DetailPerawatanPage extends StatelessWidget {
  final Map<String, dynamic> perawatan;
  const DetailPerawatanPage({super.key, required this.perawatan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Detail Perawatan ${perawatan['id']}"),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("ID Perawatan", perawatan["id"].toString()),
                _buildDetailRow(
                  "Nama Alat",
                  perawatan["inventori_name"] ?? "-",
                ),
                _buildDetailRow("Operator", perawatan["operator_name"] ?? "-"),
                _buildDetailRow(
                  "Tanggal Mulai",
                  perawatan["tanggal_mulai"] ?? "-",
                ),
                _buildDetailRow(
                  "Tanggal Selesai",
                  perawatan["tanggal_selesai"] ?? "-",
                ),
                _buildDetailRow("Catatan", perawatan["catatan"] ?? "-"),
                _buildDetailRow(
                  "Status",
                  perawatan["status_perawatan"] ?? "-",
                  color:
                      perawatan["status_perawatan"] == "diproses"
                          ? Colors.orange
                          : Colors.green,
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Kembali",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color color = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: color),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
