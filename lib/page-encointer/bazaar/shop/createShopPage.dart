
// Todo: @armin this is totally outdated and needs communication with the chain
// to make sense at all. I suggest you neglect creating shops for now. Later you could
// add the functionality to add them to the mock data or something like that, but I haven't
// thought this through.

import 'package:encointer_wallet/page-encointer/bazaar/shop/createShopForm.dart';
import 'package:encointer_wallet/page-encointer/common/communityChooserPanel.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateShopPage extends StatefulWidget {
  const CreateShopPage(this.store);

  static final String route = '/encointer/bazaar/createShopPage';
  final AppStore store;

  @override
  _CreateShopPageState createState() => _CreateShopPageState(store);
}

class _CreateShopPageState extends State<CreateShopPage> {
  _CreateShopPageState(this.store);
  final AppStore store;

  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).bazaar;

    return Scaffold(
      appBar: AppBar(title: Text(dic['shop.create'])),
      body: SafeArea(
          // child: !_submitting
          //   ?
          child: Column(children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
              CommunityChooserPanel(store),
              SizedBox(
                height: 16,
              ),
              Expanded(
                child: CreateShopForm(store),
              ),
            ]),
          ),
        ),
      ])),
    );
  }
}
