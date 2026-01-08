import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../repositories/company_profile_repository.dart';
import '../models/company_profile.dart';
import '../utils/terbilang.dart';

class InvoicePdfService {
  static Future<Uint8List> generate(
    Invoice invoice,
    List<InvoiceItem> items,
  ) async {
    final pdf = pw.Document();

    final logoData = await rootBundle.load('assets/images/wm.webp');
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    final repo = CompanyProfileRepository();
    final CompanyProfile? company = await repo.getProfile();

    final companyName = company?.name ?? 'Nama Perusahaan';
    final address = company?.address ?? '';
    final phone = company?.phone ?? '';
    final email = company?.email ?? '';
    final bankAccount = company?.bankAccount ?? '';

    String formatRupiah(double value) {
      if (value == 0) return 'Rp 0';
      final text = value.toStringAsFixed(0);
      final buffer = StringBuffer();
      for (int i = 0; i < text.length; i++) {
        if (i > 0 && (text.length - i) % 3 == 0) buffer.write('.');
        buffer.write(text[i]);
      }
      return 'Rp ${buffer.toString()}';
    }

    String formatTanggal(String isoDate) {
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      try {
        final date = DateTime.parse(isoDate);
        final day = date.day.toString().padLeft(2, '0');
        final month = months[date.month - 1];
        final year = date.year;
        return '$day $month $year';
      } catch (e) {
        return isoDate;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Stack(
              children: [
                pw.Positioned.fill(
                  child: pw.Opacity(
                    opacity: 0.05,
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Container(
                            width: 60,
                            height: 60,
                            child: pw.Image(logo),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            companyName,
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue,
                            ),
                          ),
                          if (address.isNotEmpty) pw.Text(address),
                          if (phone.isNotEmpty) pw.Text('Telp: $phone'),
                          if (email.isNotEmpty) pw.Text(email),
                        ],
                      ),
                    ),
                    pw.Divider(
                      height: 24,
                      thickness: 1,
                      color: PdfColors.grey400,
                    ),
                    pw.SizedBox(height: 16),

                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(6),
                            ),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.SizedBox(height: 4),
                              pw.Text(invoice.customerName),
                              if ((invoice.customerAddress ?? '').isNotEmpty)
                                pw.Text('${invoice.customerAddress}'),
                            ],
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(6),
                            ),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('No Nota: ${invoice.invoiceNumber}'),
                              pw.Text(
                                'Tanggal: ${formatTanggal(invoice.invoiceDate)}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 20),

                    pw.TableHelper.fromTextArray(
                      border: pw.TableBorder.all(
                        color: PdfColors.grey300,
                        width: 0.5,
                      ),
                      headerStyle: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        fontSize: 10,
                      ),
                      headerDecoration: pw.BoxDecoration(color: PdfColors.blue),
                      cellAlignment: pw.Alignment.center,
                      cellStyle: pw.TextStyle(fontSize: 9),
                      headers: const [
                        'No',
                        'Nama Item',
                        'Qty',
                        'Satuan',
                        'Harga',
                        'Subtotal',
                      ],
                      data: List.generate(items.length, (i) {
                        final item = items[i];
                        return [
                          '${i + 1}',
                          item.productName,
                          item.qty.toString(),
                          item.unit,
                          formatRupiah(item.price),
                          formatRupiah(item.subtotal),
                        ];
                      }),
                    ),

                    pw.SizedBox(height: 24),

                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue100,
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(6),
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'TOTAL',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue,
                                ),
                              ),
                              pw.Text(
                                formatRupiah(invoice.total),
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue,
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                '',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue,
                                  fontSize: 10,
                                ),
                              ),
                              pw.Text(
                                terbilang(invoice.total.toInt()),
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontStyle: pw.FontStyle.italic,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 24),

                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(6),
                        ),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          bankAccount.isNotEmpty
                              ? 'Pembayaran akan dicek dan dikatakan berhasil apabila sudah masuk ke ($bankAccount).'
                              : 'Pembayaran akan dicek dan dikatakan berhasil apabila sudah masuk ke rekening yang tertera pada company profile.',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey800,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),

                    pw.SizedBox(height: 48),

                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text('Hormat Kami,'),
                            pw.SizedBox(height: 50),
                            pw.Container(
                              width: 200,
                              height: 1,
                              color: PdfColors.black,
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              company?.owner ?? 'Nama Pemilik',
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
