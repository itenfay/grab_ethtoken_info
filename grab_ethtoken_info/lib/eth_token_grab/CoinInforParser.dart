import 'package:html/parser.dart' as html;

import './CoinInforModel.dart';
import '../db/CoinInforProvider.dart';

/// From: https://coinmarketcap.com
@Deprecated("Please Use EthTokenholdingsParser")
class CoinInforParser {
  static void parse(String input) {
    var dom = html.parse(input);

    var tbodyList = dom.getElementsByTagName("tbody");
    if (tbodyList != null && tbodyList.isNotEmpty) {
      var first = tbodyList.first;
      
      var list = first.getElementsByClassName("no-wrap currency-name");
      for (var i = 0; i < list.length; i++) {        
        var element = list.elementAt(i);
        
        var m = new CoinInforModel();

        var imgList = element.getElementsByTagName("img");
        m.name = _parseName(imgList);
        m.imgUrl = _parseImgUrl(imgList);

        var symbolList = element.getElementsByClassName("link-secondary");
        m.symbol = _parseSymbol(symbolList);

        CoinInforProvider.shared.insert(m);
      }
    }
  }

  static String _parseName(List list) {
    if (list != null && list.isNotEmpty) {
      var e = list.first;
      var name = e.attributes["alt"];
      // print("name: $name");
      return name;
    }
    return null;
  }

  static String _parseImgUrl(List list) {
    if (list != null && list.isNotEmpty) {
      var e = list.first;
      var src = e.attributes["data-src"];
      if (src == null) {
        src = e.attributes["src"];
      }
      var imageurl = src.replaceAll("16x16", "64x64");
      // print("image url: $imageurl");
      return imageurl;
    }
    return null;
  }

  static String _parseSymbol(List list) {
    if (list != null && list.isNotEmpty) {
      var symbol = list.first.innerHtml;
      // print("symbol: $symbol");
      return symbol;
    }
    return null;
  }
}
