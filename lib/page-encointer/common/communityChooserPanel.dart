import 'package:encointer_wallet/common/components/roundedCard.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class CommunityChooserPanel extends StatefulWidget {
  CommunityChooserPanel(this.store);

  final AppStore store;

  @override
  _CommunityChooserPanelState createState() => _CommunityChooserPanelState(store);
}

class _CommunityChooserPanelState extends State<CommunityChooserPanel> {
  _CommunityChooserPanelState(this.store);

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: RoundedCard(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: <Widget>[
            Text("Choose community:"),
            Observer(
              builder: (_) => (store.encointer.communities == null)
                  ? CupertinoActivityIndicator()
                  : (store.encointer.communities.isEmpty)
                      ? Text("no currencies found")
                      : DropdownButton<dynamic>(
                          key: Key('cid-dropdown'),
                          value: (store.encointer.chosenCid == null ||
                                  store.encointer.communities.where((cn) => cn.cid == store.encointer.chosenCid).isEmpty)
                              ? store.encointer.communities[0]
                              : store.encointer.communities.where((cn) => cn.cid == store.encointer.chosenCid).first,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 32,
                          elevation: 32,
                          onChanged: (newValue) {
                            setState(() {
                              store.encointer.setChosenCid(newValue.cid);
                            });
                          },
                          items: store.encointer.communities
                              .asMap()
                              .entries
                              .map((entry) => DropdownMenuItem<dynamic>(
                                    key: Key('cid-${entry.key}'),
                                    value: entry.value,
                                    child: Text(entry.value.name),
                                  ))
                              .toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
