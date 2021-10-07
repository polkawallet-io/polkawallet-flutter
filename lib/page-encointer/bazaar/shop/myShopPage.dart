import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shop/createShopPage.dart';
import 'package:encointer_wallet/common/components/roundedButton.dart';

class MyShopPage extends StatefulWidget {
  const MyShopPage(this.store);

  static final String route = '/encointer/bazaar/myShopPage';
  final AppStore store;

  @override
  _MyShopPageState createState() => _MyShopPageState(store);
}

class _MyShopPageState extends State<MyShopPage> {
  _MyShopPageState(this.store);
  final AppStore store;

  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).bazaar;

    return Scaffold(
      appBar: AppBar(title: Text(dic['my.shops'])),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 15),
          child: RoundedButton(
            text: dic['shop.insert'],
            onPressed: () {
              Navigator.pushNamed(context, CreateShopPage.route);
            },
          ),
        ),
      ),
    );
  }
}
