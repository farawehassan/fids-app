import 'package:fids_apparel/database/user_db_helper.dart';
import 'package:fids_apparel/model/product_history.dart';
import 'package:fids_apparel/model/reportsDB.dart';
import 'package:fids_apparel/model/productDB.dart';
import 'package:fids_apparel/model/store_details.dart';
import 'package:fids_apparel/model/user.dart';
import 'package:fids_apparel/networking/rest_data.dart';
import 'daily_report_value.dart';
import 'package:fids_apparel/model/linear_sales.dart';

/// A class to handle my asynchronous methods linking to the server or database
class FutureValues{

  /// Method to get the current [user] in the database using the
  /// [DatabaseHelper] class
  Future<User> getCurrentUser() async {
    var dbHelper = DatabaseHelper();
    Future<User> user = dbHelper.getUser();
    return user;
  }

  /// Method to get all the products from the database in the server with
  /// the help of [RestDataSource]
  /// It returns a list of [Product]
  Future<List<Product>> getAllProductsFromDB() {
    var data = RestDataSource();
    Future<List<Product>> product = data.fetchAllProducts();
    return product;
  }

  /// Method to get all the products from the database in the server that its
  /// [currentQuantity] is not 0 with the help of [RestDataSource]
  /// It returns a list of [Product]
  Future<List<Product>> getAvailableProductsFromDB() async {
    List<Product> products = List();
    Future<List<Product>> availableProduct = getAllProductsFromDB();
    await availableProduct.then((value){
      for(int i = 0; i < value.length; i++){
        if(double.parse(value[i].currentQuantity) != 0.0){
          products.add(value[i]);
        }
      }
    }).catchError((e){
      throw e;
    });
    return products;
  }

  /// Method to get all the products from the database in the server that its
  /// [currentQuantity] is = 0 with the help of [RestDataSource]
  /// It returns a list of [Product]
  Future<List<Product>> getFinishedProductFromDB() async {
    List<Product> products = List();
    Future<List<Product>> finishedProduct = getAllProductsFromDB();
    await finishedProduct.then((value){
      for(int i = 0; i < value.length; i++){
        if(double.parse(value[i].currentQuantity) == 0.0){
          products.add(value[i]);
        }
      }
    }).catchError((e){
      throw e;
    });
    return products;
  }

  /// Method to get all the product history from the database in the server with
  /// the help of [RestDataSource]
  /// It returns a list of [ProductHistory]
  Future<List<ProductHistory>> getAllProductsHistoryFromDB() {
    var data = RestDataSource();
    Future<List<ProductHistory>> productHistory = data.fetchAllProductHistory();
    return productHistory;
  }

  /// Method to get a particular the product history from the database
  /// in the server with the help of [RestDataSource]
  /// It returns a list of [ProductHistory]
  Future<ProductHistory> getAProductHistoryFromDB(String id) {
    var data = RestDataSource();
    Future<ProductHistory> productHistory = data.findProductHistory(id);
    return productHistory;
  }

  /// Method to get all the reports from the database in the server with
  /// the help of [RestDataSource]
  /// It returns a list of [Reports]
  Future<List<Reports>> getAllReportsFromDB() {
    var data = RestDataSource();
    Future<List<Reports>> dailyReportData = data.fetchAllReports();
    return dailyReportData;
  }

  /// Method to get today's reports from [DailyReportValue] based on time by
  /// calling the [getTodayReport]
  /// It returns a list of [Reports]
  Future<List<Reports>> getTodayReports() {
    var reportValue = DailyReportValue();
    Future<List<Reports>> todayReport = reportValue.getTodayReport();
    return todayReport;
  }


  /// Method to get all the store details such as:
  ///  cost price net worth, selling price net worth, number of product items,
  ///  total sales made, totalProfitMade
  /// It returns a model of [StoreDetails]
  Future<StoreDetails> getStoreDetails() async {
    var data = RestDataSource();
    Future<StoreDetails> storeDetails = data.fetchStoreDetails();
    return storeDetails;
  }

  /// Method to get report of a [month] using the class [DailyReportValue]
  /// /// It returns a list of [Reports]
  List<Reports> getMonthReports(String month, List<Reports> reports) {
    var reportValue = DailyReportValue();

    switch(month) {
      case 'Jan': {
        List<Reports> monthReport = reportValue.getJanReport(reports);
        return monthReport;
      }
      break;

      case 'Feb': {
        List<Reports> monthReport = reportValue.getFebReport(reports);
        return monthReport;
      }
      break;

      case 'Mar': {
        List<Reports> monthReport = reportValue.getMarReport(reports);
        return monthReport;
      }
      break;

      case 'Apr': {
        List<Reports> monthReport = reportValue.getAprReport(reports);
        return monthReport;
      }
      break;

      case 'May': {
        List<Reports> monthReport = reportValue.getMayReport(reports);
        return monthReport;
      }
      break;

      case 'Jun': {
        List<Reports> monthReport = reportValue.getJunReport(reports);
        return monthReport;
      }
      break;

      case 'Jul': {
        List<Reports> monthReport = reportValue.getJulReport(reports);
        return monthReport;
      }
      break;

      case 'Aug': {
        List<Reports> monthReport = reportValue.getAugReport(reports);
        return monthReport;
      }
      break;

      case 'Sep': {
        List<Reports> monthReport = reportValue.getSepReport(reports);
        return monthReport;
      }
      break;

      case 'Oct': {
        List<Reports> monthReport = reportValue.getOctReport(reports);
        return monthReport;
      }
      break;

      case 'Nov': {
        List<Reports> monthReport = reportValue.getNovReport(reports);
        return monthReport;
      }
      break;

      case 'Dec': {
        List<Reports> monthReport = reportValue.getDecReport(reports);
        return monthReport;
      }
      break;

      default: {
        return null;
      }
      break;
    }

  }

  /// Method to get report of a year by accumulating the report of each month
  /// using the [LinearSales] model by calculating the [totalSales] as the
  /// sum of every [totalPrice] in the [DailyReportValue] if its [paymentMode]
  /// != 'Iya Bimbo' and also calculating the profit using [calculateProfit()] function
  /// It returns a list of [LinearSales]
  List<LinearSales> getYearReports(List<Reports> reports) {
    List<LinearSales> sales = List();
    var reportValue = DailyReportValue();

    List<Reports> janReport = reportValue.getJanReport(reports);
    LinearSales janLinearSales = LinearSales();
    double janTotalProfitMade = 0.0;
    double janTotalSales = 0;
    for(int i = 0; i < janReport.length; i++){
      if(janReport[i].paymentMode != 'Retail'){
        janTotalProfitMade += janReport[i].unitPrice - janReport[i].costPrice;
        janTotalSales += janReport[i].unitPrice;
      }
    }
    janLinearSales.month = 'Jan';
    janLinearSales.sales = janTotalSales;
    janLinearSales.profit = janTotalProfitMade;
    sales.add(janLinearSales);

    List<Reports> febReport = reportValue.getFebReport(reports);
    LinearSales febLinearSales = LinearSales();
    double febTotalProfitMade = 0.0;
    double febTotalSales = 0;
    for(int i = 0; i < febReport.length; i++){
      if(febReport[i].paymentMode != 'Retail'){
        febTotalProfitMade += febReport[i].unitPrice - febReport[i].costPrice;
        febTotalSales += febReport[i].unitPrice;
      }
    }
    febLinearSales.month = 'Feb';
    febLinearSales.sales = febTotalSales;
    febLinearSales.profit = febTotalProfitMade;
    sales.add(febLinearSales);

    List<Reports> marReport = reportValue.getMarReport(reports);
    LinearSales marLinearSales = LinearSales();
    double marTotalProfitMade = 0.0;
    double marTotalSales = 0;
    for(int i = 0; i < marReport.length; i++){
      if(marReport[i].paymentMode != 'Retail'){
        marTotalProfitMade += marReport[i].unitPrice - marReport[i].costPrice;
        marTotalSales += marReport[i].unitPrice;
      }
    }
    marLinearSales.month = 'Mar';
    marLinearSales.sales = marTotalSales;
    marLinearSales.profit = marTotalProfitMade;
    sales.add(marLinearSales);

    List<Reports> aprReport = reportValue.getAprReport(reports);
    LinearSales aprLinearSales = LinearSales();
    double aprTotalProfitMade = 0.0;
    double aprTotalSales = 0;
    for(int i = 0; i < aprReport.length; i++){
      if(aprReport[i].paymentMode != 'Retail'){
        aprTotalProfitMade += aprReport[i].unitPrice - aprReport[i].costPrice;
        aprTotalSales += aprReport[i].unitPrice;
      }
    }
    aprLinearSales.month = 'Apr';
    aprLinearSales.sales = aprTotalSales;
    aprLinearSales.profit = aprTotalProfitMade;
    sales.add(aprLinearSales);

    List<Reports> mayReport = reportValue.getMayReport(reports);
    LinearSales mayLinearSales = LinearSales();
    double mayTotalProfitMade = 0.0;
    double mayTotalSales = 0;
    for(int i = 0; i < mayReport.length; i++){
      if(mayReport[i].paymentMode != 'Retail'){
        mayTotalProfitMade += mayReport[i].unitPrice - mayReport[i].costPrice;
        mayTotalSales += mayReport[i].unitPrice;
      }
    }
    mayLinearSales.month = 'May';
    mayLinearSales.sales = mayTotalSales;
    mayLinearSales.profit = mayTotalProfitMade;
    sales.add(mayLinearSales);

    List<Reports> junReport = reportValue.getJunReport(reports);
    LinearSales junLinearSales = LinearSales();
    double junTotalProfitMade = 0.0;
    double junTotalSales = 0;
    for(int i = 0; i < junReport.length; i++){
      if(junReport[i].paymentMode != 'Retail'){
        junTotalProfitMade += junReport[i].unitPrice - junReport[i].costPrice;
        junTotalSales += junReport[i].unitPrice;
      }
    }
    junLinearSales.month = 'Jun';
    junLinearSales.sales = junTotalSales;
    junLinearSales.profit = junTotalProfitMade;
    sales.add(junLinearSales);

    List<Reports> julReport = reportValue.getJulReport(reports);
    LinearSales julLinearSales = LinearSales();
    double julTotalProfitMade = 0.0;
    double julTotalSales = 0;
    for(int i = 0; i < julReport.length; i++){
      if(julReport[i].paymentMode != 'Retail'){
        julTotalProfitMade += julReport[i].unitPrice - julReport[i].costPrice;
        julTotalSales += julReport[i].unitPrice;
      }
    }
    julLinearSales.month = 'Jul';
    julLinearSales.sales = julTotalSales;
    julLinearSales.profit = julTotalProfitMade;
    sales.add(julLinearSales);

    List<Reports> augReport = reportValue.getAugReport(reports);
    LinearSales augLinearSales = LinearSales();
    double augTotalProfitMade = 0.0;
    double augTotalSales = 0;
    for(int i = 0; i < augReport.length; i++){
      if(augReport[i].paymentMode != 'Retail'){
        augTotalProfitMade += augReport[i].unitPrice - augReport[i].costPrice;
        augTotalSales += augReport[i].unitPrice;
      }
    }
    augLinearSales.month = 'Aug';
    augLinearSales.sales = augTotalSales;
    augLinearSales.profit = augTotalProfitMade;
    sales.add(augLinearSales);

    List<Reports> sepReport = reportValue.getSepReport(reports);
    LinearSales sepLinearSales = LinearSales();
    double sepTotalProfitMade = 0.0;
    double sepTotalSales = 0;
    for(int i = 0; i < sepReport.length; i++){
      if(sepReport[i].paymentMode != 'Retail'){
        sepTotalProfitMade += sepReport[i].unitPrice - sepReport[i].costPrice;
        sepTotalSales += sepReport[i].unitPrice;
      }
    }
    sepLinearSales.month = 'Sep';
    sepLinearSales.sales = sepTotalSales;
    sepLinearSales.profit = sepTotalProfitMade;
    sales.add(sepLinearSales);

    List<Reports> octReport = reportValue.getOctReport(reports);
    LinearSales octLinearSales = LinearSales();
    double octTotalProfitMade = 0.0;
    double octTotalSales = 0;
    for(int i = 0; i < octReport.length; i++){
      if(octReport[i].paymentMode != 'Retail'){
        octTotalProfitMade += octReport[i].unitPrice - octReport[i].costPrice;
        octTotalSales += octReport[i].unitPrice;
      }
    }
    octLinearSales.month = 'Oct';
    octLinearSales.sales = octTotalSales;
    octLinearSales.profit = octTotalProfitMade;
    sales.add(octLinearSales);

    List<Reports> novReport = reportValue.getNovReport(reports);
    LinearSales novLinearSales = LinearSales();
    double novTotalProfitMade = 0.0;
    double novTotalSales = 0;
    for(int i = 0; i < novReport.length; i++){
      if(novReport[i].paymentMode != 'Retail'){
        novTotalProfitMade += novReport[i].unitPrice - novReport[i].costPrice;
        novTotalSales += novReport[i].unitPrice;
      }
    }
    novLinearSales.month = 'Nov';
    novLinearSales.sales = novTotalSales;
    novLinearSales.profit = novTotalProfitMade;
    sales.add(novLinearSales);

    List<Reports> decReport = reportValue.getDecReport(reports);
    LinearSales decLinearSales = LinearSales();
    double decTotalProfitMade = 0.0;
    double decTotalSales = 0;
    for(int i = 0; i < decReport.length; i++){
      if(decReport[i].paymentMode != 'Retail'){
        decTotalProfitMade += decReport[i].unitPrice - decReport[i].costPrice;
        decTotalSales += decReport[i].unitPrice;
      }
    }
    decLinearSales.month = 'Dec';
    decLinearSales.sales = decTotalSales;
    decLinearSales.profit = decTotalProfitMade;
    sales.add(decLinearSales);

    return sales;

  }

}


