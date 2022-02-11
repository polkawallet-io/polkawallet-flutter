import 'package:encointer_wallet/page-encointer/bazaar/menu/1_my_offerings/myOfferings.dart';
import 'package:encointer_wallet/page-encointer/bazaar/menu/2_my_businesses/myBusinesses.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/material.dart';

import 'package:encointer_wallet/utils/translations/translations.dart';

class BazaarMenu extends StatelessWidget {
  const BazaarMenu({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Translations dic = I18n.of(context).translationsForLocale();
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
            title: Text(dic.bazaar.offeringsMy),
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
            title: Text(dic.bazaar.businessesMy),
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
            title: Text(dic.bazaar.notifications),
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
