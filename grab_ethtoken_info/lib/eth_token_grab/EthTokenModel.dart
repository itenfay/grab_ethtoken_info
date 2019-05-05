/// Defines a model for the token.
class EthTokenModel {
  // The address for the token.
  String address;

  // The name for the token.
  String name;

  // The balance for the token.
  String balance;

  // The symbol for the token.
  String symbol;

  // The value for the token.
  String value;

  // The state for the token.
  bool isShown;

  // Constructor
  EthTokenModel({
    this.address, 
    this.name, 
    this.balance, 
    this.symbol, 
    this.value, 
    this.isShown
  });

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    
    if (address != null && address.isNotEmpty) {
      map["address"] = address.toLowerCase();
    }
    if (name != null && name.isNotEmpty) {
      map["name"] = name;
    }
    if (balance != null && balance.isNotEmpty) {
      map["balance"] = balance;
    }
    if (symbol != null && symbol.isNotEmpty) {
      map["symbol"] = symbol;
    }
    if (value != null && value.isNotEmpty) {
      map["value"] = value;
    }
   
    map["isShown"] = this.isShown == true ? 1 : 0;
    
    return map;
  }

  EthTokenModel.fromMap(Map<String, dynamic> map) {
    address = map["address"];
    name = map["name"];
    balance = map["balance"];
    symbol = map["symbol"];
    value = map["value"];
    isShown = map["isShown"] == 1;
  }
}
