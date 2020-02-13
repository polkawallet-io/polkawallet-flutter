import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:polka_wallet/page/staking/validator.dart';
import 'package:polka_wallet/service/api.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/store/staking.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class StakingOverview extends StatefulWidget {
  StakingOverview(
      this.api, this.store, this.settingsStore, this.reloadStakingOverview);

  final Api api;
  final StakingStore store;
  final SettingsStore settingsStore;
  final Function reloadStakingOverview;

  @override
  _StakingOverviewState createState() =>
      _StakingOverviewState(api, store, settingsStore, reloadStakingOverview);
}

class _StakingOverviewState extends State<StakingOverview> {
  _StakingOverviewState(
      this.api, this.store, this.settingsStore, this.reloadStakingOverview);

  final Api api;
  final StakingStore store;
  final SettingsStore settingsStore;
  final Function reloadStakingOverview;

  int _tab = 0;
  ScrollController _scrollController;
  int _validatorListLength = 10;
  int _nextListLength = 10;

  Future<void> _getNextUpsInfo() async {
    int len = store.nextUps.length;
    if (len > 0) {
      var res = await Future.wait(store.nextUps
          .sublist(_nextListLength - 10, _nextListLength)
          .map((address) =>
              api.evalJavascript('api.derive.staking.query("$address")')));
      print(res.length);
      store.setNextUpsInfo(res);
    }
  }

  Widget _buildTopCard(BuildContext context) {
    var dic = I18n.of(context).staking;
    String symbol = settingsStore.networkState.tokenSymbol;
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
                title: dic['nominators'],
                content: store.nominatorCount.toString(),
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
                title: '${dic['total']} ($symbol)',
                content: '${Fmt.token(store.staked, 18)} M',
              ),
              InfoItem(
                title: dic['staked'],
                content: NumberFormat('0.00%').format(
                    store.staked / int.parse(store.overview['issuance'])),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildValidatorList() {
    if (_tab == 1) {
      return store.nextUpsInfo.length > 0
          ? store.nextUpsInfo
              .sublist(0, _nextListLength)
              .map((i) => Validator(null, i))
              .toList()
          : [CupertinoActivityIndicator()];
    }
    return store.validatorsInfo.length > 0
        ? store.validatorsInfo
            .sublist(0, _validatorListLength)
            .map((i) => Validator(null, i))
            .toList()
        : [CupertinoActivityIndicator()];
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        setState(() {
          int end;
          if (_tab == 0) {
            end = _validatorListLength + 10;
            _validatorListLength = end > store.validatorsInfo.length
                ? store.validatorsInfo.length
                : end;
          } else {
            end = _nextListLength + 10;
            _nextListLength =
                end > store.nextUps.length ? store.nextUps.length : end;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        bool hashData = store.overview['validators'] != null;
        if (hashData) {
          return RefreshIndicator(
            child: ListView(
              controller: _scrollController,
              children: <Widget>[
                _buildTopCard(context),
                Container(
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(16),
                        height: 16,
                        decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(width: 3, color: Colors.pink)),
                        ),
                      ),
                      Text(
                        I18n.of(context).staking['validators'],
                        style: Theme.of(context).textTheme.display4,
                      ),
                      Expanded(
                        child: Container(),
                      )
                    ],
                  ),
                ),
                ..._buildValidatorList()
              ],
            ),
            onRefresh: reloadStakingOverview,
          );
        }
        return CupertinoActivityIndicator();
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
