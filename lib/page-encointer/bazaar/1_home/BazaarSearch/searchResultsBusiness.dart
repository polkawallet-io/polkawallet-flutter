import 'package:encointer_wallet/page-encointer/bazaar/shared/bazaarItemVertical.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'searchResultsBusinessFiltered.dart';

class SearchResultsBusiness extends StatelessWidget {
  final results;

  const SearchResultsBusiness(this.results, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${results.length} ${I18n.of(context).translationsForLocale().bazaar.businessesFound}'),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 6,
            child: ListTile(
              leading: Icon(Icons.filter_alt),
              title: Text("Filter"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchResultsBusinessFiltered(results)),
                );
              }, // TODO state management
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) => BazaarItemVertical(
                data: results,
                index: index,
                cardHeight: 125,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
