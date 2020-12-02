import 'package:fids_apparel/bloc/product_suggestions.dart';
import 'package:fids_apparel/database/user_db_helper.dart';
import 'package:fids_apparel/model/productDB.dart';
import 'package:fids_apparel/ui/navs/productsSold/products_sold.dart';
import 'package:fids_apparel/ui/receipt/receipt_page.dart';
import 'package:fids_apparel/utils/constants.dart';
import 'package:fids_apparel/utils/round_icon.dart';
import 'package:fids_apparel/utils/size_config.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fids_apparel/ui/welcome_screen.dart';
import 'package:fids_apparel/bloc/future_values.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile_page.dart';
import 'available_prints.dart';
import 'daily/daily_reports.dart';
import 'monthly/reports_page.dart';

/// A StatefulWidget class that displays the sales record
class MyHomePage extends StatefulWidget {

  static const String id = 'home_page';

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  /// Switch button for toggling between light mode and dark mode
  bool _enabled = false;

  /// Function for toggling between light mode and dark mode
  void themeSwitch(context) {
    DynamicTheme.of(context).setBrightness(
        Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark);
  }

  /// Instantiating a class of the [FutureValues]
  var futureValue = FutureValues();

  /// Variable to hold the price of label and tag
  double _labelAndTag = 275;

  /// A variable holding the number of rows
  int increment = 0;

  /// A List to hold the Map of the data above
  List<Map> _detailsList = [];

  /// A Map to hold the product's name to its current quantity
  Map products = {};

  /// A Map to hold the product's name to its cost price
  var productCost = Map();

  /// A List to hold the names of all the availableProducts in the database
  List<String> availableProducts = [];

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

  /// Function to fetch all the available product's names from the database to
  /// [availableProducts]
  void _availableProductNames() {
    Future<List<Product>> productNames = futureValue.getAvailableProductsFromDB();
    productNames.then((value) {
      for (int i = 0; i < value.length; i++){
        availableProducts.add(value[i].productName);
        products[value[i].productName] = double.parse(value[i].currentQuantity);
        productCost[value[i].productName] = double.parse(value[i].costPrice);
      }
    }).catchError((error){
      print(error);
      Constants.showMessage(error.toString());
    });
  }

  /// Calls [_getCurrentUser()] before the class builds its widgets
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getThemeBoolValuesSF();
  }

  /// Function to check whether a product's quantity is not more than the
  /// buyer's quantity
  /// It returns false if it does and true if it does not
  bool _checkProductQuantity(String name, double qty) {
    bool response = false;
    if(products.containsKey(name) && products[name] >= qty){
      response = true;
    }
    return response;
  }

  /// Function to check whether a product's quantity is not more than the
  /// buyer's quantity by calling [_checkProductQuantity()]
  /// It returns true if it does and false if it does not
  bool _checkQuantity() {
    bool response = false;
    try {
      for(int i = 0; i < _detailsList.length; i++){
        if (_checkProductQuantity(_detailsList[i]['product'], double.parse(_detailsList[i]['qty'])) == false){
          response = true;
        }
      }
    } catch (e) {
      print(e);
      Constants.showMessage("Error in fetching sales");
      response = true;
    }
    print(response);
    return response;
  }

  /// Function to delete a row from the record sales at a particular [index]
  void _deleteItem(index){
    if (!mounted) return;
    setState((){
      try {
        _detailsList.removeAt(index);
      } catch (e) {
        print(e);
        Constants.showMessage(e);
      }
    });
  }

  /// Building a Scaffold Widget to display an AppBar that sends [_detailsList]
  /// when the send icon is pressed, a listView of dismissible widget
  /// of [_detailsList], a floatingActionButton to add a new row when pressed by
  /// calling [_addCaptureDialog()] and a drawer to show other screens and details when pressed
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Sales Record')),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.white,
            ),
            onPressed: () {
              if (_detailsList.isNotEmpty && _checkQuantity() == false){
                try {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Receipt(sentProducts: _detailsList)),
                  );
                } catch (e) {
                  print(e);
                  Constants.showMessage("Error in records");
                }
              }
              else{
                Constants.showMessage("Error in records or no records");
              }
            },
          ),
        ],
      ),
      body:  Padding(
        padding: EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20.0, left: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  titleText("QTY"),
                  titleText("PRINTS"),
                  titleText("PRICE"),
                  //titleText("TOTAL"),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: ListView(
                  shrinkWrap: true,
                  children: _detailsList.map((data) {
                    int index = _detailsList.indexOf(data);
                    return Dismissible(
                      key: ObjectKey(_detailsList[index]),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        setState(() {
                          _deleteItem(index);
                          increment--;
                        });
                      },
                      background: Container(color: Colors.red),
                      child: _row(_detailsList[index], index),
                      );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  GestureDetector(
                    onTap: (){
                      _showProfile();
                    },
                    child: UserAccountsDrawerHeader(
                      accountName: Text("FID'S APPAREL"),
                      accountEmail: Text("fidsapparel@gmail.com"),
                      currentAccountPicture: Hero(
                        tag: 'displayPicture',
                        child: CircleAvatar(
                          backgroundImage: AssetImage('Assets/images/logo.png'),
                          backgroundColor: Color(0XFFA6277C),
                        ),
                      ),
                      onDetailsPressed: (){
                        _showProfile();
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.create),
                    title: Text('Sales Record'),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.book),
                    title: Text('Prints'),
                    onTap: (){
                      Navigator.pushNamed(context, Products.id);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.assignment_returned),
                    title: Text('Daily Reports'),
                    onTap: (){
                      Navigator.pushNamed(context, DailyReports.id);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.assignment_returned),
                    title: Text('Monthly Reports'),
                    onTap: (){
                      Navigator.pushNamed(context, ReportPage.id);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.assignment_returned),
                    title: Text('Prints Sold'),
                    onTap: (){
                      Navigator.pushNamed(context, ProductsSold.id);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    trailing: Switch(
                      activeColor: Color(0XFFA6277C),
                      value: _enabled,
                      onChanged: (bool value) {
                        if (!mounted) return;
                        setState(() {
                          _addThemeBoolToSF(value);
                          themeSwitch(context);
                        });
                      },
                    ),
                    title: Text('Theme'),
                    subtitle: _enabled ? Text('Dark Mode') : Text('Light Mode'),
                    onTap: (){
                    },
                  ),
                  ListTile(
                    title: Text('Sign Out'),
                    onTap: (){
                      _logout();
                    },
                  ),
                ],
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  height: 1.0,
                  color: Colors.grey[400],
                ),
                FlatButton(
                  onPressed: (){
                    showAboutDialog(
                      context: context,
                      applicationName: 'FID\'S APPAREL',
                      applicationIcon: AnimatedContainer(
                        width: 40.0,
                        height: 40.0,
                        duration: Duration(milliseconds: 750),
                        curve: Curves.fastOutSlowIn,
                        child: Image(
                          image: AssetImage('Assets/images/logo.png'),
                        ),
                      ),
                      applicationVersion: '1.0.0',
                      applicationLegalese: 'Developed by Farawe Taiwo Hassan',
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "About",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: RoundIconButton(
        onPressed: _addCaptureDialog,
        icon: Icons.add,
      ),
    );
  }

  Widget _row(Map details, int index){
    return GestureDetector(
      onLongPress: (){
        _showCaptureDialog(details, index);
      },
      onTap: (){
        _showCaptureDialog(details, index);
      },
      child: Column(
        children: <Widget>[
          SizedBox(height: 15),
          Row(
            children: <Widget>[
              Container(
                width: (SizeConfig.screenWidth - 36) * 0.15,
                child: Text(
                  '${details['qty']}',
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFFA6277C),
                  ),
                ),
              ),
              Container(
                width: (SizeConfig.screenWidth - 36) * 0.5,
                child: Text(
                  details['product'],
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFFA6277C),
                  ),
                ),
              ),
              Container(
                width: (SizeConfig.screenWidth - 36) * 0.35,
                child: Text(
                  '${Constants.money(double.parse(details['unitPrice']))}',
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFFA6277C),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Container(
            width: SizeConfig.screenWidth,
            height: 1,
            color: Color(0XFFC3D3D4),
          ),
        ],
      ),
    );
  }

  /// Function to show dialog when you want to capture new sales
  void _addCaptureDialog(){
    availableProducts.clear();
    products.clear();
    productCost.clear();
    _availableProductNames();

    /// GlobalKey of a my form state to validate my form while capturing data
    final _verifyFormKey = GlobalKey<FormState>();

    /// Variable to hold the cost price of an item recorded
    final TextEditingController costPriceController = TextEditingController();
    double costPrice = 0.0;

    /// Variable to hold the printPrice of an item recorded
    double printPrice;

    /// Variable to hold the quantity of an item recorded
    final TextEditingController qtyController = TextEditingController();
    double quantity;

    /// Variable to hold the tailor's price of an item recorded
    final TextEditingController tailorController = TextEditingController();
    double tailorPrice;

    /// Variable to hold the unitPrice of an item recorded
    final TextEditingController priceController = TextEditingController();
    double unitPrice;

    /// Variable to hold the name of an item recorded
    final TextEditingController productController = TextEditingController();
    String selectedProduct;

    Map details = {
      'qty':'$quantity',
      'product':selectedProduct,
      'printPrice':'$printPrice',
      'tailorPrice':'$tailorPrice',
      'costPrice':'$costPrice',
      'unitPrice':'$unitPrice',
    };

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0.0,
        child: Form(
          key: _verifyFormKey,
          child: Container(
            width: SizeConfig.screenWidth * 0.9,
            padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Packaging: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: Constants.money(_labelAndTag),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0XFFA6277C)
                                )
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // To close the dialog
                          },
                          icon: Icon(
                            Icons.close,
                            color: Color(0XFFA6277C).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: SizeConfig.screenWidth,
                    height: 1,
                    color: Color(0XFFA6277C).withOpacity(0.6),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: SizeConfig.screenWidth - 50,
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 15),
                    child: TypeAheadFormField(
                      validator: (val) {
                        if(val.length == 0){
                          return "Enter name of print used";
                        }
                        return null;
                      },
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: productController,
                        decoration: kTextFieldDecoration.copyWith(labelText: 'Name of Prints Used'),
                      ),
                      suggestionsCallback: (pattern) {
                        return AvailableProducts.getSuggestions(pattern, availableProducts);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion),
                        );
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (suggestion) {
                        productController.text = suggestion;
                        selectedProduct = productController.text;
                        details['product'] = '$selectedProduct';
                        if (!mounted) return;
                        setState(() {
                          printPrice = productCost[selectedProduct];
                          details['printPrice'] = '$printPrice';
                        });
                      },
                      onSaved: (value) {
                        selectedProduct = value;
                        details['product'] = '$selectedProduct';
                        if (!mounted) return;
                        setState(() {
                          printPrice = productCost[selectedProduct];
                          details['printPrice'] = '$printPrice';
                        });
                      },
                    ),
                  ),
                  Container(
                    width: SizeConfig.screenWidth - 50,
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 15),
                    child: TextFormField(
                      keyboardType: TextInputType.numberWithOptions(),
                      validator: (val) {
                        if (val.length == 0 || val.isEmpty) {
                          return "Enter number of yards used";
                        }
                        if(!_checkProductQuantity(selectedProduct, double.parse(val))){
                          return "Enter a valid qty";
                        }
                        return null;
                      },
                      controller: qtyController,
                      onChanged: (value) {
                        if (!mounted) return;
                        setState(() {
                          quantity = double.parse(value.trim());
                          details['qty'] = '$quantity';
                          if(tailorController.text != null && tailorController.text.isNotEmpty && printPrice != null){
                            costPrice = (double.parse(qtyController.text.trim()) * printPrice) + double.parse(tailorController.text) + _labelAndTag;
                            costPriceController.text = Constants.money(costPrice);
                            details['costPrice'] = '$costPrice';
                          }
                        });
                      },
                      decoration: kTextFieldDecoration.copyWith(labelText: 'Number of yards used'),
                    ),
                  ),
                  Container(
                    width: SizeConfig.screenWidth - 50,
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 15),
                    child: TextFormField(
                      keyboardType: TextInputType.numberWithOptions(),
                      validator: (val) {
                        if (val.length == 0 || val.isEmpty) {
                          return "Enter tailor's amount";
                        }
                        return null;
                      },
                      controller: tailorController,
                      onChanged: (value) {
                        if (!mounted) return;
                        setState(() {
                          tailorPrice = double.parse(value);
                          details['tailorPrice'] = '$tailorPrice';
                          if(qtyController.text != null && qtyController.text.isNotEmpty && printPrice != null){
                            costPrice = (double.parse(qtyController.text) * printPrice) + double.parse(tailorController.text) + _labelAndTag;
                            costPriceController.text = Constants.money(costPrice);
                            details['costPrice'] = '$costPrice';
                          }
                        });
                      },
                      decoration: kTextFieldDecoration.copyWith(labelText: 'Tailor\'s Amount'),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 39),
                    child: Container(
                      width: SizeConfig.screenWidth - 50,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        validator: (val) {
                          if (val.length == 0 || val.isEmpty) {
                            return "Cost Price";
                          }
                          return null;
                        },
                        controller: costPriceController,
                        decoration: kTextFieldDecoration.copyWith(labelText: 'Cost Price'),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 39),
                    child: Container(
                      width: SizeConfig.screenWidth - 50,
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(),
                        validator: (val) {
                          if (val.length == 0 || val.isEmpty) {
                            return "Unit Price";
                          }
                          return null;
                        },
                        controller: priceController,
                        onChanged: (value) {
                          if (!mounted) return;
                          setState(() {
                            unitPrice = double.parse(value);
                            details['unitPrice'] = '$unitPrice';
                          });
                        },
                        decoration: kTextFieldDecoration.copyWith(labelText: 'Unit Price'),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10),
                    alignment: Alignment.bottomRight,
                    child: FlatButton(
                      onPressed: () {
                        if(_verifyFormKey.currentState.validate()){
                          if(!mounted)return;
                          setState(() {
                            _detailsList.add(details);
                          });
                          Navigator.of(context).pop(); // To close the dialog
                        }
                      },
                      color: Colors.transparent,
                      textColor: Color(0XFFA6277C),
                      child: Text('SAVE'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Function to show dialog when you want to view captured sales [details] at
  /// [index] of [_detailsList]
  void _showCaptureDialog(Map details, int index){
    /// GlobalKey of a my form state to validate my form while capturing data
    final _verifyFormKey = GlobalKey<FormState>();

    /// Variable to hold the quantity of an item recorded
    final TextEditingController qtyController = TextEditingController();
    qtyController.text = details['qty'];
    double quantity = double.parse(details['qty']);

    /// Variable to hold the name of an item recorded
    final TextEditingController productController = TextEditingController();
    productController.text = details['product'];
    String selectedProduct = details['product'];

    /// Variable to hold the printPrice of an item recorded
    double printPrice = double.parse(details['printPrice']);

    /// Variable to hold the tailor's price of an item recorded
    final TextEditingController tailorController = TextEditingController();
    tailorController.text = details['tailorPrice'].toString();
    double tailorPrice = double.parse(details['tailorPrice']);

    /// Variable to hold the cost price of an item recorded
    final TextEditingController costPriceController = TextEditingController();
    costPriceController.text = Constants.money(double.parse(details['costPrice']));
    double costPrice = double.parse(details['costPrice']);

    /// Variable to hold the unitPrice of an item recorded
    final TextEditingController priceController = TextEditingController();
    priceController.text = details['unitPrice'].toString();
    double unitPrice = double.parse(details['unitPrice']);

    print('showing');
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0.0,
        child: Form(
          key: _verifyFormKey,
          child: Container(
            width: SizeConfig.screenWidth * 0.9,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Packaging: ',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: Constants.money(_labelAndTag),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0XFFA6277C)
                                  )
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // To close the dialog
                          },
                          icon: Icon(
                            Icons.close,
                            color: Color(0XFFA6277C).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: SizeConfig.screenWidth,
                    height: 1,
                    color: Color(0XFFA6277C).withOpacity(0.6),
                  ),
                  SizedBox(height: 10),

                  Container(
                    width: SizeConfig.screenWidth - 50,
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 15),
                    child: TypeAheadFormField(
                      validator: (val) {
                        if(val.length == 0){
                          return "Enter name of print used";
                        }
                        return null;
                      },
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: productController,
                        decoration: kTextFieldDecoration.copyWith(labelText: 'Name of Prints Used'),
                      ),
                      suggestionsCallback: (pattern) {
                        return AvailableProducts.getSuggestions(pattern, availableProducts);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion),
                        );
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (suggestion) {
                        productController.text = suggestion;
                        selectedProduct = productController.text;
                        details['product'] = '$selectedProduct';
                        if (!mounted) return;
                        setState(() {
                          printPrice = productCost[selectedProduct];
                          details['printPrice'] = '$printPrice';
                        });
                      },
                      onSaved: (value) {
                        selectedProduct = value;
                        details['product'] = '$selectedProduct';
                        if (!mounted) return;
                        setState(() {
                          printPrice = productCost[selectedProduct];
                          details['printPrice'] = '$printPrice';
                        });
                      },
                    ),
                  ),
                  Container(
                    width: SizeConfig.screenWidth - 50,
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 15),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val.length == 0 || val.isEmpty) {
                          return "Enter number of yards used";
                        }
                        if(!_checkProductQuantity(selectedProduct, double.parse(val))){
                          return "Enter a valid qty";
                        }
                        return null;
                      },
                      controller: qtyController,
                      onChanged: (value) {
                        if (!mounted) return;
                        setState(() {
                          quantity = double.parse(value);
                          details['qty'] = '$quantity';
                          if(tailorController.text != null && printPrice != null){
                            costPrice = (double.parse(qtyController.text) * printPrice) + double.parse(tailorController.text) + _labelAndTag;
                            costPriceController.text = Constants.money(costPrice);
                            details['costPrice'] = '$costPrice';
                          }
                        });
                      },
                      decoration: kTextFieldDecoration.copyWith(labelText: 'Number of yards used'),
                    ),
                  ),
                  Container(
                    width: SizeConfig.screenWidth - 50,
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 15),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val.length == 0 || val.isEmpty) {
                          return "Enter tailor's amount";
                        }
                        return null;
                      },
                      controller: tailorController,
                      onChanged: (value) {
                        if (!mounted) return;
                        setState(() {
                          tailorPrice = double.parse(value);
                          details['tailorPrice'] = '$tailorPrice';
                          if(qtyController.text != null && printPrice != null){
                            costPrice = (double.parse(qtyController.text) * printPrice) + double.parse(tailorController.text) + _labelAndTag;
                            costPriceController.text = Constants.money(costPrice);
                            details['costPrice'] = '$costPrice';
                          }
                        });
                      },
                      decoration: kTextFieldDecoration.copyWith(labelText: 'Tailor\'s Amount'),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 39),
                    child: Container(
                      width: SizeConfig.screenWidth - 50,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        validator: (val) {
                          if (val.length == 0 || val.isEmpty) {
                            return "Cost Price";
                          }
                          return null;
                        },
                        controller: costPriceController,
                        decoration: kTextFieldDecoration.copyWith(labelText: 'Cost Price'),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 39),
                    child: Container(
                      width: SizeConfig.screenWidth - 50,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val.length == 0 || val.isEmpty) {
                            return "Unit Price";
                          }
                          return null;
                        },
                        controller: priceController,
                        onChanged: (value) {
                          if (!mounted) return;
                          setState(() {
                            unitPrice = double.parse(value);
                            details['unitPrice'] = '$unitPrice';
                          });
                        },
                        decoration: kTextFieldDecoration.copyWith(labelText: 'Unit Price'),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: FlatButton(
                          onPressed: () {
                            if(!mounted)return;
                            setState(() {
                              _detailsList.removeAt(index);
                            });
                            Navigator.of(context).pop(); // To close the dialog
                          },
                          color: Colors.transparent,
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FlatButton(
                          onPressed: () {
                            if(_verifyFormKey.currentState.validate()){
                              if(!mounted)return;
                              setState(() {
                                _detailsList.removeAt(index);
                                _detailsList.insert(index, details);
                              });
                              Navigator.of(context).pop(); // To close the dialog
                            }
                          },
                          color: Colors.transparent,
                          textColor: Color(0XFFA6277C),
                          child: Text('SAVE'),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Function to show profile of the account if the user is an Admin 'Admin'
  void _showProfile(){
    if(_userType == 'Admin'){
      Navigator.pushNamed(context, Profile.id);
    }else{
      Navigator.of(context).pop();
    }
  }

  /// Function to logout your account
  void _logout() async {
    var db = DatabaseHelper();
    await db.deleteUsers();
    _getBoolValuesSF();
  }

  /// Function to get the 'loggedIn' in your SharedPreferences
  _getBoolValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool boolValue = prefs.getBool('loggedIn') ?? true;
    if(boolValue == true){
      _addBoolToSF();
    }
  }

  /// Function to set the 'loggedIn' in your SharedPreferences to false
  _addBoolToSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', false);
    Navigator.of(context).pushReplacementNamed(WelcomeScreen.id);
  }

  /// Function to get the 'loggedIn' in your SharedPreferences
  _getThemeBoolValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool boolValue = prefs.getBool('themeMode');
    if(boolValue == true){
      if (!mounted) return;
      setState(() {
        _enabled = true;
      });
    }
    else if(boolValue == false){
      if (!mounted) return;
      setState(() {
        _enabled = false;
      });
    } else {
      _addThemeBoolToSF(false);
      if (!mounted) return;
      setState(() {
        _enabled = false;
      });
    }
  }

  /// Function to set the 'loggedIn' in your SharedPreferences to false
  _addThemeBoolToSF(bool state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('themeMode', state);
    _getThemeBoolValuesSF();
  }

}
