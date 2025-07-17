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
  List<Map<String, dynamic>> _filteredOrders = [];
  List<Map<String, dynamic>> _filteredPerawatans = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _token;
  int _selectedIndex = 0;

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
        _filteredPerawatans = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
    });

    await Future.wait([_fetchOrders(query), _fetchPerawatans(query)]);

    setState(() => _isLoading = false);
  }

  Future<void> _fetchOrders(String query) async {
    const String orderApiUrl =
        "http://192.168.1.105:8000/api/orders/all/public";

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
                  order['inventori_name']?.toString().toLowerCase() ?? '';
              return nama.contains(query.toLowerCase());
            }).toList();

        setState(() {
          _filteredOrders = filtered;
        });
      }
    } catch (e) {
      debugPrint("Error fetching orders: $e");
    }
  }

  Future<void> _fetchPerawatans(String query) async {
    const String perawatanApiUrl =
        "http://192.168.1.105:8000/api/perawatan/all";

    try {
      final response = await http.get(
        Uri.parse(perawatanApiUrl),
        headers: {"Authorization": "Bearer $_token"},
      );

      if (response.statusCode == 200) {
        final perawatanData = jsonDecode(response.body);
        final List<dynamic> rawPerawatans = perawatanData['perawatans'];

        List<Map<String, dynamic>> perawatans = List<Map<String, dynamic>>.from(
          rawPerawatans,
        );

        final filtered =
            perawatans.where((perawatan) {
              final detailPerawatans =
                  perawatan['detail_perawatans'] as List? ?? [];
              return detailPerawatans.any((detail) {
                final alatName =
                    detail['alat']?['nama']?.toString().toLowerCase() ?? '';
                return alatName.contains(query.toLowerCase());
              });
            }).toList();

        setState(() {
          _filteredPerawatans = filtered;
        });
      }
    } catch (e) {
      debugPrint("Error fetching perawatans: $e");
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
        title: const Text("Cari order dan perawatan alat"),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                _selectedIndex == 0
                                    ? Colors.blueAccent
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        "Orders (${_filteredOrders.length})",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight:
                              _selectedIndex == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          color:
                              _selectedIndex == 0
                                  ? Colors.blueAccent
                                  : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                _selectedIndex == 1
                                    ? Colors.blueAccent
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        "Perawatans (${_filteredPerawatans.length})",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight:
                              _selectedIndex == 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          color:
                              _selectedIndex == 1
                                  ? Colors.blueAccent
                                  : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
                        "Masukkan nama alat untuk mencari order atau perawatan...",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final currentList =
        _selectedIndex == 0 ? _filteredOrders : _filteredPerawatans;

    if (currentList.isEmpty) {
      return Center(
        child: Text(
          "Tidak ada hasil untuk ${_selectedIndex == 0 ? 'orders' : 'perawatans'}",
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: currentList.length,
      itemBuilder: (context, index) {
        final item = currentList[index];
        return _selectedIndex == 0
            ? _buildOrderCard(item)
            : _buildPerawatanCard(item);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
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
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_cart, color: Colors.blue),
          ),
          title: Text(
            order['operator'] ?? '-',
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
                "Alat: ${order['inventori_name'] ?? '-'}",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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

  Widget _buildPerawatanCard(Map<String, dynamic> perawatan) {
    final detailPerawatans = perawatan['detail_perawatans'] as List? ?? [];
    final inventoriNames = detailPerawatans
        .map((detail) => detail['alat']?['nama'] ?? '-')
        .join(', ');

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
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.build, color: Colors.green),
          ),
          title: Text(
            perawatan['operator']?['nama'] ?? '-',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                "ID: PERAWATAN-00${perawatan['id']}",
                style: TextStyle(color: Colors.grey[700]),
              ),
              Text(
                "Alat: $inventoriNames",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => DetailPage(data: perawatan, isOrder: false),
              ),
            );
          },
        ),
      ),
    );
  }
}
