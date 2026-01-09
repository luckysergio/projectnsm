import '../database/database_helper.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class InvoiceRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<int> createInvoice(Invoice invoice, List<InvoiceItem> items) async {
    final db = await _dbHelper.database;

    return await db.transaction<int>((txn) async {
      final invoiceId = await txn.insert('invoices', invoice.toMap());

      for (final item in items) {
        await txn.insert('invoice_items', {
          ...item.toMap(),
          'invoice_id': invoiceId,
        });
      }

      return invoiceId;
    });
  }

  Future<void> updateInvoice(Invoice invoice, List<InvoiceItem> items) async {
    if (invoice.id == null) {
      throw ArgumentError('Invoice ID tidak boleh null saat update.');
    }

    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      await txn.update(
        'invoices',
        invoice.toMap(),
        where: 'id = ?',
        whereArgs: [invoice.id],
      );

      await txn.delete(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [invoice.id!],
      );

      for (final item in items) {
        await txn.insert('invoice_items', {
          ...item.toMap(),
          'invoice_id': invoice.id!,
        });
      }
    });
  }

  Future<int> getLastInvoiceNumberOfMonth(String year, String month) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      '''
    SELECT invoice_number
    FROM invoices
    WHERE invoice_number LIKE ?
    ORDER BY invoice_number DESC
    LIMIT 1
    ''',
      ['INV/NSM/$year/$month/%'],
    );

    if (result.isEmpty) return 0;

    final lastInvoice = result.first['invoice_number'] as String;

    final lastNumberStr = lastInvoice.split('/').last;

    return int.tryParse(lastNumberStr) ?? 0;
  }

  Future<List<Invoice>> getInvoices({int? limit, int offset = 0}) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'invoices',
      orderBy: 'invoice_date DESC',
      limit: limit,
      offset: offset,
    );

    return result.map((row) => Invoice.fromMap(row)).toList();
  }

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

  Future<List<InvoiceItem>> getItemsByInvoice(int invoiceId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
      orderBy: 'id ASC',
    );

    return result.map((row) => InvoiceItem.fromMap(row)).toList();
  }

  Future<void> deleteInvoice(int invoiceId) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      await txn.delete(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [invoiceId],
      );
      await txn.delete('invoices', where: 'id = ?', whereArgs: [invoiceId]);
    });
  }
}
