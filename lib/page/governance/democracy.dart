import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Democracy extends StatefulWidget {
  Democracy(this.store);

  final AppStore store;
  @override
  _DemocracyState createState() => _DemocracyState(store);
}

class _DemocracyState extends State<Democracy> {
  _DemocracyState(this.store);

  final AppStore store;

  bool _isLoading = true;

  Future<void> _fetchReferendums() async {
    setState(() {
      _isLoading = true;
    });
    await store.api.fetchReferendums();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchReferendums();
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).gov;
    return Observer(
      builder: (_) {
        print(store.gov.referendums[0]);
        print(store.gov.referendumVotes.keys);
        return RefreshIndicator(
          onRefresh: _fetchReferendums,
          child: ListView(
            children: <Widget>[Text('Democracy')],
          ),
        );
      },
    );
  }
}
