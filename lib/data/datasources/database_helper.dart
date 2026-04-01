import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'agrobiometrik.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE models(
        model_version TEXT PRIMARY KEY,
        model_type TEXT,
        embedding_size INTEGER,
        training_date TEXT,
        path TEXT,
        compatability_flags TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE animals(
        id TEXT PRIMARY KEY,
        name TEXT,
        species TEXT,
        breed TEXT,
        birth_date_est TEXT,
        health_tags TEXT,
        production_tags TEXT,
        registration_date TEXT,
        created_by TEXT,
        last_modified_by TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE embeddings(
        id TEXT PRIMARY KEY,
        animal_id TEXT,
        vector_data BLOB,
        model_version TEXT,
        normalization_method TEXT,
        capture_condition TEXT,
        angle TEXT,
        capture_date TEXT,
        is_outlier INTEGER,
        FOREIGN KEY(animal_id) REFERENCES animals(id),
        FOREIGN KEY(model_version) REFERENCES models(model_version)
      )
    ''');

    await db.execute('''
      CREATE TABLE captures(
        id TEXT PRIMARY KEY,
        animal_id TEXT,
        image_path TEXT,
        timestamp TEXT,
        gps_lat REAL,
        gps_long REAL,
        confidence REAL,
        device_id TEXT,
        FOREIGN KEY(animal_id) REFERENCES animals(id)
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
