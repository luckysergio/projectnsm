import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sales_nsm/pembayaran_page.dart';
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
      Uri.parse("http://192.168.1.104:8000/api/orders/active"),
      headers: {"Authorization": "Bearer $_token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data["orders"]);
    } else {
      throw Exception("Gagal mengambil data order.");
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
                final customerName =
                    order["customer"]?["nama"]?.toString() ?? "Tidak diketahui";
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
                      "SEWA-00${order['id']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Pemesan: $customerName"),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.blue,
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailOrderPage(order: order),
                        ),
                      );
                      if (result == true) {
                        setState(() {
                          _ordersFuture = _fetchOrders();
                        });
                      }
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

class DetailOrderPage extends StatefulWidget {
  final Map<String, dynamic> order;
  const DetailOrderPage({super.key, required this.order});

  @override
  State<DetailOrderPage> createState() => _DetailOrderPageState();
}

class _DetailOrderPageState extends State<DetailOrderPage> {
  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (_) {
      return "-";
    }
  }

  String formatJam(String? time) {
    if (time == null || time.isEmpty) return "-";
    try {
      DateTime parsedTime = DateTime.parse("1970-01-01T$time");
      return "${DateFormat('HH.mm').format(parsedTime)} WIB";
    } catch (_) {
      return "-";
    }
  }

  String formatRupiah(dynamic number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    try {
      return formatCurrency.format(int.parse(number.toString()));
    } catch (_) {
      return "Rp 0";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List detailOrders = widget.order["detail_orders"] ?? [];
    final pembayaran = widget.order["pembayaran"];
    final tagihan = pembayaran != null ? (pembayaran["tagihan"] ?? 0) : 0;
    final detailPembayarans = pembayaran?["detail_pembayarans"] ?? [];

    final totalDibayar = (detailPembayarans as List).fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item["jml_dibayar"].toString()) ?? 0),
    );
    final sisa = tagihan - totalDibayar;

    return Scaffold(
      appBar: AppBar(
        title: Text("SEWA-00${widget.order['id']}"),
        centerTitle: true,
        elevation: 0,
        shadowColor: Colors.transparent,
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
                  _buildRow(
                    "Pemesan",
                    widget.order["customer"]?["nama"] ?? "-",
                  ),
                  const Divider(),
                  for (var d in detailOrders) ...[
                    Center(
                      child: Text(
                        "Pompa ${d["alat"]?["nama"] ?? "-"}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildRow("Alamat", d["alamat"] ?? "-"),
                    _buildRow("Tanggal", formatDate(d["tgl_mulai"])),
                    _buildRow("Mulai", formatJam(d["jam_mulai"])),
                    _buildRow("Selesai", formatJam(d["jam_selesai"])),
                    _buildRow("Status", d["status"] ?? "-"),
                    _buildRow(
                      "Total jam sewa",
                      d["total_sewa"]?.toString() ?? "-",
                    ),
                    _buildRow("Harga", formatRupiah(d["harga_sewa"])),
                    const Divider(),
                  ],
                  _buildRow("Total Tagihan", formatRupiah(tagihan)),
                  _buildRow("Total Dibayar", formatRupiah(totalDibayar)),
                  _buildRow(
                    "Sisa Pembayaran",
                    formatRupiah(sisa),
                    color: sisa > 0 ? Colors.red : Colors.green,
                  ),
                  const SizedBox(height: 20),
                  if (sisa > 0)
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.payment),
                        label: const Text("Lakukan Pembayaran"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      PembayaranPage(order: widget.order),
                            ),
                          );

                          if (result == true) {
                            navigator.pop(true);
                          }
                        },
                      ),
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
