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
    final List detailPembayarans = data["detail_pembayarans"] ?? [];
    final List detailOrders = data["detail_orders"] ?? [];
    final tagihan = data["tagihan"] ?? 0;

    final totalDibayar = detailPembayarans.fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item["jml_dibayar"].toString()) ?? 0),
    );
    final sisa = tagihan - totalDibayar;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("SEWA-00${data['id']}"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[50],
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
                  _buildRow("Pemesan", data["nama_pemesan"] ?? "-"),
                  _buildRow("Alamat Order", data["alamat"] ?? "-"),
                  const Divider(),
                  Center(
                    child: const Text(
                      "Detail Order",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
                          formatRupiah(detail["harga_sewa"]),
                        ),
                        _buildRow(
                          "Total Sewa",
                          formatRupiah(detail["total_sewa"]),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Jumlah Dibayar: ${formatRupiah(item['jml_dibayar'])}",
                              ),
                              const SizedBox(height: 6),
                              if (item['bukti_pembayaran'] != null &&
                                  item['bukti_pembayaran']
                                      .toString()
                                      .isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item['bukti_pembayaran'],
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Text("Gagal memuat gambar."),
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
