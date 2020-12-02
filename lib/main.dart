import 'package:fids_apparel/ui/navs/daily/daily_report_list.dart';
import 'package:fids_apparel/ui/navs/daily/daily_reports.dart';
import 'package:fids_apparel/ui/navs/monthly/monthly_reports.dart';
import 'package:fids_apparel/ui/navs/monthly/reports_page.dart';
import 'package:fids_apparel/ui/navs/productsSold/products_sold.dart';
import 'package:fids_apparel/ui/navs/productsSold/retail_sales.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'ui/navs/home_page.dart';
import 'ui/navs/available_prints.dart';
import 'ui/welcome_screen.dart';
import 'ui/register/login_screen.dart';
import 'ui/profile_page.dart';
import 'ui/register/create_worker.dart';
import 'ui/splash.dart';

/// Enabling platform override for desktop
void enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

/// Function to call my main application [MyApp()]
/// and [enablePlatformOverrideForDesktop()]
void main() {
  enablePlatformOverrideForDesktop();
  runApp(MyApp());
}

/// A StatelessWidget class to hold basic details and routes of my application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => ThemeData(
          brightness: brightness,
          primaryColor: Color(0XFFA6277C),
          accentColor: Color(0XFFA6277C),
          primarySwatch: Colors.purple,
        ),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            title: 'Fid\'s Apparel',
            debugShowCheckedModeBanner: false,
            theme: theme,
            initialRoute: Splash.id,
            routes: {
              Splash.id: (context) => Splash(),
              MyHomePage.id: (context) => MyHomePage(),
              Products.id: (context) => Products(),
              WelcomeScreen.id: (context) => WelcomeScreen(),
              LoginScreen.id: (context) => LoginScreen(),
              DailyReports.id: (context) => DailyReports(),
              DailyReportList.id: (context) => DailyReportList(),
              ReportPage.id: (context) => ReportPage(),
              ProductsSold.id: (context) => ProductsSold(),
              RetailSales.id: (context) => RetailSales(),
              // ignore: missing_required_param
              MonthReport.id: (context) => MonthReport(),
              Profile.id: (context) => Profile(),
              CreateWorker.id: (context) => CreateWorker(),
            },
          );
        });
  }
}
