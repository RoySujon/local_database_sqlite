import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static const dbp = 'roy.db';
//<<=======================[Create Table Method]=======================>>
  static createTables(sql.Database database) async {
    await database.execute(
        """CREATE TABLE items (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
         title TEXT,
         description TEXT,
         phoneNo TEXT,
         createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
         )
         """);
  }

  static deletTable() async {
    final db = await sql.deleteDatabase('roy.db');
  }

//<<=======================[Create DB]=======================>>
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'roy.db',
      version: 1,
      onCreate: (db, version) async {
        await createTables(db);
        print('==============create Database==============');
      },
    );
  }

//<<=======================[Create Items]=======================>>
  static createItem(String title, String? description, String phoneNo) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'phoneNo': phoneNo
    };

    final inputData = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return inputData;
  }

//<<=======================[Get All Items]=======================>>
  static Future<List<Map<String, dynamic>>> getAllItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id ");
  }

//<<=======================Get only One Item=======================>>
  static Future<List<Map<String, dynamic>>> getOneItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

//<<=======================[Update Itme]=======================>>
  static updateItem(
      int id, String title, String? description, String phoneNo) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'phoneNo': phoneNo,
      'createdAt': DateTime.timestamp().toString()
    };
    final updateResult = await db.update(
      'items',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
    return updateResult;
  }

//<<=======================[Delete spacific item]=======================>>
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint("Something going Wrong : $e");
    }
  }
}
