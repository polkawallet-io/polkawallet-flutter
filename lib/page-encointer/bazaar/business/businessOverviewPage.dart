// Currently obsolete - not being deleted due to the idea of "offline state" of businesses. Realisable?

import 'package:encointer_wallet/page-encointer/common/communityChooserPanel.dart';
import 'package:encointer_wallet/page-encointer/bazaar/business/businessOverviewPanel.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class BusinessOverviewPage extends StatelessWidget {
  BusinessOverviewPage(this.store);

  static const String route = '/encointer/bazaar/businessOverviewPage';

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).bazaar;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['businesses']),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: Column(children: <Widget>[
          BusinessObserver(store)
          //BusinessOverviewPanel(store),
        ]),
      ),
    );
  }
}

class BusinessObserver extends StatefulWidget {
  BusinessObserver(this.store);

  static final String route = '/encointer/bazaar/businessObserver';

  final AppStore store;

  @override
  _BusinessObserverState createState() => _BusinessObserverState(store);
}

class _BusinessObserverState extends State<BusinessObserver> with SingleTickerProviderStateMixin {
  _BusinessObserverState(this.store);

  final AppStore store;
  bool appConnected = false;

  @override
  void initState() {
    _checkConnectionState();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _checkConnectionState() async {
    appConnected = await webApi.isConnected();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
            CommunityChooserPanel(store),
            // TODO: what to show in case of offline?
            //appConnected ? _getBusinessView(store.encointer.currentPhase) : _getBusinessViewOffline(),
            _getBusinessView(),
          ])),
    );
  }

  Widget _getBusinessView() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 32, 16, 32),
        child: BusinessOverviewPanel(store),
      ),
    );
  }
}
