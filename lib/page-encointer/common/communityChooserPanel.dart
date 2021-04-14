import 'package:encointer_wallet/common/components/roundedCard.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/format.dart';
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
              builder: (_) => (store.encointer.communityIdentifiers == null)
                  ? CupertinoActivityIndicator()
                  : (store.encointer.communityIdentifiers.isEmpty)
                      ? Text("no currencies found")
                      : DropdownButton<dynamic>(
                          key: Key('cid-dropdown'),
                          value: (store.encointer.chosenCid == null ||
                                  !store.encointer.communityIdentifiers.contains(store.encointer.chosenCid))
                              ? store.encointer.communityIdentifiers[0]
                              : store.encointer.chosenCid,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 32,
                          elevation: 32,
                          onChanged: (newValue) {
                            setState(() {
                              store.encointer.setChosenCid(newValue);
                            });
                          },
                          items: store.encointer.communityIdentifiers
                              .asMap()
                              .entries
                              .map((entry) => DropdownMenuItem<dynamic>(
                                    key: Key('cid-${entry.key}'),
                                    value: entry.value,
                                    child: Text(Fmt.communityIdentifier(entry.value)),
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
