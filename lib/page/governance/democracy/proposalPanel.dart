import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/governance/democracy/proposalDetailPage.dart';
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
    final int decimals = widget.store.settings.networkState.tokenDecimals ?? 12;
    final String symbol = widget.store.settings.networkState.tokenSymbol ?? '';
    final String tokenView = Fmt.tokenView(
      symbol,
      decimalsDot: decimals,
      network: widget.store.settings.endpoint.info,
    );
    final CouncilProposalData proposalMeta = widget.proposal.image?.proposal;
    final Map accInfo =
        widget.store.account.accountIndexMap[widget.proposal.proposer];
    return GestureDetector(
      child: RoundedCard(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  proposalMeta != null
                      ? '${proposalMeta.section}.${proposalMeta.method}'
                      : 'preimage: ${Fmt.address(widget.proposal.imageHash)}',
                  style: Theme.of(context).textTheme.headline4,
                ),
                Text(
                  '#${widget.proposal.index}',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
            Divider(height: 24),
            Row(
              children: <Widget>[
                AddressIcon(widget.proposal.proposer),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Fmt.accountDisplayName(
                            widget.proposal.proposer, accInfo),
                        Text(
                          '${dic['treasury.bond']}: ${Fmt.balance(widget.proposal.balance.toString(), decimals: decimals)} $tokenView',
                          style: TextStyle(
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: <Widget>[
                    Text(
                      widget.proposal.seconds.length.toString(),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Text(dic['proposal.seconds'])
                  ],
                )
              ],
            ),
          ],
        ),
      ),
      onTap: () => Navigator.of(context)
          .pushNamed(ProposalDetailPage.route, arguments: widget.proposal),
    );
  }
}
