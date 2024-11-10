import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/notes_model.dart';

class DatabaseHandler{

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'my_simple_note.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE notes("
              "id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "title TEXT, "
              "body TEXT, "
              "dateTime TEXT,"
              "isPriority INTEGER DEFAULT 0)"
        );
      },
      version: 1,
    );
  }

  Future<int> addNote(Note note)  async {
    final Database db = await initializeDB();
      return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getAllNotes() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query(
      'notes',
      orderBy: 'dateTime DESC'
    );
    return queryResult.map((e) => Note.fromMap(e)).toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await initializeDB();
    return await db.update(
      'notes',
      note.toMap(),
      where: "id = ?",
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await initializeDB();
    return await db.delete(
      'notes',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}