import 'package:fids_apparel/bloc/daily_report_value.dart';
import 'package:fids_apparel/bloc/future_values.dart';
import 'package:fids_apparel/model/reportsDB.dart';
import 'package:fids_apparel/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A StatelessWidget class that displays detailed list of items sold today
class DailyReportList extends StatefulWidget {

  static const String id = 'daily_report_list';

  @override
  _DailyReportListState createState() => _DailyReportListState();
}

class _DailyReportListState extends State<DailyReportList> {

  /// Instantiating a class of the [DailyReportValue]
  var reportValue = DailyReportValue();

  /// Instantiating a class of the [FutureValues]
  final futureValue = FutureValues();

  /// A Map to hold the report's data
  Map _data = {};

  /// A List to hold the Map of the report's data above
  List<Map> _reports = [];

  /// An integer variable to hold the length of the reports above
  int _reportLength;

  /// Converting [dateTime] in string format to return a formatted time
  /// of hrs, minutes and am/pm
  String _getFormattedTime(String dateTime) {
    return DateFormat('h:mm a').format(DateTime.parse(dateTime)).toString();
  }

  /// Creating a [DataTable] widget from a List of Map [salesList]
  /// using QTY, PRODUCT, UNIT, TOTAL, PAYMENT, TIME as DataColumn and
  /// the values of each DataColumn in the [salesList] as DataRows
  SingleChildScrollView _dataTable(List<Map> salesList){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20.0,
        columns: [
          DataColumn(label: Text('YARDS', style: TextStyle(fontWeight: FontWeight.bold),)),
          DataColumn(label: Text('PRODUCT', style: TextStyle(fontWeight: FontWeight.bold),)),
          DataColumn(label: Text('PRINT', style: TextStyle(fontWeight: FontWeight.bold),)),
          DataColumn(label: Text('TAILOR', style: TextStyle(fontWeight: FontWeight.bold),)),
          DataColumn(label: Text('UNIT', style: TextStyle(fontWeight: FontWeight.bold),)),
          DataColumn(label: Text('PAYMENT', style: TextStyle(fontWeight: FontWeight.bold),)),
          DataColumn(label: Text('TIME', style: TextStyle(fontWeight: FontWeight.bold),)),
        ],
        rows: salesList.map((report) => DataRow(
            cells: [
              DataCell(
                Text(report['qty'].toString()),
              ),
              DataCell(
                Text(report['productName'].toString()),
              ),
              DataCell(
                Text(Constants.money(report['printPrice'])),
              ),
              DataCell(
                Text(Constants.money(report['tailorPrice'])),
              ),
              DataCell(
                Text(Constants.money(report['unitPrice'])),
              ),
              DataCell(
                Text(report['paymentMode']),
              ),
              DataCell(
                Text(_getFormattedTime(report['time'])),
              ),
            ]
        )).toList(),
      ),
    );
  }

  Future<void> _getReports() async {
    Future<List<Reports>> report = futureValue.getAllReportsFromDB();
    await report.then((value) {
      if (!mounted) return;
      setState(() {
        for(int i = 0; i < value.length; i++){
          if(reportValue.checkIfToday(value[i].createdAt)){
            _data = {
              'qty':value[i].yards,
              'productName': value[i].productName,
              'printPrice':value[i].printPrice,
              'tailorPrice':value[i].tailorPrice,
              'unitPrice':value[i].unitPrice,
              'paymentMode':value[i].paymentMode,
              'time':value[i].createdAt
            };
            _reports.add(_data);
          }
        }
        _reportLength = _reports.length;
      });
    }).catchError((e){
      print(e);
      Constants.showMessage(e.toString());
    });
  }

  /// Function to build a detailed list of today's report
  /// in [_dataTable()] format
  Widget _buildList(){
    if(_reports.length > 0 && _reports.isNotEmpty){
      return _dataTable(_reports);
    }
    else if(_reportLength == 0){
      return Container(
        alignment: AlignmentDirectional.center,
        child: Center(child: Text("No sales yet")),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0XFFA6277C)),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getReports();
  }
  /// Building a Scaffold Widget to display a detailed list of today's report
  /// in [_dataTable()] format
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE, d MMM').format(now);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Today\'s Sales'),
            Text(formattedDate),
          ],
        ),
      ),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          reverse: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              _buildList()
            ],
          )
      ),
    );
  }
}
