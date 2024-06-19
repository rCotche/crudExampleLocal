import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SqlHelper {
  //Premiere methode
  //Le sql pour créer les tables
  //return rien
  static Future<void> createTables(sql.Database database) async {
    //3 " pour avoir une string multiligne
    await database.execute("""CREATE TABLE items(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      description TEXT,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");
  }

  //2e methode
  //Création de la de la base de donnée
  //check if dbtech.db exist sinon la cree
  //check if on a une table sinon la cree
  static Future<sql.Database> db() async {
    return sql.openDatabase('dbtech.db', version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  //3e
  //insertion
  static Future<int> createItem(String title, String? description) async {
    //open connection, open la database
    final db = await SqlHelper.db();

    //cree une Map<String, object> | en js c'est un object
    //clé : champ de la bdd
    //valeur : valur passé en param de la fonction
    final data = {'title': title, 'description': description};

    //This method helps insert a map of [values] into the specified [table]
    //and returns the id of the last inserted row.

    //conflictAlgorithm prevent from duplicate entry
    //bonne pratique
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  //4e
  //getter
  //vu que une data c'est une map
  //et que on veut recuperer tous les data
  //alors on va recuperer une liste de map
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SqlHelper.db();

    //This is a helper to query a table and return the items found.
    //All optional clauses and filters are formatted as SQL queries excluding the clauses' names.
    return db.query('items', orderBy: "id");
  }

  //5e
  //get by id
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SqlHelper.db();

    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  //
  static Future<int> updateItem(
      int id, String title, String? description) async {
    final db = await SqlHelper.db();

    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString(),
    };

    final result = db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  //
  static Future<void> deleteItem(int id) async {
    final db = await SqlHelper.db();

    try {
      await db.delete('items', where: "id = ?", whereArgs: [id]);
    } on Exception catch (e) {
      debugPrint("erreur: $e");
    }
  }
}
