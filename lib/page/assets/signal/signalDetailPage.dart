import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/checkRule.dart';
import 'package:polka_wallet/common/components/formulaInput.dart';
import 'package:polka_wallet/common/components/goPageBtn.dart';
import 'package:polka_wallet/common/components/subTitle.dart';
import 'package:polka_wallet/page/assets/signal/signalResultPage.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class SignalDetailPage extends StatefulWidget {
  SignalDetailPage(this.store);

  static final String route = '/assets/signal/detail';
  final AppStore store;

  @override
  _DetailPageState createState() => _DetailPageState(store);
}

class _DetailPageState extends State<SignalDetailPage> {
  _DetailPageState(this.store);

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
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              Text(
                dic['transaction.message'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  dic['signal.instruction'],
                  textAlign: TextAlign.center,
                ),
              ),
              subTitle(dic['formula']),
              Row(
                children: <Widget>[
                  formulaInput(
                    lable: dic['lock.duration']
                  ),
                  Text(' , '),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        TextField(
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                            Text(
                              '${dic["signal"]},${dic["lock"]}',
                              style: TextStyle(
                                fontSize: 10
                              )
                            ),
                            Icon(Icons.arrow_drop_down)
                          ]),
                        ),
                      ],
                    ),
                  ),
                  Text(' , '),
                  formulaInput(
                    lable: dic['amount.tokens']
                  ),
                ]
              ),
              subTitle(
                dic['your.transaction'],
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                title: Container(
                  padding: const EdgeInsets.all(5),
                  color: Colors.grey[200],
                  child: Text(
                    '12,${dic["lock"]},50',
                    textAlign: TextAlign.center,
                  ),
                ),
                trailing: Icon(Icons.content_copy),
              ),
              Text(
                '${dic["expected"]} MSB: MSB',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12
                )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  dic['signal.important'],
                  textAlign: TextAlign.center,
                ),
              ),
              subTitle(
                dic['your.convenience'],
                alignment: Alignment.centerLeft
              ),
              checkRule(dic['message.qrcode']),
              checkRule(dic['check.message']),
            ]
          );
        }
      )),
      bottomNavigationBar: ListTile(
        contentPadding: const EdgeInsets.only(left: 10,right: 10,bottom: 30),
        // leading: Icon(Icons.chevron_left),
        title: Row(children: <Widget>[
          Icon(Icons.chevron_left),
          goPageBtn(
            dic['back'],
            textAlign: TextAlign.left,
            onTap: () => Navigator.pop(context),
          ),
          goPageBtn(
            dic['agree'],
            onTap: () => Navigator.pushNamed(context, SignalResultPage.route),
          ),
          Icon(Icons.chevron_right)
        ]),
      ),

    );
  }
}

void _tapRule(){
  
}