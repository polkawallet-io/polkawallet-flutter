import 'package:encointer_wallet/page-encointer/bazaar/menu/1_my_offerings/myOfferings.dart';
import 'package:encointer_wallet/page-encointer/bazaar/menu/2_my_businesses/myBusinesses.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/material.dart';

class BazaarMenu extends StatelessWidget {
  const BazaarMenu({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).bazaar;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 150,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text('Menu'),
            ),
          ),
          ListTile(
            title: Text(dic['offerings.my']),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyOfferings(),
                ),
              );
            },
          ),
          ListTile(
            title: Text(dic['businesses.my']),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyBusinesses(),
                ),
              );
            },
          ),
          SizedBox(
            height: 50,
          ),
          ListTile(
            title: Text(dic['notifications']),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
