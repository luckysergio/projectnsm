import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HistoriOrderPage extends StatefulWidget {
  const HistoriOrderPage({super.key});

  @override
  State<HistoriOrderPage> createState() => _HistoriOrderPageState();
}

class _HistoriOrderPageState extends State<HistoriOrderPage> {
  late Future<List<dynamic>> _orderList;

  @override
  void initState() {
    super.initState();
    _orderList = fetchHistoriOrders();
  }

  Future<List<dynamic>> fetchHistoriOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception("Token tidak ditemukan.");

    final response = await http.get(
      Uri.parse("http://192.168.1.101:8000/api/orders/completed/public"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['orders'];
    } else {
      throw Exception("Gagal mengambil data histori order.");
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(dateStr));
    } catch (e) {
      return '-';
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
      body: FutureBuilder<List<dynamic>>(
        future: _orderList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada histori order."));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const Icon(Icons.history, color: Colors.blue),
                  title: Text(
                    "NSM-SEWA-00${order['id']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text("Pemesan: ${order['nama_pemesan']}")],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailOrderPage(order: order),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailOrderPage extends StatelessWidget {
  final Map<String, dynamic> order;
  const DetailOrderPage({super.key, required this.order});

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

  String formatRupiah(int number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  @override
  Widget build(BuildContext context) {
    final List detailPembayarans = order["detail_pembayarans"] ?? [];
    final List detailOrders = order["detail_orders"] ?? [];
    final tagihan = order["tagihan"] ?? 0;

    final totalDibayar = detailPembayarans.fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item["jml_dibayar"].toString()) ?? 0),
    );
    final sisa = tagihan - totalDibayar;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("SEWA-00${order['id']}"),
        centerTitle: true,
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.grey[100],
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow("Pemesan", order["nama_pemesan"]),
                  _buildRow("Alamat Order", order["alamat"] ?? "-"),
                  const Divider(),
                  const Text(
                    "Detail Order",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (detailOrders.isEmpty)
                    const Text("Tidak ada detail order."),
                  ...detailOrders.map((detail) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildRow("Alat", detail["alat"] ?? "-"),
                        _buildRow("Operator", detail["operator"] ?? "-"),
                        _buildRow("Alamat", detail["alamat"] ?? "-"),
                        _buildRow(
                          "Tanggal Mulai",
                          formatDate(detail["tgl_mulai"]),
                        ),
                        _buildRow("Jam Mulai", formatJam(detail["jam_mulai"])),
                        _buildRow(
                          "Tanggal Selesai",
                          formatDate(detail["tgl_selesai"]),
                        ),
                        _buildRow(
                          "Jam Selesai",
                          formatJam(detail["jam_selesai"]),
                        ),
                        _buildRow(
                          "Harga Sewa",
                          formatRupiah(detail["harga_sewa"] ?? 0),
                        ),
                        _buildRow(
                          "Total Sewa",
                          detail["total_sewa"].toString(),
                        ),
                        const Divider(),
                      ],
                    );
                  }),
                  const SizedBox(height: 10),
                  _buildRow("Total Tagihan", formatRupiah(tagihan)),
                  _buildRow("Total Dibayar", formatRupiah(totalDibayar)),
                  _buildRow(
                    "Sisa Pembayaran",
                    formatRupiah(sisa),
                    color: sisa > 0 ? Colors.red : Colors.green,
                  ),
                  const SizedBox(height: 16),
                  if (detailPembayarans.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bukti Pembayaran",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...detailPembayarans.map((item) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Jumlah Dibayar: ${formatRupiah(item['jml_dibayar'])}",
                              ),
                              if (item['bukti_pembayaran'] != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['bukti_pembayaran'],
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Text(
                                                "Gagal memuat gambar.",
                                              ),
                                    ),
                                  ),
                                ),
                              const Divider(),
                            ],
                          );
                        }),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: TextStyle(color: color ?? Colors.black)),
          ),
        ],
      ),
    );
  }
}
