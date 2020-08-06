import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/listTail.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/governance/council/motionDetailPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Motions extends StatefulWidget {
  Motions(this.store);

  final AppStore store;

  @override
  _MotionsState createState() => _MotionsState();
}

class _MotionsState extends State<Motions> {
  Future<void> _fetchData() async {
    webApi.gov.updateBestNumber();
    await webApi.gov.fetchCouncilMotions();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalMotionsRefreshKey.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).gov;
    return Observer(
      builder: (BuildContext context) {
        return RefreshIndicator(
          onRefresh: _fetchData,
          key: globalMotionsRefreshKey,
          child: ListView(
            padding: EdgeInsets.only(top: 16),
            children: widget.store.gov.councilMotions.length > 0
                ? widget.store.gov.councilMotions.map((e) {
                    return RoundedCard(
                      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: EdgeInsets.only(top: 16, bottom: 16),
                      child: ListTile(
                        title: Text(
                            '#${e.votes.index} ${e.proposal.section}.${e.proposal.method}'),
                        subtitle: Text(e.proposal.meta.documentation.trim()),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '${e.votes.ayes.length}/${e.votes.threshold}',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            Text(dic['yes']),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(MotionDetailPage.route, arguments: e);
                        },
                      ),
                    );
                  }).toList()
                : [ListTail(isEmpty: true, isLoading: false)],
          ),
        );
      },
    );
  }
}
