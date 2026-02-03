import '../database/database_helper.dart';
import '../models/company_profile.dart';

class CompanyProfileRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<CompanyProfile> insertProfile(CompanyProfile profile) async {
    final db = await _dbHelper.database;
    final id = await db.insert('company_profile', profile.toMap());

    return CompanyProfile(
      id: id,
      name: profile.name,
      owner: profile.owner,
      bankAccount: profile.bankAccount,
      address: profile.address,
      phone: profile.phone,
    );
  }

  Future<CompanyProfile> updateProfile(CompanyProfile profile) async {
    if (profile.id == null) {
      throw Exception('ID profile tidak boleh null saat update');
    }
    final db = await _dbHelper.database;
    await db.update(
      'company_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
    return profile;
  }

  Future<CompanyProfile?> getProfile() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'company_profile',
      orderBy: 'id ASC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return CompanyProfile.fromMap(result.first);
  }
}
