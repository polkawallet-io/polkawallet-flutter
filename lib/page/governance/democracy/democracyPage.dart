import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/backgroundWrapper.dart';
import 'package:polka_wallet/common/components/topTaps.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/governance/democracy/democracy.dart';
import 'package:polka_wallet/page/governance/democracy/proposals.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class DemocracyPage extends StatefulWidget {
  DemocracyPage(this.store);

  static const String route = '/gov/democracy/index';

  final AppStore store;

  @override
  _DemocracyPageState createState() => _DemocracyPageState();
}

class _DemocracyPageState extends State<DemocracyPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).gov;
    var tabs = [dic['democracy.referendum'], dic['democracy.proposal']];
    bool isKusama =
        widget.store.settings.endpoint.info == networkEndpointKusama.info;
    String imageColor = isKusama ? 'black' : 'pink';
    return BackgroundWrapper(
      AssetImage("assets/images/staking/top_bg_$imageColor.png"),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.only(top: 20),
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).cardColor,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TopTabs(
                      names: tabs,
                      activeTab: _tab,
                      onTab: (v) {
                        setState(() {
                          if (_tab != v) {
                            _tab = v;
                          }
                        });
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: _tab == 0
                      ? Democracy(widget.store)
                      : Proposals(widget.store),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
