import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/invoice.dart';
import '../repositories/invoice_repository.dart';
import '../services/invoice_pdf_service.dart';

class InvoicePreviewPage extends StatelessWidget {
  final Invoice invoice;

  const InvoicePreviewPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final repo = InvoiceRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Preview Nota')),
      body: PdfPreview(
        build: (format) async {
          final items = await repo.getItemsByInvoice(invoice.id!);
          return InvoicePdfService.generate(invoice, items);
        },
      ),
    );
  }
}
