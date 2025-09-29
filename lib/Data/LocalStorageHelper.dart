import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'DataModel.dart';

class LocalStorageHelper {
  static Database? _database;
  static const String tableName = 'grocery_items';
  static const String categoriesTable = 'categories';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'grocery_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT,
        name TEXT,
        quantity INTEGER,
        urgency TEXT,
        addedBy TEXT,
        timestamp TEXT,
        category TEXT,
        tags TEXT,
        isCompleted INTEGER,
        isSynced INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $categoriesTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        color TEXT,
        icon TEXT
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {'name': 'Fruits & Vegetables', 'color': '#4CAF50', 'icon': '🥬'},
      {'name': 'Dairy & Eggs', 'color': '#FFEB3B', 'icon': '🥛'},
      {'name': 'Meat & Seafood', 'color': '#F44336', 'icon': '🥩'},
      {'name': 'Bakery', 'color': '#FF9800', 'icon': '🍞'},
      {'name': 'Pantry', 'color': '#9C27B0', 'icon': '🥫'},
      {'name': 'Frozen', 'color': '#2196F3', 'icon': '🧊'},
      {'name': 'Beverages', 'color': '#00BCD4', 'icon': '🥤'},
      {'name': 'Snacks', 'color': '#795548', 'icon': '🍿'},
      {'name': 'Health & Beauty', 'color': '#E91E63', 'icon': '🧴'},
      {'name': 'Household', 'color': '#607D8B', 'icon': '🧽'},
      {'name': 'Other', 'color': '#9E9E9E', 'icon': '📦'},
    ];

    for (var category in defaultCategories) {
      await db.insert(categoriesTable, category);
    }
  }

  Future<int> insertGroceryItem(GroceryItem item) async {
    final db = await database;
    return await db.insert(tableName, {
      'key': item.key,
      'name': item.itemData?.name,
      'quantity': item.itemData?.quantity,
      'urgency': item.itemData?.urgency,
      'addedBy': item.itemData?.addedBy,
      'timestamp': item.itemData?.timestamp,
      'category': item.itemData?.category,
      'tags': item.itemData?.tags?.join(','),
      'isCompleted': item.itemData?.isCompleted == true ? 1 : 0,
      'isSynced': item.itemData?.isSynced == true ? 1 : 0,
    });
  }

  Future<List<GroceryItem>> getAllGroceryItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    
    return List.generate(maps.length, (i) {
      return GroceryItem(
        maps[i]['key'],
        GroceryItemData(
          name: maps[i]['name'],
          quantity: maps[i]['quantity'],
          urgency: maps[i]['urgency'],
          addedBy: maps[i]['addedBy'],
          timestamp: maps[i]['timestamp'],
          category: maps[i]['category'],
          tags: maps[i]['tags'] != null ? maps[i]['tags'].split(',') : null,
          isCompleted: maps[i]['isCompleted'] == 1,
          isSynced: maps[i]['isSynced'] == 1,
        ),
      );
    });
  }

  Future<int> updateGroceryItem(String key, GroceryItemData itemData) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        'name': itemData.name,
        'quantity': itemData.quantity,
        'urgency': itemData.urgency,
        'addedBy': itemData.addedBy,
        'timestamp': itemData.timestamp,
        'category': itemData.category,
        'tags': itemData.tags?.join(','),
        'isCompleted': itemData.isCompleted == true ? 1 : 0,
        'isSynced': itemData.isSynced == true ? 1 : 0,
      },
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<int> deleteGroceryItem(String key) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<List<GroceryItem>> getUnsyncedItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    
    return List.generate(maps.length, (i) {
      return GroceryItem(
        maps[i]['key'],
        GroceryItemData(
          name: maps[i]['name'],
          quantity: maps[i]['quantity'],
          urgency: maps[i]['urgency'],
          addedBy: maps[i]['addedBy'],
          timestamp: maps[i]['timestamp'],
          category: maps[i]['category'],
          tags: maps[i]['tags'] != null ? maps[i]['tags'].split(',') : null,
          isCompleted: maps[i]['isCompleted'] == 1,
          isSynced: maps[i]['isSynced'] == 1,
        ),
      );
    });
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query(categoriesTable);
  }

  Future<int> addCategory(String name, String color, String icon) async {
    final db = await database;
    return await db.insert(categoriesTable, {
      'name': name,
      'color': color,
      'icon': icon,
    });
  }

  Future<void> markAsSynced(String key) async {
    final db = await database;
    await db.update(
      tableName,
      {'isSynced': 1},
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(tableName);
  }

  Future<GroceryItem?> getGroceryItemByKey(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'key = ?',
      whereArgs: [key],
    );
    
    if (maps.isEmpty) return null;
    
    final map = maps[0];
    return GroceryItem(
      map['key'],
      GroceryItemData(
        name: map['name'],
        quantity: map['quantity'],
        urgency: map['urgency'],
        addedBy: map['addedBy'],
        timestamp: map['timestamp'],
        category: map['category'],
        tags: map['tags'] != null ? map['tags'].split(',') : null,
        isCompleted: map['isCompleted'] == 1,
        isSynced: map['isSynced'] == 1,
      ),
    );
  }
}
