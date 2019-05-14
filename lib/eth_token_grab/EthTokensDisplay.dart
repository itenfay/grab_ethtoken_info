//
// Created by dyf on 2018/9/7.
// Copyright (c) 2018 dyf.
//

import 'package:flutter/material.dart';

import '../db/EthTokensProvider.dart';
import '../db/EthTokenholdingsProvider.dart';

import './EthTokenModel.dart';
import './EthAddNewTokens.dart';
import './ExtendedUtility.dart';
import './AppConfigurator.dart';

class EthTokensDisplayView extends StatefulWidget {
  final List _dataSource = [];
  
  final List _addresses = [];

  EthTokensDisplayView(String address) {
    _addresses.add(address);
  }
  
  @override
  _EthTokensDisplayState createState() => _EthTokensDisplayState();
}

class _EthTokensDisplayState extends State<EthTokensDisplayView> {
  Map<String, dynamic> _map = new Map();

  @override
  void initState() {
    super.initState();
    _initDataSource();
  }
  
  void _initDataSource() async {
    final ethTP = EthTokensProvider.shared;
    List data = await ethTP.getModels();
    setState(() {
      for (int i = 0; i < data.length; i++) {
        EthTokenModel m = data.elementAt(i);
        if (m.isShown) {
          String addr = widget._addresses.first;
          if (eo.isEqual(addr, m.address)) {
            if (!_hasEthereum(addr)) {
              widget._dataSource.insert(0, m);
            }
          } else {
            widget._dataSource.add(m);
          }
        } 
      }
    });
    _initMap();
  }

  void _initMap() async {
    final ethTHP = EthTokenholdingsProvider.shared;
    List data = await ethTHP.getModels();
    setState(() {
      for (int i = 0; i < data.length; i++) {
        var m = data.elementAt(i);
        _map["${m.address}"] = m.imgUrl;
      }
    });
  }

  bool _hasEthereum(String address) {
    for (EthTokenModel m in widget._dataSource) {
      if (eo.isEqual(m.address, address)) {
        return true;
      }
    }
    return false;
  }

  void _reloadData() {
    _initDataSource();
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
      title: _createTitleColumn(),
      actions: <Widget>[
        _createAddButton(),
      ],
    );
  }

  IconButton _createAddButton() {
    return new IconButton(
      icon: new Icon(Icons.add),
      iconSize: 32.0,
      onPressed: () {
        _pushAddNewTokensView();
      },
    );
  }

  void _pushAddNewTokensView() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (BuildContext context) {
        return new EthAddNewTokensView();
      })
    ).then((value) {
      _reloadData();
    });
  }

  Column _createTitleColumn() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Text(
          "我的资产", 
          style: new TextStyle(fontSize: 18.0)
        ),
        new Text(
          ExtendedString(widget._addresses.first).truncate(8), 
          style: new TextStyle(fontSize: 18.0)
        ),
      ], 
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
        _createTrailingContainer(index)
      ],
    );
  }

  Card _createToKenImageCard(int index) {
    return new Card(
      shape: CircleBorder(),
      // color: Colors.transparent, 
      child: new Container(
        padding: EdgeInsets.all(12.0),
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
            top: 10.0, 
            right: 10.0, 
            bottom: 5.0
          ),
          child: new Text(
            model.symbol ?? "", 
            style: new TextStyle(color: Colors.black, fontSize: 16.0),
          ),
        ),

        new Container(
          padding: EdgeInsets.only(
            left: 10.0, 
            top: .0, 
            right: 10.0, 
            bottom: 10.0
          ),
          child: new Text(
            ExtendedString.init(model.address).truncate(8),
            style: new TextStyle(color: Colors.grey, fontSize: 14.0),
          ),
        )
      ],
    );
  }
  
  Container _createTrailingContainer(int index) {
    return new Container(
      padding: EdgeInsets.only(
        right: 5.0
      ),
      child: _createTrailingColumn(index),
    );
  }

  Column _createTrailingColumn(int index) {
    final model = _getTokenModel(index);
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Container(
          padding: EdgeInsets.only(
            left: .0, 
            top: 10.0, 
            right: 10.0, 
            bottom: 5.0
          ),
          child: new Text(
            model.balance ?? "", 
            style: new TextStyle(color: Colors.black, fontSize: 16.0),
          ),
        ),

        new Container(
          padding: EdgeInsets.only(
            left: .0, 
            top: .0, 
            right: 10.0, 
            bottom: 10.0
          ),
          child: new Text(
            model.value ?? "",
            style: new TextStyle(color: Colors.grey, fontSize: 14.0),
          ),
        )
      ],
    );
  }
}
