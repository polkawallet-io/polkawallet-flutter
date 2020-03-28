import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/goPageBtn.dart';
import 'package:polka_wallet/common/components/linkTap.dart';
import 'package:polka_wallet/page/assets/lock/LockDetailPage.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LockPage extends StatefulWidget {
  LockPage(this.store);

  static final String route = '/assets/lock';
  final AppStore store;

  @override
  _LockPageState createState() => _LockPageState(store);
}

class _LockPageState extends State<LockPage> {
  _LockPageState(this.store);

  final AppStore store;
  TextEditingController textCtl = TextEditingController(text: 'xxx-yy11-zz22');

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).assets;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['lock.tokens'])
      ),
      body: SafeArea(
        child: Builder(
          builder: (BuildContext context) {
          return ListView(
            shrinkWrap: true, 
            padding: const EdgeInsets.only(top:30,bottom: 20,right: 20,left: 20),
            children: <Widget>[
              Text(
                dic['lock.start'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26 
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Icon(
                  Icons.lock,
                  size: 100
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: Image.asset(
                  'assets/images/assets/DOT.png',
                  width: 40,
                  height: 40,
                )
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  dic['lock.instrution'],
                  textAlign: TextAlign.center,
                ),
              ),
              linkTap(
                dic['lock.whatlocking'],
                onTap: (){}
              ),
              linkTap(
                dic['lock.howlock'],
                onTap: (){}
              ),
              
            ]
          );
        }
      )),
      bottomNavigationBar: ListTile(
        contentPadding: const EdgeInsets.only(left: 10,right: 10,bottom: 30),
        title: Row(children: <Widget>[
          goPageBtn(
            dic['agree'],
            onTap: () => Navigator.pushNamed(context, LockDetailPage.route),
          ),
          Icon(Icons.chevron_right)
        ])
      )
    );
  }
}

void _tapRule(){
  
}