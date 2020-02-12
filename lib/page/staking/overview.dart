import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/service/api.dart';
import 'package:polka_wallet/store/staking.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class StakingOverview extends StatefulWidget {
  StakingOverview(this.api, this.store);

  final Api api;
  final StakingStore store;

  @override
  _StakingOverviewState createState() => _StakingOverviewState(api, store);
}

class _StakingOverviewState extends State<StakingOverview> {
  _StakingOverviewState(this.api, this.store);

  final Api api;
  final StakingStore store;

  int _tab = 0;

  Widget _buildTopCard(BuildContext context) {
    var dic = I18n.of(context).staking;
    String session;
    if (store.overview['session'] != null) {
      session =
          '${store.overview['session']['sessionProgress']}/${store.overview['session']['sessionLength']}';
    }
    String era;
    if (store.overview['session'] != null) {
      era =
          '${store.overview['session']['eraProgress']}/${store.overview['session']['eraLength']}';
    }
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(const Radius.circular(8)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16.0, // has the effect of softening the shadow
              spreadRadius: 4.0, // has the effect of extending the shadow
              offset: Offset(
                2.0, // horizontal, move right 10
                2.0, // vertical, move down 10
              ),
            )
          ]),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              InfoItem(
                title: dic['validators'],
                content:
                    '${store.overview['validators'].length}/${store.overview['validatorCount']}',
              ),
              InfoItem(
                title: dic['waitting'],
                content: store.nextUps.length.toString(),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Row(
              children: <Widget>[
                InfoItem(
                  title: dic['session'],
                  content: session,
                ),
                InfoItem(
                  title: dic['era'],
                  content: era,
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              InfoItem(
                title: dic['total'],
                content: '15',
              ),
              InfoItem(
                title: dic['staked'],
                content: '15',
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTabs(BuildContext context) {
    var dic = I18n.of(context).staking;
    var tabs = [dic['validators'], dic['waitting']];
    return tabs.map(
      (title) {
        var index = tabs.indexOf(title);
        return GestureDetector(
          child: Column(
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 18,
                          color: _tab != index ? Colors.black54 : Colors.pink),
                    )
                  ],
                ),
              ),
              Container(
                height: 16,
                width: 32,
                decoration: _tab != index
                    ? null
                    : BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 3, color: Colors.pink)),
                      ),
              )
            ],
          ),
          onTap: () {
            if (_tab != index) {
              setState(() {
                _tab = index;
              });
            }
          },
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        bool hashData = store.overview['validators'] != null;
        print(store.overview.keys);
        return ListView(
          children: <Widget>[
            hashData ? _buildTopCard(context) : Container(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: _buildTabs(context),
              ),
            ),
            hashData
                ? Text(_tab == 0
                    ? store.overview['validators'].length.toString()
                    : 'ggg')
                : Container()
          ],
        );
      },
    );
  }
}

class InfoItem extends StatelessWidget {
  InfoItem({this.title, this.content});
  final String title;
  final String content;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
          ),
          content == null
              ? CupertinoActivityIndicator()
              : Text(
                  content,
                  style: Theme.of(context).textTheme.display4,
                )
        ],
      ),
    );
  }
}
