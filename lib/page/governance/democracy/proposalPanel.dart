import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/gov/types/proposalInfoData.dart';
import 'package:polka_wallet/store/gov/types/treasuryOverviewData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ProposalPanel extends StatefulWidget {
  ProposalPanel(this.store, this.proposal);

  final AppStore store;
  final ProposalInfoData proposal;

  @override
  _ProposalPanelState createState() => _ProposalPanelState();
}

class _ProposalPanelState extends State<ProposalPanel> {
  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).gov;
    final CouncilProposalData proposalMeta = widget.proposal.image != null
        ? widget.proposal.image.proposal ?? CouncilProposalData()
        : CouncilProposalData();
    return RoundedCard(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${proposalMeta.section}.${proposalMeta.method}',
                style: Theme.of(context).textTheme.headline4,
              ),
              Text(
                '#${widget.proposal.index}',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
          Divider(),
          Row(
            children: <Widget>[
              AddressIcon(widget.proposal.proposer),
              Expanded(
                child: Column(
                  children: <Widget>[],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
