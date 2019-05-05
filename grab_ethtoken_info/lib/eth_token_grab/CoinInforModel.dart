/// Defines a model for the coin.
@Deprecated('Please Use EthTokenholdingsModel')
class CoinInforModel {
  String name;
  String symbol;
  String imgUrl;

  CoinInforModel({
    this.name, 
    this.symbol, 
    this.imgUrl
  });

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (name != null && name.isNotEmpty) {
      map["name"] = name;
    }
    if (symbol != null && symbol.isNotEmpty) {
      map["symbol"] = symbol;
    }
    if (imgUrl != null && imgUrl.isNotEmpty) {
      map["imgUrl"] = imgUrl;
    }
    return map;
  }

  CoinInforModel.fromMap(Map<String, dynamic> map) {
    name = map["name"];
    symbol = map["symbol"];
    imgUrl = map["imgUrl"];
  }
}
