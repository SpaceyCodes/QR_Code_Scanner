import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import '../model/urls.dart';

class DatabaseProvider {
  static const String TABLE_URL = "url";
  static const String URL_ID = "id";
  static const String URL_NAME = "name";

  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();

  Database _database;

  Future<Database> get database async {
    print("database getter called");

    if (_database != null) {
      return _database;
    }

    _database = await createDatabase();

    return _database;
  }

  Future<Database> createDatabase() async {
    String dbPath = await getDatabasesPath();

    return await openDatabase(
      join(dbPath, 'urlDB.db'),
      version: 1,
      onCreate: (Database database, int version) async {
        print("Creating food table");

        await database.execute(
          "CREATE TABLE $TABLE_URL ("
          "$URL_ID INTEGER PRIMARY KEY,"
          "$URL_NAME TEXT"
          ")",
        );
      },
    );
  }

  Future<List<URL>> getUrls() async {
    final db = await database;

    var urls = await db.query(TABLE_URL, columns: [URL_ID, URL_NAME]);

    List<URL> urlList = List<URL>();

    urls.forEach((currenturl) {
      URL url = URL.fromMap(currenturl);

      urlList.add(url);
    });

    return urlList;
  }

  Future<URL> insert(URL url) async {
    final db = await database;
    url.id = await db.insert(TABLE_URL, url.toMap());
    return url;
  }

  Future<int> delete(int id) async {
    final db = await database;
    print('Delete item');
    return await db.delete(
      TABLE_URL,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> update(URL url) async {
    final db = await database;

    return await db.update(
      TABLE_URL,
      url.toMap(),
      where: "id = ?",
      whereArgs: [url.id],
    );
  }
}
