import 'dart:io';

import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:image_picker/image_picker.dart';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initDatabase();
      return _db;
    } else {
      return _db;
    }
  }

  Future<Database> initDatabase() async {
    sqfliteFfiInit();

    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, 'face_detection.db');

    return await openDatabase(path,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  void _onUpgrade(Database db, int oldversion, int newversion) {
    print("onUpgrade =====================================");
  }
// Database db
  _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE "faces"(
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "image" BLOB
    )
  ''');

    print(" onCreate =====================================");
  }

  readData(String sql) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }

  insertData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  Future<void> addPerson({required File? image}) async {
    // get the database connection
    SqlDb dbInstance = SqlDb(); // إنشاء مثيل من فئة SqlDb

    // الحصول على اتصال قاعدة البيانات من خلال مثيل الفئة
    var databaseConnection = await dbInstance.db;

    // create a map of the product data
    Map<String, dynamic> personFace = {
      "image": image,
    };

    // insert the product into the database
    await databaseConnection!.insert("faces", personFace);

    updateData(String sql) async {
      Database? mydb = await db;
      int response = await mydb!.rawUpdate(sql);
      return response;
    }

    deleteData(String sql) async {
      Database? mydb = await db;
      int response = await mydb!.rawDelete(sql);
      return response;
    }

    Future<void> deleteDatabase() async {
      String databasepath = await getDatabasesPath();
      String path = p.join(databasepath, 'face_detection.db');
      databaseFactory.deleteDatabase(path);
      print(" deleted =====================================");
    }

    Future<List<Map>> printData({required String categoryName}) async {
      // get the database connection
      var db = await SqlDb().db;

      // create the SQL query
      String sql = "SELECT * FROM $categoryName";

      // execute the query
      List<Map> response = await db!.rawQuery(sql);

      return response;
    }

// SELECT
// DELETE
// UPDATE
// INSERT
  }
}
