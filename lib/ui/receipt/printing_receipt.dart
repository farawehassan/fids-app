import 'dart:typed_data';
import 'package:fids_apparel/bloc/future_values.dart';
import 'package:fids_apparel/model/reportsDB.dart';
import 'package:fids_apparel/networking/rest_data.dart';
import 'package:fids_apparel/utils/constants.dart';
import 'package:fids_apparel/utils/size_config.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:esc_pos_printer/esc_pos_printer.dart';

/// A StatefulWidget class that prints receipt of items recorded
class PrintingReceipt extends StatefulWidget {

  static const String id = 'printing_receipt';

  /// Passing the products recorded in this class constructor
  final List<Map> sentProducts;

  PrintingReceipt({@required this.sentProducts});

  @override
  _PrintingReceiptState createState() => _PrintingReceiptState();
}

class _PrintingReceiptState extends State<PrintingReceipt> {

  /// Instantiating a class of the [FutureValues]
  var futureValue = FutureValues();

  /// A List to hold the Map of [sentProducts]
  List<Map> _receivedProducts = [];

  /// Variable holding today's datetime
  DateTime _dateTime = DateTime.now();

  /// A Map to hold the details of a sales record
  Map products = {};

  /// A List to hold the Map of the data above
  List<Map> productsList = [];

  /// Variable holding the total price
  double totalPrice = 0.0;

  /// A class [PrinterBluetoothManager] to handle bluetooth connection and
  /// sending of receipt through the package [esc_pos_printer]
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();

  /// A list of [PrinterBluetooth] holding the bluetooth devices
  /// available around you
  List<PrinterBluetooth> _devices = [];

  /// This adds the product details [sentProducts] to [_receivedProducts] if it's
  /// not empty and calculate the total price [totalPrice]
  void _addProducts() {
    for (var product in widget.sentProducts) {
      if (product.isNotEmpty)  {
        _receivedProducts.add(product);
        totalPrice += double.parse(product['unitPrice']);
      }
    }
  }

  /// Calls [_addProducts()] before the class builds its widgets
  @override
  void initState() {
    super.initState();
    _addProducts();
  }

  /// Function to build a ticket of [_receivedProducts] using the
  /// package [esc_pos_printer]
  Future<Ticket> _showReceipt() async{
    Ticket ticket = Ticket(PaperSize.mm58);

    // Print image
    final ByteData data = await rootBundle.load('Assets/images/logo.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final Image image = decodeImage(bytes);
    ticket.image(image);

    ticket.text('FID\'S APPAREL',
      styles: PosStyles(
        align: PosTextAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1
    );

    ticket.text('Contemporary women wears / Made in Nigeria', styles: PosStyles(align: PosTextAlign.center));
    ticket.text('Instagram: @fidsapparel', styles: PosStyles(align: PosTextAlign.center));
    ticket.text('Tel: 07036094173', styles: PosStyles(align: PosTextAlign.center));
    ticket.text('Email: fidsapparel@gmail.com',
        styles: PosStyles(align: PosTextAlign.center), linesAfter: 1);
    ticket.emptyLines(1);

    ticket.row([
      PosColumn(text: 'Qty', width: 1),
      PosColumn(text: 'Item', width: 7),
      PosColumn(
          text: 'Price', width: 2, styles: PosStyles(align: PosTextAlign.right)),
      PosColumn(
          text: 'Total', width: 2, styles: PosStyles(align: PosTextAlign.right)),
    ]);

    for(var item in _receivedProducts){
      ticket.row([
        PosColumn(text: '1', width: 1),
        PosColumn(text: '${item['product']}', width: 7),
        PosColumn(
            text: '${item['unitPrice']}', width: 2, styles: PosStyles(align: PosTextAlign.right)),
        PosColumn(
            text: '${item['unitPrice']}', width: 2, styles: PosStyles(align: PosTextAlign.right)),
      ]);
    }

    ticket.emptyLines(1);

    ticket.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: '${Constants.money(totalPrice)}',
          width: 6,
          styles: PosStyles(
            align: PosTextAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    ticket.emptyLines(2);
    //ticket.hr(ch: '=', linesAfter: 1);

    ticket.feed(2);
    ticket.text('Thank you!',
        styles: PosStyles(align: PosTextAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    ticket.text(timestamp, styles: PosStyles(align: PosTextAlign.center), linesAfter: 2);

    ticket.feed(2);
    ticket.cut();
    return ticket;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Printer"),
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context,position){
          return ListTile(
            onTap: () async {
              printerManager.selectPrinter(_devices[position]);
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (_) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 0.0,
                  child: Container(
                    width: SizeConfig.safeBlockHorizontal * 60,
                    height: 150.0,
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Text(
                              "Select payment mode",
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // To close the dialog
                                _showReceipt().then((ticketValue){
                                  printerManager.printTicket(ticketValue).then((result) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.msg)));
                                    if(result.msg == "Success"){
                                      _saveProduct("Transfer");
                                    }
                                  }).catchError((error){
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                                  });
                                });
                              },
                              textColor: Colors.purple,
                              child: Text('Transfer'),
                            ),
                            FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // To close the dialog
                                _showReceipt().then((ticketValue){
                                  printerManager.printTicket(ticketValue).then((result) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.msg)));
                                    if(result.msg == "Success"){
                                      _saveProduct("Cash");
                                    }
                                  }).catchError((error){
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                                  });
                                });
                              },
                              textColor: Colors.purple,
                              child: Text('Cash'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            title: Text(_devices[position].name),
            subtitle: Text(_devices[position].address),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        printerManager.startScan(Duration(seconds: 4));
        printerManager.scanResults.listen((scannedDevices) {
          if (!mounted) return;
          setState(() {
            _devices = scannedDevices;
          });
          if(_devices.isEmpty){
            Constants.showMessage('No Available Printer');
          }
        }).onError((handleError){
          Constants.showMessage('${handleError.toString()}');
        });
      },child: Icon(Icons.search),),
    );
  }

  /// This function calls [saveNewDailyReport()] with the details in
  /// [_receivedProducts]
  void _saveProduct(String paymentMode) async {
    if(_receivedProducts.length > 0 && _receivedProducts.isNotEmpty){
      for (var product in _receivedProducts) {
        try {
          await _saveNewDailyReport(
              double.parse(product['qty']),
              product['product'],
              double.parse(product['printPrice']),
              double.parse(product['tailorPrice']),
              double.parse(product['costPrice']),
              double.parse(product['unitPrice']),
              paymentMode
          ).then((value){
            Constants.showMessage("${product['product']} was sold successfully");
          });
        } catch (e) {
          print(e);
          Constants.showMessage(e.toString());
        }
      }
      Navigator.pop(context);
    }
    else {
      Constants.showMessage("Empty receipt");
      Navigator.pop(context);
    }
  }

  /// Function that adds new report to the database by calling
  /// [addNewDailyReport] in the [RestDataSource] class
  Future<void> _saveNewDailyReport(double qty, String productName, double printPrice,
      double tailor, double costPrice, double unitPrice, String paymentMode) async {
    try {
      var api = RestDataSource();
      var dailyReport = Reports();
      dailyReport.qty = 1;
      dailyReport.yards = qty;
      dailyReport.productName = productName.toString();
      dailyReport.printPrice = printPrice;
      dailyReport.tailorPrice = tailor;
      dailyReport.costPrice = costPrice;
      dailyReport.unitPrice = unitPrice;
      dailyReport.paymentMode = paymentMode;
      dailyReport.createdAt = _dateTime.toString();

      await api.addNewDailyReport(dailyReport).then((value) {
      }).catchError((e) {
        print(e);
        throw (e);
      });
    } catch (e) {
      print(e);
      throw (e);
    }
  }

}