import '../database/database_helper.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class InvoiceRepository {
  final _dbHelper = DatabaseHelper.instance;

  /// =============================
  /// CREATE INVOICE + ITEMS
  /// =============================
  Future<int> createInvoice(Invoice invoice, List<InvoiceItem> items) async {
    final db = await _dbHelper.database;

    return await db.transaction<int>((txn) async {
      // Insert invoice
      final invoiceId = await txn.insert('invoices', invoice.toMap());

      // Insert items
      for (final item in items) {
        final data = item.toMap();
        data['invoice_id'] = invoiceId;

        await txn.insert('invoice_items', data);
      }

      return invoiceId;
    });
  }

  /// Ambil nomor urut terakhir nota di bulan tertentu
  Future<int> getLastInvoiceNumberOfMonth(String year, String month) async {
    final db = await _dbHelper.database;

    // Cari invoice bulan ini, urut dari nomor terbesar
    final result = await db.rawQuery(
      '''
    SELECT invoice_number 
    FROM invoices 
    WHERE invoice_number LIKE ?
    ORDER BY invoice_number DESC
    LIMIT 1
  ''',
      ['NSM-$year-$month-%'],
    );

    if (result.isEmpty) return 0;

    final lastInvoiceNumber = result.first['invoice_number'] as String;

    // Ambil 4 digit terakhir sebagai nomor urut
    final lastNumberStr = lastInvoiceNumber.split('-').last;
    return int.tryParse(lastNumberStr) ?? 0;
  }

  /// =============================
  /// GET ALL INVOICES (UNTUK LIST)
  /// =============================
  Future<List<Invoice>> getAllInvoices() async {
    final db = await _dbHelper.database;

    final result = await db.query('invoices', orderBy: 'invoice_date DESC');

    return result.map((e) => Invoice.fromMap(e)).toList();
  }

  /// =============================
  /// GET INVOICES (PAGINATION READY)
  /// =============================
  Future<List<Invoice>> getInvoices({int limit = 20, int offset = 0}) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'invoices',
      orderBy: 'invoice_date DESC',
      limit: limit,
      offset: offset,
    );

    return result.map((e) => Invoice.fromMap(e)).toList();
  }

  /// =============================
  /// GET SINGLE INVOICE
  /// =============================
  Future<Invoice?> getInvoiceById(int id) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Invoice.fromMap(result.first);
  }

  /// =============================
  /// GET ITEMS BY INVOICE
  /// =============================
  Future<List<InvoiceItem>> getItemsByInvoice(int invoiceId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );

    return result.map((e) => InvoiceItem.fromMap(e)).toList();
  }

  /// =============================
  /// DELETE INVOICE + ITEMS
  /// =============================
  Future<void> deleteInvoice(int invoiceId) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // hapus item dulu
      await txn.delete(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [invoiceId],
      );

      // hapus invoice
      await txn.delete('invoices', where: 'id = ?', whereArgs: [invoiceId]);
    });
  }
}
