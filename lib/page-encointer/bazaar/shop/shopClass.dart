import 'package:encointer_wallet/service/ipfsApi/httpApi.dart';
import 'dart:convert';

class Shop {
  final String name;
  final String description;
  final String imageHash;

  Shop({this.name, this.description, this.imageHash});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      name: json['name'],
      description: json['description'],
      imageHash: json['imageHash'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'imageHash': imageHash,
      };

  Future<Shop> getShopData(shopID) async {
    final ipfsObject = await Ipfs().getJson(shopID);
    if (ipfsObject != 0) {
      return Shop.fromJson(jsonDecode(ipfsObject)); //store response as string
    } else {
      // TODO: What to do in case of non-existent URL? (i.e. node not running?)
      // in case of invalid IPFS URL
      return Shop();
    }
  }
}
