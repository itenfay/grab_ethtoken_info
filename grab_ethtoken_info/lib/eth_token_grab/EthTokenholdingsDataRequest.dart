import 'dart:async';

import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;

import './HtmlConverter.dart';
import './ExtendedUtility.dart';

class EthTokenholdingsDataRequest {
  String _address;

  EthTokenholdingsDataRequest(String address) {
    _address = address;
  }

  EthTokenholdingsDataRequest.init(String address)
   : this(address);

  int _getCount(String input) {
    return ExtendedString(input).toInt();
  }

  int _getRow(String input) {
    var dom = html.parse(input);
    List tbodyList = dom.getElementsByTagName("tr");
    return tbodyList.length;
  }

  int _getTotalPage(int count, int row) {
    double doub = count / row;
    int page = count ~/ row;
    if (doub > page) {
      page += 1;
    }
    return page;
  }

  String _getUrl(int page) {
    String baseUrl = "https://etherscan.io";
    var a = "&a=" + _address;
    var q = "&q=";
    var p = "&p=$page";
    var f = "&f=";
    var h = "&h=";
    var fav = "&fav=";
    var s = "&sort=total_price_usd";
    var o = "&order=desc";
    var url = baseUrl + "/tokenholdingsHandler.ashx?" + a + q + p + f + h + fav + s + o;
    return url;
  }

  String _convertToHtml(String input) {
    return new HtmlConverter.init(input).convert(isTable: true);
  }

  Future<dynamic> _doDataRequest(int p) async {
    try {
      var dio = new Dio();
      dio.options.connectTimeout = 5*1000;
      var url = _getUrl(p);
      print("url: $url");
      Response response = await dio.get(url); 
      return response;
    } on DioError catch(e) {
      return e;
    }
  }

  Future<String> getData() async {
    var ret = await _doDataRequest(1);
    if (ret is Response) {
      var data = ret.data;
      if (data != null && data is Map && data.isNotEmpty) {  
        var records = data["recordsfound"];
        
        int count = _getCount(records);
        if (count > 0) {
          var tbody = data["layout"];
          int row = _getRow(_convertToHtml(tbody));
          int page = _getTotalPage(count, row);
          
          String allData = await _getOtherData(tbody, page);
          return _convertToHtml(allData);
        }
      }
    } else {
      print("e: ${ret.toString()}");
    }

    return null;
  }

  Future<String> _getOtherData(String baseData, int p) async {
    String retData = baseData; 
  
    for (int i = 2; i < p + 1; i++) {
      var ret = await _doDataRequest(i);
      if (ret is Response) {
        var data = ret.data;
        if (data is Map) {
          var tbody = data["layout"];
          retData += tbody;
        }
      } else {
        print("e: ${ret.toString()}");
      }
    }

    return retData;
  }
}
