import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/shop.dart';
import '../models/product.dart';
import '../models/sale.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'apex.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT,
        role TEXT,
        is_active INTEGER
      )
    ''');

    // Shops table
    await db.execute('''
      CREATE TABLE shops (
        id INTEGER PRIMARY KEY,
        name TEXT,
        location TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT,
        unit TEXT,
        category TEXT,
        stock REAL,
        cost_price REAL,
        selling_price REAL,
        minimum_quantity REAL,
        barcode TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Sales table
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY,
        seller_id INTEGER,
        sale_date TEXT
      )
    ''');

    // Sale items table
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER,
        product_id INTEGER,
        quantity INTEGER,
        price INTEGER,
        FOREIGN KEY (sale_id) REFERENCES sales (id)
      )
    ''');
  }

  // User methods
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  // Shop methods
  Future<void> insertShop(Shop shop) async {
    final db = await database;
    await db.insert('shops', shop.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Shop?> getShop() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('shops', limit: 1);
    if (maps.isNotEmpty) {
      return Shop.fromJson(maps.first);
    }
    return null;
  }

  // Product methods
  Future<void> insertProducts(List<Product> products) async {
    final db = await database;
    Batch batch = db.batch();
    for (var product in products) {
      batch.insert('products', product.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
  }

  // Sale methods
  Future<void> insertSales(List<Sale> sales) async {
    final db = await database;
    Batch batch = db.batch();
    for (var sale in sales) {
      batch.insert('sales', {
        'id': sale.id,
        'seller_id': sale.sellerId,
        'sale_date': sale.saleDate,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      for (var item in sale.items) {
        batch.insert('sale_items', {
          'sale_id': sale.id,
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.price,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    await batch.commit(noResult: true);
  }

  Future<List<Sale>> getSales() async {
    final db = await database;
    final List<Map<String, dynamic>> saleMaps = await db.query('sales');
    List<Sale> sales = [];
    for (var saleMap in saleMaps) {
      final List<Map<String, dynamic>> itemMaps = await db.query('sale_items', where: 'sale_id = ?', whereArgs: [saleMap['id']]);
      List<SaleItem> items = itemMaps.map((item) => SaleItem.fromJson(item)).toList();
      sales.add(Sale(
        id: saleMap['id'],
        sellerId: saleMap['seller_id'],
        saleDate: saleMap['sale_date'],
        items: items,
        totalAmount: items.fold(0, (sum, item) => sum + item.quantity * item.price),
      ));
    }
    return sales;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('shops');
    await db.delete('products');
    await db.delete('sales');
    await db.delete('sale_items');
  }
}