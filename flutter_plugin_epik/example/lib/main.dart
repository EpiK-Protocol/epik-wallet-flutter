import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:epikplugin/epikplugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await EpikPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              MaterialButton(
                minWidth: double.infinity,
                padding: EdgeInsets.all(15),
                child: Text("创建助记词\n$newMnemonic"),
                onPressed: () {
                  HD.newMnemonic().then((str) {
                    setState(() => newMnemonic = str);
                  });
                },
              ),
              MaterialButton(
                minWidth: double.infinity,
                padding: EdgeInsets.all(15),
                child: Text(
                    "助记词生成种子\n${seedFromMnemonic == null ? "" : base64Encode(seedFromMnemonic)}"),
                onPressed: () {
                  if (newMnemonic == null) return;

                  HD.seedFromMnemonic(newMnemonic).then((seed) {
                    setState(() => seedFromMnemonic = seed);
                  });
                },
              ),
              MaterialButton(
                minWidth: double.infinity,
                padding: EdgeInsets.all(15),
                child: Text(
                    "生成随机种子\n${newSeed == null ? "" : base64Encode(newSeed)}"),
                onPressed: () {
                  HD.newSeed().then((seed) {
                    setState(() => newSeed = seed);
                  });
                },
              ),
              MaterialButton(
                minWidth: double.infinity,
                padding: EdgeInsets.all(15),
                child: Text(
                    "助记词创建钱包\nhashcode=${walletnewFromMnemonic?.hashCode}"),
                onPressed: () {
                  if (newMnemonic != null)
                    HD.newFromMnemonic(newMnemonic).then((hdwallet) {
                      setState(() => walletnewFromMnemonic = hdwallet);
                    });
                },
              ),
              MaterialButton(
                minWidth: double.infinity,
                padding: EdgeInsets.all(15),
                child:
                    Text("随机种子创建钱包\nhashcode=${walletnewFromSeed?.hashCode}"),
                onPressed: () {
                  if (newSeed != null)
                    HD.newFromSeed(newSeed).then((hdwallet) {
                      setState(() => walletnewFromSeed = hdwallet);
                    });
                },
              ),

              MaterialButton(
                minWidth: double.infinity,
                padding: EdgeInsets.all(15),
                child: Text(
                    "设置HdWallet RPC地址 \nurl = ${hdwallet_rpc}"),
                onPressed: () {
                  if (walletnewFromMnemonic != null) {
                    String rpcUrl = "https://mainnet.infura.io/v3/1bbd25bd3af94ca2b294f93c346f69cd";
                    walletnewFromMnemonic
                        .setRPC(rpcUrl)
                        .then((_) {
                      setState(() => hdwallet_rpc=rpcUrl);
                    });
                  }
                },
              ),

              MaterialButton(
                minWidth: double.infinity,
                padding: EdgeInsets.all(15),
                child: Text(
                    "生成ETH子钱包\nETH path = ${hdwallet_eth_path}\nETH addrss = ${hdwallet_eth_address}"),
                onPressed: () {
                  if (walletnewFromMnemonic != null) {
                    hdwallet_eth_path = Bip44Path.getPath("ETH");
                    walletnewFromMnemonic
                        .derive(hdwallet_eth_path)
                        .then((address) {
                      setState(() => hdwallet_eth_address = address);
                    });
                  }
                },
              ),


              MaterialButton(
                minWidth: double.infinity,
                padding: EdgeInsets.all(15),
                child: Text(
                    "ETH 余额\n${hdwallet_eth_balance}"),
                onPressed: () {
                  if (walletnewFromMnemonic != null) {
                    setState(() {
                      hdwallet_eth_balance="loading...";
                    });
                    walletnewFromMnemonic
                        .balance(hdwallet_eth_address)
                        .then((balance) {
                      setState(() => hdwallet_eth_balance = balance);
                    });
                  }

                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String newMnemonic;
  Uint8List newSeed, seedFromMnemonic;
  HdWallet walletnewFromMnemonic, walletnewFromSeed;
  String hdwallet_rpc;
  String hdwallet_eth_path, hdwallet_eth_address, hdwallet_eth_balance;
}
