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
  List<dynamic> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final String apiUrl = "http://192.168.1.104:8000/api/order-documents";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (!mounted) return;
    if (token == null) {
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
        setState(() {
          _documents = data["data"];
          _isLoading = false;
        });
      } else {
        throw Exception("Gagal mengambil histori");
      }
    } catch (e) {
      setState(() => _isLoading = false);
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
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _documents.isEmpty
              ? const Center(child: Text("Tidak ada histori dokumentasi"))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _documents.length,
                itemBuilder: (context, index) {
                  final doc = _documents[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(
                        Icons.inventory,
                        color: Colors.blue,
                        size: 40,
                      ),
                      title: Text(
                        "Dokumentasi ID ${doc['id']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Pemesan: ${doc['order']['nama_pemesan']}"),
                          Text(
                            "Catatan: ${doc['note'] ?? 'Tidak ada catatan'}",
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
                            builder: (context) => DetailOrderPage(order: doc),
                          ),
                        );
                      },
                    ),
                  );
                },
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
      if (widget.order["photo"] != null) {
        photoUrls = List<String>.from(jsonDecode(widget.order["photo"]));
      }
      setState(() {});
    } catch (e) {
      debugPrint("Error parsing JSON: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Detail Dokumentasi Order ${widget.order['order_id']}"),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      body: Padding(
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
                  _buildDetailRow(
                    "ID Dokumentasi",
                    widget.order["id"].toString(),
                  ),
                  _buildDetailRow(
                    "Nama Pemesan",
                    widget.order["order"]["nama_pemesan"],
                  ),
                  _buildDetailRow(
                    "Catatan",
                    widget.order["note"] ?? "Tidak ada catatan",
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
                final url =
                    "http://192.168.1.104:8000/storage/${mediaUrls[index]}";
                return Image.network(url, fit: BoxFit.cover);
              },
            ),
      ],
    );
  }
}
