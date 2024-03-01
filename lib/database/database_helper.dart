import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = 'mpesafees.db';
  static final _databaseVersion = 1;

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE mpesafeesInfo (
          _id INTEGER PRIMARY KEY,
          theme TEXT NOT NULL
        )
        ''');

    await db.execute('''
        CREATE TABLE review (
          _id INTEGER PRIMARY KEY,
          reviewed INTEGER
        )
        ''');

    // How many times has the app been opened
    // Ask them to review us on the 5th launch
    await db.execute('''
        CREATE TABLE dayOfInstall (
          _id INTEGER PRIMARY KEY,
          day INTEGER
        )
        ''');
  }

  Future<int> insert(Map<String, dynamic> row, mytable) async {
    Database? db = await instance.database;
    return await db!.insert(mytable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(mytable) async {
    Database? db = await instance.database;
    return await db!.query(mytable);
  }

  Future<int?> queryRowCount(mytable) async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM $mytable'));
  }

  deleteAll(table) async {
    Database? db = await instance.database;
    return await db!.rawDelete("DELETE FROM $table");
  }

  Future<int> update(Map<String, dynamic> row, mytable) async {
    Database? db = await instance.database;
    int id = row['_id'];
    return await db!.update(mytable, row, where: '_id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id, mytable) async {
    Database? db = await instance.database;
    return await db!.delete(mytable, where: '_id = ?', whereArgs: [id]);
  }

  Future<int> deleteTable(mytable) async {
    Database? db = await instance.database;
    return await db!.delete(mytable);
  }
}
