class DecodeTokenModel {
  int? ver;
  String? jti;
  String? iss;
  String? aud;
  String? sub;
  int? iat;
  int? exp;
  String? cid;
  String? uid;
  List<String>? scp;
  int? authTime;

  DecodeTokenModel(
      {this.ver,
        this.jti,
        this.iss,
        this.aud,
        this.sub,
        this.iat,
        this.exp,
        this.cid,
        this.uid,
        this.scp,
        this.authTime});

  DecodeTokenModel.fromJson(Map<String, dynamic> json) {
    ver = json['ver'];
    jti = json['jti'];
    iss = json['iss'];
    aud = json['aud'];
    sub = json['sub'];
    iat = json['iat'];
    exp = json['exp'];
    cid = json['cid'];
    uid = json['uid'];
    scp = json['scp'].cast<String>();
    authTime = json['auth_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ver'] = this.ver;
    data['jti'] = this.jti;
    data['iss'] = this.iss;
    data['aud'] = this.aud;
    data['sub'] = this.sub;
    data['iat'] = this.iat;
    data['exp'] = this.exp;
    data['cid'] = this.cid;
    data['uid'] = this.uid;
    data['scp'] = this.scp;
    data['auth_time'] = this.authTime;
    return data;
  }
}
