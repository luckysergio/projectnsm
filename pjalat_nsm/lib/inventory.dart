import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String? _selectedCategory;
  bool _isLoading = false;
  List<Map<String, dynamic>> _inventoryList = [];

  final String apiUrl = "http://192.168.1.104:8000/api/inventory";

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
      "api_value": "pompa_longboom",
    },
    {
      "title": "Pompa Super Long",
      "image": "assets/images/super-longboom.png",
      "api_value": "pompa_superlong",
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (!mounted) return;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Token tidak ditemukan, silakan login ulang!"),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse("$apiUrl/$category"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _inventoryList = data.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Gagal mengambil data, coba lagi! Error: ${response.statusCode}",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Inventori alat"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
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
            if (_selectedCategory != null)
              _buildTitle("Daftar $_selectedCategory"),
            const SizedBox(height: 10),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _inventoryList.isEmpty
                      ? _buildEmptyState()
                      : _buildPompaList(),
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
          final pompa = pompaCategories[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = pompa["title"];
              });
              _fetchInventory(pompa["api_value"]!);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black26.withAlpha(50), blurRadius: 5),
                ],
                color:
                    _selectedCategory == pompa["title"]
                        ? Colors.blue.shade100
                        : Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      pompa["image"]!,
                      width: 120,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pompa["title"]!,
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

  Widget _buildPompaList() {
    return ListView.builder(
      itemCount: _inventoryList.length,
      itemBuilder: (context, index) {
        final pompa = _inventoryList[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              pompa["nama_alat"],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Waktu Pemakaian: ${pompa["waktu_pemakaian"]} Jam",
              style: const TextStyle(fontSize: 14),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(pompa["status"]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pompa["status"].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "tersedia":
        return Colors.green;
      case "sedang_disewa":
        return Colors.orange;
      case "sedang_perawatan":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
