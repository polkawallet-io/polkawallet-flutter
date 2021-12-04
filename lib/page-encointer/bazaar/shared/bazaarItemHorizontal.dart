import 'package:encointer_wallet/page-encointer/bazaar/2_offerings/offeringDetail.dart';
import 'package:encointer_wallet/page-encointer/bazaar/3_businesses/businessDetail.dart';
import 'package:flutter/material.dart';

import 'data_model/model/bazaarItemData.dart';

class HorizontalBazaarItemList extends StatelessWidget {
  HorizontalBazaarItemList(this.data, this.rowTitle, this.cardHeight, this.cardWidth);

  final List<BazaarItemData> data;
  final double cardHeight;
  final String rowTitle;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        rowTitle,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 2),
      ),
      SizedBox(
        height: cardHeight, // otherwise ListView would use infinite height
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemExtent: cardWidth,
          itemCount: data != null ? data.length : 0,
          itemBuilder: (context, index) => BazaarItemHorizontal(data: data, index: index),
        ),
      ),
    ]);
  }
}

class BazaarItemHorizontal extends StatelessWidget {
  const BazaarItemHorizontal({
    Key key,
    @required this.data,
    @required this.index,
  }) : super(key: key);

  final List<BazaarItemData> data;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: data[index].cardColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
        Radius.circular(15),
      )),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  (data[index] is BazaarBusinessData) ? BusinessDetail(data[index]) : OfferingDetail(data[index]),
            ),
          );
        },
        child: Column(children: [
          AspectRatio(
            aspectRatio: 1.6,
            child: _ImageWithOverlaidIcon(data: data, index: index),
          ),
          Text(
            "${data[index].title}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 30),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Text(
              "${data[index].description}",
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
      ),
    );
  }
}

class _ImageWithOverlaidIcon extends StatelessWidget {
  const _ImageWithOverlaidIcon({
    Key key,
    @required this.data,
    @required this.index,
  }) : super(key: key);

  final List<BazaarItemData> data;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ClipRRect(
          child: data[index].image,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(15),
            bottom: Radius.circular(0),
          )),
      Positioned(
          // opaque background to icon
          child: Opacity(
            opacity: .4,
            child: Container(height: 24, width: 24, color: Colors.white),
          ),
          right: 0),
      Positioned(child: data[index].icon, right: 0),
    ]);
  }
}
