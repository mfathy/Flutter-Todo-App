import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:todo_app/model/todo.dart';

class DbHelper {
  String tb1Todo = "todo";
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colPriority = "priority";
  String colDate = "date";

  static final DbHelper _dbHelper = new DbHelper._internal();

  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  static Database _db;

  Future<Database> get db async {
    if (_db == null) {
      _db = await initDb();
    }

    return _db;
  }

  Future<Database> initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "todos.db";
    var dbTodos = await openDatabase(path, version: 1, onCreate: _createDb);

    return dbTodos;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $tb1Todo($colId INTEGER PRIMARY KEY, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)");
  }

  Future<int> insertTodo(Todo todo) async {
    Database db = await this.db;
    var result = await db.insert(tb1Todo, todo.toMap());
    return result;
  }

  Future<List> getTodos() async {
    Database db = await this.db;
    var result =
        await db.rawQuery("SELECT * FROM $tb1Todo order by $colPriority ASC");
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.db;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT count (*) from $tb1Todo"));

    return result;
  }

  Future<int> updateTodo(Todo todo) async {
    Database db = await this.db;
    var result = await db.update(tb1Todo, todo.toMap(), where: "$colId = ?", whereArgs: [todo.id]);
    return result;
  }

  Future<int> deleteTodo(int id) async {
    Database db = await this.db;
    var result = await db.rawDelete("DELETE FROM $tb1Todo WHERE $colId = $id");
    return result;
  }
}
