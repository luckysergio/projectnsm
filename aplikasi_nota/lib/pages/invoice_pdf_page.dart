import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../services/invoice_pdf_service.dart';

class InvoicePdfPage extends StatefulWidget {
  final Invoice invoice;
  final List<InvoiceItem> items;

  const InvoicePdfPage({
    super.key,
    required this.invoice,
    required this.items,
  });

  @override
  State<InvoicePdfPage> createState() => _InvoicePdfPageState();
}

class _InvoicePdfPageState extends State<InvoicePdfPage> {
  late Future<Uint8List> _pdfFuture;

  @override
  void initState() {
    super.initState();
    _pdfFuture = InvoicePdfService.generate(
      widget.invoice,
      widget.items,
    );
  }

  Future<void> _sharePdf() async {
    final bytes = await _pdfFuture;

    final safeName = widget.invoice.invoiceNumber.replaceAll('/', '_');

    await Printing.sharePdf(
      bytes: bytes,
      filename: '$safeName.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cetak Nota'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Bagikan PDF',
            onPressed: _sharePdf,
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _pdfFuture,
        allowPrinting: true,
        allowSharing: false, // ⬅️ MATIKAN BAWAAN
        maxPageWidth: 700,
        initialPageFormat: PdfPageFormat.a4,
      ),
    );
  }
}
