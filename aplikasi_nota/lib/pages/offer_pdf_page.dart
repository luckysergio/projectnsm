import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../models/offer.dart';
import '../models/offer_item.dart';
import '../services/offer_pdf_service.dart';

class OfferPdfPage extends StatefulWidget {
  final Offer offer;
  final List<OfferItem> items;

  const OfferPdfPage({
    super.key,
    required this.offer,
    required this.items,
  });

  @override
  State<OfferPdfPage> createState() => _OfferPdfPageState();
}

class _OfferPdfPageState extends State<OfferPdfPage> {
  late Future<Uint8List> _pdfFuture;

  @override
  void initState() {
    super.initState();
    _pdfFuture = OfferPdfService.generate(widget.offer, widget.items);
  }

  Future<void> _sharePdf() async {
    final bytes = await _pdfFuture;
    final safeName = widget.offer.offerNumber.replaceAll('/', '_');
    await Printing.sharePdf(
      bytes: bytes,
      filename: '$safeName.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cetak Penawaran'),
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
        allowSharing: false, // matikan bawaan
        maxPageWidth: 700,
        initialPageFormat: PdfPageFormat.a4,
      ),
    );
  }
}
