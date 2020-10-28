import 'package:flutter/material.dart';
import 'package:polka_wallet/store/app.dart';

class NFTPage extends StatefulWidget {
  NFTPage(this.store);

  static const String route = '/acala/nft';
  final AppStore store;

  @override
  _NFTPageState createState() => _NFTPageState();
}

class _NFTPageState extends State<NFTPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('NFTs'), centerTitle: true),
      body: SafeArea(
        child: ListView(
          children: [
            Text('my nfts'),
          ],
        ),
      ),
    );
  }
}
