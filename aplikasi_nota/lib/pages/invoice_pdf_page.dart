import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
    try {
      final pdfBytes = await _pdfFuture;

      final safeName = widget.invoice.invoiceNumber.replaceAll('/', '_');
      final fileName = '$safeName.pdf';

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      final xFile = XFile(
        file.path,
        mimeType: 'application/pdf',
        name: fileName,
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          subject: 'Nota ${widget.invoice.invoiceNumber}',
          text: 'Terlampir nota ${widget.invoice.invoiceNumber}',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal berbagi PDF: $e')),
      );
    }
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
            onPressed: _sharePdf,
            tooltip: 'Bagikan PDF',
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _pdfFuture,
        allowPrinting: true,
        allowSharing: false,
        maxPageWidth: 700,
        initialPageFormat: PdfPageFormat.a4,
      ),
    );
  }
}
