import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatusOrderPage extends StatefulWidget {
  const StatusOrderPage({super.key});

  @override
  StatusOrderPageState createState() => StatusOrderPageState();
}

class StatusOrderPageState extends State<StatusOrderPage> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;
  String? _token;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    if (_token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali.");
    }

    final response = await http.get(
      Uri.parse("http://192.168.1.104:8000/api/orders/pending"),
      headers: {"Authorization": "Bearer $_token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data["orders"]);
    } else {
      throw Exception("Gagal mengambil data order.");
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

  String formatJam(String? time) {
    if (time == null || time.isEmpty) return "-";
    try {
      DateTime parsedTime = DateTime.parse(
        "1970-01-01T$time",
      ); // Parsing waktu (anggap tanggalnya tidak penting)
      return "${DateFormat('HH.mm').format(parsedTime)} WIB"; // Format jam dan menit, lalu tambahkan 'WIB'
    } catch (e) {
      return "-"; // Jika format waktu tidak valid
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Status Order"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("Tidak ada order yang tersedia."),
              );
            }

            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
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
                      "Order ID: ${order['id']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Pemesan: ${order['nama_pemesan']}"),
                        Text(
                          "Pengiriman: ${formatDate(order['tgl_pemakaian'])}",
                        ),
                        Text(
                          "Status: ${order['status_order']}",
                          style: TextStyle(
                            color:
                                order['status_order'] == "Dikirim"
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.blue,
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailOrderPage(order: order),
                        ),
                      );

                      setState(() {
                        _ordersFuture = _fetchOrders();
                      });
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class DetailOrderPage extends StatelessWidget {
  final Map<String, dynamic> order;
  const DetailOrderPage({super.key, required this.order});

  // Fungsi untuk format tanggal
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

  // Fungsi untuk format jam
  String formatJam(String? time) {
    if (time == null || time.isEmpty) return "-";
    try {
      DateTime parsedTime = DateTime.parse(
        "1970-01-01T$time",
      ); // Parsing waktu (anggap tanggalnya tidak penting)
      return "${DateFormat('HH.mm').format(parsedTime)} WIB"; // Format jam dan menit, lalu tambahkan 'WIB'
    } catch (e) {
      return "-"; // Jika format waktu tidak valid
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Order ${order['id']}"),
        centerTitle: true,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("ID Order", order["id"].toString()),
                _buildDetailRow("Nama Pemesan", order["nama_pemesan"]),
                _buildDetailRow("Jenis Alat", order["inventori_name"] ?? "-"),
                _buildDetailRow(
                  "Status",
                  order["status_order"],
                  color:
                      order["status_order"] == "Dikirim"
                          ? Colors.green
                          : Colors.orange,
                ),
                _buildDetailRow(
                  "Pengiriman",
                  formatDate(order["tgl_pemakaian"] ?? "-"),
                ),
                _buildDetailRow("Jam Mulai", formatJam(order["jam_mulai"])),
                _buildDetailRow("Jam Selesai", formatJam(order["jam_selesai"])),

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
}
