import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'note_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT,
        body TEXT,
        updated_at INTEGER,
        sync_status TEXT,
        is_deleted INTEGER
      )
    ''');
  }

  Future<void> insertOrUpdate(NoteModel note) async {
    final db = await instance.database;
    await db.insert('notes', note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<NoteModel>> getNotes() async {
    final db = await instance.database;
    final result = await db.query('notes');
    return result.map((json) => NoteModel.fromMap(json)).toList();
  }

  Future<NoteModel?> getNoteById(String id) async {
    final db = await instance.database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return NoteModel.fromMap(maps.first);
    return null;
  }

  Future<List<NoteModel>> getPendingNotes() async {
    final db = await instance.database;
    final result = await db.query('notes', where: "sync_status = 'pendingSync' OR is_deleted = 1");
    return result.map((json) => NoteModel.fromMap(json)).toList();
  }

  Future<void> softDelete(String id) async {
    final db = await instance.database;
    await db.update('notes', {'sync_status': 'pendingSync', 'is_deleted': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> hardDelete(String id) async {
    final db = await instance.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}