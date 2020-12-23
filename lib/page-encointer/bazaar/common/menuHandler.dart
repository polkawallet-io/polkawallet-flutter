import 'package:flutter/material.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shop/myShopPage.dart';
import 'package:encointer_wallet/store/app.dart';

class MenuHandler extends StatelessWidget {
  MenuHandler(this.store);

  final AppStore store;

  void _dismiss(context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).bazaar;
    return GestureDetector(
      onTap: () {
        _dismiss(context); // return when tapped on background
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.8),
        body: Opacity(
          opacity: 1,
          child: SafeArea(
            child: Align(
              widthFactor: double.infinity,
              heightFactor: double.infinity,
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {}, // make sure nothing happens if clicked on white area of menu
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width / 1.6,
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.fromLTRB(15, 30, 15, 0),
                  child: ListView(
                    children: <Widget>[
                      ListTile(
                        title: Text(dic['menu']),
                        trailing: Icon(Icons.close, size: 25),
                        onTap: () => _dismiss(context),
                      ),
                      ListTile(
                        leading: Container(
                          width: 32,
                          child: Icon(Icons.shop_outlined, color: Colors.grey, size: 22),
                        ),
                        title: Text(dic['my.shops']),
                        trailing: Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () => {
                          Navigator.of(context).pushNamed(MyShopPage.route),
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
