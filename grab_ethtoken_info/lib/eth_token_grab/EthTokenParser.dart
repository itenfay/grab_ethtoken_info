import 'dart:async';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import './EthTokenModel.dart' show EthTokenModel;
import '../db/EthTokensProvider.dart';
import './ExtendedUtility.dart';

class EthTokenParser {
  static const _aTag = "token";
  static const _bTag = "br";
  static const _cTag = "[spam]";

  static Future<bool> parse(String input) async {
    var document = html.parse(input);

    var e = document.getElementById("balancelist");
    if (e != null) {
      var aList = e.getElementsByTagName("a");

      for (var i = 0; i < aList.length; i++) {
        var el = aList.elementAt(i);

        EthTokenModel m = new EthTokenModel();
        
        String address = _parseAddress(el);
        m.address = address.toLowerCase();
        
        var name = _parseName(el);
        m.name = name;

        var value = _parseValue(el);
        m.value = value;

        var sb = _parseSymbolAndBalance(el);
        var sbList = sb.split(" ");
        
        var symbol = sbList.last;
        //print("symbol: $symbol");
        m.symbol = symbol;
        
        var balance = sbList.first;
        // print("balance: $balance");
        m.balance = balance;

        if (m.address != null && m.address.isNotEmpty) {
          final ethTP = EthTokensProvider.shared;
          m.isShown = await ethTP.getFlag(m.address);
          ethTP.insert(m);
        }
      }
    }

    return true;
  }

  /// e.g.: https://etherscan.io/token/0xe41d2489571d322189246dafa5ebde1f4699f498
  static parseIconUrl(String baseUrl, String input) {
    var dom = html.parse(input);
    var breadcrumbs = dom.getElementsByClassName("breadcrumbs");
    if (breadcrumbs != null && breadcrumbs.isNotEmpty) {
      var e = breadcrumbs.first;
      var nodeList = e.getElementsByTagName("img");
      if (nodeList != null && nodeList.isNotEmpty) {
        var imgurl = nodeList.first.attributes["src"];
        imgurl = baseUrl + imgurl;
        // print("imgurl: $imgurl");
        return imgurl;
      }
    }
    return null;
  }

  static _parseAddress(Element e) {
    var href = e.attributes["href"];
    List addrList = href.split(new RegExp("[\/\?]"));
    for (var i = 0; i < addrList.length; i++) {
      var e = addrList.elementAt(i);
      if (eo.isEqual(e, _aTag) && (i + 1) < addrList.length) {
        var address = addrList.elementAt(i + 1);
        // print("address: $address");
        return address;
      }
    }
    return null;
  }

  static _parseValue(Element e) {
    var valueList = e.getElementsByClassName("pull-right");
    if (valueList != null && valueList.isNotEmpty) {
      var value = valueList.first.innerHtml;
      if (!eo.isEqual(value, _cTag)) {
        // print("value: $value");
        return value;
      }
    }
    return null;
  }

  static _parseName(Element e) {
    var inh = e.innerHtml;

    var inhList = inh.split(new RegExp("[\<\>]"));
    // print("inhList: $inhList");
    if (inhList != null && inhList.isNotEmpty) {
      var name = inhList.first;
      if (name.isEmpty) {
        var nameList = e.getElementsByClassName("liH");
        if (nameList != null && nameList.isNotEmpty) {
          name = nameList.first.innerHtml;
        }
      }
      // print("name: $name");
      return name;
    }

    return null;
  }

  static _parseSymbolAndBalance(Element e) {
    var inh = e.innerHtml;

    var inhList = inh.split(new RegExp("[\<\>]"));
    for (var i = 0; i < inhList.length; i++) {
      var e = inhList.elementAt(i);
      if (eo.isEqual(e, _bTag) && (i + 1) < inhList.length) {
        var symbolAndBalance = inhList.elementAt(i + 1);
        // print("symbolAndBalance: $symbolAndBalance");
        return symbolAndBalance;
      }
    }

    return null;
  }
}
