import 'dart:async';

import 'package:flutter/material.dart';

import './Network/http_utils.dart';
import './eth_token_grab/EthTokensDisplay.dart';
import './eth_token_grab/EthTokenParser.dart';
import './db/EthTokensProvider.dart';
import './db/EthTokenholdingsProvider.dart';
import './eth_token_grab/EthTokenholdingsDataRequest.dart';
import './eth_token_grab/EthTokenholdingsParser.dart';
import './eth_token_grab/AppConfigurator.dart';

void openTokenholdingsDB() async { 
  EthTokenholdingsProvider.shared.open().then<bool>((isOpen){
    print("EthTokenholdingsProvider isOpen: $isOpen");
  });
}

void openTokensDB() async {
  EthTokensProvider.shared.open().then<bool>((isOpen) {
    print("EthTokensProvider isOpen: $isOpen");
  });
}

// 0x71c7656ec7ab88b098defb751b7401b5f6d8976f
// 0xed60906ff7f93b20eeb719ff8c05952e121d5388

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    openTokenholdingsDB();
    openTokensDB();
  
    return new MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  String _data = "";

  void _getTokenData() {
    var baseUrl = "https://etherscan.io";
    var httpUtils = new HttpUtils.config(baseUrl: baseUrl);
    httpUtils.connectTimeout = 10;
    // httpUtils.contentType = ContentType.html;
    // 0x71c7656ec7ab88b098defb751b7401b5f6d8976f
    httpUtils.get("/address/0x71c7656ec7ab88b098defb751b7401b5f6d8976f");
    print("url: ${httpUtils.url}");
    httpUtils.listen((Response response) {
      String data = response.data;
      //print("data: $data");
      setState(() {
        _data = data;
      });
    }, (DioError error) {
      print("e: ${error.message}");
    });
  }

  void _getTokenholdingsData() async {
    String a = "0x71c7656ec7ab88b098defb751b7401b5f6d8976f";
    String data = await EthTokenholdingsDataRequest.init(a).getData();
    if (data != null && data.isNotEmpty) {
      EthTokenholdingsParser.parse(data, a);
    }
  }

  @override
  void initState() {
    super.initState();
    _getTokenData();
    _getTokenholdingsData();
  }

  void _incrementCounter() {
    // setState(() {
    //   // This call to setState tells the Flutter framework that something has
    //   // changed in this State, which causes it to rerun the build method below
    //   // so that the display can reflect the updated values. If we changed
    //   // _counter without calling setState(), then the build method would not be
    //   // called again, and so nothing would appear to happen.
    //   _counter++;
    // });
    if (_data.isNotEmpty) {
      EthTokenParser.parse(_data).then<bool>((finished){
        if (finished) {
          Navigator.push(context, _createPushRoute());
        }
      });
    } else {
      print("data is empty.");
    }
  }

  MaterialPageRoute _createPushRoute() {
    return MaterialPageRoute(builder: (context) => 
      new EthTokensDisplayView("0x71c7656ec7ab88b098defb751b7401b5f6d8976f")
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppConfigurator('UI').createAppBar(
        title: new Text(widget.title, style: new TextStyle(fontSize: 18.0),)
      ),
      // new AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: new Text(widget.title),
      // ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'You have pushed the button this many times:',
            ),
            new Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
