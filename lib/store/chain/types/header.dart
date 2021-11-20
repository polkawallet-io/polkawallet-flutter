/// Header retrieved via chain.subscribeNewHeads, but some fields are omitted.
class Header {
  Header(this.hash, this.number);

  String hash;
  int number;

  factory Header.fromJson(Map<String, dynamic> json) {
    return Header(json['hash'], json['number']);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'hash': this.hash, 'number': this.number};
}
