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
        is_favorite INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_product_name ON products (name);');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
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
    final result = await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    await deleteEmptyCategories();
    return result;
  }

  Future<List<Product>> fetchProductsWithFilters({
    int? categoryId,
    bool showOnlyFavorites = false,
    String? query,
    int page = 0,
    int pageSize = 10,
  }) async {
    final db = await instance.database;
    String sql = 'SELECT * FROM products WHERE 1=1';
    List<dynamic> args = [];

    if (categoryId != null) {
      sql += ' AND category_id = ?';
      args.add(categoryId);
    }

    if (showOnlyFavorites) {
      sql += ' AND is_favorite = 1';
    }

    if (query != null && query.isNotEmpty) {
      sql += ' AND name LIKE ?';
      args.add('%$query%');
    }

    sql += ' LIMIT ? OFFSET ?';
    args.addAll([pageSize, page * pageSize]);

    final result = await db.rawQuery(sql, args);
    return result.map((json) => Product.fromMap(json)).toList();
  }

  // Category CRUD operations
  Future<int> insertOrFindCategory(String categoryName) async {
    final db = await instance.database;
    final result = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [categoryName],
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int;
    } else {
      return await db.insert('categories', {'name': categoryName});
    }
  }

  Future<void> deleteEmptyCategories() async {
    final db = await instance.database;
    await db.delete(
      'categories',
      where: 'id NOT IN (SELECT DISTINCT category_id FROM products)',
    );
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
