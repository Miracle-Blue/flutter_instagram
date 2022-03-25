class User {
  String _uid = "";
  String fullName = "";
  String email = "";
  String password = "";
  String imgUrl = "";

  String deviceId = "";
  String deviceType = "";
  String deviceToken = "";

  bool followed = false;
  int followersCount = 0;
  int followingCount = 0;

  User({required this.fullName, required this.email, required this.password});

  User.fromJson(Map<String, dynamic> json)
      : _uid = json['uid'],
        fullName = json['full_name'],
        email = json['email'],
        password = json['password'],
        imgUrl = json['img_url'],
        deviceId = json['device_id'],
        deviceType = json['device_type'],
        deviceToken = json['device_token'];

  Map<String, dynamic> toJson() => {
    'uid': _uid,
    'full_name': fullName,
    'email': email,
    'password': password,
    'img_url': imgUrl,
    'device_id': deviceId,
    'device_type': deviceType,
    'device_token': deviceToken,
  };


  String get uid => _uid;

  set uid(String value) {
    if (value.isNotEmpty) {
      _uid = value;
    }
  }

  @override
  bool operator == (other) {
    return (other is User) && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}