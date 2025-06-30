import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JadwalPengirimanPage extends StatefulWidget {
  const JadwalPengirimanPage({super.key});

  @override
  State<JadwalPengirimanPage> createState() => _JadwalPengirimanPageState();
}

class _JadwalPengirimanPageState extends State<JadwalPengirimanPage> {
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
      Uri.parse("http://192.168.1.101:8000/api/orders/active/public"),
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
        title: const Text("Jadwal Pengiriman Alat"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.transparent,
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
                      Icons.local_shipping,
                      color: Colors.blue,
                      size: 40,
                    ),
                    title: Text(
                      "SEWA-00${order['id']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Pemesan: ${order["customer"]?["nama"] ?? "Tidak diketahui"}",
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.blue,
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DetailPengirimanPage(order: order),
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

class DetailPengirimanPage extends StatefulWidget {
  final Map<String, dynamic> order;
  const DetailPengirimanPage({super.key, required this.order});

  @override
  State<DetailPengirimanPage> createState() => _DetailPengirimanPageState();
}

class _DetailPengirimanPageState extends State<DetailPengirimanPage> {
  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    } catch (_) {
      return "-";
    }
  }

  String formatJam(String? time) {
    if (time == null || time.isEmpty) return "-";
    try {
      return "${DateFormat('HH.mm').format(DateTime.parse("1970-01-01T$time"))} WIB";
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

  Future<List<Map<String, dynamic>>> _fetchOperators() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("Token tidak ditemukan.");

      final response = await http.get(
        Uri.parse("http://192.168.1.101:8000/api/karyawan/operator-alat"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data["operators"]);
      } else {
        throw Exception("Gagal mengambil data operator");
      }
    } catch (e) {
      throw Exception("Error fetching operators: $e");
    }
  }

  Future<void> prosesDetailOrder(
    BuildContext context,
    Map<String, dynamic> detailOrder,
  ) async {
    try {
      final operators = await _fetchOperators();

      if (!context.mounted) return;

      if (operators.isEmpty) {
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Peringatan"),
                content: const Text("Tidak ada operator yang tersedia"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
        return;
      }

      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder:
            (context) => ProcessDetailOrderDialog(
              operators: operators,
              detailOrder: detailOrder,
              order: widget.order,
            ),
      );

      if (!context.mounted) return;

      if (result == null) return;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("Token tidak ditemukan.");

      final response = await http.put(
        Uri.parse(
          "http://192.168.1.101:8000/api/detail-order/${detailOrder['id']}",
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': result['status'],
          'catatan': result['catatan'],
          'id_operator': result['id_operator'],
        }),
      );

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Sukses"),
                content: const Text("Detail order berhasil diproses."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Error"),
                content: Text(
                  errorData['error'] ?? "Gagal memproses detail order",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Error"),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'proses':
        return Colors.blue;
      case 'persiapan':
        return Colors.purple;
      case 'dikirim':
        return Colors.green;
      case 'selesai':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List detailOrders = widget.order["detail_orders"] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text("SEWA-00${widget.order['id']}"),
        centerTitle: true,
        elevation: 0,
        shadowColor: Colors.transparent,
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
                  Center(
                    child: Text(
                      "${widget.order["customer"]?["nama"] ?? "-"} - ${widget.order["customer"]?["instansi"] ?? "-"}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  for (int i = 0; i < detailOrders.length; i++) ...[
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Pompa ${detailOrders[i]["alat"]?["nama"] ?? "-"}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      detailOrders[i]["status"],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    detailOrders[i]["status"]?.toUpperCase() ??
                                        "-",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildRow(
                              "Alamat",
                              detailOrders[i]["alamat"] ?? "-",
                            ),
                            _buildRow(
                              "Tanggal",
                              formatDate(detailOrders[i]["tgl_mulai"]),
                            ),
                            _buildRow(
                              "Mulai",
                              formatJam(detailOrders[i]["jam_mulai"]),
                            ),
                            _buildRow(
                              "Selesai",
                              formatJam(detailOrders[i]["jam_selesai"]),
                            ),
                            _buildRow(
                              "Total jam sewa",
                              detailOrders[i]["total_sewa"]?.toString() ?? "-",
                            ),
                            _buildRow(
                              "Harga",
                              formatRupiah(detailOrders[i]["harga_sewa"]),
                            ),
                            if (detailOrders[i]["operator"] != null)
                              _buildRow(
                                "Operator",
                                detailOrders[i]["operator"]["nama"] ?? "-",
                              ),
                            if (detailOrders[i]["catatan"] != null &&
                                detailOrders[i]["catatan"]
                                    .toString()
                                    .isNotEmpty)
                              _buildRow(
                                "Catatan",
                                detailOrders[i]["catatan"] ?? "-",
                              ),
                            const SizedBox(height: 12),
                            Center(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text("Proses Detail"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed:
                                    () => prosesDetailOrder(
                                      context,
                                      detailOrders[i],
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
          const Text(": "),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}

class ProcessDetailOrderDialog extends StatefulWidget {
  final List<Map<String, dynamic>> operators;
  final Map<String, dynamic> detailOrder;
  final Map<String, dynamic> order;

  const ProcessDetailOrderDialog({
    super.key,
    required this.operators,
    required this.detailOrder,
    required this.order,
  });

  @override
  State<ProcessDetailOrderDialog> createState() =>
      _ProcessDetailOrderDialogState();
}

class _ProcessDetailOrderDialogState extends State<ProcessDetailOrderDialog> {
  String _selectedStatus = 'proses';
  String? _selectedOperator;
  final TextEditingController _catatanController = TextEditingController();

  final List<Map<String, String>> _statusOptions = [
    {'value': 'pending', 'label': 'Pending'},
    {'value': 'proses', 'label': 'Proses'},
    {'value': 'persiapan', 'label': 'Persiapan'},
    {'value': 'dikirim', 'label': 'Dikirim'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.detailOrder['status'] ?? 'proses';
    _selectedOperator = widget.detailOrder['id_operator']?.toString();
    _catatanController.text = widget.detailOrder['catatan'] ?? '';
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Proses ${widget.detailOrder['alat']?['nama'] ?? 'Detail Order'}",
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order: SEWA-00${widget.order['id']}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Status:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items:
                  _statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status['value'],
                      child: Text(status['label']!),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            const Text(
              "Pilih Operator:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedOperator,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                hintText: "Pilih operator...",
              ),
              items:
                  widget.operators.map((operator) {
                    return DropdownMenuItem<String>(
                      value: operator['id'].toString(),
                      child: Text(operator['nama'] ?? 'Unknown'),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedOperator = value;
                });
              },
            ),
            const SizedBox(height: 16),

            const Text(
              "Catatan:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _catatanController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Masukkan catatan...",
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_selectedOperator == null) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Silakan pilih operator")),
              );
              return;
            }

            Navigator.pop(context, {
              'status': _selectedStatus,
              'id_operator': int.parse(_selectedOperator!),
              'catatan': _catatanController.text.trim(),
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text("Proses"),
        ),
      ],
    );
  }
}
