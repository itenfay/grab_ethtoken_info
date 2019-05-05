import 'dart:io';
import 'package:flutter/material.dart';

/// Const constructor.
const ExtendedObject eo = const ExtendedObject();

abstract class Equation<T> {
  bool isEqual(T a, T b);
}

class ExtendedObject implements Equation {
  const ExtendedObject();
  @override
  bool isEqual(a, b) => (a == b);
}

enum TruncatedStyle {
  head, // Truncate at head of string: "...wxyz"
  tail, // Truncate at tail of string: "abcd..."
  middle, // Truncate middle of string:  "ab...yz"
}

/// [ExtendedString] convert a string into integer.
class ExtendedString {
  String _source;

  ExtendedString(String s) {
    _source = s;
  }

  ExtendedString.init(String s)
   : this(s);

  int toInt() {
    if (_source == null) return 0;
    int startIndex = _source.indexOf(new RegExp(r'[0-9]'));
    if (startIndex < 0) return 0;
    int endIndex = _source.lastIndexOf(new RegExp(r'[0-9]'));
    var input = _source.substring(startIndex, endIndex + 1);
    return int.parse(input, radix: 10);
  }

  String truncate(int reservedLength, {TruncatedStyle style: TruncatedStyle.middle}) {
    if (_source != null && _source.isNotEmpty) {
      int total = _source.length;
      if (reservedLength >= total) return _source;
      switch(style) {
        case TruncatedStyle.head:
          return _source.replaceRange(0, reservedLength, "...");
          break;

        case TruncatedStyle.tail:
          return _source.replaceRange(total - reservedLength, total, "...");
          break;

        case TruncatedStyle.middle:
        default:
          return _source.replaceRange(reservedLength, total - reservedLength, "...");
          break;
      }
    }
    return _source;
  }

  // Jadging For imgUrl.
  bool isEthereum() {
    if (_source != null && _source.isNotEmpty) {
      return _source.contains("ethereum") ? true : false;
    }
    return false;
  }
}

bool isXSeries(BuildContext ctx) {
  if (Platform.isIOS) {
    var size = MediaQuery.of(ctx).size;
    if (size.width == 375 && size.height == 812) {
      return true;
    }
  }
  return false;
}
