import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _orderList = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<void> _fetchData(String query) async {
    setState(() {
      _isLoading = true;
      _isSearching = true;
    });

    const String orderApiUrl = "http://192.168.1.104:8000/api/orders/histori";
    const String perawatanApiUrl =
        "http://192.168.1.104:8000/api/perawatan/proses-selesai";

    try {
      final responses = await Future.wait([
        http.get(
          Uri.parse(orderApiUrl),
          headers: {"Authorization": "Bearer $_token"},
        ),
        http.get(
          Uri.parse(perawatanApiUrl),
          headers: {"Authorization": "Bearer $_token"},
        ),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final orderData = jsonDecode(responses[0].body);
        final perawatanData = jsonDecode(responses[1].body);

        List<Map<String, dynamic>> orders = List<Map<String, dynamic>>.from(
          orderData['orders'],
        );
        List<Map<String, dynamic>> perawatan = List<Map<String, dynamic>>.from(
          perawatanData['perawatan'],
        );

        orders = orders.map((e) => {...e, "type": "order"}).toList();
        perawatan = perawatan.map((e) => {...e, "type": "perawatan"}).toList();

        setState(() {
          _orderList = [...orders, ...perawatan];
          _filteredOrders =
              _orderList
                  .where(
                    (order) => order['inventori_name'].toLowerCase().contains(
                      query.toLowerCase(),
                    ),
                  )
                  .toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      setState(() => _isSearching = false);
    } else {
      _fetchData(query);
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat(
        'dd-MM-yyyy',
      ).format(parsedDate); // format tanggal ke dd/MM/yyyy
    } catch (e) {
      return "-"; // jika format tanggal tidak valid
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Menu pencarian"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: _onSearch,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Cari berdasarkan nama alat...",
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child:
                !_isSearching
                    ? const Center(
                      child: Text(
                        "Masukkan nama alat untuk mencari...",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredOrders.isEmpty
                    ? const Center(
                      child: Text(
                        "Tidak ada hasil",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];
                        return _buildOrderCard(order);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    String typeLabel = order["type"] == "order" ? "Order" : "Perawatan";
    Color typeColor =
        order["type"] == "order" ? Colors.blueAccent : Colors.green;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          title: Text(
            order['inventori_name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Status: ${order['status_order'] ?? order['status_perawatan']}",
                style: TextStyle(color: Colors.grey[700]),
              ),
              Text(
                "Mulai : ${formatDate(order['tgl_pengiriman'] ?? order['tanggal_mulai'])}",
                style: TextStyle(color: Colors.grey[700]),
              ),
              Text(
                "Selesai : ${formatDate(order['tgl_pengembalian'] ?? order['tanggal_selesai'])}",
                style: TextStyle(color: Colors.grey[700]),
              ),
              Text(
                "Operator: ${order['operator_name'] ?? '-'}",
                style: TextStyle(color: Colors.grey[700]),
              ),
              Text(
                "Catatan: ${order['catatan'] ?? '-'}",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              typeLabel,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => DetailPage(
                      data: order,
                      isOrder: order.containsKey("status_order"),
                    ),
              ),
            );
          },
        ),
      ),
    );
  }
}
