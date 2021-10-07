
// Todo: @armin this is totally outdated and needs communication with the chain
// to make sense at all. I suggest you neglect creating businesses for now. Later you could
// add the functionality to add them to the mock data or something like that, but I haven't
// thought this through.

import 'package:encointer_wallet/page-encointer/bazaar/business/createBusinessForm.dart';
import 'package:encointer_wallet/page-encointer/common/communityChooserPanel.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateBusinessPage extends StatefulWidget {
  const CreateBusinessPage(this.store);

  static final String route = '/encointer/bazaar/createBusinessPage';
  final AppStore store;

  @override
  _CreateBusinessPageState createState() => _CreateBusinessPageState(store);
}

class _CreateBusinessPageState extends State<CreateBusinessPage> {
  _CreateBusinessPageState(this.store);
  final AppStore store;

  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).bazaar;

    return Scaffold(
      appBar: AppBar(title: Text(dic['business.create'])),
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
                child: CreateBusinessForm(store),
              ),
            ]),
          ),
        ),
      ])),
    );
  }
}
