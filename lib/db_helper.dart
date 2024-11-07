import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/product.dart';
import 'models/category.dart';
import 'models/review.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('products.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        category_id INTEGER NOT NULL,
        is_favorite INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_product_name ON products (name);');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        review_text TEXT,
        rating INTEGER,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
  }

  // Product CRUD operations
  Future<List<Product>> fetchProducts(
      {String? query, int page = 0, int pageSize = 10}) async {
    final db = await instance.database;
    final offset = page * pageSize;
    String sql = 'SELECT * FROM products';
    List<dynamic> args = [];

    if (query != null && query.isNotEmpty) {
      sql += ' WHERE name LIKE ?';
      args.add('%$query%');
    }

    sql += ' LIMIT ? OFFSET ?';
    args.addAll([pageSize, offset]);

    final result = await db.rawQuery(sql, args);
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    return await db.insert('products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Category CRUD operations
  Future<int> insertCategory(Category category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> fetchCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((json) => Category.fromMap(json)).toList();
  }

  // Review CRUD operations
  Future<int> insertReview(Review review) async {
    final db = await instance.database;
    return await db.insert('reviews', review.toMap());
  }

  Future<List<Review>> fetchReviewsForProduct(int productId) async {
    final db = await instance.database;
    final result = await db.query(
      'reviews',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return result.map((json) => Review.fromMap(json)).toList();
  }

  Future<int> updateReview(Review review) async {
    final db = await instance.database;
    return await db.update(
      'reviews',
      review.toMap(),
      where: 'id = ?',
      whereArgs: [review.id],
    );
  }

  Future<int> deleteReview(int id) async {
    final db = await instance.database;
    return await db.delete(
      'reviews',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertSampleData() async {
    final db = await instance.database;
    final existingProducts = await db.query('products');
    if (existingProducts.isNotEmpty) return;
    int categoryId = await db.insert('categories', {'name': 'Electronics'});
    await db.insert('products', {
      'name': 'Smartphone',
      'price': 699.99,
      'category_id': categoryId,
      'is_favorite': 0,
    });
    await db.insert('products', {
      'name': 'Laptop',
      'price': 999.99,
      'category_id': categoryId,
      'is_favorite': 1,
    });
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
