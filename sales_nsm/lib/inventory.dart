import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String? _selectedCategoryTitle;
  bool _isLoading = false;
  List<Map<String, dynamic>> _inventoryList = [];

  final String apiBaseUrl = "http://192.168.1.104:8000/api/inventory";

  final List<Map<String, String>> pompaCategories = const [
    {
      "title": "Pompa Standart",
      "image": "assets/images/standart.png",
      "api_value": "pompa_standart",
    },
    {
      "title": "Pompa Mini",
      "image": "assets/images/mini.png",
      "api_value": "pompa_mini",
    },
    {
      "title": "Pompa Long Boom",
      "image": "assets/images/longboom.png",
      "api_value": "pompa_long_boom",
    },
    {
      "title": "Pompa Super Long",
      "image": "assets/images/super-longboom.png",
      "api_value": "pompa_super_long",
    },
    {
      "title": "Pompa Kodok",
      "image": "assets/images/kodok.png",
      "api_value": "pompa_kodok",
    },
  ];

  Future<void> _fetchInventory(String category) async {
    setState(() {
      _isLoading = true;
      _inventoryList = [];
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!mounted) return;

    if (token == null) {
      _showMessage("Token tidak ditemukan. Silakan login ulang.");
      setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse("$apiBaseUrl/$category");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        setState(() {
          _inventoryList =
              data.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        _showMessage("Token tidak valid. Silakan login ulang.");
        setState(() => _isLoading = false);
      } else {
        _showMessage("Gagal mengambil data (${response.statusCode})");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMessage("Terjadi kesalahan: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Inventory Alat"),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle("Jenis-Jenis Pompa"),
            const SizedBox(height: 12),
            _buildCategoryList(),
            const SizedBox(height: 20),
            if (_selectedCategoryTitle != null)
              _buildTitle("Daftar $_selectedCategoryTitle"),
            const SizedBox(height: 10),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _inventoryList.isEmpty
                      ? _buildEmptyState()
                      : _buildInventoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pompaCategories.length,
        itemBuilder: (context, index) {
          final category = pompaCategories[index];
          final isSelected = _selectedCategoryTitle == category["title"];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryTitle = category["title"];
              });
              _fetchInventory(category["api_value"]!);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[100] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      category["image"]!,
                      width: 120,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category["title"]!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Tidak ada data untuk kategori ini.",
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildInventoryList() {
    return ListView.builder(
      itemCount: _inventoryList.length,
      itemBuilder: (context, index) {
        final item = _inventoryList[index];
        final nama = item["nama"] ?? "Tidak diketahui";
        final status = item["status"] ?? "tidak_diketahui";

        final hargaRaw = item["harga"];
        double harga = 0;
        if (hargaRaw is String) {
          harga = double.tryParse(hargaRaw) ?? 0;
        } else if (hargaRaw is num) {
          harga = hargaRaw.toDouble();
        }

        final hargaFormatted = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        ).format(harga);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 4,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            title: Text(
              nama,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pemakaian: ${item["pemakaian"] ?? "-"} Jam"),
                const SizedBox(height: 6),
                Text(
                  "Harga: $hargaFormatted / Jam",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status.toString().toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
        return Colors.green;
      case 'disewa':
        return Colors.orange;
      case 'perawatan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
