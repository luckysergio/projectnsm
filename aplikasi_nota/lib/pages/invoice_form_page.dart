import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../models/invoice_item.dart';
import '../repositories/invoice_repository.dart';
import '../models/invoice.dart';
import '../utils/terbilang.dart';
import '../services/invoice_pdf_service.dart';

class InvoiceFormPage extends StatefulWidget {
  const InvoiceFormPage({super.key});

  @override
  State<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  final _formKey = GlobalKey<FormState>();

  final customerNameCtrl = TextEditingController();
  final customerPhoneCtrl = TextEditingController();
  final customerAddressCtrl = TextEditingController();

  final List<InvoiceItem> items = [];
  final List<TextEditingController> priceControllers = [];

  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);

  final List<String> satuanOptions = ['pcs', 'm³', 'jam', 'liter', 'kg'];

  @override
  void dispose() {
    customerNameCtrl.dispose();
    customerPhoneCtrl.dispose();
    customerAddressCtrl.dispose();
    for (var ctrl in priceControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void addItem() {
    setState(() {
      final newItem = InvoiceItem(
        productName: '',
        qty: 0,
        unit: 'pcs',
        price: 0,
        subtotal: 0,
      );
      items.add(newItem);
      priceControllers.add(TextEditingController(text: ''));
    });
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
      priceControllers.removeAt(index);
    });
  }

  // Helper: format angka ke Rupiah (untuk tampilan)
  String formatRupiah(double value) {
    if (value == 0) return 'Rp 0';
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp ${formatter.format(value)}';
  }

  // Helper: ekstrak angka dari string input
  double parsePrice(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(clean) ?? 0;
  }

  // Simpan data terbaru dari controller ke item sebelum simpan/preview
  void syncItemsFromControllers() {
    for (int i = 0; i < items.length; i++) {
      final rawText = priceControllers[i].text;
      final price = parsePrice(rawText);
      final qty = items[i].qty;
      items[i].price = price;
      items[i].subtotal = qty * price;
    }
  }

  Invoice _buildInvoice() {
    syncItemsFromControllers();
    return Invoice(
      invoiceNumber: DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceDate: DateTime.now().toIso8601String().split('T').first,
      customerName: customerNameCtrl.text,
      customerPhone: customerPhoneCtrl.text,
      customerAddress: customerAddressCtrl.text,
      subtotal: total,
      total: total,
    );
  }

  Future<void> saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (items.isEmpty) {
      _showMessage('Item nota belum ditambahkan');
      return;
    }

    final invoice = _buildInvoice();
    await InvoiceRepository().createInvoice(invoice, items);

    if (!mounted) return;
    _showMessage('Nota berhasil disimpan');
    Navigator.pop(context);
  }

  Future<void> previewPdf() async {
    if (items.isEmpty) {
      _showMessage('Item nota kosong');
      return;
    }

    final invoice = _buildInvoice();
    await Printing.layoutPdf(
      onLayout: (_) => InvoicePdfService.generate(invoice, items),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Nota'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            const Text(
              'Pemesan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...[
              (customerNameCtrl, 'Nama Pemesan', TextInputType.text, true),
              (customerPhoneCtrl, 'No. Telepon', TextInputType.phone, false),
              (customerAddressCtrl, 'Alamat', TextInputType.text, false),
            ].map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: TextFormField(
                  controller: field.$1,
                  keyboardType: field.$3,
                  decoration: InputDecoration(
                    labelText: field.$2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator:
                      field.$4
                          ? (v) =>
                              v?.trim().isEmpty == true ? 'Wajib diisi' : null
                          : null,
                ),
              );
            }),

            const SizedBox(height: 24),
            const Text(
              'Item Nota',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Text(
                    'Belum ada item. Tekan tombol + untuk menambahkan.',
                  ),
                ),
              )
            else
              Column(
                children:
                    items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final priceCtrl = priceControllers[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: item.productName,
                                      decoration: InputDecoration(
                                        hintText: 'Nama item',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (v) {
                                        item.productName = v;
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => removeItem(index),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      initialValue: item.qty.toString(),
                                      decoration: InputDecoration(
                                        labelText: 'Qty',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (v) {
                                        final qty = int.tryParse(v) ?? 0;
                                        item.qty = qty;
                                        // Hitung ulang subtotal real-time
                                        final price = parsePrice(
                                          priceCtrl.text,
                                        );
                                        item.subtotal = qty * price;
                                        setState(
                                          () {},
                                        ); // Trigger rebuild untuk subtotal & total
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 2,
                                    child: DropdownButtonFormField<String>(
                                      value: item.unit,
                                      decoration: InputDecoration(
                                        labelText: 'Satuan',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      items:
                                          satuanOptions
                                              .map(
                                                (e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(e),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          item.unit = v;
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: priceCtrl,
                                      decoration: InputDecoration(
                                        labelText: 'Harga',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (rawInput) {
                                        // Update harga internal (tanpa format)
                                        final price = parsePrice(rawInput);
                                        item.price = price;
                                        // Hitung ulang subtotal
                                        item.subtotal = item.qty * price;
                                        // Trigger UI update
                                        setState(() {});
                                      },
                                      onTapOutside: (_) {
                                        // Format saat keluar fokus
                                        final raw = priceCtrl.text.replaceAll(
                                          RegExp(r'[^\d]'),
                                          '',
                                        );
                                        if (raw.isNotEmpty) {
                                          final numValue =
                                              int.tryParse(raw) ?? 0;
                                          final formatted = NumberFormat(
                                            '#,##0',
                                            'id_ID',
                                          ).format(numValue);
                                          priceCtrl.value = TextEditingValue(
                                            text: formatted,
                                            selection: TextSelection.collapsed(
                                              offset: formatted.length,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  formatRupiah(item.subtotal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(total),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    terbilang(total.toInt()),
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('SIMPAN NOTA'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: saveInvoice,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PREVIEW PDF'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: Colors.blueAccent,
                  side: const BorderSide(color: Colors.blueAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: previewPdf,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
