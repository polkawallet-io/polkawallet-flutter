import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/listTail.dart';
import 'package:polka_wallet/page/governance/democracy/proposalPanel.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';

class Proposals extends StatefulWidget {
  Proposals(this.store);

  final AppStore store;

  @override
  _ProposalsState createState() => _ProposalsState();
}

class _ProposalsState extends State<Proposals> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> _fetchData() async {
    if (widget.store.settings.loading) {
      return;
    }
    await webApi.gov.fetchProposals();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshKey.currentState.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) {
        return RefreshIndicator(
          key: _refreshKey,
          onRefresh: _fetchData,
          child: widget.store.gov.proposals == null ||
                  widget.store.gov.proposals.length == 0
              ? Center(child: ListTail(isEmpty: true, isLoading: false))
              : ListView.builder(
                  itemCount: widget.store.gov.proposals.length + 1,
                  itemBuilder: (_, int i) {
                    if (widget.store.gov.proposals.length == i) {
                      return Center(
                          child: ListTail(isEmpty: false, isLoading: false));
                    }
                    return ProposalPanel(
                        widget.store, widget.store.gov.proposals[i]);
                  }),
        );
      },
    );
  }
}
