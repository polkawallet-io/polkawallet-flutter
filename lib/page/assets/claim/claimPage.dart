import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ClaimPage extends StatefulWidget {
  ClaimPage(this.store);

  static final String route = '/assets/claim';
  final AppStore store;

  @override
  _ClaimPageState createState() => _ClaimPageState(store);
}

class _ClaimPageState extends State<ClaimPage> {
  _ClaimPageState(this.store);

  final AppStore store;
  TapGestureRecognizer tapRuleRecongnizer = TapGestureRecognizer()
    ..onTap = () => _tapRule();
  TextEditingController textCtl = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).assets;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['claim.transaction'])
      ),
      body: SafeArea(
        child: Builder(
          builder: (BuildContext context) {
          return ListView(
            shrinkWrap: true, 
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              Text(
                dic['claim.instruction'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16 
                ),
              ),
              Container(
                padding: EdgeInsets.only(top:100),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'xxx-yy11-zz22',
                        labelText: dic['claim.hash'],
                      ),
                      controller: textCtl,
                      readOnly: true
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.content_copy), 
                    onPressed: null
                  )
                ],
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(dic['claim.which.chain']),
                trailing: IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: (){},
                ),
                onTap: (){
                  showCupertinoModalPopup(
                    context: context,
                    builder: (ctx) {
                      return Container(
                        height: 200.0,
                        // padding: const EdgeInsets.only(bottom: 50.0),
                        child: CupertinoPicker(
                          itemExtent: 30.0,
                          children: [
                            Text('chain1'),
                            Text('chain2')
                          ],
                          onSelectedItemChanged: (index){
                          }
                        ),
                      );
                    }
                  );
                }
              ),
            ]
          );
        }
      )),
      bottomNavigationBar: ListView(
        padding: const EdgeInsets.only(left: 10,right: 10,bottom: 20),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          Text.rich(
                TextSpan(
                  // style: TextStyle(
                  // ),
                  children: [
                    TextSpan(
                      text: dic['claim.token.instruction']
                    ),
                    TextSpan(
                      text: dic['claim.dhx.document'],
                      style: TextStyle(
                        color: Colors.blue
                      ),
                      recognizer: tapRuleRecongnizer
                    ),
                  ]
                ),
                textAlign: TextAlign.center,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Container(
                  margin: const EdgeInsets.only(top: 30,right: 10,left: 10,bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: OutlineButton(
                    borderSide: BorderSide(
                      color: Colors.purple
                    ),
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                    ),
                    child: Text(
                      dic['claim'],
                      style: const TextStyle(
                        fontSize: 22.0,
                        color: Colors.white
                      ),
                    ),
                    onPressed: () {}
                  )
                )
              )
        ],
      ),
    );
  }
}

void _tapRule(){
  
}