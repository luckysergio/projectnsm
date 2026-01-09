import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../services/invoice_pdf_service.dart';

class InvoicePdfPage extends StatelessWidget {
  final Invoice invoice;
  final List<InvoiceItem> items;

  const InvoicePdfPage({
    super.key,
    required this.invoice,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cetak Nota'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final pdfBytes = await InvoicePdfService.generate(invoice, items);

              await Printing.sharePdf(
                bytes: pdfBytes,
                filename: '${invoice.invoiceNumber}.pdf',
              );
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => InvoicePdfService.generate(invoice, items),
        allowPrinting: true,
        allowSharing: false, // ❗ dimatikan, pakai manual
        maxPageWidth: 700,
        initialPageFormat: PdfPageFormat.a4,
      ),
    );
  }
}
