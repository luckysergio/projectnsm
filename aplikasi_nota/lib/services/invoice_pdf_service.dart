import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../utils/terbilang.dart';

class InvoicePdfService {
  static Future<Uint8List> generate(
    Invoice invoice,
    List<InvoiceItem> items,
  ) async {
    final pdf = pw.Document();

    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.jpeg')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ================= KOP =================
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(logo, width: 80),
                  pw.SizedBox(width: 16),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PT NIAGA SOLUSI MANDIRI',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Jl. Contoh Alamat No. 123, Jakarta'),
                      pw.Text('Telp: 0812-3456-7890'),
                    ],
                  ),
                ],
              ),

              pw.Divider(thickness: 2),
              pw.SizedBox(height: 16),

              // ================= INFO NOTA =================
              pw.Text(
                'NOTA',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Pemesan : ${invoice.customerName}'),
                      pw.Text('No HP   : ${invoice.customerPhone}'),
                      pw.Text('Alamat  : ${invoice.customerAddress}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('No Nota : ${invoice.invoiceNumber}'),
                      pw.Text('Tanggal : ${invoice.invoiceDate}'),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // ================= TABLE ITEM =================
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                headers: const ['No', 'Nama Item', 'Qty', 'Harga', 'Subtotal'],
                data: List.generate(items.length, (i) {
                  final item = items[i];
                  return [
                    '${i + 1}',
                    item.productName,
                    item.qty.toString(),
                    'Rp ${item.price.toStringAsFixed(0)}',
                    'Rp ${item.subtotal.toStringAsFixed(0)}',
                  ];
                }),
              ),

              pw.SizedBox(height: 16),

              // ================= TOTAL =================
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'TOTAL: Rp ${invoice.total.toStringAsFixed(0)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      terbilang(invoice.total.toInt()),
                      style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 32),

              // ================= FOOTER =================
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  children: [
                    pw.Text('Hormat Kami,'),
                    pw.SizedBox(height: 48),
                    pw.Text('PT Niaga Solusi Mandiri'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
