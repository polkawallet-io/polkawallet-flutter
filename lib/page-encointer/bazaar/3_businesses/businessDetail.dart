import 'package:encointer_wallet/page-encointer/bazaar/menu/2_my_businesses/businessesOnMap.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/bazaarItemHorizontal.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/model/bazaarItemData.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong2/latlong.dart";

class BusinessDetail extends StatelessWidget {
  final BazaarBusinessData business;
  final double cardHeight = 200;
  final double cardWidth = 160;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).bazaar;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("${business.title}"),
            SizedBox(
              width: 6,
            ),
            business.icon
          ],
        ),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Container(padding: EdgeInsets.all(4), child: business.image),
              Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(2, 8, 0, 16),
                    child: Text("${business.description}"),
                  )),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SmallLeaflet(),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(children: [
                      // OpeningHoursTable(business.openingHours),
                      Card(
                        margin: EdgeInsets.fromLTRB(4, 0, 2, 0),
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text(dic['day'])),
                            DataColumn(label: Text(dic['openning.hours']))
                          ],
                          headingRowHeight: 32,
                          columnSpacing: 4,
                          horizontalMargin: 8,
                          dataRowHeight: 32,
                          rows: List<DataRow>.generate(
                            7,
                            (int index) => DataRow(
                              cells: <DataCell>[
                                DataCell(
                                  Container(width: 30, child: Text(business.openingHours.getDayString(index))),
                                ),
                                DataCell(Text(
                                  business.openingHours.getOpeningHoursFor(index).toString(),
                                ))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),
                  )
                ],
              ),
              HorizontalBazaarItemList(business.offerings, dic['offerings'], cardHeight, cardWidth),
            ],
          ),
        ],
      ),
    );
  }

  BusinessDetail(this.business);
}

class SmallLeaflet extends StatelessWidget {
  const SmallLeaflet({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 257,
          child: FlutterMap(
            options: MapOptions(
              center: LatLng(47.389712, 8.517076),
              zoom: 15.0,
              maxZoom: 18.4,
            ),
            layers: [
              TileLayerOptions(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayerOptions(
                markers: [
                  Marker(
                    width: 20.0,
                    height: 20.0,
                    point: LatLng(47.389712, 8.517076),
                    builder: (ctx) => Icon(
                      Icons.location_on,
                      color: Colors.indigoAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusinessesOnMap(),
                  ))
            },
            child: Icon(Icons.fullscreen, size: 40),
          ),
        )
      ],
    );
  }
}
