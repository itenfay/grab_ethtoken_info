import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../eth_token_grab/EthTokenModel.dart';

class EthTokensProvider {
  static EthTokensProvider _instance;
  
  static EthTokensProvider get shared { 
    if (_instance == null) {
      _instance = new EthTokensProvider();
    }
    return _instance;
  }

  Database _db;
  String _dbName = "eth_tokinfor.db";
  String _table = "tokinf";
  
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
      onCreate: (Database db, int version) async {
        await db.execute('''
          create table if not exists $_table(
            id integer primary key autoincrement, 
            address varchar(50) unique not null, 
            name varchar(40), 
            symbol varchar(10), 
            balance varchar(50), 
            value varchar(50), 
            isShown integer default 0
          );'''
        );
    });
    return _db.isOpen;
  }

  Future<bool> _hasAddress(String address) async {
    List<Map> maps = await _db.query(_table, 
      columns: ["address"], 
      where: "address = ?",
      whereArgs: [address]
    );
    return maps.length > 0 ? true : false;
  }

  Future<int> insert(EthTokenModel m) async {
    bool ret = await _hasAddress(m.address);
    if (!ret) {
      return await _db.insert(_table, m.toMap());
    } else {
      return await update(m);
    }
  }

  Future<int> update(EthTokenModel m) async {
    return await _db.update(_table, 
      m.toMap(), 
      where: "address = ?", 
      whereArgs: [m.address]
    );
  }

  Future<int> updateFlag(String address, bool state) async {
    return await _db.update(_table,
      {"isShown": state ? 1 : 0}, 
      where: "address = ?", 
      whereArgs: [address]
    );
  }

  Future<int> delete(EthTokenModel m) async {
    return await _db.delete(_table,
      where: "address = ?", 
      whereArgs: [m.address]
    );
  }

  Future<bool> getFlag(String address) async {
    List<Map> maps = await _db.query(_table, 
      columns: ["isShown"], 
      where: "address = ?", 
      whereArgs: [address]
    );
    if (maps.length > 0) {
      return maps.first["isShown"] == 1;
    }
    return false;
  }

  Future<EthTokenModel> getModel(String address) async {
    List<Map> maps = await _db.query(_table,
      columns: ["address", "name", "symbol", "balance", "value", "isShown"], 
      where: "address = ?", 
      whereArgs: [address]
    );
    if (maps.length > 0) {
      return new EthTokenModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<EthTokenModel>> getModels() async {
    List<Map> maps = await _db.query(_table,
      columns: ["address", "name", "symbol", "balance", "value", "isShown"]
    );
    if (maps.length > 0) {
      List<EthTokenModel> models = new List();
      for (var i = 0; i < maps.length; i++) {
        Map map = maps[i];
        models.add(EthTokenModel.fromMap(map));
      }
      return models;
    }
    return null;
  }

  Future close() async => await _db.close();
}
