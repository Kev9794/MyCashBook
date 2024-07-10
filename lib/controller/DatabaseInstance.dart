import 'dart:io';
import 'package:buku_kas_nusantara/view/homePage.dart';
import 'package:buku_kas_nusantara/view/loginPage.dart';
import 'package:buku_kas_nusantara/model/CashFlow.dart';
import 'package:buku_kas_nusantara/model/User.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseInstance {
  final String _databaseName = "databaseBKN.db";
  final int _databaseVersion = 1;

  // Database User
  final String _tableUser = "user";
  final String _columnIdUser = "id";
  final String _columnUsername = "username";
  final String _columnPassword = "password";
  final String _columnName = "name";
  final String _columnStatus = "is_logged_in";
  final String _columnCreatedAtUser = "created_at";
  final String _columnUpdatedAtUser = "updated_at";

  // Database CashFlow
  final String _tableCashFlow = "user_CashFlow";
  final String _columnIdCashFlow = "id";
  final String _columnIdUserCashFlow = "id_user";
  final String _columnTypeCashFlow = "type";
  final String _columnDateCashFlow = "date";
  final String _columnTotalCashFlow = "total";
  final String _columnDescriptionCashFlow = "description";
  final String _columnCreatedAtCashFlow = "created_at";
  final String _columnUpdatedAtCashFlow = "updated_at";

  Database? _database;
  // Cek Apakah Database Sudah Ada
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Create Database
    _database = await _initDatabase();
    return _database!;
  }

  // Mencari Database Di Directory
  Future _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, _databaseName);
    try {
      _database = await openDatabase(path,
          version: _databaseVersion, onCreate: _onCreate);
      return _database;
    } catch (e) {
      print('Error saat membuka database: $e');
      return null;
    }
  }

  // Membuat Tabel
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $_tableUser (
      $_columnIdUser INTEGER PRIMARY KEY AUTOINCREMENT, 
      $_columnUsername TEXT, 
      $_columnPassword TEXT, 
      $_columnName TEXT, 
      $_columnStatus TEXT, 
      $_columnCreatedAtUser TEXT, 
      $_columnUpdatedAtUser TEXT)
      ''');

    await db.execute('''
    CREATE TABLE $_tableCashFlow (
      $_columnIdCashFlow INTEGER PRIMARY KEY AUTOINCREMENT, 
      $_columnIdUserCashFlow INTEGER, 
      $_columnTypeCashFlow TEXT, 
      $_columnDateCashFlow TEXT, 
      $_columnTotalCashFlow INTEGER, 
      $_columnDescriptionCashFlow TEXT, 
      $_columnCreatedAtCashFlow TEXT, 
      $_columnUpdatedAtCashFlow TEXT,
      FOREIGN KEY ($_columnIdUserCashFlow) REFERENCES $_tableUser ($_columnIdUser))
      ''');
  }

  // Insert Database
  Future<int> createUser(User user) async {
    final db = await database;
    return await db.insert(_tableUser, user.toMap());
  }

  // Mencari User Berdasarkan Username
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      _tableUser,
      where: '$_columnUsername = ?',
      whereArgs: [username],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // Mencari User Berdasarkan ID
  Future<User?> getUserById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      _tableUser,
      where: '$_columnIdUser = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // Login
  Future<void> login(
      String username, String password, BuildContext context) async {
    User? user = await DatabaseInstance().getUserByUsername(username);
    if (user != null && user.password == password) {
      // Login berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  id_user: user.id!,
                )),
      );
    } else {
      // Gagal login
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Username atau password salah.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Register
  Future<void> register(String username, String password, String name,
      BuildContext context) async {
    User? user = User(
      namaUser: username,
      kataSandi: password,
      nama: name,
      dibuat: DateTime.now().toString(),
      diperbaharui: DateTime.now().toString(),
    );
    int result = await DatabaseInstance().createUser(user);
    if (result > 0) {
      // Registrasi berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      // Gagal registrasi
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Gagal registrasi. Silakan coba lagi.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Ubah Password
  Future<void> changePassword(
      int id, String password, String newPassword, BuildContext context) async {
    User? user = await DatabaseInstance().getUserById(id);
    if (user != null && user.password == password) {
      // Password lama sesuai, update password di objek user
      user.kataSandi = newPassword;
      user.dibuat = DateTime.now().toString();

      // Lakukan UPDATE ke database
      final db = await DatabaseInstance().database;
      await db.update(
        DatabaseInstance()._tableUser, // Nama tabel yang sesuai
        user.toMap(), // Data yang diperbarui
        where: '${DatabaseInstance()._columnIdUser} = ?', // Kriteria WHERE
        whereArgs: [id], // Parameter WHERE
      );
      // Kembali ke halaman login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      // Password lama tidak sesuai
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Password lama tidak sesuai.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Insert Database CashFlow
  Future<int?> createCashFlow(CashFlow flow) async {
    final db = await database;
    return await db.insert(_tableCashFlow, flow.toMap());
  }

  // Tambah Pendapatan
  Future<void> addIncome(int id_user, String date, int total,
      String description, BuildContext context) async {
    // Buat objek CashFlow
    CashFlow? flow = CashFlow(
      idUser: id_user,
      tipe: 'income',
      tanggal: date,
      jumlah: total,
      keterangan: description,
      dibuat: DateTime.now().toString(),
      diperbaharui: DateTime.now().toString(),
    );
    // Insert ke database
    int? result = await DatabaseInstance().createCashFlow(flow);
    if (result! > 0) {
      // Tambah pendapatan berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(id_user: id_user)),
      );
    } else {
      // Gagal menambahkan pendapatan
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Gagal menambahkan. Silakan coba lagi.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Tambah Pengeluaran
  Future<void> addOutcome(int id_user, String date, int total,
      String description, BuildContext context) async {
    // Buat objek CashFlow
    CashFlow flow = CashFlow(
      idUser: id_user,
      tipe: 'outcome',
      tanggal: date,
      jumlah: total,
      keterangan: description,
      dibuat: DateTime.now().toString(),
      diperbaharui: DateTime.now().toString(),
    );
    // Insert ke database
    int? result = await DatabaseInstance().createCashFlow(flow);
    if (result! > 0) {
      // Tambah pengeluaran berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(id_user: id_user)),
      );
    } else {
      // Gagal menambahkan pengeluaran
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Gagal menambahkan. Silakan coba lagi.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Mengambil semua data CashFlow User Login
  Future<List<CashFlow>> all(int id_user) async {
    final db = await database;
    // cek apakah database sudah terbuka
    if (_database != null) {
      final data = await db.query(
            _tableCashFlow,
            where: '$_columnIdUserCashFlow = ?',
            whereArgs: [id_user],
          ) ??
          [];
      List<CashFlow> result = data.map((e) => CashFlow.fromMap(e)).toList();
      // Memeriksa dan mengganti nilai null jika diperlukan
      for (var flow in result) {
        if (flow.jumlah == null) {
          flow.jumlah = 0; // Ganti dengan nilai default atau nilai yang sesuai
        }
        if (flow.keterangan == null) {
          flow.keterangan =
              ""; // Ganti dengan nilai default atau nilai yang sesuai
        }
      }
      print(result);
      return result;
    } else {
      print('Database belum terbuka');
      return [];
    }
  }

  // Menghitung total pendapatan
  Future<int> totalIncome({required int id_user}) async {
    // cek apakah database sudah terbuka
    final db = await database;
    int income = 0; // Inisialisasi dengan nilai 0
    if (_database != null) {
      final data = await db.query(
            _tableCashFlow,
            where: '$_columnIdUserCashFlow = ? AND $_columnTypeCashFlow = ?',
            whereArgs: [id_user, "income"],
          ) ??
          [];
      List<CashFlow> result = data.map((e) => CashFlow.fromMap(e)).toList();
      // Menjumlahkan total pendapatan
      for (var flow in result) {
        income += flow.total;
      }
      return income;
    } else {
      return income; // Return 0 jika database belum terbuka
    }
  }

  // Menghitung total pengeluaran
  Future<int> totalOutcome({required int id_user}) async {
    // cek apakah database sudah terbuka
    final db = await database;
    int outcome = 0; // Inisialisasi dengan nilai 0
    if (_database != null) {
      final data = await db.query(
            _tableCashFlow,
            where: '$_columnIdUserCashFlow = ? AND $_columnTypeCashFlow = ?',
            whereArgs: [id_user, "outcome"],
          ) ??
          [];
      List<CashFlow> result = data.map((e) => CashFlow.fromMap(e)).toList();
      // Menjumlahkan total pendapatan
      for (var flow in result) {
        outcome += flow.total;
      }
      return outcome;
    } else {
      return outcome; // Return 0 jika database belum terbuka
    }
  }

  // Mengambil data nama user
  Future<String> getName({required int id_user}) async {
    User? user = await DatabaseInstance().getUserById(id_user);
    return user!.name;
  }

  // Mengambil data cash flow untuk grafik
  Future<List<CashFlowData>> getCashFlowData(int id_user) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableCashFlow,
      where: '$_columnIdUserCashFlow = ?',
      whereArgs: [id_user],
      orderBy: '$_columnDateCashFlow ASC', // Order by date ascending
    );

    if (maps.isNotEmpty) {
      return maps.map((map) {
        return CashFlowData(
          DateTime.parse(map[_columnDateCashFlow]),
          map[_columnTotalCashFlow].toDouble(),
        );
      }).toList();
    } else {
      return [];
    }
  }
}
