import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/landmark.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) {
      print('>>> Database: Using existing instance');
      return _database!;
    }

    print('>>> Database: Initializing new instance');
    _database = await _initDB('landmarks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print('>>> Database path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) {
        print('>>> Database opened successfully');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    print('>>> Creating database tables');
    await db.execute('''
      CREATE TABLE landmarks (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        lat REAL NOT NULL,
        lon REAL NOT NULL,
        image TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 1,
        timestamp INTEGER NOT NULL
      )
    ''');
    print('>>> Database tables created');
  }

  Future<int> insertLandmark(Landmark landmark) async {
    try {
      final db = await database;
      final result = await db.insert(
        'landmarks',
        landmark.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('>>> DB Insert: ID=${landmark.id}, Result=$result');
      return result;
    } catch (e) {
      print('>>> DB Insert Error: $e');
      rethrow;
    }
  }

  Future<List<Landmark>> getAllLandmarks() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'landmarks',
        orderBy: 'timestamp DESC',
      );

      print('>>> DB Query: Found ${maps.length} landmarks');

      final landmarks = List.generate(
        maps.length,
            (i) => Landmark.fromMap(maps[i]),
      );

      for (var landmark in landmarks) {
        print('>>> DB Landmark: ID=${landmark.id}, Title=${landmark.title}');
      }

      return landmarks;
    } catch (e) {
      print('>>> DB Query Error: $e');
      rethrow;
    }
  }

  Future<Landmark?> getLandmark(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'landmarks',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        print('>>> DB Get: Landmark ID=$id not found');
        return null;
      }

      print('>>> DB Get: Found landmark ID=$id');
      return Landmark.fromMap(maps.first);
    } catch (e) {
      print('>>> DB Get Error: $e');
      rethrow;
    }
  }

  Future<int> updateLandmark(Landmark landmark) async {
    try {
      final db = await database;
      final result = await db.update(
        'landmarks',
        landmark.toMap(),
        where: 'id = ?',
        whereArgs: [landmark.id],
      );
      print('>>> DB Update: ID=${landmark.id}, Rows affected=$result');
      return result;
    } catch (e) {
      print('>>> DB Update Error: $e');
      rethrow;
    }
  }

  Future<int> deleteLandmark(int id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'landmarks',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('>>> DB Delete: ID=$id, Rows affected=$result');
      return result;
    } catch (e) {
      print('>>> DB Delete Error: $e');
      rethrow;
    }
  }

  Future<void> clearAllLandmarks() async {
    try {
      final db = await database;
      final result = await db.delete('landmarks');
      print('>>> DB Clear: Deleted $result rows');
    } catch (e) {
      print('>>> DB Clear Error: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    print('>>> Database closed');
  }
}