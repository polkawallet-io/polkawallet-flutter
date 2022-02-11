import 'package:encointer_wallet/page-encointer/bazaar/shared/bazaarItemVertical.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/demo_data/demoData.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/model/bazaarItemData.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'searchResultsBusiness.dart';
import 'searchResultsOffering.dart';

class SearchResults extends StatelessWidget {
  // TODO implement state management with logic that takes the first of each list of search results
  final businessResults = searchResultsInBusinesses;
  final offeringsResults = searchResultsInOfferings;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResultSummaryListTile(businessResults, I18n.of(context).translationsForLocale().bazaar.businessesResults),
        ResultSummaryListTile(offeringsResults, I18n.of(context).translationsForLocale().bazaar.offeringsResults),
        Text(
          I18n.of(context).translationsForLocale().bazaar.topResults,
          style: TextStyle(fontWeight: FontWeight.bold, height: 2.5),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [0, 1]
              .map(
                (int index) => BazaarItemVertical(
                  data: [businessResults[0], offeringsResults[0]],
                  index: index,
                  cardHeight: 125,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class ResultSummaryListTile extends StatelessWidget {
  final results;
  final title;

  const ResultSummaryListTile(
    this.results,
    this.title, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        height: 30,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.green[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              results.length.toString(),
            ),
          ],
        ),
      ),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                (results[0] is BazaarBusinessData) ? SearchResultsBusiness(results) : SearchResultsOffering(results),
          ),
        );
      }, // TODO state management
    );
  }
}
