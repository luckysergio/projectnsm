import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/invoice.dart';
import '../repositories/invoice_repository.dart';
import '../services/invoice_pdf_service.dart';

class InvoicePreviewPage extends StatelessWidget {
  final Invoice invoice;

  const InvoicePreviewPage({super.key, required this.invoice});

  // Fungsi bantu: buat PDF error sederhana
  Future<Uint8List> _generateErrorPdf(String message) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'Gagal Memuat Nota',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    message,
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.red),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
      ),
    );
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    if (invoice.id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Preview Nota')),
        body: const Center(child: Text('ID nota tidak valid.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Preview Nota')),
      body: PdfPreview(
        maxPageWidth: 800,
        build: (pageFormat) async {
          try {
            final repo = InvoiceRepository();
            final items = await repo.getItemsByInvoice(invoice.id!);
            final pdfBytes = await InvoicePdfService.generate(invoice, items);

            if (pdfBytes.isEmpty) {
              throw Exception('Hasil PDF kosong');
            }

            return pdfBytes;
          } catch (e) {
            debugPrint('Error di PDF preview: $e');
            return _generateErrorPdf(e.toString());
          }
        },
      ),
    );
  }
}
