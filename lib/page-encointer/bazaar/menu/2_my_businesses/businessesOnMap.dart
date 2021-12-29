import 'package:encointer_wallet/page-encointer/bazaar/3_businesses/businessDetail.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/demo_data/demoData.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/model/bazaarItemData.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import "package:latlong2/latlong.dart";

class BusinessesOnMap extends StatelessWidget {
  final data = allBusinesses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).bazaar['businesses']),
      ),
      body: BMap(data),
    );
  }
}

class BMap extends StatelessWidget {
  /// Used to trigger showing/hiding of popups.
  final PopupController _popupLayerController = PopupController();
  final List<BazaarBusinessData> businessData;
  final bazaarBusinessDataFor = Map<LatLng, BazaarBusinessData>();

  BMap(List<BazaarItemData> data)
      // initializer (only use businesses, offerings do not have coordinates)
      : businessData =
            data.where((item) => item is BazaarBusinessData).map((item) => item as BazaarBusinessData).toList() {
    // construct a map using "collection for"
    bazaarBusinessDataFor.addAll({for (var business in businessData) business.coordinates: business});
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(47.389712, 8.517076),
        zoom: 15.0,
        maxZoom: 18.4,
        onTap: (_) => _popupLayerController.hideAllPopups(), // Hide popup when the map is tapped.
      ),
      children: [
        TileLayerWidget(
          options: TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
        ),
        PopupMarkerLayerWidget(
          options: PopupMarkerLayerOptions(
            popupController: _popupLayerController,
            markers: _markers,
            markerRotateAlignment: PopupMarkerLayerOptions.rotationAlignmentFor(AnchorAlign.top),
            popupBuilder: (BuildContext context, Marker marker) =>
                BusinessDetailsPopup(marker, bazaarBusinessDataFor[marker.point]),
          ),
        ),
      ],
    );
  }

  List<Marker> get _markers {
    return businessData
        .map((item) => Marker(
            point: item.coordinates,
            width: 40,
            height: 40,
            builder: (_) => Icon(Icons.location_on, size: 40, color: Colors.blueAccent),
            anchorPos: AnchorPos.align(AnchorAlign.top)))
        .toList();
  }
}

class BusinessDetailsPopup extends StatelessWidget {
  final Marker marker;
  final BazaarBusinessData dataForThisMarker;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BusinessDetail(dataForThisMarker),
            ),
          );
        },
        child: Container(
          width: 150,
          height: 70,
          padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                dataForThisMarker.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 2.0),
              ),
              Text(
                dataForThisMarker.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BusinessDetailsPopup(this.marker, this.dataForThisMarker, {Key key}) : super(key: key);
}
