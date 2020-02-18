import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/i18n/index.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Receive extends StatelessWidget {
  Receive(this.store);

  final AccountStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(I18n.of(context).assets['receive']),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Stack(
            alignment: AlignmentDirectional.topCenter,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 32),
                child: Image.asset('assets/images/assets/sweep_code_line.png'),
              ),
              Container(
                margin: EdgeInsets.only(top: 40),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.all(const Radius.circular(4)),
                  color: Colors.white,
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16),
                      child:
                          Image.asset('assets/images/assets/Assets_nav_0.png'),
                    ),
                    Text(
                      store.currentAccount.name,
                      style: Theme.of(context).textTheme.display4,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 4, color: Colors.pinkAccent),
                        borderRadius:
                            BorderRadius.all(const Radius.circular(8)),
                      ),
                      margin: EdgeInsets.fromLTRB(48, 24, 48, 24),
                      child: QrImage(
                        data: store.currentAccount.address,
                        size: 200,
//                        embeddedImage:
//                            AssetImage('assets/images/public/About_logo.png'),
//                        embeddedImageStyle:
//                            QrEmbeddedImageStyle(size: Size(40, 40)),
                      ),
                    ),
                    Container(
                      width: 160,
                      child: Text(store.currentAccount.address),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 32),
                      child: RaisedButton(
                        color: Colors.pinkAccent,
                        child: Text(
                          I18n.of(context).assets['copy'],
                          style: Theme.of(context).textTheme.button,
                        ),
                        onPressed: () => UI.copyAndNotify(
                            context, store.currentAccount.address),
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
