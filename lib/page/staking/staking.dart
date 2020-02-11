import 'package:flutter/material.dart';

import 'package:polka_wallet/store/staking.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Staking extends StatefulWidget {
  Staking(this.store);

  final StakingStore store;

  @override
  _StakingState createState() => _StakingState(store);
}

class _StakingState extends State<Staking> {
  _StakingState(this.store);

  final StakingStore store;

  int _tab = 0;

  List<Widget> _buildTabs() {
    var dic = I18n.of(context).staking;
    var tabs = [dic['actions'], dic['overview']];
    return tabs.map(
      (title) {
        var index = tabs.indexOf(title);
        return GestureDetector(
          child: Column(
            children: <Widget>[
              Container(
                width: 160,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    )
                  ],
                ),
              ),
              Container(
                height: 16,
                width: 32,
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: _tab == index ? 3 : 0, color: Colors.white)),
                ),
//                child: Text('aa'),
              )
            ],
          ),
          onTap: () {
            setState(() {
              _tab = index;
            });
          },
        );
      },
    ).toList();
  }

  Widget _buildTopCard() {
    var dic = I18n.of(context).staking;
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
                content: '15',
              ),
              InfoItem(
                title: dic['waitting'],
                content: '15',
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Row(
              children: <Widget>[
                InfoItem(
                  title: dic['session'],
                  content: '15',
                ),
                InfoItem(
                  title: dic['era'],
                  content: '15',
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

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          color: Colors.transparent,
          child: ListView(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _buildTabs(),
              ),
              _buildTopCard(),
              Text('Staking'),
            ],
          ),
        ),
      );
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
          Text(
            content,
            style: Theme.of(context).textTheme.display4,
          )
        ],
      ),
    );
  }
}
