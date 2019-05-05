import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../eth_token_grab/CoinInforModel.dart' show CoinInforModel;

@Deprecated('Please use EthTokenholdingsProvider')
class CoinInforProvider {
  static CoinInforProvider _instance;

  static CoinInforProvider get shared {
    if (_instance == null) {
      _instance = new CoinInforProvider();
    }
    return _instance;
  }

  Database _db;
  String _dbName = "coinInf.db";
  String _table = "coinInf";

  Future<String> _getDatabasePath() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);
    return path;
  }

  Future<bool> open() async {
    String path = await _getDatabasePath();
    print("db path: $path");  
    _db = await openDatabase(path, 
      version: 1, 
      onCreate: (Database db, int version ) async {
        await db.execute('''
          create table if not exists $_table(
            id integer primary key autoincrement, 
            name varchar(40), 
            symbol varchar(10), 
            imgUrl varchar(100)
          );'''
        );
    });
    return _db.isOpen;
  }

  Future<bool> _hasCoinName(String name) async {
    List<Map> maps = await _db.query(_table,
      columns: ["name"],
      where: "name = ?",
      whereArgs: [name]
    );
    return maps.length > 0 ? true : false;
  }

  Future<int> insert(CoinInforModel m) async {
    bool ret = await _hasCoinName(m.name);
    if (!ret) { 
      return await _db.insert(_table, m.toMap());
    } else {
      return update(m);
    }
  }

  Future<int> update(CoinInforModel m) async {
    return await _db.update(_table,
      m.toMap(), 
      where: "name = ?", 
      whereArgs: [m.name]
    );
  }

  Future<int> delete(String name) async {
    return await _db.delete(_table, 
      where: "name = ?", 
      whereArgs: [name]
    );
  }

  Future<CoinInforModel> getModel(String name) async {
    List<Map> maps = await _db.query(_table,
      columns: ["name", "symbol", "imgUrl"], 
      where: "name = ?", 
      whereArgs: [name]
    );
    if (maps.length > 0) {
      return new CoinInforModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<CoinInforModel>> getModels() async {
    List<Map> maps = await _db.query(_table,
      columns: ["name", "symbol", "imgUrl"]
    );
    if (maps.length > 0) {
      List<CoinInforModel> models = new List();
      for (var i = 0; i < maps.length; i++) {
        Map map = maps.elementAt(i);
        var m = CoinInforModel.fromMap(map);
        models.add(m);
      }
      return models;
    }
    return null;
  }

  Future close() async => await _db.close();
}
