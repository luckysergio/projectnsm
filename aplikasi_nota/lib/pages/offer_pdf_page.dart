import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../models/offer.dart';
import '../models/offer_item.dart';
import '../services/offer_pdf_service.dart';

class OfferPdfPage extends StatelessWidget {
  final Offer offer;
  final List<OfferItem> items;

  const OfferPdfPage({
    super.key,
    required this.offer,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cetak Penawaran'),
        centerTitle: true,
      ),
      body: PdfPreview(
        build: (format) => OfferPdfService.generate(offer, items),
        allowPrinting: true,
        allowSharing: true, // share via tombol AppBar
        maxPageWidth: 700,
        initialPageFormat: PdfPageFormat.a4,
      ),
    );
  }
}
