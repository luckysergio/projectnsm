import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HistoriOrderPage extends StatefulWidget {
  const HistoriOrderPage({super.key});

  @override
  HistoriOrderPageState createState() => HistoriOrderPageState();
}

class HistoriOrderPageState extends State<HistoriOrderPage> {
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
      Uri.parse("http://192.168.1.104:8000/api/orders/completed"),
      headers: {"Authorization": "Bearer $_token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data["orders"]);
    } else {
      throw Exception("Gagal mengambil data order.");
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Histori Order"),
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
                        Text("Alat : ${order['inventori_name'] ?? '-'}"),
                        Text(
                          "Status: ${order['status_order']}",
                          style: TextStyle(
                            color:
                                order['status_order'] == "Dikirim"
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                        ),
                        // Menambahkan format tanggal pada bagian ini
                        Text(
                          "Pengiriman: ${formatDate(order['tgl_pemakaian'])}",
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
                          builder: (context) => DetailOrderPage(order: order),
                        ),
                      );
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

  String formatRupiah(double amount) {
    final NumberFormat rupiahFormat = NumberFormat(
      "#,##0",
      "id_ID",
    ); // Format tanpa desimal
    return "RP. ${rupiahFormat.format(amount)}"; // Menambahkan 'RP.' di depan
  }

  double? parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value);
  }

  // Fungsi untuk format overtime agar tanpa desimal jika berupa angka bulat
  String formatOvertime(double overtime) {
    if (overtime == overtime.toInt()) {
      return overtime.toInt().toString(); // Menghapus desimal jika angka bulat
    } else {
      return overtime.toString();
    }
  }

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
                  "Pengiriman",
                  formatDate(order["tgl_pemakaian"]),
                ),
                _buildDetailRow(
                  "Pengembalian",
                  formatDate(order["tgl_pengembalian"] ?? "-"),
                ),
                _buildDetailRow("Jam Mulai", formatJam(order["jam_mulai"])),
                _buildDetailRow("Jam Selesai", formatJam(order["jam_selesai"])),
                _buildDetailRow("Order Sewa", "${order["total_sewa"]} Jam"),
                _buildDetailRow(
                  "Jumlah Sewa",
                  (order["harga_sewa"] != null)
                      ? formatRupiah(
                        parseDouble(order["harga_sewa"].toString()) ?? 0,
                      )
                      : "-",
                ),
                _buildDetailRow(
                  "Overtime",
                  (order["overtime"] != null)
                      ? "${formatOvertime(parseDouble(order["overtime"].toString()) ?? 0)} Jam"
                      : "-",
                ),
                _buildDetailRow(
                  "Denda",
                  (order["denda"] != null)
                      ? formatRupiah(
                        parseDouble(order["denda"].toString()) ?? 0,
                      )
                      : "-",
                ),
                _buildDetailRow(
                  "Total Pembayaran",
                  (order["total_harga"] != null)
                      ? formatRupiah(
                        parseDouble(order["total_harga"].toString()) ?? 0,
                      )
                      : "-",
                ),
                _buildDetailRow("Operator", order["operator_name"] ?? "-"),
                _buildDetailRow(
                  "Status Pembayaran",
                  order["status_pembayaran"],
                  color:
                      order["status_pembayaran"] == "lunas"
                          ? Colors.green
                          : Colors.orange,
                ),
                _buildDetailRow(
                  "Status order",
                  order["status_order"],
                  color:
                      order["status_order"] == "Selesai"
                          ? Colors.green
                          : Colors.orange,
                ),
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
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Wrap(
              children: [
                Text(value, style: TextStyle(fontSize: 16, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
