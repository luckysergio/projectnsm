import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class JadwalPengirimanPage extends StatefulWidget {
  const JadwalPengirimanPage({super.key});

  @override
  State<JadwalPengirimanPage> createState() => _JadwalPengirimanPageState();
}

class _JadwalPengirimanPageState extends State<JadwalPengirimanPage> {
  List<Map<String, dynamic>> _pengirimanList = [];
  bool _isLoading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) _fetchPendingOrders();
  }

  Future<void> _fetchPendingOrders() async {
    setState(() => _isLoading = true);

    if (_token == null) {
      debugPrint("Token belum dimuat!");
      return;
    }

    const String apiUrl =
        "http://192.168.1.104:8000/api/orders/jadwal-pengiriman";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $_token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _pengirimanList = List<Map<String, dynamic>>.from(
            data['orders'] ?? [],
          );
        });
      } else {
        debugPrint("Error: Status code ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> order) async {
    String status = order['status_order'];
    TextEditingController operatorController = TextEditingController(
      text: order['operator_name'] ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Status Pengiriman"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: "diproses", child: Text("Diproses")),
                  DropdownMenuItem(
                    value: "persiapan",
                    child: Text("Persiapan"),
                  ),
                  DropdownMenuItem(value: "dikirim", child: Text("Dikirim")),
                ],
                onChanged: (value) {
                  status = value!;
                },
                decoration: _inputDecoration("Status Pengiriman"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: operatorController,
                decoration: _inputDecoration("Nama Operator"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (status.isEmpty || operatorController.text.trim().isEmpty) {
                  // Tampilkan snackbar atau alert jika ada field kosong
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Semua data harus diisi!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                _updateOrderStatus(
                  order['id'],
                  status,
                  operatorController.text.trim(),
                );
                Navigator.pop(context);
              },
              child: const Text("Proses"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateOrderStatus(
    int id,
    String status,
    String operatorName,
  ) async {
    final String apiUrl = "http://192.168.1.104:8000/api/update-order/$id";
    setState(() => _isLoading = true);

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: jsonEncode({
          "status_order": status,
          "operator_name": operatorName,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackbar("Status berhasil diperbarui", Colors.green);
        _fetchPendingOrders();
      } else {
        _showSnackbar("Gagal memperbarui status", Colors.red);
      }
    } catch (e) {
      _showSnackbar("Terjadi kesalahan!", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return "-";
    }
  }

  String formatJam(String? time) {
    if (time == null || time.isEmpty) return "-";
    try {
      DateTime parsedTime = DateTime.parse("1970-01-01T$time");
      return "${DateFormat('HH.mm').format(parsedTime)} WIB";
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Jadwal Pengiriman"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pengirimanList.isEmpty
              ? const Center(child: Text("Tidak ada jadwal pengiriman"))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pengirimanList.length,
                itemBuilder: (context, index) {
                  final order = _pengirimanList[index];
                  return _buildPengirimanCard(order);
                },
              ),
    );
  }

  Widget _buildPengirimanCard(Map<String, dynamic> order) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Alat: ${order['inventori_name']}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Nama Pemesan: ${order['nama_pemesan']}",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              "Alamat Pemesan: ${order['alamat_pemesan']}",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              "Jam Berangkat: ${formatJam(order['jam_berangkat'])}",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              "Jam Mulai: ${formatJam(order['jam_mulai'])}",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              "Jam Selesai: ${formatJam(order['jam_selesai'])}",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              "Tanggal Pengiriman: ${formatDate(order['tgl_pengiriman'])}",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              "Tanggal Pengembalian: ${formatDate(order['tgl_pengembalian'])}",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              "Status: ${order['status_order']}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getStatusColor(order['status_order']),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _showEditDialog(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Proses",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "diproses":
        return Colors.orangeAccent;
      case "dikirim":
        return Colors.green;
      case "persiapan":
        return Colors.deepOrangeAccent;
      default:
        return Colors.grey;
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.blue.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
