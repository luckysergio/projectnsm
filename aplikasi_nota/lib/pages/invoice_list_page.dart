import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../repositories/invoice_repository.dart';
import 'invoice_pdf_page.dart'; // pastikan InvoicePdfPage menerima invoice & items

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  List<Invoice> invoices = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    setState(() => loading = true);
    final repo = InvoiceRepository();
    invoices = await repo.getInvoices(); // ambil data dari database
    setState(() => loading = false);
  }

  // Format tanggal: "01 Januari 2026"
  String formatTanggal(String isoDate) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    try {
      final date = DateTime.parse(isoDate);
      final day = date.day.toString().padLeft(2, '0');
      final month = months[date.month - 1];
      final year = date.year;
      return '$day $month $year';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Nota'), centerTitle: true),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : invoices.isEmpty
              ? const Center(child: Text('Belum ada nota'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: invoices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final invoice = invoices[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        invoice.customerName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'No Nota: ${invoice.invoiceNumber}\nTanggal: ${formatTanggal(invoice.invoiceDate)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.print, color: Colors.blue),
                        onPressed: () async {
                          if (invoice.id == null) return;

                          // Ambil items untuk invoice ini
                          final repo = InvoiceRepository();
                          final items = await repo.getItemsByInvoice(
                            invoice.id!,
                          );
                          if (!context.mounted) return;

                          // Pindah ke halaman PDF dengan invoice + items
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => InvoicePdfPage(
                                    invoice: invoice,
                                    items: items,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
