import 'package:flutter/material.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:encointer_wallet/common/components/roundedCard.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class CommunityChooserHandler extends StatefulWidget {
  CommunityChooserHandler(this.store);

  final AppStore store;

  @override
  _CommunityChooserHandlerState createState() => _CommunityChooserHandlerState(store);
}

class _CommunityChooserHandlerState extends State<CommunityChooserHandler> {
  _CommunityChooserHandlerState(this.store);

  BuildContext context;
  final AppStore store;

  void _setStateAndReturn(var newCid) {
    setState(() {
      store.encointer.setChosenCid(newCid);
    });
    Navigator.pop(context, true);
  }

  void _dismiss() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    final Map<String, String> dic = I18n.of(context).bazaar;

    return GestureDetector(
      onTap: () {
        _dismiss(); // return when tapped on background
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.85),
        body: Opacity(
          opacity: 1,
          child: SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width / 1.2,
              padding: EdgeInsets.fromLTRB(10, 10, 100, 50),
              child: RoundedCard(
                child: Observer(
                  builder: (_) => (store.encointer.communityIdentifiers == null)
                      ? CupertinoActivityIndicator()
                      : (store.encointer.communityIdentifiers.isEmpty)
                          ? Text(dic['community.notFound'])
                          : SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  RoundedCard(
                                      child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: 50,
                                        height: 50,
                                        child: Image.asset('assets/images/assets/ERT.png'),
                                      ),
                                      Container(width: 15),
                                      Text(
                                        dic['community.choose'],
                                      ),
                                    ],
                                  )),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    //padding: const EdgeInsets.all(8.0),
                                    itemCount: store.encointer.communityIdentifiers.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return ListTile(
                                        title:
                                            Text(Fmt.communityIdentifier(store.encointer.communityIdentifiers[index])),
                                        onTap: () {
                                          _setStateAndReturn(store.encointer.communityIdentifiers[index]);
                                        },
                                      );
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
      ),
    );
  }
}
