import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/goPageBtn.dart';
import 'package:polka_wallet/common/components/linkTap.dart';
import 'package:polka_wallet/page/assets/signal/signalDetailPage.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class SignalPage extends StatefulWidget {
  SignalPage(this.store);

  static final String route = '/assets/signal';
  final AppStore store;

  @override
  _SignalPageState createState() => _SignalPageState(store);
}

class _SignalPageState extends State<SignalPage> {
  _SignalPageState(this.store);

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).assets;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['signal.tokens'])
      ),
      body: SafeArea(
        child: Builder(
          builder: (BuildContext context) {
            return ListView(
              shrinkWrap: true, 
              padding: const EdgeInsets.only(top:30,bottom: 20,left: 20,right: 20),
              children: <Widget>[
                Center(
                  child: Text(
                    dic['signal.welcome'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26 
                    ),
                  )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Icon(
                    Icons.thumb_up,
                    size: 100
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Container(),
                      ),
                      Expanded(
                        child: Image.asset(
                          'assets/images/assets/DOT.png',
                          width: 40,
                          height: 40,
                        )
                      ),
                      Expanded(
                        child: Image.asset(
                          'assets/images/assets/FIR.png',
                          width: 40,
                          height: 40,
                        )
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(),
                      ),
                    ]
                  )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    dic['signal.instruction'],
                    textAlign: TextAlign.center,
                  ),
                ),
                linkTap(
                  dic['signal.what'],
                  onTap: (){}
                ),
                linkTap(
                  dic['signal.how'],
                  onTap: (){}
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    dic['signal.warning'],
                    textAlign: TextAlign.center,
                  ),
                ),
                linkTap(
                  dic['signal.how.iota'],
                  onTap: (){}
                ),
              ]
            );
          }
        )
      ),
      bottomNavigationBar: ListTile(
        contentPadding: const EdgeInsets.only(left: 10,right: 10,bottom: 30),
        title: Row(children: <Widget>[
          Icon(Icons.chevron_left),
          goPageBtn(
            dic['back'],
            textAlign: TextAlign.left,
            onTap: () => Navigator.pop(context),
          ),
          goPageBtn(
            dic['understand'],
            onTap: () => Navigator.pushNamed(context, SignalDetailPage.route),
          ),
          Icon(Icons.chevron_right)
        ])
      )
    );
  }
}

void _tapRule(){
  
}