import 'package:encointer_wallet/common/components/BorderedTitle.dart';
import 'package:encointer_wallet/common/components/roundedButton.dart';
import 'package:encointer_wallet/common/components/roundedCard.dart';
import 'package:encointer_wallet/page-encointer/bazaar/article/articleClass.dart';
import 'package:encointer_wallet/page-encointer/bazaar/article/articleCard.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shop/shopCard.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shop/shopClass.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shop/createShopPage.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shop/shopOverviewPage.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//TODO: when shop is included, update this widget such that newly added product is shown
class BazaarEntry extends StatelessWidget {
  BazaarEntry(this.store);

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).bazaar;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    dic['bazaar.title'],
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).cardColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // TODO: implement search option
            searchBar(context, dic),
            Divider(height: 28), // not nice solution
            Flexible(
              fit: FlexFit.tight,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(8),
                children: <Widget>[
                  // TODO: implement articles
                  /*Container(
                    margin: EdgeInsets.only(left: 10, top: 15),
                    child: articleSection(context, dic),
                  ),*/
                  Container(
                    margin: EdgeInsets.only(left: 10, top: 15),
                    child: shopSection(context, dic, store),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget searchBar(BuildContext context, Map<String, String> dic) {
  return Stack(
    children: <Widget>[
      Container(
        margin: EdgeInsets.only(left: 40, right: 40, top: 15),
        child: Material(
          borderRadius: BorderRadius.circular(30.0),
          elevation: 8,
          child: Container(
            child: TextFormField(
              cursorColor: Theme.of(context).primaryColor,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor, size: 30),
                hintText: dic['looking.for'],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget shopSection(BuildContext context, Map<String, String> dic, AppStore store) {
  final double _height = MediaQuery.of(context).size.height;

  return Column(
    children: <Widget>[
      // Title
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 40),
            child: BorderedTitle(
              title: dic['shops'],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 40, left: 100, right: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, ShopOverviewPage.route);
              },
              child: Text(
                dic['show.all'],
                style: Theme.of(context).textTheme.headline2.apply(fontSizeFactor: 0.7),
              ),
            ),
          ),
        ],
      ),
      RoundedCard(
        margin: EdgeInsets.only(top: 16),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 5, left: 5, bottom: 5),
              child: Row(
                children: <Widget>[
                  Text(
                    dic['recently.added'],
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ],
              ),
            ),
            Container(
              height: _height / 5,
              child: ListView.builder(
                padding: EdgeInsets.all(5),
                shrinkWrap: true,
                itemCount: store.encointer.shopRegistry == null ? 0 : store.encointer.shopRegistry.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, index) {
                  return _buildShopEntries(context, index, store);
                },
              ),
            ),
            // Add Article button
            Container(
              margin: EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 15),
              child: RoundedButton(
                text: dic['shop.insert'],
                onPressed: () {
                  Navigator.pushNamed(context, CreateShopPage.route);
                },
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget articleSection(BuildContext context, Map<String, String> dic, List<Article> itemList) {
  final double _height = MediaQuery.of(context).size.height;
  return Column(
    children: <Widget>[
      // Title
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 40),
            child: BorderedTitle(
              title: dic['article'],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 40, left: 100, right: 20),
            child: GestureDetector(
              onTap: () {},
              child: Text(
                dic['show.all'],
                style: Theme.of(context).textTheme.headline2.apply(fontSizeFactor: 0.7),
                //TextStyle(
                // color: Colors.indigo[255],
                //),
              ),
            ),
          ),
        ],
      ),
      RoundedCard(
        margin: EdgeInsets.only(top: 16),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 5, left: 5, bottom: 5),
              child: Row(
                children: <Widget>[
                  Text(
                    dic['recently.added'],
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ],
              ),
            ),
            Container(
              height: _height / 5,
              child: ListView.builder(
                padding: EdgeInsets.all(5),
                shrinkWrap: true,
                itemCount: itemList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, index) {
                  return _buildArticleEntries(context, index, itemList);
                },
              ),
            ),
            // Add Article button
            Container(
              margin: EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 15),
              child: RoundedButton(
                text: dic['article.insert'],
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildArticleEntries(BuildContext context, int index, List<Article> itemList) {
  return GestureDetector(
    onTap: () {
      // Navigator.of(context).pushNamed(DETAIL_UI);
    },
    child: ArticleCard(
      title: '${itemList[index].title}',
      category: 'dummy',
      price: "₹${itemList[index].price}",
      dateAdded: "${itemList[index].dateAdded}",
      description: "${itemList[index].desc}",
      image: "${itemList[index].image}",
      location: "${itemList[index].location}",
    ),
  );
}

List<String> reverse(List<String> list) {
  int end = list.length - 1;
  var reversedList = new List(list.length);
  for (int i = 0; i <= end; i++) {
    reversedList[end - i] = list[i];
  }
  return reversedList.cast<String>();
}

Widget _buildShopEntries(BuildContext context, int index, AppStore store) {
  List<String> reversedList = reverse(store.encointer.shopRegistry);
  return GestureDetector(
    onTap: () {
      //TODO make clickable
      // Navigator.of(context).pushNamed(DETAIL_UI);
    },
    child: FutureBuilder<Shop>(
      future: Shop().getShopData(reversedList[index]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ShopCard(
            title: snapshot.data.name,
            description: snapshot.data.description,
            imageHash: snapshot.data.imageHash,
            // TODO add these items to shop
            category: ' ',
            location: "Zürich, Technopark",
            dateAdded: "02 December 2020",
          );
          //return Text(snapshot.data.name);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a loading spinner.
        return CircularProgressIndicator();
      },
    ),
  );
}
