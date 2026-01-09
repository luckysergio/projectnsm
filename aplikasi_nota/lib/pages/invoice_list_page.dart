import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../repositories/invoice_repository.dart';
import 'invoice_pdf_page.dart';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  List<Invoice> invoices = [];
  List<Invoice> filteredInvoices = [];
  bool loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadInvoices();
    _searchController.addListener(_filterInvoices);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterInvoices);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadInvoices() async {
    setState(() => loading = true);
    final repo = InvoiceRepository();
    invoices = await repo.getInvoices();
    filteredInvoices = List.from(invoices);
    setState(() => loading = false);
  }

  void _filterInvoices() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        filteredInvoices = List.from(invoices);
      });
      return;
    }

    final filtered =
        invoices.where((invoice) {
          final matchesName = invoice.customerName.toLowerCase().contains(
            query,
          );
          final matchesNumber = invoice.invoiceNumber.toLowerCase().contains(
            query,
          );
          return matchesName || matchesNumber;
        }).toList();

    setState(() {
      filteredInvoices = filtered;
    });
  }

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
      appBar: AppBar(
        title: const Text('Daftar Nota'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // ================= SEARCH BAR (TIDAK SCROLL) =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama atau no nota...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          Expanded(
            child:
                loading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredInvoices.isEmpty
                    ? const Center(child: Text('Tidak ada nota ditemukan'))
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredInvoices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final invoice = filteredInvoices[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              foregroundColor: Colors.blue,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              invoice.customerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (invoice.customerPhone?.isNotEmpty == true)
                                  Text('📞 ${invoice.customerPhone}'),
                                Text('No Nota: ${invoice.invoiceNumber}'),
                                Text(
                                  'Tanggal: ${formatTanggal(invoice.invoiceDate)}',
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.print, color: Colors.blue),
                              onPressed: () async {
                                if (invoice.id == null) return;

                                final repo = InvoiceRepository();
                                final items = await repo.getItemsByInvoice(
                                  invoice.id!,
                                );
                                if (!context.mounted) return;

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
          ),
        ],
      ),
    );
  }
}
