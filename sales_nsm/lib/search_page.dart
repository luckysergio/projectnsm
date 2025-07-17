import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _filteredOrders = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _token;

  final _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  final _tanggalFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) setState(() {});
  }

  Future<void> _fetchData(String query) async {
    if (_token == null || query.isEmpty) {
      setState(() {
        _filteredOrders = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
    });

    const String orderApiUrl = "http://192.168.1.105:8000/api/orders/all";

    try {
      final response = await http.get(
        Uri.parse(orderApiUrl),
        headers: {"Authorization": "Bearer $_token"},
      );

      if (response.statusCode == 200) {
        final orderData = jsonDecode(response.body);
        final List<dynamic> rawOrders = orderData['orders'];

        List<Map<String, dynamic>> orders = List<Map<String, dynamic>>.from(
          rawOrders,
        );

        final filtered =
            orders.where((order) {
              final nama =
                  order['nama_pemesan']?.toString().toLowerCase() ?? '';
              return nama.contains(query.toLowerCase());
            }).toList();

        setState(() {
          _filteredOrders = filtered;
        });
      }
    } catch (e) {
      debugPrint("Error fetching orders: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch(String query) {
    _fetchData(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Cari Order"),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: _onSearch,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Cari berdasarkan nama pemesan...",
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
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
                        "Masukkan nama pemesan untuk mencari order...",
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
                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
    final tanggal = order['tanggal_order'];
    final tanggalFormatted =
        tanggal != null ? _tanggalFormat.format(DateTime.parse(tanggal)) : '-';

    final totalTagihan = order['tagihan'] ?? 0;
    final totalDibayar = order['total_dibayar'] ?? 0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          title: Text(
            order['nama_pemesan'] ?? '-',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                "Status: ${order['status_order'] ?? '-'}",
                style: TextStyle(color: Colors.grey[700]),
              ),
              Text(
                "Tanggal: $tanggalFormatted",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _rupiahFormat.format(totalTagihan),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Bayar: ${_rupiahFormat.format(totalDibayar)}",
                style: const TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(data: order, isOrder: true),
              ),
            );
          },
        ),
      ),
    );
  }
}
