import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JadwalPerawatanPage extends StatefulWidget {
  const JadwalPerawatanPage({super.key});

  @override
  State<JadwalPerawatanPage> createState() => _JadwalPerawatanPageState();
}

class _JadwalPerawatanPageState extends State<JadwalPerawatanPage> {
  List<Map<String, dynamic>> _perawatanList = [];
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

    const String apiUrl = "http://192.168.1.104:8000/api/perawatan/pending";

    try {
      debugPrint("Fetching data from: $apiUrl");
      debugPrint("Token: $_token");

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $_token"},
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['orders'] != null) {
          debugPrint("Jumlah data yang diterima: ${data['orders'].length}");
        } else {
          debugPrint("Key 'orders' tidak ditemukan dalam response!");
        }

        setState(() {
          _perawatanList = List<Map<String, dynamic>>.from(
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

  Future<void> _showEditDialog(Map<String, dynamic> perawatan) async {
    TextEditingController operatorController = TextEditingController(
      text: perawatan['operator_name'] ?? '',
    );
    TextEditingController catatanController = TextEditingController(
      text: perawatan['catatan'] ?? '',
    );

    String status = perawatan['status_perawatan'];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Perawatan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: "pending", child: Text("Pending")),
                  DropdownMenuItem(value: "proses", child: Text("Proses")),
                ],
                onChanged: (value) {
                  status = value!;
                },
                decoration: _inputDecoration("Status Perawatan"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: operatorController,
                decoration: _inputDecoration("Nama Operator"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: catatanController,
                maxLines: 3,
                decoration: _inputDecoration("Catatan"),
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
                if (status.isEmpty ||
                    operatorController.text.trim().isEmpty ||
                    catatanController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Semua data harus diisi!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                _updatePerawatan(
                  perawatan['id'],
                  status,
                  operatorController.text.trim(),
                  catatanController.text.trim(),
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

  Future<void> _updatePerawatan(
    int id,
    String status,
    String operator,
    String catatan,
  ) async {
    final String apiUrl = "http://192.168.1.104:8000/api/perawatan/$id";
    setState(() => _isLoading = true);

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: jsonEncode({
          "status_perawatan": status,
          "operator_name": operator,
          "catatan": catatan,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackbar("Data berhasil diperbarui", Colors.green);
        _fetchPendingOrders();
      } else {
        _showSnackbar("Gagal memperbarui data", Colors.red);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Jadwal Perawatan"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _perawatanList.isEmpty
              ? const Center(child: Text("Tidak ada jadwal perawatan pending"))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _perawatanList.length,
                itemBuilder: (context, index) {
                  final perawatan = _perawatanList[index];
                  return _buildPerawatanCard(perawatan);
                },
              ),
    );
  }

  Widget _buildPerawatanCard(Map<String, dynamic> perawatan) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Alat: ${perawatan['inventori_name']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text("Tanggal Mulai: ${formatDate(perawatan['tanggal_mulai'])}"),
            const SizedBox(height: 5),
            Text(
              "Status: ${perawatan['status_perawatan']}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    perawatan['status_perawatan'] == "pending"
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _showEditDialog(perawatan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Proses",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
