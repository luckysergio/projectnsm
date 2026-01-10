import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/offer.dart';
import '../models/offer_item.dart';
import '../repositories/company_profile_repository.dart';
import '../models/company_profile.dart';
import '../utils/terbilang.dart';

class OfferPdfService {
  static Future<Uint8List> generate(
    Offer offer,
    List<OfferItem> items,
  ) async {
    final pdf = pw.Document();

    final logoData = await rootBundle.load('assets/images/logo.webp');
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    final wmData = await rootBundle.load('assets/images/wm.webp');
    final watermark = pw.MemoryImage(wmData.buffer.asUint8List());

    final ttdData = await rootBundle.load('assets/images/ttdbaru.webp');
    final ttdImage = pw.MemoryImage(ttdData.buffer.asUint8List());

    final companyRepo = CompanyProfileRepository();
    final CompanyProfile? company = await companyRepo.getProfile();

    final bankAccount = company?.bankAccount ?? '';
    final companyName = company?.name ?? '';
    final address = company?.address ?? '';
    final phone = company?.phone ?? '';

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
        'Desember'
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

    pw.Widget termItem(String text) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(' ', style: pw.TextStyle(fontSize: 9)),
            pw.Expanded(
              child: pw.Text(
                text,
                style: pw.TextStyle(fontSize: 9, height: 1.4),
                textAlign: pw.TextAlign.justify,
              ),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        build: (_) => [
          pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Opacity(
                    opacity: 0.06,
                    child: pw.Image(watermark,
                        width: 300, height: 300, fit: pw.BoxFit.scaleDown),
                  ),
                ),
              ),

              // KONTEN UTAMA
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 150,
                        height: 150,
                        alignment: pw.Alignment.center,
                        child: pw.Image(logo),
                      ),

                      pw.Expanded(
                        child: pw.Container(
                          height: 150,
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
                          '',
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
                      height: 12, thickness: 1, color: PdfColors.grey400),
                  pw.SizedBox(height: 8),

                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Kepada Yth:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(offer.customerName),
                            pw.SizedBox(height: 4),
                            pw.Text('Perihal:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(offer.subject),
                            pw.SizedBox(height: 4),
                            pw.Text('Proyek:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(offer.project),
                          ],
                        ),
                      ),
                      pw.Container(
                        width: 120,
                        child: pw.Align(
                          alignment: pw.Alignment.topRight,
                          child: pw.Text(
                            offer.offerNumber,
                            style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey600),
                          ),
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 10),

                  pw.Text(
                    'Dengan hormat,\n\n'
                    'Bersama ini kami dari $companyName bermaksud mengajukan '
                    'penawaran harga terkait pekerjaan yang sedang Bapak/Ibu rencanakan. '
                    'Adapun rincian penawaran kami adalah sebagai berikut:',
                    style: const pw.TextStyle(fontSize: 10),
                  ),

                  pw.SizedBox(height: 10),

                  // TABEL ITEM
                  pw.TableHelper.fromTextArray(
                    border: pw.TableBorder.all(
                        color: PdfColors.grey300, width: 0.5),
                    headerDecoration: pw.BoxDecoration(color: PdfColors.blue),
                    headerStyle: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10),
                    cellAlignment: pw.Alignment.center,
                    cellStyle: pw.TextStyle(fontSize: 9),
                    headers: const [
                      'No',
                      'Nama Produk',
                      'Qty',
                      'Satuan',
                      'Harga',
                      'Subtotal'
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

                  pw.SizedBox(height: 12),

                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(8)),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Text('Terbilang:',
                                style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue)),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              terbilang(offer.total.toInt()),
                              style: pw.TextStyle(
                                  fontSize: 11,
                                  fontStyle: pw.FontStyle.italic,
                                  color: PdfColors.grey700),
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Text('TOTAL',
                                style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue)),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              formatRupiah(offer.total),
                              style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 12),

                  pw.Container(
                    padding: const pw.EdgeInsets.all(14),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey50,
                      borderRadius: pw.BorderRadius.circular(8),
                      border:
                          pw.Border.all(color: PdfColors.grey300, width: 0.5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Syarat dan Ketentuan',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        termItem(
                            '1. Minimal terdapat pembayaran awal (cash atau transfer).'),
                        termItem(
                            '2. Pembayaran transfer ditujukan ke rekening resmi perusahaan: '
                            '${bankAccount.isNotEmpty ? bankAccount : 'belum tersedia'}.'),
                        termItem(
                            '3. Penggunaan pipa lebih dari 10 batang dikenakan biaya tambahan Rp100.000 per batang.'),
                        termItem(
                            '4. Biaya koordinasi dengan petugas keamanan dan masyarakat setempat menjadi tanggung jawab pembeli.'),
                        termItem(
                            '5. Pembeli bertanggung jawab atas kelayakan akses jalan yang dilalui armada mixer/pompa.'),
                        termItem(
                            '6. Waktu pembongkaran lebih dari 1 jam dikenakan biaya tambahan Rp150.000 per jam.'),
                        termItem(
                            '7. Harga dapat berubah sewaktu-waktu apabila terjadi fluktuasi harga bahan baku, BBM, atau kebijakan moneter.'),
                        pw.Divider(color: PdfColors.grey300),
                        pw.Text(
                          'Demikian penawaran ini kami sampaikan. '
                          'Untuk informasi lebih lanjut, silakan hubungi kami di '
                          '${phone.isNotEmpty ? phone : 'nomor perusahaan'}.',
                          style: pw.TextStyle(fontSize: 9, height: 1.4),
                          textAlign: pw.TextAlign.justify,
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Besar harapan kami untuk dapat menjalin kerja sama yang baik. '
                          'Atas perhatian dan kepercayaannya, kami ucapkan terima kasih.',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontStyle: pw.FontStyle.italic,
                            color: PdfColors.grey700,
                            height: 1.4,
                          ),
                          textAlign: pw.TextAlign.justify,
                        ),
                      ],
                    ),
                  ),

                  // FOOTER
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.only(left: 20),
                        height: 120,
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data: 'https://maps.app.goo.gl/LwQmA1JNhUUoqsUVA',
                              width: 60,
                              height: 60,
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text('LOKASI KANTOR',
                                style: pw.TextStyle(
                                    fontSize: 8, color: PdfColors.grey700)),
                          ],
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.only(right: 12),
                        height: 120,
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              'Tangerang Selatan, ${formatTanggal(offer.offerDate)}',
                              style: pw.TextStyle(
                                  fontSize: 11, color: PdfColors.black),
                            ),
                            pw.SizedBox(height: 6),
                            pw.Image(ttdImage,
                                width: 120, height: 70, fit: pw.BoxFit.contain),
                            pw.SizedBox(height: 4),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                  offer.sales.isNotEmpty
                                      ? offer.sales
                                      : 'Nama Sales',
                                  style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold),
                                ),
                                pw.Text(
                                  'Marketing',
                                  style: pw.TextStyle(
                                      fontSize: 9, color: PdfColors.grey600),
                                ),
                              ],
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
        ],
      ),
    );

    return pdf.save();
  }
}
