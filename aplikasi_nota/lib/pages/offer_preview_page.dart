import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/offer.dart';
import '../repositories/offer_repository.dart';
import '../services/offer_pdf_service.dart';

class OfferPreviewPage extends StatelessWidget {
  final Offer offer;

  const OfferPreviewPage({
    super.key,
    required this.offer,
  });

  // PDF error fallback
  Future<Uint8List> _generateErrorPdf(String message) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (_) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Gagal Memuat Penawaran',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                message,
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.red,
                ),
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
    if (offer.id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Preview Penawaran')),
        body: const Center(child: Text('ID penawaran tidak valid')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Penawaran'),
        centerTitle: true,
      ),
      body: PdfPreview(
        maxPageWidth: 800,
        build: (format) async {
          try {
            final repo = OfferRepository();
            final items = await repo.getItemsByOffer(offer.id!);

            final pdfBytes = await OfferPdfService.generate(offer, items);

            if (pdfBytes.isEmpty) {
              throw Exception('PDF penawaran kosong');
            }

            return pdfBytes;
          } catch (e) {
            debugPrint('Error preview penawaran: $e');
            return _generateErrorPdf(e.toString());
          }
        },
      ),
    );
  }
}
