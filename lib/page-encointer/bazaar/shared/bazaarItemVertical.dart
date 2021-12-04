import 'package:encointer_wallet/page-encointer/bazaar/2_offerings/offeringDetail.dart';
import 'package:encointer_wallet/page-encointer/bazaar/3_businesses/businessDetail.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/bazaarItemVerticalState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'data_model/model/bazaarItemData.dart';

class BazaarItemVertical extends StatelessWidget {
  const BazaarItemVertical({
    Key key,
    this.data,
    this.index,
    this.cardHeight,
  }) : super(key: key);

  final List<BazaarItemData> data;
  final int index;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    BazaarItemVerticalState tempState = BazaarItemVerticalState(); // TODO make it a descendant of BazaarMainState
    return Card(
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
        child: SizedBox(
          height: cardHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: .8,
                child: Stack(children: [
                  Center(
                    child: data[index].image,
                  ),
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Observer(
                      builder: (BuildContext context) => IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: tempState.toggleLiked,
                        icon: tempState.liked
                            ? Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                              )
                            : Icon(
                                Icons.favorite_border,
                                color: Colors.blueGrey,
                              ),
                      ),
                    ),
                  )
                ]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 2, 4),
                  child: _ItemDescription(
                    title: data[index].title,
                    description: data[index].description,
                    info: data[index].info.toString(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemDescription extends StatelessWidget {
  const _ItemDescription({
    Key key,
    this.title,
    this.description,
    this.info,
  }) : super(key: key);

  final String title;
  final String description;
  final String info;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                info,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
