import 'dart:io';

import 'package:flutter/material.dart';
import 'package:encointer_wallet/service/ipfsApi/httpApi.dart';
import 'package:encointer_wallet/config/consts.dart';

class MockIpfs extends Ipfs {
  MockIpfs({gateway = ipfs_gateway_local}) : super(gateway: gateway);

  @override
  Future getJson(String cid) async {
    _log("unimplemented getJson");
  }

  @override
  Image getCommunityIcon(String cid, double devicePixelRatio) {
    return Image.asset('assets/images/assets/Assets_nav_0.png');
  }

  @override
  Future<String> uploadImage(File image) async {
    _log("unimplemented uploadImage");
    return "unimplemented uploadImage";
  }

  @override
  Future<String> uploadJson(Map<String, dynamic> json) async {
    _log("unimplemented uploadJson");
    return "unimplemented uploadJson";
  }
}

void _log(String msg) {
  print("[MockIpfs]: msg");
}
