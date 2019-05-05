/// Defines a model for the token holdings.
class EthTokenholdingsModel {
  String address;
  String imgUrl;

  EthTokenholdingsModel({
    this.address, 
    this.imgUrl
  });

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (address != null && address.isNotEmpty) {
      map["address"] = address.toLowerCase();
    }
    if (imgUrl != null && imgUrl.isNotEmpty) {
      map["imgUrl"] = imgUrl;
    }
    return map;
  }

  EthTokenholdingsModel.fromMap(Map<String, dynamic> map) {
    address = map["address"];
    imgUrl = map["imgUrl"];
  }
}
