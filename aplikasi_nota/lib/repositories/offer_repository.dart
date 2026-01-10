import '../database/database_helper.dart';
import '../models/offer.dart';
import '../models/offer_item.dart';

class OfferRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<int> createOffer(Offer offer, List<OfferItem> items) async {
    final db = await _dbHelper.database;

    return await db.transaction<int>((txn) async {
      final offerId = await txn.insert('offers', offer.toMap());

      for (final item in items) {
        await txn.insert('offer_items', {
          ...item.toMap(),
          'offer_id': offerId,
        });
      }

      return offerId;
    });
  }

  Future<void> updateOffer(Offer offer, List<OfferItem> items) async {
    if (offer.id == null) {
      throw ArgumentError('Offer ID tidak boleh null saat update.');
    }

    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      await txn.update(
        'offers',
        offer.toMap(),
        where: 'id = ?',
        whereArgs: [offer.id],
      );

      await txn.delete(
        'offer_items',
        where: 'offer_id = ?',
        whereArgs: [offer.id],
      );

      for (final item in items) {
        await txn.insert('offer_items', {
          ...item.toMap(),
          'offer_id': offer.id!,
        });
      }
    });
  }

  Future<int> getLastOfferNumberOfMonth(String year, String month) async {
    final db = await _dbHelper.database;

    final monthPadded = month.padLeft(2, '0');

    final result = await db.rawQuery(
      '''
    SELECT offer_number
    FROM offers
    WHERE offer_number LIKE ?
    ORDER BY offer_number DESC
    LIMIT 1
    ''',
      ['SPH/NSM/$year/$monthPadded/%'],
    );

    if (result.isEmpty) return 0;

    final lastOffer = result.first['offer_number'] as String;
    final lastNumberStr = lastOffer.split('/').last;

    return int.tryParse(lastNumberStr) ?? 0;
  }

  Future<List<Offer>> getOffers({int? limit, int offset = 0}) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'offers',
      orderBy: 'offer_date DESC',
      limit: limit,
      offset: offset,
    );

    return result.map((row) => Offer.fromMap(row)).toList();
  }

  Future<Offer?> getOfferById(int id) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'offers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Offer.fromMap(result.first);
  }

  Future<List<OfferItem>> getItemsByOffer(int offerId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'offer_items',
      where: 'offer_id = ?',
      whereArgs: [offerId],
      orderBy: 'id ASC',
    );

    return result.map((row) => OfferItem.fromMap(row)).toList();
  }

  Future<void> deleteOffer(int offerId) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      await txn.delete(
        'offer_items',
        where: 'offer_id = ?',
        whereArgs: [offerId],
      );
      await txn.delete('offers', where: 'id = ?', whereArgs: [offerId]);
    });
  }
}
