import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jazzicon/jazziconshape.dart';
import 'package:jazzicon/jazzicon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  JazziconData? jd;

  List<String> addresslist=[
    "0x85CddC7f65410E9Cb94D959Ac57405ee0EcBFBE3",
    "0x576C3F273bE7d218A6Eb040D421b51237945ce10",
    "0xEB8D9FDcf121bbae84c4E91aE47E9348c367c7F4",
    "0xb9bd886414b2d37b73c1266ebcb9d7f5fdb7383b",
    "0xb934F4294Df760290e969F355C107752400150bB",
    "0x318406407ea60F2E1C305bEd64Fb4A9db72AA6bD",
    "0x07Becc171101448476ABF27C1f73989F945A0742",
    "0xfe3526e15Bd6dAD0796B84bEb548b603B6B6E444",
  ];

  List<JazziconData> jdlist=[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // jd = Jazzicon.getJazziconData(200, address: "0x85CddC7f65410E9Cb94D959Ac57405ee0EcBFBE3");
    addresslist.forEach((address) {
      jdlist.add(Jazzicon.getJazziconData(160, address: address));
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: jdlist.map((e){
            return Jazzicon.getIconWidget(e);
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}
