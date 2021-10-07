import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:encointer_wallet/page-encointer/bazaar/business/createBusinessPage.dart';
import 'package:encointer_wallet/common/components/roundedButton.dart';

class MyBusinessPage extends StatefulWidget {
  const MyBusinessPage(this.store);

  static final String route = '/encointer/bazaar/myBusinessPage';
  final AppStore store;

  @override
  _MyBusinessPageState createState() => _MyBusinessPageState(store);
}

class _MyBusinessPageState extends State<MyBusinessPage> {
  _MyBusinessPageState(this.store);
  final AppStore store;

  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).bazaar;

    return Scaffold(
      appBar: AppBar(title: Text(dic['my.businesses'])),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 15),
          child: RoundedButton(
            text: dic['business.insert'],
            onPressed: () {
              Navigator.pushNamed(context, CreateBusinessPage.route);
            },
          ),
        ),
      ),
    );
  }
}
