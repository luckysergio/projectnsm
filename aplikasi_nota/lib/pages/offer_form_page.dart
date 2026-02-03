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
  final salesPhoneCtrl = TextEditingController();

  DateTime selectedDate = DateTime.now();

  final List<OfferItem> items = [];
  final List<TextEditingController> qtyControllers = [];
  final List<TextEditingController> priceControllers = [];

  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);

  final List<String> satuanOptions = [
    'pcs',
    'jam',
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
    salesPhoneCtrl.dispose();
    for (var ctrl in qtyControllers) {
      ctrl.dispose();
    }
    for (var ctrl in priceControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void addItem() {
    if (items.length >= 5) return;
    setState(() {
      final newItem = OfferItem(
        productName: '',
        qty: 0.0,
        unit: 'pcs',
        price: 0.0,
        subtotal: 0.0,
      );
      items.add(newItem);
      qtyControllers.add(TextEditingController(text: ''));
      priceControllers.add(TextEditingController(text: ''));
    });
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
      qtyControllers.removeAt(index);
      priceControllers.removeAt(index);
    });
  }

  String formatRupiah(double value) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp ${formatter.format(value)}';
  }

  // Parsing qty dengan support desimal
  double parseQty(String raw) {
    if (raw.isEmpty) return 0.0;

    // Ganti koma dengan titik untuk parsing
    String clean = raw.replaceAll(RegExp(r'[^\d,.]'), '');
    clean = clean.replaceAll(',', '.');

    // Hapus titik ganda
    final parts = clean.split('.');
    if (parts.length > 2) {
      clean = '${parts[0]}.${parts.sublist(1).join()}';
    }

    return double.tryParse(clean) ?? 0.0;
  }

  // Parsing harga dari input yang diformat
  double parsePrice(String raw) {
    if (raw.isEmpty) return 0.0;

    // Hapus semua karakter non-digit
    String clean = raw.replaceAll(RegExp(r'[^\d]'), '');

    // Parse sebagai integer (rupiah biasanya tanpa desimal)
    return double.tryParse(clean) ?? 0.0;
  }

  // Format harga untuk display dengan thousand separator
  String formatPrice(double value) {
    if (value == 0) return '';

    // Format dengan thousand separator tanpa desimal
    return NumberFormat('#,##0', 'id_ID').format(value.toInt());
  }

  // Format qty untuk display - tanpa trailing zeros untuk integer
  String formatQty(double value) {
    if (value == 0) return '';

    // Jika qty adalah integer (tanpa desimal)
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    // Jika ada desimal, format dengan maksimal 3 desimal
    final formatter = NumberFormat('#,##0.###', 'id_ID');

    // Hilangkan trailing zeros
    String formatted = formatter.format(value);

    // Jika ada desimal, hilangkan trailing zeros
    if (formatted.contains(',')) {
      final parts = formatted.split(',');
      if (parts.length == 2) {
        final decimal = parts[1].replaceAll(RegExp(r'0+$'), '');
        if (decimal.isEmpty) {
          return parts[0]; // Hanya bagian integer
        }
        return '${parts[0]},$decimal'; // Desimal tanpa trailing zeros
      }
    }
    return formatted;
  }

  void updateItem(int index) {
    final qty = parseQty(qtyControllers[index].text);
    final price = parsePrice(priceControllers[index].text);

    setState(() {
      items[index] = items[index].copyWith(
        qty: qty,
        price: price,
      );

      // Update controllers untuk formatting
      qtyControllers[index].text = formatQty(qty);
      priceControllers[index].text = formatPrice(price);

      // Update cursor position ke akhir text
      qtyControllers[index].selection = TextSelection.fromPosition(
          TextPosition(offset: qtyControllers[index].text.length));
      priceControllers[index].selection = TextSelection.fromPosition(
          TextPosition(offset: priceControllers[index].text.length));
    });
  }

  void onQtyChanged(int index, String value) {
    // Update nilai sementara
    final qty = parseQty(value);
    setState(() {
      items[index] = items[index].copyWith(qty: qty);
    });
  }

  void onPriceChanged(int index, String value) {
    // Update nilai sementara
    final price = parsePrice(value);
    setState(() {
      items[index] = items[index].copyWith(price: price);
    });
  }

  Future<Offer> _buildOffer() async {
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

    // Validasi item
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.productName.trim().isEmpty) {
        _showMessage('Nama item pada baris ${i + 1} belum diisi');
        return;
      }
      if (item.qty <= 0) {
        _showMessage('Qty pada baris ${i + 1} harus lebih dari 0');
        return;
      }
      if (item.price <= 0) {
        _showMessage('Harga pada baris ${i + 1} harus lebih dari 0');
        return;
      }
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

    // Validasi sebelum preview
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.productName.trim().isEmpty || item.qty <= 0 || item.price <= 0) {
        _showMessage('Lengkapi semua item terlebih dahulu');
        return;
      }
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
      floatingActionButton: items.length < 5
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
                  final qtyCtrl = qtyControllers[index];
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
                                  onChanged: (v) {
                                    setState(() {
                                      items[index] = items[index].copyWith(
                                        productName: v,
                                      );
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
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
                                  controller: qtyCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Qty',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: false,
                                  ),
                                  inputFormatters: [
                                    // Izinkan angka, koma, dan titik
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9,.]'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    onQtyChanged(index, value);
                                  },
                                  onEditingComplete: () {
                                    updateItem(index);
                                  },
                                  onTapOutside: (_) {
                                    updateItem(index);
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
                                      setState(() {
                                        items[index] = items[index].copyWith(
                                          unit: v,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
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
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    onPriceChanged(index, value);
                                  },
                                  onEditingComplete: () {
                                    updateItem(index);
                                  },
                                  onTapOutside: (_) {
                                    updateItem(index);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal:',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                formatRupiah(item.subtotal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
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
