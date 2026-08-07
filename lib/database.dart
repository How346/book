import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('okbook.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE parties(
        id TEXT PRIMARY KEY,
        name TEXT,
        phone TEXT,
        type INTEGER,
        balancePaise INTEGER,
        createdAt TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        partyId TEXT,
        amountPaise INTEGER,
        isGot INTEGER,
        note TEXT,
        date TEXT,
        FOREIGN KEY (partyId) REFERENCES parties (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE cashbook(
        id TEXT PRIMARY KEY,
        amountPaise INTEGER,
        isIncome INTEGER,
        category TEXT,
        note TEXT,
        date TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE items(
        id TEXT PRIMARY KEY,
        name TEXT,
        stockCount INTEGER,
        pricePaise INTEGER
      )
    ''');
  }

  Future<void> insertParty(Party party) async {
    final db = await instance.database;
    await db.insert('parties', party.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Party>> getAllParties() async {
    final db = await instance.database;
    final result = await db.query('parties', orderBy: 'createdAt DESC');
    return result.map((json) => Party.fromMap(json)).toList();
  }

  Future<void> updatePartyBalance(String id, int newBalance) async {
    final db = await instance.database;
    await db.update('parties', {'balancePaise': newBalance}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertTransaction(TransactionModel tx) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.insert('transactions', tx.toMap());
      final res = await txn.query('parties', columns: ['balancePaise'], where: 'id = ?', whereArgs: [tx.partyId]);
      if (res.isNotEmpty) {
        int currentBal = res.first['balancePaise'] as int;
        // isGot = payment received (reduces pending balance)
        int diff = tx.isGot ? -tx.amountPaise : tx.amountPaise;
        int newBal = currentBal + diff;
        await txn.update('parties', {'balancePaise': newBal}, where: 'id = ?', whereArgs: [tx.partyId]);
      }
    });
  }

  Future<List<TransactionModel>> getTransactionsForParty(String partyId) async {
    final db = await instance.database;
    final result = await db.query('transactions', where: 'partyId = ?', whereArgs: [partyId], orderBy: 'date ASC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<void> insertCashbook(CashbookEntry entry) async {
    final db = await instance.database;
    await db.insert('cashbook', entry.toMap());
  }

  Future<List<CashbookEntry>> getCashbook() async {
    final db = await instance.database;
    final result = await db.query('cashbook', orderBy: 'date DESC');
    return result.map((json) => CashbookEntry.fromMap(json)).toList();
  }

  Future<void> insertItem(Item item) async {
    final db = await instance.database;
    await db.insert('items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Item>> getItems() async {
    final db = await instance.database;
    final result = await db.query('items');
    return result.map((json) => Item.fromMap(json)).toList();
  }
}
