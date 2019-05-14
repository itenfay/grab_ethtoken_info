//
// Created by dyf on 2018/9/7.
// Copyright (c) 2018 dyf.
//

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;

import './EthTokenholdingsModel.dart';
import '../db/EthTokenholdingsProvider.dart';

class EthTokenholdingsParser {
  static void parse(String input, String address) {
    dom.Document docm = html.parse(input);
   
    List<dom.Element> tbodyList = docm.getElementsByTagName("tr");
    // print("tbodyList: ${tbodyList.length}");
    for (var i = 0; i < tbodyList.length; i++) {
      EthTokenholdingsModel m = new EthTokenholdingsModel();
      
      var e = tbodyList.elementAt(i);

      List<dom.Element> addressList = e.getElementsByClassName("hex address-tag");
      if (addressList != null && addressList.isNotEmpty) {
        List<dom.Element> aList = addressList.first.getElementsByTagName("a");
        if (aList != null && aList.isNotEmpty) {
          String address = aList.first.innerHtml;
          // print("address: $address");
          m.address = address.toLowerCase();
        }
      }

      List<dom.Element> imgList = e.getElementsByTagName("img");
      if (imgList != null && imgList.isNotEmpty) {
        String baseUrl = "https://etherscan.io";
        var src = imgList.first.attributes["src"];
        String imgUrl = baseUrl + src;
        print("imgUrl: $imgUrl");
        m.imgUrl = imgUrl;
        if (imgUrl.contains("ethereum")) {
          m.address = address;
        }
      }

      if (m.address != null && m.address.isNotEmpty) {
        EthTokenholdingsProvider.shared.insert(m);
      } 
    }
  }
}
