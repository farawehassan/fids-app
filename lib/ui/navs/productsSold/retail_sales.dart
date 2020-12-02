import 'package:fids_apparel/bloc/daily_report_value.dart';
import 'package:fids_apparel/bloc/future_values.dart';
import 'package:fids_apparel/model/reportsDB.dart';
import 'package:fids_apparel/utils/constants.dart';
import 'package:flutter/material.dart';

class RetailSales extends StatefulWidget {

  static const String id = 'retail_sales';

  @override
  _RetailSalesState createState() => _RetailSalesState();
}

class _RetailSalesState extends State<RetailSales> {

  /// Instantiating a class of the [DailyReportValue]
  var reportValue = DailyReportValue();

  /// Instantiating a class of the [FutureValues]
  var futureValue = FutureValues();

  /// A variable holding my report data as a map
  var _data = new Map();

  /// Variable to hold the total sales made
  double _totalSalesPrice = 0.0;

  /// Variable to hold the total profit made
  double _totalProfitMade = 0.0;

  /// Variable to hold the type of the user logged in
  String _userType;

  /// Setting the current user's type logged in to [_userType]
  void getCurrentUser() async {
    await futureValue.getCurrentUser().then((user) {
      _userType = user.type;
    }).catchError((Object error) {
      Constants.showMessage(error.toString());
    });
  }

  /// Function to get this [month] report and map [_data] it's product name to
  /// its quantity accordingly
  /// It also calls the function [getColors()]
  void getReports() async {
    Future<List<Reports>> report = futureValue.getAllReportsFromDB();
    await report.then((value) {
      if (!mounted) return;
      setState(() {
        int increment = 0;
        for(int i = 0; i < value.length; i++){
          if(value[i].paymentMode == 'Retail'){
            _totalSalesPrice += value[i].unitPrice;
            _totalProfitMade += value[i].unitPrice - value[i].costPrice;
          }

          if(_data.containsKey(value[i].productName) && value[i].paymentMode == 'Retail'){
            _data[value[i].productName] = [
              _data[value[i].productName][0],
              _data[value[i].productName][1] + value[i].yards,
              _data[value[i].productName][2] + value[i].unitPrice,
              _data[value[i].productName][3] + (value[i].unitPrice - value[i].costPrice),
            ];
          }else if(value[i].paymentMode == 'Retail' && !(_data.containsKey(value[i].productName))){
            _data[value[i].productName] = [
              increment,
              value[i].yards,
              value[i].unitPrice,
              value[i].unitPrice - value[i].costPrice
            ];
            increment++;
          }
        }
      });
    }).catchError((onError){
      print(onError.toString());
      Constants.showMessage(onError.toString());
    });
  }

  /// A function to build the the list and send a list of map to build the
  /// data table by calling [_dataTable]
  Widget _buildList() {
    if(_data.length > 0 && _data.isNotEmpty){
      List<Map> _filteredSales = [];
      _data.forEach((k,v) {
        var value = new Map();
        value['sn'] = v[0];
        value['product'] = k;
        value['quantitySold'] = v[1];
        value['totalSales'] = v[2];
        value['profit'] =  v[3];

        _filteredSales.add(value);
      });
      return _dataTable(_filteredSales);
    }
    else{
      Container(
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

  /// Creating a [DataTable] widget from a List of Map [salesList]
  /// using SN, PRODUCT, QUANTITY SOLD, TOTAL PRICE, PROFIT MADE as DataColumn
  /// and the values of each DataColumn in the [salesList] as DataRows with
  /// a container to show the [_totalSalesPrice] and the [_totalProfitMade]
  SingleChildScrollView _dataTable(List<Map> salesList){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: <Widget>[
          DataTable(
            columnSpacing: 20.0,
            columns: _userType == 'Admin' ? [
              DataColumn(label: Text('SN', style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('PRODUCT', style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('YARDS', style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('TOTAL PRICE', style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('PROFIT MADE', style: TextStyle(fontWeight: FontWeight.bold),)),
            ] : [
              DataColumn(label: Text('SN', style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('PRODUCT', style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('YARDS', style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('TOTAL PRICE', style: TextStyle(fontWeight: FontWeight.bold),)),
            ],
            rows: salesList.map((report) => DataRow(
                cells: _userType == 'Admin' ? [
                  DataCell(Text(report['sn'].toString()),),
                  DataCell(Text(report['product'].toString()),),
                  DataCell(Text(report['quantitySold'].toString()),),
                  DataCell(Text(Constants.money(report['totalSales'])),),
                  DataCell(Text(Constants.money(report['profit'])))
                ] : [
                  DataCell(Text(report['sn'].toString()),),
                  DataCell(Text(report['product'].toString()),),
                  DataCell(Text(report['quantitySold'].toString()),),
                  DataCell(Text(Constants.money(report['totalSales']))),
                ]
            )).toList(),
          ),
          Container(
            margin: EdgeInsets.only(left: 5.0, right: 40.0),
            padding: EdgeInsets.only(right: 20.0, top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'TOTAL SALES = ',
                  style: TextStyle(
                      fontWeight: FontWeight.w600
                  ),
                ),
                Text(
                  '${Constants.money(_totalSalesPrice)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0XFFA6277C),
                  ),
                ),
              ],
            ),
          ),
          _userType == 'Admin' ? Container(
            margin: EdgeInsets.only(left: 5.0, right: 40.0),
            padding: EdgeInsets.only(right: 20.0, top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'ESTIMATED PROFITS = ',
                  style: TextStyle(
                      fontWeight: FontWeight.w600
                  ),
                ),
                Text(
                  '${Constants.money(_totalProfitMade)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0XFFA6277C),
                  ),
                ),
              ],
            ),
          ) : Container(),
        ],
      ),
    );
  }

  /// It calls [getReports()] and [getCurrentUser()] while initializing my state
  @override
  void initState() {
    super.initState();
    getReports();
    getCurrentUser();
  }

  /// It doesn't show user's [_totalProfitMade] if the [_userType] is not 'Admin'
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Retail Sales')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          reverse: false,
          child: _buildList(),
        ),
      ),
    );
  }

}
