import 'package:encointer_wallet/common/components/roundedCard.dart';
import 'package:encointer_wallet/page-encointer/common/communityChooserOnMap.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
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
    final Map dic = I18n.of(context).assets;
    return Container(
      width: double.infinity,
      child: RoundedCard(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: <Widget>[
            Text(dic['community.choose']),
            Observer(
              builder: (_) => (store.encointer.communities == null)
                  ? CupertinoActivityIndicator()
                  : (store.encointer.communities.isEmpty)
                      ? Text(dic['communities.not.found'])
                      : DropdownButton<dynamic>(
                          key: Key('cid-dropdown'),
                          // todo find out, why adding the hint breaks the integration test walkthrough when choosing community #225
                          // hint: Text(dic['community.choose']),
                          value: (store.encointer.chosenCid == null ||
                                  store.encointer.communities
                                      .where((cn) => cn.cid == store.encointer.chosenCid)
                                      .isEmpty)
                              ? null
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

class CommunityWithCommunityChooser extends StatefulWidget {
  const CommunityWithCommunityChooser(this.store, {Key key}) : super(key: key);

  final AppStore store;

  @override
  _CommunityWithCommunityChooserState createState() => _CommunityWithCommunityChooserState(store);
}

class _CommunityWithCommunityChooserState extends State<CommunityWithCommunityChooser> {
  final AppStore store;

  _CommunityWithCommunityChooserState(this.store);

  @override
  Widget build(BuildContext context) {
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
            key: Key('cid-avatar'),
            child: Column(
              children: [
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(96),
                  ),
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: webApi.ipfs.getCommunityIcon(store.encointer.communityIconsCid, devicePixelRatio),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  store.encointer.communities != null && store.encointer.chosenCid != null
                      ? store.encointer.communities
                          .firstWhere((c) => c.cid == store.encointer.chosenCid)
                          .name
                          .toString()
                      : '...',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunityChooserOnMap(store),
                ),
              );
            }),
      ],
    );
  }
}
