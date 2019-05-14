//
// Created by dyf on 2018/9/7.
// Copyright (c) 2018 dyf.
//

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../eth_token_grab/EthTokenholdingsModel.dart';
export '../eth_token_grab/EthTokenholdingsModel.dart';

class EthTokenholdingsProvider {
  static EthTokenholdingsProvider _instance;

  static EthTokenholdingsProvider get shared {
    if (_instance == null) {
      _instance = new EthTokenholdingsProvider();
    }
    return _instance;
  }

  Database _db;
  String _dbName = "eth_tokholdings.db";
  String _table = "tokholdings";

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
            address varchar(50) unique not null, 
            imgUrl varchar(100)
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

  Future<int> insert(EthTokenholdingsModel m) async {
    bool ret = await _hasAddress(m.address);
    if (!ret) { 
      return await _db.insert(_table, m.toMap());
    } else {
      return update(m);
    }
  }

  Future<int> update(EthTokenholdingsModel m) async {
    return await _db.update(_table,
      m.toMap(), 
      where: "address = ?", 
      whereArgs: [m.address.toLowerCase()]
    );
  }

  Future<int> delete(String address) async {
    return await _db.delete(_table, 
      where: "address = ?", 
      whereArgs: [address]
    );
  }

  Future<String> getImgUrl(String address) async {
    List<Map> maps = await _db.query(_table,
      columns: ["imgUrl"],
      where: "address = ?", 
      whereArgs: [address]
    );
    if (maps.length > 0) {
      return maps.first["imgUrl"];
    }
    return null;
  }

  Future<EthTokenholdingsModel> getModel(String address) async {
    List<Map> maps = await _db.query(_table,
      columns: ["address", "imgUrl"], 
      where: "address = ?", 
      whereArgs: [address]
    );
    if (maps.length > 0) {
      return new EthTokenholdingsModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<EthTokenholdingsModel>> getModels() async {
    List<Map> maps = await _db.query(_table,
      columns: ["address", "imgUrl"]
    );
    if (maps != null && maps.length > 0) {
      List<EthTokenholdingsModel> models = new List();
      for (var i = 0; i < maps.length; i++) {
        Map map = maps.elementAt(i);
        var m = EthTokenholdingsModel.fromMap(map);
        models.add(m);
      }
      return models;
    }
    return null;
  }

  Future close() async => await _db.close();
}
