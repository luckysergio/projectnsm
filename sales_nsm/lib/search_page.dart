import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

    const String orderApiUrl = "http://192.168.1.104:8000/api/orders/all";

    try {
      final response = await http.get(
        Uri.parse(orderApiUrl),
        headers: {"Authorization": "Bearer $_token"},
      );

      if (response.statusCode == 200) {
        final orderData = jsonDecode(response.body);

        List<Map<String, dynamic>> orders = List<Map<String, dynamic>>.from(
          orderData['orders'],
        );

        setState(() {
          _orderList = orders;
          _filteredOrders =
              _orderList
                  .where(
                    (order) => order['nama_pemesan'].toLowerCase().contains(
                      query.toLowerCase(),
                    ),
                  )
                  .toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching orders: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Cari Order"),
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
                hintText: "Cari berdasarkan nama pemesan...",
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
            order['nama_pemesan'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            "Status: ${order['status_order']}",
            style: TextStyle(color: Colors.grey[700]),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Order",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
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
