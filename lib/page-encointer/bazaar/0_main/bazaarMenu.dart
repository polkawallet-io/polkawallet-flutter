import 'package:encointer_wallet/page-encointer/bazaar/menu/1_my_offerings/myOfferings.dart';
import 'package:encointer_wallet/page-encointer/bazaar/menu/2_my_businesses/myBusinesses.dart';
import 'package:flutter/material.dart';

class BazaarMenu extends StatelessWidget {
  const BazaarMenu({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            title: const Text('My Offerings'),
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
            title: const Text('My Businesses'),
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
            title: const Text('Notifications'),
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
