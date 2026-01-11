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

    final logoData = await rootBundle.load('assets/images/logobaru.webp');
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    final wmData = await rootBundle.load('assets/images/wm.webp');
    final watermark = pw.MemoryImage(wmData.buffer.asUint8List());

    final ttdData = await rootBundle.load('assets/images/ttdbaru.webp');
    final ttdImage = pw.MemoryImage(ttdData.buffer.asUint8List());

    final repo = CompanyProfileRepository();
    final CompanyProfile? company = await repo.getProfile();

    final companyName = company?.name ?? '';
    final owner = company?.owner ?? '';
    final address = company?.address ?? '';
    final phone = company?.phone ?? '';
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
                // WATERMARK
                pw.Positioned.fill(
                  child: pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Opacity(
                      opacity: 0.06,
                      child: pw.Image(
                        watermark,
                        width: 300,
                        height: 300,
                        fit: pw.BoxFit.scaleDown,
                      ),
                    ),
                  ),
                ),

                // ISI DOKUMEN
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    // HEADER
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment:
                          pw.CrossAxisAlignment.center, // ⬅️ penting
                      children: [
                        // LOGO (KIRI)
                        pw.Container(
                          width: 150,
                          height: 150,
                          alignment: pw.Alignment.center,
                          child: pw.Image(logo),
                        ),

                        // INFO PERUSAHAAN (TENGAH)
                        pw.Expanded(
                          child: pw.Container(
                            height: 150, // ⬅️ samakan tinggi dengan logo
                            alignment: pw.Alignment.center,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                  companyName,
                                  style: pw.TextStyle(
                                    fontSize: 18,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                                pw.SizedBox(height: 4),
                                if (address.isNotEmpty)
                                  pw.Text(
                                    address,
                                    style: pw.TextStyle(
                                      fontSize: 12,
                                      color: PdfColors.grey800,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                if (phone.isNotEmpty)
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(top: 4),
                                    child: pw.Text(
                                      phone,
                                      style: pw.TextStyle(
                                        fontSize: 12,
                                        color: PdfColors.grey800,
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // INVOICE (KANAN - TENGAH)
                        pw.Container(
                          width: 80,
                          height: 150,
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            'INVOICE',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),

                    pw.Divider(
                      height: 8,
                      thickness: 1,
                      color: PdfColors.grey400,
                    ),

                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(10),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  invoice.customerName,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                if ((invoice.customerLocation ?? '').isNotEmpty)
                                  pw.Text(invoice.customerLocation!),
                                if ((invoice.customerAddress ?? '').isNotEmpty)
                                  pw.Text(invoice.customerAddress!),
                              ],
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(10),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  ' ${formatTanggal(invoice.invoiceDate)}',
                                ),
                                pw.Text(invoice.invoiceNumber),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 10),

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
                        'Nama Produk',
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

                    // TOTAL + TERBILANG
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.all(
                          pw.Radius.circular(8),
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          // TERBILANG (KIRI)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text(
                                'Terbilang:',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                terbilang(invoice.total.toInt()),
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontStyle: pw.FontStyle.italic,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ),

                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text(
                                'TOTAL',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                formatRupiah(invoice.total),
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue,
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
                        borderRadius: pw.BorderRadius.all(
                          pw.Radius.circular(6),
                        ),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          bankAccount.isNotEmpty
                              ? 'Pembayaran dapat dilakukan Tranfer Ke Bank BCA No Rekening $bankAccount'
                              : 'Pembayaran akan dicek dan dikatakan berhasil apabila sudah masuk ke rekening yang tertera pada company profile.',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.black,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),

                    pw.SizedBox(height: 40),

                    // FOOTER
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: pw.EdgeInsets.only(left: 28),
                          height: 140,
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.BarcodeWidget(
                                barcode: pw.Barcode.qrCode(),
                                data:
                                    'https://maps.app.goo.gl/LwQmA1JNhUUoqsUVA',
                                width: 80,
                                height: 80,
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'LOKASI KANTOR',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.only(right: 12),
                          height: 140,
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Text(
                                'Tangerang Selatan, ${formatTanggal(invoice.invoiceDate)}',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.SizedBox(height: 6),
                              pw.Image(
                                ttdImage,
                                width: 150,
                                height: 90,
                                fit: pw.BoxFit.contain,
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                owner.isNotEmpty ? owner : 'Nama Pemilik',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.black,
                                ),
                              ),
                            ],
                          ),
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
