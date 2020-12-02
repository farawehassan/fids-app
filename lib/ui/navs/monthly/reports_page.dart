import 'package:fids_apparel/bloc/future_values.dart';
import 'package:fids_apparel/model/reportsDB.dart';
import 'package:fids_apparel/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fids_apparel/utils/reusable_card.dart';
import 'monthly_reports.dart';

/// A StatelessWidget class that displays all the months in a year
class ReportPage extends StatefulWidget {

  static const String id = 'reports_page';

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {

  var futureValue = FutureValues();

  var now = DateTime.now();

  List<Reports> _reports = List();

  Future<void> _getReports() async {
    Future<List<Reports>> report = futureValue.getAllReportsFromDB();
    await report.then((value) {
      if (!mounted) return;
      setState(() {
        _reports.addAll(value);
      });
    }).catchError((error){
      print(error);
      Constants.showMessage(error.toString());
    });
  }

  Widget _buildList() {
    if(_reports != null && _reports.isNotEmpty){
      return GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        children: <Widget>[
          ReusableCard(
            cardChild: 'January',
            onPress: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonthReport(month: 'Jan', reports: _reports)),
              );
            },
          ),
          ReusableCard(
            cardChild: 'Febraury',
            onPress: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonthReport(month: 'Feb', reports: _reports)),
              );
            },
          ),
          ReusableCard(
            cardChild: 'March',
            onPress: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonthReport(month: 'Mar', reports: _reports)),
              );
            },
          ),
          ReusableCard(
            cardChild: 'April',
            onPress: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonthReport(month: 'Apr', reports: _reports)),
              );
            },
          ),
          ReusableCard(
            cardChild: 'May',
            onPress: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonthReport(month: 'May', reports: _reports)),
              );
            },
          ),
          ReusableCard(
            cardChild: 'June',
            onPress: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonthReport(month: 'Jun', reports: _reports)),
              );
            },
          ),
          ReusableCard(
            cardChild: 'July',
            onPress: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonthReport(month: 'Jul', reports: _reports)),
              );
            },
          ),
          ReusableCard(
            cardChild: 'August',
            onPress: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonthReport(month: 'Aug', reports: _reports)),
              );
            },
          ),
          ReusableCard(
            cardChild: 'September',
            onPress: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonthReport(month: 'Sep', reports: _reports)),
              );
            },
          ),
          ReusableCard(
            cardChild: 'October',
            onPress: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonthReport(month: 'Oct', reports: _reports)),
              );
            },
          ),
          ReusableCard(
            cardChild: 'November',
            onPress: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonthReport(month: 'Nov', reports: _reports)),
              );
            },
          ),
          ReusableCard(
            cardChild: 'December',
            onPress: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonthReport(month: 'Dec', reports: _reports)),
              );
            },
          ),
        ],
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0XFFA6277C)),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getReports();
  }

  /// Instantiating a class of the [FutureValues]
  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Reports'),
        actions: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(right: 20),
            child: Text(
              now.year.toString(),
              style: TextStyle(
                fontSize: 18
              ),
            ),
          ),
        ],
      ),
      body: _buildList(),
    );
  }
}

