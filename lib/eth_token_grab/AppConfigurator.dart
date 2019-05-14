//
// Created by dyf on 2018/9/7.
// Copyright (c) 2018 dyf.
//

import 'dart:io';
import 'package:flutter/material.dart';

class AppConfigurator {
  final String name;
  
  static final Map<String, AppConfigurator> _cache = 
    <String, AppConfigurator>{};
  
  factory AppConfigurator(String name) {
    if (_cache.containsKey(name)) {
      return _cache[name];
    } else {
      final inst = AppConfigurator._internal(name);
      _cache[name] = inst;
      return inst;
    }
  }

  AppConfigurator._internal(this.name);

  TargetPlatform _getTargetPlatform() {
    var targetPlatform = TargetPlatform.iOS;
    if (Platform.isAndroid) {
      targetPlatform = TargetPlatform.android;
    }
    return targetPlatform;
  }
  
  TextTheme _getBlackTextTheme() {
    return Typography(platform: _getTargetPlatform()).black;
  }

  AppBar createAppBar({Widget title, bool autoImplyLeading: true, List<Widget> actions}) {
    return new AppBar(
      title: title,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.black
      ), 
      textTheme: _getBlackTextTheme(),
      elevation: 1.0,
      brightness: Brightness.light,
      automaticallyImplyLeading: autoImplyLeading,
      actions: actions,
    );
  }
}
