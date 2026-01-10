import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../models/offer_item.dart';
import '../repositories/offer_repository.dart';
import '../models/offer.dart';
import '../utils/terbilang.dart';
import '../services/offer_pdf_service.dart';

class OfferFormPage extends StatefulWidget {
  const OfferFormPage({super.key});

  @override
  State<OfferFormPage> createState() => _OfferFormPageState();
}

class _OfferFormPageState extends State<OfferFormPage> {
  final _formKey = GlobalKey<FormState>();

  final customerNameCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();
  final projectCtrl = TextEditingController();
  final salesCtrl = TextEditingController();
  final salesPhoneCtrl = TextEditingController(); // ← TAMBAHKAN INI

  DateTime selectedDate = DateTime.now();

  final List<OfferItem> items = [];
  final List<TextEditingController> priceControllers = [];

  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);

  final List<String> satuanOptions = [
    'pcs',
    'm',
    'm²',
    'm³',
    'unit',
    'batang',
  ];

  @override
  void dispose() {
    customerNameCtrl.dispose();
    subjectCtrl.dispose();
    projectCtrl.dispose();
    salesCtrl.dispose();
    salesPhoneCtrl.dispose(); // ← tambahkan ini
    for (var ctrl in priceControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void addItem() {
    if (items.length >= 5) return; // ← BATASI MAKSIMAL 5 ITEM
    setState(() {
      final newItem = OfferItem(
        productName: '',
        quality: '',
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

  String formatRupiah(double value) {
    if (value == 0) return 'Rp 0';
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp ${formatter.format(value)}';
  }

  double parsePrice(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(clean) ?? 0;
  }

  void syncItemsFromControllers() {
    for (int i = 0; i < items.length; i++) {
      final rawText = priceControllers[i].text;
      final price = parsePrice(rawText);
      final qty = items[i].qty;
      items[i].price = price;
      items[i].subtotal = qty * price;
    }
  }

  Future<Offer> _buildOffer() async {
    syncItemsFromControllers();

    final repo = OfferRepository();
    final year = selectedDate.year.toString();
    final month = selectedDate.month.toString().padLeft(2, '0');
    final lastNumber = await repo.getLastOfferNumberOfMonth(year, month);
    final nextNumber = (lastNumber + 1).toString().padLeft(4, '0');
    final offerNumber = 'SPH/NSM/$year/$month/$nextNumber';
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Offer(
      offerNumber: offerNumber,
      offerDate: formattedDate,
      subject: subjectCtrl.text,
      customerName: customerNameCtrl.text,
      project: projectCtrl.text,
      sales: salesCtrl.text,
      salesPhone: salesPhoneCtrl.text,
      subtotal: total,
      total: total,
      notes: null,
    );
  }

  Future<void> saveOffer() async {
    if (!_formKey.currentState!.validate()) {
      _showMessage('Harap lengkapi semua field wajib');
      return;
    }
    if (items.isEmpty) {
      _showMessage('Item penawaran belum ditambahkan');
      return;
    }
    if (items.length > 5) {
      _showMessage('Maksimal hanya 5 item produk');
      return;
    }

    try {
      final offer = await _buildOffer();
      await OfferRepository().createOffer(offer, items);
      if (!mounted) return;
      _showMessage('Penawaran berhasil disimpan');
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Gagal menyimpan: ${e.toString()}');
    }
  }

  Future<void> previewPdf() async {
    if (items.isEmpty) {
      _showMessage('Item penawaran kosong');
      return;
    }
    if (items.length > 5) {
      _showMessage('Maksimal hanya 5 item produk');
      return;
    }

    try {
      final offer = await _buildOffer();
      await Printing.layoutPdf(
        onLayout: (_) => OfferPdfService.generate(offer, items),
      );
    } catch (e) {
      _showMessage('Gagal generate PDF: ${e.toString()}');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Penawaran'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[50],
      floatingActionButton: items.length < 5 // ← NONAKTIFKAN JIKA SUDAH 5
          ? FloatingActionButton(
              onPressed: addItem,
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            const SizedBox(height: 16),

            // Nama Pemesan
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextFormField(
                controller: customerNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Pemesan',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Wajib diisi' : null,
              ),
            ),

            // Subjek Penawaran
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextFormField(
                controller: subjectCtrl,
                decoration: InputDecoration(
                  labelText: 'Subjek Penawaran',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Wajib diisi' : null,
              ),
            ),

            // Lokasi Proyek
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextFormField(
                controller: projectCtrl,
                decoration: InputDecoration(
                  labelText: 'Lokasi Proyek',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Wajib diisi' : null,
              ),
            ),

            // Sales
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextFormField(
                controller: salesCtrl,
                decoration: InputDecoration(
                  labelText: 'Sales',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Wajib diisi' : null,
              ),
            ),

            // Sales Phone
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextFormField(
                controller: salesPhoneCtrl,
                decoration: InputDecoration(
                  labelText: 'No. HP Sales',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Wajib diisi' : null,
              ),
            ),

            // Tanggal Penawaran
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Tanggal Penawaran',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today,
                          color: Colors.blueAccent),
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Items
            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child:
                      Text('Belum ada item. Tekan tombol + untuk menambahkan.'),
                ),
              )
            else
              Column(
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final priceCtrl = priceControllers[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
                                  decoration: const InputDecoration(
                                    hintText: 'Nama item',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (v) => item.productName = v,
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => removeItem(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
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
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onChanged: (v) {
                                    final qty = int.tryParse(v) ?? 0;
                                    item.qty = qty;
                                    final price = parsePrice(priceCtrl.text);
                                    item.subtotal = qty * price;
                                    setState(() {});
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
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  items: satuanOptions
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text(e)))
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
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onChanged: (rawInput) {
                                    final price = parsePrice(rawInput);
                                    item.price = price;
                                    item.subtotal = item.qty * price;
                                    setState(() {});
                                  },
                                  onTapOutside: (_) {
                                    final raw = priceCtrl.text
                                        .replaceAll(RegExp(r'[^\d]'), '');
                                    if (raw.isNotEmpty) {
                                      final numValue = int.tryParse(raw) ?? 0;
                                      final formatted =
                                          NumberFormat('#,##0', 'id_ID')
                                              .format(numValue);
                                      priceCtrl.value = TextEditingValue(
                                        text: formatted,
                                        selection: TextSelection.collapsed(
                                            offset: formatted.length),
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

            // Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withAlpha(77)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(total),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    terbilang(total.toInt()),
                    style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Info batas item
            if (items.length >= 5)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Maksimal 5 item telah tercapai',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('SIMPAN PENAWARAN'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: saveOffer,
              ),
            ),

            const SizedBox(height: 12),

            // Tombol Preview PDF
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
                      borderRadius: BorderRadius.circular(12)),
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
