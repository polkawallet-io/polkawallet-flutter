
/// Bazaar entry page
///
/// Todo: @armin: For my taste this file is way to big. Please separate it into smaller files. However, I don't know
/// how much of this will be needed in the new design anyhow.

import 'package:encointer_wallet/common/components/BorderedTitle.dart';
import 'package:encointer_wallet/common/components/roundedCard.dart';
import 'package:encointer_wallet/mocks/api/apiIpfsBazaar.dart';
import 'package:encointer_wallet/page-encointer/bazaar/common/communityChooserHandler.dart';
import 'package:encointer_wallet/page-encointer/bazaar/common/menuHandler.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shop/shopCard.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shop/shopOverviewPanel.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/bazaar.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

class BazaarEntry extends StatefulWidget {
  BazaarEntry(this.store);

  final AppStore store;

  @override
  _BazaarEntryState createState() => _BazaarEntryState(store);
}

class _BazaarEntryState extends State<BazaarEntry> {
  _BazaarEntryState(this.store);

  final AppStore store;
  Future<void> _chooseCommunity() async {
    await Navigator.push(
      context,
      PageRouteBuilder(opaque: false, pageBuilder: (context, _, __) => CommunityChooserHandler(store)),
    );
  }

  @observable
  bool reload = false;

  Future<void> refreshPage() async {
    reload = true;
    if (store.encointer.chosenCid != null) {
      await store.encointer.reloadbusinessRegistry();
      await resetState();
      reload = false;
    }
  }

  @override
  void initState() {
    refreshPage();
    super.initState();
  }

  Future<void> resetState() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).bazaar;
    Color secondaryColor = Theme.of(context).secondaryHeaderColor;

    final List<Widget> _widgetList = <Widget>[
      homeView(context, store),
      ShopOverviewPanel(store),
      //articleView(context, store),d
    ];

    final List<Widget> _tabList = <Widget>[
      Row(children: [Icon(Icons.home, color: secondaryColor), SizedBox(width: 5), Text("Home")]),
      Row(children: [Icon(Icons.shop, color: secondaryColor), SizedBox(width: 5), Text("Shops")]),
      //articleView(context, store),
    ];

    return DefaultTabController(
      length: _tabList.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: _tabList,
          ),
          title: Text(dic['bazaar.title']),
          centerTitle: true,
          leading: IconButton(icon: Image.asset('assets/images/assets/ERT.png'), onPressed: () => _chooseCommunity()),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(opaque: false, pageBuilder: (context, _, __) => MenuHandler(store)),
                );
              },
            ),
          ],
          flexibleSpace: Container(
            padding: EdgeInsets.fromLTRB(10, 53, 100, 10),
            child: Observer(
              builder: (_) {
                return store.encointer.balanceEntries[store.encointer.chosenCid] != null
                    ? Stack(children: <Widget>[
                        Text(
                          Fmt.communityIdentifier(store.encointer.chosenCid),
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () => _chooseCommunity(),
                          child: Container(
                            color: Colors.transparent,
                            width: 120,
                            height: 15,
                          ),
                        ),
                      ])
                    : GestureDetector(
                        onTap: () => _chooseCommunity(),
                        child: Text(
                          dic['community.load'],
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      );
              },
            ),
          ),
        ),
        body: TabBarView(children: _widgetList),
      ),
    );
  }

  Widget homeView(BuildContext context, AppStore store) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // TODO: implement search option
            //searchBar(context),
            //Divider(height: 28),
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
                    child: recentlyAdded(context, store),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchBar(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).bazaar;
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

  Widget recentlyAdded(BuildContext context, AppStore store) {
    final double _height = MediaQuery.of(context).size.height;
    final Map<String, String> dic = I18n.of(context).bazaar;

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
                title: dic['recently.added'],
              ),
            ),
            //TODO: Better view for recently added?
            /*Container(
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
            ),*/
          ],
        ),
        Observer(builder: (_) {
          return RoundedCard(
            margin: EdgeInsets.only(top: 16),
            child: Container(
              height: _height / 5,
              // TODO: Change from businessRegistry == null to != null is not registered - how to fix?
              //  Problem only when restarting app.
              child: (store.encointer.businessRegistry == null) || reload || (store.encointer.chosenCid == null)
                  ? Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget>[
                          // TODO: how to refresh automatically?
                          !reload
                              ? TextButton(
                                  // todo: @armin: we never want to use direct string literals in the app.
                                  // please use the `i18n` dictionaries for the texts.
                                  child: Text("Refresh"),
                                  onPressed: () {
                                    refreshPage();
                                  })
                              : Container(
                                  alignment: Alignment.topCenter,
                                  child: Text(""),
                                ),
                          Container(
                            alignment: Alignment.center,
                            child: CupertinoActivityIndicator(),
                          ),
                        ],
                      ),
                    )
                  : (store.encointer.businessRegistry.isEmpty)
                      ? Container(
                          alignment: Alignment.center,
                          child: Text(dic['no.items']),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(5),
                          shrinkWrap: true,
                          itemCount: store.encointer.businessRegistry.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, index) {
                            return _buildShopEntries(context, index, store);
                          },
                        ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildShopEntries(BuildContext context, int index, AppStore store) {
    // todo: This not performant. we should create an iterable from the outside and only pass an element to it.
    List<AccountBusinessTuple> businesses = new List.from(store.encointer.businessRegistry.reversed);

    return GestureDetector(
      onTap: () {
        //TODO make clickable
        // Navigator.of(context).pushNamed(DETAIL_UI);
      },
      child: FutureBuilder<IpfsBusiness>(
        future: BazaarIpfsApiMock.getBusiness(businesses[index].businessData.url),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // @armin as far as I know are the two todos below not in the UI draft from the issue. If you don't find
            // any reason to use `category` and `dateAdded` just skipp them, or consult with alain.
            return ShopCard(
              title: snapshot.data.name,
              description: snapshot.data.description,
              imageHash: snapshot.data.imagesCid,
              // Todo: what kind of categories do we want?
              category: ' ',
              location: snapshot.data.contactInfo,
              // Todo: How do we determine this in reality. Do we rely on the shop owner's to populate that themselves?
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
}
