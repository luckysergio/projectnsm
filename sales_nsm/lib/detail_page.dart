import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isOrder;

  const DetailPage({super.key, required this.data, required this.isOrder});

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Detail Order"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            ..._buildDetailContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.shopping_cart, size: 60, color: Colors.blue),
          const SizedBox(height: 10),
          Text(
            data["inventori_name"] ?? "-",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            "Status: ${data['status_order']}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  data["status_order"] == "Selesai"
                      ? Colors.green
                      : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDetailContent() {
    return [
      _buildDetailRow("ID Order", data["id"].toString()),
      _buildDetailRow("Nama Pemesan", data["nama_pemesan"]),
      _buildDetailRow("Jenis Alat", data["inventori_name"] ?? "-"),
      _buildDetailRow("Order Sewa", "${data["total_sewa"]} Jam"),
      _buildDetailRow("Pengiriman", formatDate(data["tgl_pengiriman"])),
      _buildDetailRow("Pengembalian", formatDate(data["tgl_pengembalian"])),
      _buildDetailRow("Operator", data["Operator_name"] ?? "-"),
      _buildDetailRow(
        "Status Pembayaran",
        data["status_pembayaran"],
        color:
            data["status_pembayaran"] == "lunas" ? Colors.green : Colors.orange,
      ),
      _buildDetailRow(
        "Status Order",
        data["status_order"],
        color: data["status_order"] == "Selesai" ? Colors.green : Colors.orange,
      ),
      _buildDetailRow("Jam Mulai", formatJam(data["jam_mulai"])),
      _buildDetailRow("Jam Selesai", formatJam(data["jam_selesai"])),
      _buildDetailRow(
        "Jumlah Sewa",
        (data["harga_sewa"] != null)
            ? formatRupiah(parseDouble(data["harga_sewa"].toString()) ?? 0)
            : "-",
      ),
      _buildDetailRow(
        "Overtime",
        (data["overtime"] != null)
            ? "${formatOvertime(parseDouble(data["overtime"].toString()) ?? 0)} Jam"
            : "-",
      ),
      _buildDetailRow(
        "Denda",
        (data["denda"] != null)
            ? formatRupiah(parseDouble(data["denda"].toString()) ?? 0)
            : "-",
      ),
      _buildDetailRow(
        "Total Harga",
        (data["total_harga"] != null)
            ? formatRupiah(parseDouble(data["total_harga"].toString()) ?? 0)
            : "-",
      ),
    ];
  }

  Widget _buildDetailRow(String label, dynamic value, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
