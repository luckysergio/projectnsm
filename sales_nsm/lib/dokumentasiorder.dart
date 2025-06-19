import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DokumentasiHistoriPage extends StatefulWidget {
  const DokumentasiHistoriPage({super.key});

  @override
  State<DokumentasiHistoriPage> createState() => _DokumentasiHistoriPageState();
}

class _DokumentasiHistoriPageState extends State<DokumentasiHistoriPage> {
  Map<String, List<dynamic>> _groupedDocuments = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    const String apiUrl = "http://192.168.1.104:8000/api/order-documents";
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Token tidak ditemukan! Silakan login ulang."),
        ),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data["data"] ?? [];

        // Group by order_id
        final Map<String, List<dynamic>> grouped = {};
        for (var doc in documents) {
          final orderId = doc["order_id"].toString();
          if (!grouped.containsKey(orderId)) {
            grouped[orderId] = [];
          }
          grouped[orderId]!.add(doc);
        }

        if (!mounted) return;
        setState(() {
          _groupedDocuments = grouped;
          _isLoading = false;
        });
      } else {
        throw Exception("Gagal mengambil histori");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Histori Dokumentasi"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _groupedDocuments.isEmpty
              ? const Center(child: Text("Tidak ada histori dokumentasi"))
              : ListView(
                padding: const EdgeInsets.all(16),
                children:
                    _groupedDocuments.entries.map((entry) {
                      final orderId = entry.key;
                      final docs = entry.value;

                      final namaPemesan =
                          docs.first['order']?["customer"]?["nama"]
                              ?.toString() ??
                          '-';
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  "NSM-SEWA-00$orderId",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Center(
                                child: Text(
                                  "Pemesan: $namaPemesan",
                                  style: const TextStyle(fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const Divider(),
                              Column(
                                children:
                                    docs.map((doc) {
                                      return ListTile(
                                        leading: const Icon(
                                          Icons.image_outlined,
                                          color: Colors.blue,
                                        ),
                                        title: Text(
                                          "Dokumentasi ID ${doc['id']}",
                                        ),
                                        subtitle: Text(
                                          doc['note'] ?? 'Tidak ada catatan',
                                        ),
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => DetailOrderPage(
                                                    order: doc,
                                                  ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
    );
  }
}

class DetailOrderPage extends StatefulWidget {
  final Map<String, dynamic> order;
  const DetailOrderPage({super.key, required this.order});

  @override
  State<DetailOrderPage> createState() => _DetailOrderPageState();
}

class _DetailOrderPageState extends State<DetailOrderPage> {
  List<String> photoUrls = [];

  @override
  void initState() {
    super.initState();
    _loadMediaData();
  }

  void _loadMediaData() {
    try {
      final photo = widget.order["photo"];
      if (photo is List) {
        photoUrls = List<String>.from(photo);
      } else if (photo is String && photo.isNotEmpty) {
        photoUrls = [photo];
      }
      setState(() {});
    } catch (e) {
      debugPrint("Error parsing photo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Detail Dokumentasi Order ${order['order_id']}"),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("ID Dokumentasi", order["id"].toString()),
                    _buildDetailRow(
                      "Nama Pemesan",
                      order["order"]?["customer"]?["nama"]?.toString() ?? "-",
                    ),
                    _buildDetailRow(
                      "Catatan",
                      order["note"] ?? "Tidak ada catatan",
                    ),
                    const SizedBox(height: 20),
                    _buildMediaGrid("Foto Dokumentasi", photoUrls),
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

  Widget _buildMediaGrid(String label, List<String> mediaUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        mediaUrls.isEmpty
            ? const Text("Tidak ada file", style: TextStyle(color: Colors.grey))
            : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: mediaUrls.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    mediaUrls[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, color: Colors.grey);
                    },
                  ),
                );
              },
            ),
      ],
    );
  }
}
