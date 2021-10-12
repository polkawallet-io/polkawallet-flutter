import 'package:encointer_wallet/config/consts.dart';
import 'package:flutter/material.dart';

class BusinessCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageHash;
  // TODO
  final String dateAdded;
  final String category;
  final String location;

  BusinessCard({this.title, this.dateAdded, this.category, this.description, this.imageHash, this.location});

  String getImageAdress(String imageHash) {
    return '$ipfs_gateway_encointer/ipfs/$imageHash';
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.indigo[50],
      child: Container(
        padding: EdgeInsets.only(left: 10, top: 10, right: 5, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: height / 40),
                ),
                Container(
                  width: width / 3,
                  padding: EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(2),
                          //color: Colors.grey[200],
                          child: Text(
                            category,
                            softWrap: true,
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Flexible(
                  child: Container(
                      width: width / 2.5,
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: height / 70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      )),
                ),
                SizedBox(
                  height: 5,
                ),
                Flexible(
                  child: Container(
                    width: width / 2.75,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: GestureDetector(
                            child: Icon(
                              Icons.favorite_border,
                              size: height / 30,
                            ),
                            onTap: () {
                              print('Fav');
                            },
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              dateAdded,
                              style: TextStyle(fontSize: height / 65),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.location_on,
                                  size: height / 65,
                                ),
                                Text(
                                  location,
                                  style: TextStyle(fontSize: height / 65),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              width: width / 2.5,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              // Todo: @armin here the image should also be fetched with the `BazaarMockApi` and will therefore be
              // a future that shows an `CupertinoActivity` indicator until loaded.
              child: Image.asset(
                this.imageHash,
                fit: BoxFit.cover,
                height: height / 4.5,
                width: width / 4.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
