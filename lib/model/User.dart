class User {
  int? _id;
  late String namaUser, kataSandi, nama, dibuat, diperbaharui;

  User(
      {required this.namaUser,
      required this.kataSandi,
      required this.nama,
      required this.dibuat,
      required this.diperbaharui});

  User.fromMap(dynamic objek) {
    _id = objek['id'];
    namaUser = objek['username'];
    kataSandi = objek['password'];
    nama = objek['name'];
    dibuat = objek['created_at'];
    diperbaharui = objek['updated_at'];
  }

  int? get id => _id;
  String get username => namaUser;
  String get password => kataSandi;
  String get name => nama;
  String get createdAt => dibuat;
  String get updatedAt => diperbaharui;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = _id;
    map['username'] = namaUser;
    map['password'] = kataSandi;
    map['name'] = nama;
    map['created_at'] = dibuat;
    map['updated_at'] = diperbaharui;
    return map;
  }
}
