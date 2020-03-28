import 'package:flutter/material.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

Widget lockAppBtn(context){
  var dic = I18n.of(context).assets;
  
  return Container(
    padding: const EdgeInsets.only(top:30),
    child:  Row(
      children: [
        Expanded(
          child: Container(),
        ),
        Container(
          margin: const EdgeInsets.only(top: 20,right: 10,left: 10,bottom: 10),
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(10.0)
          ),
          child: OutlineButton(
            borderSide: BorderSide(
              color: Colors.purple
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)
            ),
            child: Text(dic['lock.app'],
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white
              ),
            ),
            onPressed: () {}
          )
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              Text('MXC'),
              Icon(Icons.arrow_drop_down)
            ],
            // title: Text('MXC'),
            // trailing: Icon(Icons.arrow_drop_down),
          ),
        ),
        Expanded(
          child: Container(),
        ),
      ]
    )
);
}