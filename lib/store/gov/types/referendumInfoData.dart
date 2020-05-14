class ReferendumInfo extends _ReferendumInfo {
  static ReferendumInfo fromJson(Map<String, dynamic> json, String address) {
    ReferendumInfo info = ReferendumInfo();
    info.index = json['index'];
    info.imageHash = json['imageHash'];
    info.status = json['status'];
    info.image = json['image'];
    info.detail = json['detail'];

    info.votedAye = json['votedAye'].toString();
    info.votedNay = json['votedNay'].toString();
    info.votedTotal = json['votedTotal'].toString();

    info.userVoted = 0;
    json['votes'].forEach((i) {
      if (i['accountId'] == address) {
        if (int.parse(i['vote'].toString()) > 0) {
          info.userVoted = 1;
        } else {
          info.userVoted = -1;
        }
      }
    });
    return info;
  }
}

abstract class _ReferendumInfo {
  int index;
  String imageHash;

  String votedAye;
  String votedNay;
  String votedTotal;

  Map<String, dynamic> status;
  Map<String, dynamic> image;
  Map<String, dynamic> detail;

  int userVoted;
}
