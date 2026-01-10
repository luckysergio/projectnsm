import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nota.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE invoices (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_number TEXT NOT NULL UNIQUE,
  invoice_date TEXT NOT NULL,
  customer_name TEXT NOT NULL,
  customer_phone TEXT,
  customer_location TEXT,
  customer_address TEXT,
  subtotal REAL NOT NULL,
  total REAL NOT NULL,
  notes TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
    ''');

    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        product_name TEXT,
        qty INTEGER,
        unit TEXT,
        price REAL,
        subtotal REAL,
        FOREIGN KEY(invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
  CREATE TABLE offers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    offer_number TEXT NOT NULL UNIQUE,
    offer_date TEXT NOT NULL,
    subject TEXT NOT NULL,
    customer_name TEXT NOT NULL,
    project TEXT,
    sales TEXT,
    sales_phone TEXT,
    subtotal REAL NOT NULL,
    total REAL NOT NULL,
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
  );
''');

    await db.execute('''
  CREATE TABLE offer_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    offer_id INTEGER NOT NULL,
    product_name TEXT NOT NULL,
    quality TEXT,
    qty INTEGER,
    unit TEXT NOT NULL,
    price REAL NOT NULL DEFAULT 0,
    subtotal REAL NOT NULL DEFAULT 0,
    FOREIGN KEY(offer_id) REFERENCES offers(id) ON DELETE CASCADE
  );
''');

    await db.execute('''
      CREATE TABLE company_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        owner TEXT NOT NULL,
        bank_account TEXT,
        address TEXT,
        phone TEXT,
        email TEXT,
        social_media TEXT,
        website TEXT
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nota.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
