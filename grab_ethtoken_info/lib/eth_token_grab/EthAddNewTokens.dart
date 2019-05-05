import 'package:flutter/material.dart';

import './EthTokenModel.dart';
import './ExtendedUtility.dart';
import './AppConfigurator.dart';

import '../db/EthTokensProvider.dart';
import '../db/EthTokenholdingsProvider.dart';

class EthAddNewTokensView extends StatefulWidget {
  final List _dataSource = [];
  
  @override
  _EthAddNewTokensState createState() => _EthAddNewTokensState();
}

class _EthAddNewTokensState extends State<EthAddNewTokensView> {
  Map<String, dynamic> _map = new Map();

  @override
  void initState() {
    super.initState();
    _initDataSource();
  }
  
  void _initDataSource() async {
    List data = await EthTokensProvider.shared.getModels();
    setState(() {
      widget._dataSource.addAll(data);
    });
    _initMap();
  }

  void _initMap() async {
    final ethTHP = EthTokenholdingsProvider.shared;
    List data = await ethTHP.getModels();
    setState(() {
      for (int i = 0; i < data.length; i++) {
        EthTokenholdingsModel m = data.elementAt(i);
        _map["${m.address}"] = m.imgUrl;   
        bool ret = new ExtendedString(m.imgUrl).isEthereum();
        if (ret) {
          _addEthereum(m.address);
        }
      }
    });
    _checkLastFromDataSource();
  }
  
  void _addEthereum(String address) async {
    final ethTP = EthTokensProvider.shared;
    
    EthTokenModel tok = new EthTokenModel();
    tok.address = address;
    tok.name = "Ethereum";
    tok.symbol = "ETH";
    tok.isShown = await ethTP.getFlag(address); 
    
    ethTP.insert(tok);
        
    setState(() {
      widget._dataSource.insert(0, tok);
    });
  }

  void _checkLastFromDataSource() {
    EthTokenModel m = widget._dataSource.last;
    String name = m.name.toLowerCase();
    bool ret = ExtendedString(name).isEthereum();
    if (ret) {
      setState(() {
        widget._dataSource.removeLast();
      });
    }
  }

  Widget build(BuildContext context) {
    return _createscaffold();
  }

  Scaffold _createscaffold() {
    return new Scaffold(
      appBar: _createAppBar(),
      body: _getBody(),
    );
  }

  EthTokenModel _getTokenModel(int index) {
    return widget._dataSource[index];
  }

  AppBar _createAppBar() {
    return AppConfigurator('UI').createAppBar(
      title: new Text(
        "添加新资产", 
        style: new TextStyle(fontSize: 18.0)
      )
    );
  }

  Widget _getBody() {
    return new Container(
      padding: EdgeInsets.only(
        left: .0,
        top: 5.0,
        right: .0,
        bottom: isXSeries(context) ? 34.0 : 0.0,
      ),
      child: _createListView(),
    );
  }

  Widget _createListView() {
    return new ListView.builder(
      padding: EdgeInsets.only(
        left: .0,
        top: 5.0,
        right: .0,
        bottom: .0
      ),
      itemCount: widget._dataSource.length * 2,
      itemBuilder: (ctx, i) {
        if (i.isOdd) return new Divider(indent: 15.0);

        final index = i ~/ 2;

        return _buildRow(index);
      },
    );
  }

  Widget _buildRow(int index) { 
    return new Container(
      child: _createTokenInfoRow(index)
    );
  }
  
  Row _createTokenInfoRow(int index) {
    return new Row(
      children: [
        new Container(
          padding: new EdgeInsets.only(left: 10.0),
          child: _createToKenImageCard(index),
        ),
        _createTextSection(index),
        _createSwitchContainer(index)
      ],
    );
  }

  Card _createToKenImageCard(int index) {
    return new Card(
      shape: CircleBorder(),
      // color: Colors.grey[400], 
      child: new Container(
        padding: EdgeInsets.all(15.0),
        child: _createTokenImage(index),
      )
    );
  }

  Image _createTokenImage(int index) {
    var m = _getTokenModel(index);
    
    var imgUrl = _map["${m.address}"];
    if (imgUrl != null && imgUrl.isNotEmpty) {
      return new Image.network(imgUrl, 
        width: 20.0, 
        height: 20.0, 
        fit: BoxFit.cover
      );
    } else {
      return new Image.asset(
        "images/Default_64x64.png", 
        width: 20.0, 
        height: 20.0, 
        fit: BoxFit.cover
      );
    }
  }

  Expanded _createTextSection(int index) {
    return new Expanded(
      child: _createColumnForTextSection(index),
    );
  }

  Column _createColumnForTextSection(int index) {
    final model = _getTokenModel(index);
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        new Container(
          padding: EdgeInsets.only(
            left: 10.0, 
            top: 5.0, 
            right: 10.0, 
            bottom: 2.0
          ),
          child: new Text(
            model.symbol ?? "?", 
            style: new TextStyle(color: Colors.black, fontSize: 16.0),
          ),
        ),

        new Container(
          padding: EdgeInsets.only(
            left: 10.0, 
            top: .0, 
            right: 10.0, 
            bottom: 2.0
          ),
          child: new Text(
            model.name ?? "?",
            style: new TextStyle(color: Colors.grey, fontSize: 14.0),
          ),
        ),

        new Container(
          padding: EdgeInsets.only(
            left: 10.0, 
            top: .0, 
            right: 10.0, 
            bottom: 5.0
          ),
          child: new Text(
            ExtendedString.init(model.address).truncate(8),
            style: new TextStyle(color: Colors.grey, fontSize: 14.0),
          ),
        )
      ],
    );
  }

  Container _createSwitchContainer(int index) {
    var m = _getTokenModel(index);
    return new Container(
      padding: EdgeInsets.only(
        left: 0.0,
        top: .0,
        right: 5.0,
        bottom: .0
      ),
      child: new Switch(
        value: m.isShown,
        activeColor: Colors.greenAccent[400],
        activeTrackColor: Colors.greenAccent[400], 
        onChanged: (bool newValue) {
          final ethTP = EthTokensProvider.shared;
          setState(() {
            ethTP.updateFlag(m.address, m.isShown = newValue);
          });
        }
      ),
    );
  }
}
