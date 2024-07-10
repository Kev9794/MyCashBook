class CashFlow {
  int? _id;
  late int idUser, jumlah;
  late String tipe, tanggal, keterangan, dibuat, diperbaharui;

  CashFlow(
      {required this.idUser,
      required this.tipe,
      required this.tanggal,
      required this.jumlah,
      required this.keterangan,
      required this.dibuat,
      required this.diperbaharui});

  CashFlow.fromMap(dynamic objek) {
    _id = objek['id'];
    idUser = objek['id_user'];
    tipe = objek['type'];
    tanggal = objek['date'];
    jumlah = objek['total'];
    keterangan = objek['description'];
    dibuat = objek['created_at'];
    diperbaharui = objek['updated_at'];
  }

  int? get id => _id;
  int get id_user => idUser;
  String get type => tipe;
  String get date => tanggal;
  int get total => jumlah;
  String get description => keterangan;
  String get createdAt => dibuat;
  String get updatedAt => diperbaharui;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = _id;
    map['id_user'] = idUser;
    map['type'] = tipe;
    map['date'] = tanggal;
    map['total'] = jumlah;
    map['description'] = keterangan;
    map['created_at'] = dibuat;
    map['updated_at'] = diperbaharui;
    return map;
  }
}
