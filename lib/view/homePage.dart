import 'package:buku_kas_nusantara/view/addIncomePage.dart';
import 'package:buku_kas_nusantara/view/addOutcomePage.dart';
import 'package:buku_kas_nusantara/controller/DatabaseInstance.dart';
import 'package:buku_kas_nusantara/view/detailCashFlowPage.dart';
import 'package:buku_kas_nusantara/view/editUserPage.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomePage extends StatefulWidget {
  final int id_user;
  const HomePage({Key? key, required this.id_user}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<int> income;
  late Future<int> outcome;
  late Future<String> name;
  late Future<List<CashFlowData>> _cashFlowDataFuture;

  @override
  void initState() {
    super.initState();
    income = DatabaseInstance().totalIncome(id_user: widget.id_user);
    outcome = DatabaseInstance().totalOutcome(id_user: widget.id_user);
    name = DatabaseInstance().getName(id_user: widget.id_user);
    _cashFlowDataFuture = DatabaseInstance().getCashFlowData(widget.id_user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30),
          ),
        ),
        title: Container(
          alignment: Alignment.bottomLeft,
          child: FutureBuilder<String>(
            future: name,
            builder: (context, nameSnapshot) {
              if (nameSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (nameSnapshot.hasError) {
                return Text("Error: ${nameSnapshot.error}");
              } else {
                return Text(
                  "Selamat datang, ${nameSnapshot.data}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                );
              }
            },
          ),
        ),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.deepOrange.shade600,
      ),
      body: ListView(
        children: <Widget>[
          Center(
              child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Column(
                          children: <Widget>[
                            const Text(
                              "Rangkuman Bulan Ini",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            FutureBuilder<int>(
                              future: income,
                              builder: (context, incomeSnapshot) {
                                if (incomeSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (incomeSnapshot.hasError) {
                                  return Text("Error: ${incomeSnapshot.error}");
                                } else {
                                  return FutureBuilder<int>(
                                    future: outcome,
                                    builder: (context, outcomeSnapshot) {
                                      if (outcomeSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (outcomeSnapshot.hasError) {
                                        return Text(
                                            "Error: ${outcomeSnapshot.error}");
                                      } else {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                              child: Column(
                                                children: <Widget>[
                                                  const Text(
                                                    "Pengeluaran",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const SizedBox(
                                                    height: 2,
                                                  ),
                                                  Text(
                                                    "Rp.${outcomeSnapshot.data}",
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                              child: Column(
                                                children: <Widget>[
                                                  const Text(
                                                    "Pemasukan",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  ),
                                                  const SizedBox(
                                                    height: 2,
                                                  ),
                                                  Text(
                                                    "Rp.${incomeSnapshot.data}",
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      FutureBuilder<List<CashFlowData>>(
                        future: _cashFlowDataFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (snapshot.hasData) {
                            return SfCartesianChart(
                              primaryXAxis: DateTimeAxis(),
                              primaryYAxis: NumericAxis(),
                              series: <ChartSeries>[
                                LineSeries<CashFlowData, DateTime>(
                                  dataSource: snapshot.data!,
                                  xValueMapper: (CashFlowData data, _) =>
                                      data.date,
                                  yValueMapper: (CashFlowData data, _) =>
                                      data.nominal,
                                )
                              ],
                            );
                          } else {
                            return const Text("No data available");
                          }
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GridView.count(
                        crossAxisCount: 2, // Jumlah kolom (2 kolom)
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(20),
                        mainAxisSpacing: 20, // Spasi vertikal antara kotak
                        crossAxisSpacing: 20, // Spasi horizontal antara kotak
                        children: <Widget>[
                          SizedBox(
                            width: 150,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddIncomePage(
                                            id_user: widget.id_user,
                                          ))),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 100,
                                    color: Colors.green,
                                  ),
                                  Text("Pemasukan",
                                      style: TextStyle(
                                        fontSize: 15,
                                      )),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddOutcomePage(
                                            id_user: widget.id_user,
                                          ))),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.remove_circle_outline_rounded,
                                    size: 100,
                                    color: Colors.red,
                                  ),
                                  Text("Pengeluaran",
                                      style: TextStyle(
                                        fontSize: 15,
                                      )),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailCashFlowPage(
                                            id_user: widget.id_user,
                                          ))),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.swap_horizontal_circle_outlined,
                                    size: 100,
                                    color: Colors.deepOrange,
                                  ),
                                  Text("Detail Cash Flow",
                                      style: TextStyle(
                                        fontSize: 15,
                                      )),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditUserPage(
                                            id_user: widget.id_user,
                                          ))),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.settings_outlined,
                                    size: 100,
                                    color: Colors.blueGrey,
                                  ),
                                  Text("Pengaturan",
                                      style: TextStyle(
                                        fontSize: 15,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ))),
        ],
      ),
    );
  }
}

class CashFlowData {
  final DateTime date;
  final double nominal;

  CashFlowData(this.date, this.nominal);
}
