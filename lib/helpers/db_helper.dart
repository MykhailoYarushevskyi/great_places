import 'dart:developer';

import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

class DBHelper {
  static const String MAIN_TAG = '## DBHelper';

  static Future<Database> database(String table) async {
    final dbPath = await sql.getDatabasesPath();
    print('$MAIN_TAG.database() dbPath: $dbPath');
    return await sql.openDatabase(
      path.join(dbPath, 'places.db'),
      onCreate: (db, version) {
        log('$MAIN_TAG.database() -> onCreate()');
        return db.execute(
            'CREATE TABLE $table(id TEXT PRIMARY KEY, title TEXT, image TEXT, latitude REAL, longitude REAL, address TEXT, is_favorite TEXT)');
        // , longitude REAL, latitude REAL, address TEXT)');
      },
      version: 1,
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    // int count = await (await DBHelper.database(table)).insert(
    //  or:
    final db = await DBHelper.database(table);
    if (db.isOpen) {
      int count = await db.insert(
        table,
        data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace,
      );
      print('#MAIN_TAG.insert() -> sqlDb.insert -> id: $count');
    } else {
      log('## [E] DBHelper.insert() Database is not Open');
    }
  }

  /// Method for getting data from database. Return the loaded data as 
  /// a [List<Map<String, dynamic>>].
  /// 
  /// `where` is the optional WHERE clause to apply when loading the data.
  /// Passing null will loading all rows.
  ///
  /// You may include '?'s in the where clause, which will be replaced by the
  /// values from `whereArgs` 
  /// e.g. `where: "id = ?, name = ?"`(here 'id' and 'name' is names of the colunms), 
  /// and then `whereArgs: [place.id, place.name]`
  /// or directly `where: "id = \"$place.id\"", "id = \"$place.name\""`
  ///
  /// `conflictAlgorithm` (optional) specifies algorithm to use in case of a
  /// conflict. See [ConflictAlgorithm] docs for more details
  static Future<List<Map<String, dynamic>>> getData(
    String table, {
    String orderBy,
    String where,
    List<String> whereArgs,
  }) async {
    List<Map<String, dynamic>> _loadedData;
    final db = await DBHelper.database(table);
    if (db.isOpen) {
      _loadedData = await db.query(
        table,
        orderBy: orderBy,
        where: where,
        whereArgs: whereArgs,
      );
    } else {
      log('## [E] DBHelper.getData() Database is not Open');
    }
    return _loadedData;
  }

  /// Method for updating rows in the database. Returns
  /// the number of changes made
  ///
  /// Update `table` with `values`, a map from column names to new column
  /// values. null is a valid value that will be translated to NULL.
  ///
  /// `where` is the optional WHERE clause to apply when updating.
  /// Passing null will update all rows.
  ///
  /// You may include '?'s in the where clause, which will be replaced by the
  /// values from `whereArgs`
  /// e.g. `where: "id = ?, name = ?"`(here 'id' and 'name' is names of the colunms), 
  /// and then `whereArgs: [place.id, place.name]`
  /// or directly `where: "id = \"$place.id\"", "id = \"$place.name\""`
  ///
  /// `conflictAlgorithm` (optional) specifies algorithm to use in case of a
  /// conflict. See [ConflictAlgorithm] docs for more details
  ///
  /// ```
  /// int count = await db.update(tableTodo, todo.toMap(),
  ///    where: '$columnId = ?', whereArgs: [todo.id]);
  /// ```
  static Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String whereIs,
    List<dynamic> whereArgs,
    ConflictAlgorithm conflictAlgorithm = sql.ConflictAlgorithm.replace,
  }) async {
    int count;
    final db = await DBHelper.database(table);
    if (db.isOpen) {
      count = await db.update(
        table,
        data,
        where: whereIs,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm,
      );
      // ,
      //     where: '$columnId = ?', whereArgs: [todo.id]);
    }
    return count;
  }

  /// Method for deleting rows in the database.
  ///
  /// Delete from `table`
  ///
  /// `where` is the optional WHERE clause to apply when updating. Passing null
  /// will update all rows.
  ///
  /// You may include '?'s in the where clause, which will be replaced by the
  /// values from `whereArgs`
  /// e.g. `where: "id = ?, name = ?"`(here 'id' and 'name' is names of the colunms), 
  /// and then `whereArgs: [place.id, place.name]`
  /// or directly `where: "id = \"$place.id\"", "id = \"$place.name\""`
  ///
  /// Returns the number of rows affected if a whereClause is passed in, 0
  /// otherwise. To remove all rows and get a count, pass '1' as the
  /// whereClause.
  /// ```
  ///  int count = await db.delete(tableTodo, where: 'columnId = ?', whereArgs: [id]);
  /// ```
  Future<int> delete(String table,
      {String where, List<dynamic> whereArgs}) async {
    int count = 0;

    return count;
  }

  /// This is a helper to query a table and return the items found. All optional
  /// clauses and filters are formatted as SQL queries
  /// excluding the clauses' names.
  ///
  /// `table` contains the table names to compile the query against.
  ///
  /// `distinct` when set to true ensures each row is unique.
  ///
  /// The `columns` list specify which columns to return. Passing null will
  /// return all columns, which is discouraged.
  ///
  /// `where` filters which rows to return. Passing null will return all rows
  /// for the given URL. '?'s are replaced with the items in the
  /// `whereArgs` field.
  /// e.g. `where: "id = ?, name = ?"`(here 'id' and 'name' is names of the colunms), 
  /// and then `whereArgs: [place.id, place.name]`
  /// or directly `where: "id = \"$place.id\"", "id = \"$place.name\""`
  ///
  /// `groupBy` decalres how to group rows. Passing null
  /// will cause the rows to not be grouped.
  ///
  /// `having` declares which row groups to include in the cursor,
  /// if row grouping is being used. Passing null will cause
  /// all row groups to be included, and is required when row
  /// grouping is not being used.
  ///
  /// `orderBy` decalres how to order the rows,
  /// Passing null will use the default sort order,
  /// which may be unordered.
  ///
  /// `limit` Limits the number of rows returned by the query,
  ///
  /// `offset` specifies the starting index,
  /// ```
  ///  List<Map> maps = await db.query(tableTodo,
  ///      columns: ['columnId', 'columnDone', 'columnTitle'],
  ///      where: 'columnId = ?',
  ///      whereArgs: [id]);
  /// ```
  //              |
  //              V    
  // Future<List<Map<String, dynamic>>> query(String table,
  //     {bool distinct,
  //     List<String> columns,
  //     String where,
  //     List<dynamic> whereArgs,
  //     String groupBy,
  //     String having,
  //     String orderBy,
  //     int limit,
  //     int offset}) {}

  /// Execute an SQL query with no return value
  ///
  /// ```
  ///   await db.execute(
  ///   'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
  /// ```
  // Future<void> execute(String sql, [List<dynamic> arguments]) {}

  /// Close the database. Cannot be accessed anymore
  // Future<void> close() {}

  /// Executes a raw SQL SELECT query and returns a list
  /// of the rows that were found.
  ///
  /// ```
  /// List<Map> list = await database.rawQuery('SELECT * FROM Test');
  /// ```
  // Future<List<Map<String, dynamic>>> rawQuery(String sql,
  //     [List<dynamic> arguments]) {}

  /// Executes a raw SQL UPDATE query and returns
  /// the number of changes made.
  ///
  /// ```
  /// int count = await database.rawUpdate(
  ///   'UPDATE Test SET name = ?, value = ? WHERE name = ?',
  ///   ['updated name', '9876', 'some name']);
  /// ```
  // Future<int> rawUpdate(String sql, [List<dynamic> arguments]) {}
}
