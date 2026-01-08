import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart'; // <- harus ditambahkan
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../services/invoice_pdf_service.dart';

class InvoicePdfPage extends StatefulWidget {
  final Invoice invoice;
  final List<InvoiceItem> items;

  const InvoicePdfPage({super.key, required this.invoice, required this.items});

  @override
  State<InvoicePdfPage> createState() => _InvoicePdfPageState();
}

class _InvoicePdfPageState extends State<InvoicePdfPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cetak Nota'), centerTitle: true),
      body: PdfPreview(
        build:
            (format) =>
                InvoicePdfService.generate(widget.invoice, widget.items),
        allowPrinting: true,
        allowSharing: true,
        maxPageWidth: 700,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: '${widget.invoice.invoiceNumber}.pdf',
      ),
    );
  }
}
