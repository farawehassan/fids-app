import 'package:fids_apparel/model/reportsDB.dart';
import 'package:fids_apparel/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fids_apparel/bloc/daily_report_value.dart';
import 'package:fids_apparel/bloc/daily_report_chart.dart';
import 'package:fids_apparel/utils/reusable_card.dart';
import 'package:fids_apparel/bloc/future_values.dart';
import 'daily_report_list.dart';

/// A StatefulWidget class that displays the Today's Reports details
class DailyReports extends StatefulWidget {

  static const String id = 'daily_reports';

  @override
  _DailyReportsState createState() => _DailyReportsState();
}

class _DailyReportsState extends State<DailyReports> {

  /// Instantiating a class of the [DailyReportValue]
  var reportValue = DailyReportValue();

  /// Instantiating a class of the [FutureValues]
  var futureValue = FutureValues();

  /// Variable to hold the total availableCash of today's report
  double _availableCash = 0.0;

  /// Variable to hold the total totalTransfer of today's report
  double _totalTransfer = 0.0;

  /// Variable to hold the total ProfitMade in today's report
  double _totalProfitMade = 0.0;

  /// Variable to hold the type of the user logged in
  String _userType;

  /// Setting the current user's type logged in to [_userType]
  void _getCurrentUser() async {
    await futureValue.getCurrentUser().then((user) {
      _userType = user.type;
    }).catchError((Object error) {
      print(error.toString());
    });
  }

  /// Calculating profit of a particular DailyReportsData [data],
  /// if the data's payment mode is not 'Iya Bimbo'
  ///  profitMade = data's quantity * (data's unitPrice - data's costPrice)
  ///
  /// Increment [_totalProfitMade] with the result of profitMade
  void _calculateProfit(Reports data) async {
    if(data.paymentMode != 'Retail'){
      if (!mounted) return;
      setState(() {
        _totalProfitMade += (data.unitPrice - data.costPrice);
      });
    }
  }

  /// Getting today's reports from the dailyReportsDatabase based on time
  /// Calls [_calculateProfit(report)] on every report that is today
  ///
  /// Increments [_availableCash] with the value of report's totalPrice,
  /// If the payment's mode of a report is cash
  ///
  /// Increments [_totalTransfer] with the value of report's totalPrice,
  /// If the payment's mode of a report is transfer
  void _getReports() async {
    Future<List<Reports>> report = futureValue.getAllReportsFromDB();
    await report.then((value) {
      if (!mounted) return;
      setState(() {
        for(int i = 0; i < value.length; i++){
          if(reportValue.checkIfToday(value[i].createdAt)){
            _calculateProfit(value[i]);
            if(value[i].paymentMode == 'Cash'){
              _availableCash += value[i].unitPrice;
            }
            else if(value[i].paymentMode == 'Transfer'){
              _totalTransfer += value[i].unitPrice;
            }
          }
        }
      });
    }).catchError((error){
      print(error);
      Constants.showMessage(error.toString());
    });
  }

  /// Calls [_getCurrentUser()] and [_getReports()]
  /// before the class builds its widgets
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getReports();
  }

  /// Building a Scaffold Widget to display today's report, [DailyChart],
  /// [_availableCash], [_totalTransfer], totalCash and [_totalProfitMade] if
  /// the user is an Admin
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
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          reverse: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ReusableCard(
                cardChild: 'Today\'s Sales',
                onPress: (){
                  Navigator.pushNamed(context, DailyReportList.id);
                },
              ),
              SizedBox(height: 40.0,),
              DailyChart(),
              SizedBox(height: 40.0,),
              Container(
                padding: EdgeInsets.all(15.0),
                margin: EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    titleText('Available Cash: ${Constants.money(_availableCash)}'),
                    SizedBox(height: 8.0,),
                    titleText('Transferred Cash: ${Constants.money(_totalTransfer)}'),
                    SizedBox(height: 8.0,),
                    titleText('Total Cash: ${Constants.money(_availableCash + _totalTransfer)}'),
                    SizedBox(height: 8.0,),
                    _userType == 'Admin' ? titleText('Profit made: ${Constants.money(_totalProfitMade)}') : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}