import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isOrder;

  const DetailPage({super.key, required this.data, required this.isOrder});

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

  String formatRupiah(dynamic number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(int.tryParse(number.toString()) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          isOrder ? "SEWA-00${data['id']}" : "PERAWATAN-00${data['id']}",
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: isOrder ? _buildOrderDetail() : _buildPerawatanDetail(),
    );
  }

  Widget _buildOrderDetail() {
    final List detailPembayarans = data["detail_pembayarans"] ?? [];
    final List detailOrders = data["detail_orders"] ?? [];
    final tagihan = data["tagihan"] ?? 0;

    final totalDibayar = detailPembayarans.fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item["jml_dibayar"].toString()) ?? 0),
    );
    final sisa = tagihan - totalDibayar;

    return ListView(
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
                _buildSectionHeader(
                  "Informasi Order",
                  Icons.shopping_cart,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildRow("Pemesan", data["nama_pemesan"] ?? "-"),
                _buildRow("Sales", data["nama_sales"] ?? "-"),
                const Divider(height: 32),
                _buildSectionHeader(
                  "Detail Order",
                  Icons.list_alt,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                if (detailOrders.isEmpty)
                  const Text("Tidak ada detail order.")
                else
                  ...detailOrders.asMap().entries.map((entry) {
                    final index = entry.key;
                    final detail = entry.value;
                    return _buildOrderDetailCard(detail, index + 1);
                  }),
                const Divider(height: 32),
                _buildSectionHeader(
                  "Ringkasan Pembayaran",
                  Icons.payment,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildRow("Total Tagihan", formatRupiah(tagihan), isBold: true),
                _buildRow("Total Dibayar", formatRupiah(totalDibayar)),
                _buildRow(
                  "Sisa Pembayaran",
                  formatRupiah(sisa),
                  color: sisa > 0 ? Colors.red : Colors.green,
                  isBold: true,
                ),
                if (detailPembayarans.isNotEmpty) ...[
                  const Divider(height: 32),
                  _buildSectionHeader(
                    "Bukti Pembayaran",
                    Icons.receipt,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  ...detailPembayarans.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _buildPaymentProofCard(item, index + 1);
                  }),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerawatanDetail() {
    final List detailPerawatans = data["detail_perawatans"] ?? [];

    return ListView(
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
                _buildSectionHeader(
                  "Informasi Perawatan",
                  Icons.build,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildRow("Operator", data["operator"]?["nama"] ?? "-"),
                _buildRow("ID Perawatan", "PERAWATAN-00${data['id']}"),
                _buildRow("Tanggal Dibuat", formatDate(data["created_at"])),
                const Divider(height: 32),
                _buildSectionHeader(
                  "Detail Perawatan",
                  Icons.engineering,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                if (detailPerawatans.isEmpty)
                  const Text("Tidak ada detail perawatan.")
                else
                  ...detailPerawatans.asMap().entries.map((entry) {
                    final index = entry.key;
                    final detail = entry.value;
                    return _buildPerawatanDetailCard(detail, index + 1);
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetailCard(Map<String, dynamic> detail, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detail Order #$index",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            _buildRow("Status", detail["status"] ?? "-"),
            _buildRow("Alat", detail["alat"] ?? "-"),
            _buildRow("Operator", detail["operator"] ?? "-"),
            _buildRow("Alamat", detail["alamat"] ?? "-"),
            _buildRow("Tanggal Mulai", formatDate(detail["tgl_mulai"])),
            _buildRow("Jam Mulai", formatJam(detail["jam_mulai"])),
            _buildRow("Tanggal Selesai", formatDate(detail["tgl_selesai"])),
            _buildRow("Jam Selesai", formatJam(detail["jam_selesai"])),
            _buildRow("Harga Sewa", formatRupiah(detail["harga_sewa"])),
            _buildRow(
              "Total Sewa",
              "${detail["total_sewa"] ?? '-'} jam",
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerawatanDetailCard(Map<String, dynamic> detail, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detail Perawatan #$index",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            _buildRow("Nama Alat", detail["alat"]?["nama"] ?? "-"),
            _buildRow("Tanggal Mulai", formatDate(detail["tgl_mulai"])),
            _buildRow("Tanggal Selesai", formatDate(detail["tgl_selesai"])),
            _buildRow("Status", detail["status"] ?? "-"),
            _buildRow("Catatan", detail["catatan"] ?? "Tidak ada catatan"),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentProofCard(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pembayaran #$index",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Jumlah Dibayar: ${formatRupiah(item['jml_dibayar'])}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (item['bukti_pembayaran'] != null &&
                item['bukti_pembayaran'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item['bukti_pembayaran'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Gagal memuat gambar",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                ),
              )
            else
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    "Tidak ada bukti pembayaran",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String title,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const Text(": ", style: TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: color ?? Colors.black,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
