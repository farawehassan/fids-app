import 'package:fids_apparel/model/productDB.dart';
import 'package:fids_apparel/model/product_history.dart';
import 'package:fids_apparel/model/product_history_details.dart';
import 'package:fids_apparel/networking/rest_data.dart';
import 'package:fids_apparel/ui/navs/product_history.dart';
import 'package:fids_apparel/utils/round_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:folding_cell/folding_cell.dart';
import 'package:fids_apparel/utils/constants.dart';
import 'package:fids_apparel/bloc/future_values.dart';

/// A StatefulWidget class that displays available product from the database
class Products extends StatefulWidget {

  static const String id = 'available_prints';

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {

  /// Instantiating a class of the [AvailableProduct]
  Product product = Product();

  /// int variable holding 1 to display all products, 2 for available products
  /// and 3 for finished products
  int productsToShow = 2;

  /// Variable of String to hold the productName when you're adding a new product
  String _productName;

  /// Variable of double to hold the costPrice, sellingPrice, initialQuantity
  /// when you're adding a new product
  double _costPrice, _sellingPrice, _initialQuantity;

  /// Variable of int to hold the numbers of product on the page
  int _productLength;

  /// Instantiating a class of the [FutureValues]
  var futureValue = FutureValues();

  /// GlobalKey of a my form state to validate my form while saving a new product
  final _saveNewFormKey = GlobalKey<FormState>();

  /// GlobalKey of a my form state to validate my form while updating a product
  final _updateFormKey = GlobalKey<FormState>();

  /// GlobalKey of a my RefreshIndicatorState to refresh my list items in the page
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  /// A TextEditingController to control the searchText on the AppBar
  final TextEditingController _filter = TextEditingController();

  /// Variable of String to hold the searchText on the AppBar
  String _searchText = "";

  /// Variable of List<[Product]> to hold
  /// the details of all the availableProduct
  List<Product> _names = List();

  /// Variable of List<[Product]> to hold
  /// the details of all filtered availableProduct
  List<Product> _filteredNames = List();

  /// Variable of List<[ProductHistory]> to hold
  /// the details of all the product history
  List<ProductHistory> _productHistory = List();

  /// Variable to hold an Icon Widget of Search
  Icon _searchIcon = Icon(Icons.search);

  /// Variable to hold a Widget of Text for the appBarText
  Widget _appBarTitle = Text('Available Prints');

  /// Checking if the filter controller is empty to reset the
  /// _searchText on the appBar to "" and the filteredNames to Names
  _ProductsState(){
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        if (!mounted) return;
        setState(() {
          _searchText = "";
          _filteredNames = _names;
        });
      }
      else {
        if (!mounted) return;
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  /// Function to refresh details of the Available products
  /// by calling [_getNames()]
  void _refreshData(){
    if (!mounted) return;
    setState(() {
      _getNames();
    });
  }

  /// Function to get all the available products from the database and
  /// setting the details and [_filteredNames] to [_names] plus the numbers of
  /// products to [_productLength] with it history and store it to [_productHistory]
  void _getNames() async {
    List<Product> tempList = List();

    Future<List<Product>> productNames;

    if(productsToShow == 1){
      if (!mounted) return;
      setState(() {
        _appBarTitle = Text('All Prints');
      });
      productNames = futureValue.getAllProductsFromDB();
    } else if(productsToShow == 2){
      if (!mounted) return;
      setState(() {
        _appBarTitle = Text('Available Prints');
      });
      productNames = futureValue.getAvailableProductsFromDB();
    } else if(productsToShow == 3){
      if (!mounted) return;
      setState(() {
        _appBarTitle = Text('Prints Out of Stock');
      });
      productNames = futureValue.getFinishedProductFromDB();
    }

    await productNames.then((value) async {
      Future<List<ProductHistory>> products = futureValue.getAllProductsHistoryFromDB();
      await products.then((value) {
        _productHistory.addAll(value);
      }).catchError((error){
        Constants.showMessage(error.toString());
      });

      if(value.length != 0){
        for (int i = 0; i < value.length; i++){
          tempList.add(value[i]);
        }
        if (!mounted) return;
        setState(() {
          _productLength = tempList.length;
          _names = tempList;
          _filteredNames = _names;
        });
      } else if(value.length == 0 || value.isEmpty){
        if (!mounted) return;
        setState(() {
          _productLength = 0;
          _names = [];
          _filteredNames = _names;
        });
      }
    }).catchError((error){
      print(error);
      Constants.showMessage(error.toString());
    });
  }

  /// Function to change icons on the appBar when the searchIcon or closeIcon
  /// is pressed then sets the TextController to [_filter] and hintText of
  /// 'Search...' if it was the searchIcon or else it resets the AppBar to its
  /// normal state
  void _searchPressed() {
    if (!mounted) return;
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(Icons.close);
        this._appBarTitle = TextField(
          controller: _filter,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search...'
          ),
        );
      }
      else {
        this._searchIcon = Icon(Icons.search);
        this._appBarTitle = Text('Available Prints');
        _filteredNames = _names;
        _filter.clear();
      }
    });
  }

  /// A function to build the AppBar of the page by calling
  /// [_searchPressed()] when the icon is pressed
  Widget _buildBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: _appBarTitle,
      actions: <Widget>[
        IconButton(
          icon: _searchIcon,
          onPressed: _searchPressed,
        ),
        PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.showProductChoices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            }
        )
      ],
    );
  }

  /// A function to set actions for the options menu with the value [choice]
  void choiceAction(String choice){
    if(choice == Constants.ShowAll){
      if (!mounted) return;
      setState(() {
        productsToShow = 1;
        _refresh();
      });
    }
    else if(choice == Constants.ShowAvailable){
      if (!mounted) return;
      setState(() {
        productsToShow = 2;
        _refresh();
      });
    }
    else if(choice == Constants.ShowFinished){
      if (!mounted) return;
      setState(() {
        productsToShow = 3;
        _refresh();
      });
    }
  }

  /// A function to build the list of the available products by using a
  /// SimpleFoldingCell library to display its details in the [_buildFrontWidget()],
  /// [_buildInnerTopWidget()] and [_buildInnerBottomWidget()]
  Widget _buildList() {
    if (_searchText.isNotEmpty) {
      List<Product> tempList = new List();
      for (int i = 0; i < _filteredNames.length; i++) {
        if (_filteredNames[i].productName.toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(_filteredNames[i]);
        }
      }
      _filteredNames = tempList;
    }
    if(_filteredNames.length > 0 && _filteredNames.isNotEmpty){
      return ListView.builder(
        itemCount: _names == null ? 0 : _filteredNames.length,
        itemBuilder: (BuildContext context, int index) {
          return SimpleFoldingCell(
              frontWidget: _buildFrontWidget(
                  _filteredNames[index].productName),
              innerTopWidget: _buildInnerTopWidget(
                  _filteredNames[index].productName),
              innerBottomWidget: _buildInnerBottomWidget(
                  _filteredNames[index].id,
                  _filteredNames[index].productName,
                  double.parse(_filteredNames[index].initialQuantity),
                  double.parse(_filteredNames[index].currentQuantity),
                  double.parse(_filteredNames[index].costPrice),
                  double.parse(_filteredNames[index].sellingPrice)),
              cellSize: Size(MediaQuery.of(context).size.width, 90),
              padding: EdgeInsets.all(8.0),
              animationDuration: Duration(milliseconds: 300),
              borderRadius: 10
          );
        },
      );
    }
    else if(_productLength == 0){
      return Container(
        alignment: AlignmentDirectional.center,
        child: Center(child: Text("No Prints")),
      );
    }
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0XFFA6277C)),
        ),
      ),
    );
  }

  /// Function to refresh details of the products similar to the
  /// [_getNames()] method but this is from the RefreshIndicator
  Future<Null> _refresh() {
    List<Product> tempList = new List();

    Future<List<Product>> productNames;
    if(productsToShow == 1){
      productNames = futureValue.getAllProductsFromDB();
      setState(() {
        _appBarTitle = Text('All Prints');
      });
    } else if(productsToShow == 2){
      productNames = futureValue.getAvailableProductsFromDB();
      setState(() {
        _appBarTitle = Text('Available Prints');
      });
    } else if(productsToShow == 3){
      productNames = futureValue.getFinishedProductFromDB();
      setState(() {
        _appBarTitle = Text('Prints Out of Stock');
      });
    }
    return productNames.then((value) async {
      Future<List<ProductHistory>> products = futureValue.getAllProductsHistoryFromDB();
      await products.then((value) {
        _productHistory.addAll(value);
      }).catchError((error){
        Constants.showMessage(error.toString());
      });
      for (int i = 0; i < value.length; i++){
        tempList.add(value[i]);
      }
      if (!mounted) return;
      setState(() {
        _names = tempList;
        _filteredNames = _names;
      });
    });
  }

  /// Calls [_getNames()] before the class builds its widgets
  @override
  void initState() {
    this._getNames();
    super.initState();
  }

  /// Building a Scaffold Widget to display [_buildList()] and a
  /// floatingActionButton to display a form to add new product when pressed
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: Container(
          child: _buildList(),
        ),
      ),
      floatingActionButton: RoundIconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 0.0,
              child: Container(
                height: 340.0,
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _saveNewFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          "ADD NEW PRINTS",
                          style: TextStyle(
                            color: Color(0XFFA6277C).withOpacity(0.6),
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: 200,
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          validator: (val) =>
                              val.length == 0 ? "Enter print name" : null,
                          onChanged: (value) {
                            _productName = value;
                          },
                          onSaved: (value) {
                            this._productName = value;
                          },
                          cursorColor: Color(0XFFA6277C).withOpacity(0.6),
                          decoration: kAddProductDecoration.copyWith(
                              hintText: "Print name"),
                        ),
                      ),
                      Container(
                        width: 200.0,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (val) =>
                              val.length == 0 ? "Enter number of yards" : null,
                          onChanged: (value) {
                            _initialQuantity = double.parse(value);
                          },
                          onSaved: (value) {
                            this._initialQuantity = double.parse(value);
                          },
                          cursorColor: Color(0XFFA6277C),
                          decoration:
                              kAddProductDecoration.copyWith(hintText: "Number of Yards"),
                        ),
                      ),
                      Container(
                        width: 150.0,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (val) =>
                          val.length == 0 ? "Enter CP" : null,
                          onChanged: (value) {
                            _costPrice = double.parse(value);
                            _sellingPrice = double.parse(value);
                          },
                          onSaved: (value) {
                            this._costPrice = double.parse(value);
                            this._sellingPrice = double.parse(value);
                          },
                          cursorColor: Color(0XFFA6277C),
                          decoration: kAddProductDecoration.copyWith(
                              hintText: "Cost Price"),
                        ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: FlatButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // To close the dialog
                              },
                              textColor: Color(0XFFA6277C).withOpacity(0.6),
                              child: Text('CANCEL'),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: FlatButton(
                              onPressed: () {
                                if (this._saveNewFormKey.currentState.validate()) {
                                  _saveNewFormKey.currentState.save();
                                } else {
                                  return null;
                                }
                                _saveNewProduct();
                                Navigator.of(context)
                                    .pop(); // To close the dialog
                                _refreshData();
                              },
                              textColor: Color(0XFFA6277C).withOpacity(0.6),
                              child: Text('SAVE'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            barrierDismissible: false,
          );
        },
        icon: Icons.add,
      ),
    );
  }

  /// Function that builds the FrontWidget of the SimpleFoldingCell by displaying
  /// the [productName] and opening the InnerTopWidget when the card is pressed
  Widget _buildFrontWidget(String productName) {
    return Builder(builder: (BuildContext context) {
      return GestureDetector(
        onTap: () {
          SimpleFoldingCellState foldingCellState = context.findAncestorStateOfType<SimpleFoldingCellState>();
          foldingCellState?.toggleFold();
        },
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.expand_more, color: Color(0XFFA6277C).withOpacity(0.6)),
                  onPressed: () {
                    SimpleFoldingCellState foldingCellState = context.findAncestorStateOfType<SimpleFoldingCellState>();
                    foldingCellState?.toggleFold();
                  },
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  productName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Function that builds the InnerTopWidget of the SimpleFoldingCell by
  /// displaying the [productName] at the top when the FrontWidget is pressed
  Widget _buildInnerTopWidget(String productName) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.history, color: Color(0XFFA6277C)),
            onPressed: (){
              String id;
              for(int i = 0; i <_productHistory.length; i++){
                if(_productHistory[i].productName == productName) {
                  setState(() {
                    id = _productHistory[i].id;
                  });
                }
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductHistoryPage(productHistoryId: id,)),
              );
            },
          ),
          SizedBox(
            width: 5.0,
          ),
          Text(
            productName,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }


  /// Function that builds the InnerBottomWidget of the SimpleFoldingCell by
  /// displaying the details of the product [name], [iq], [cq], [cp], [sp]
  /// and also update the productDetails by calling [_updateProduct()]
  /// when the info icon is pressed and the form is filled
  Widget _buildInnerBottomWidget(String id,
      String name, double iq, double cq, double cp, double sp) {
    final controllerProduct = TextEditingController();
    final controllerQty = TextEditingController();
    final controllerCp = TextEditingController();
    final controllerSp = TextEditingController();

    String cpVal;
    String spVal;

    return Builder(builder: (context) {
      cpVal = Constants.money(cp);
      spVal = Constants.money(sp);
      return GestureDetector(
        onTap: () {
          SimpleFoldingCellState foldingCellState = context.findAncestorStateOfType<SimpleFoldingCellState>();
          foldingCellState?.toggleFold();
        },
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.expand_less, color: Color(0XFFA6277C)),
                  onPressed: () {
                    SimpleFoldingCellState foldingCellState = context.findAncestorStateOfType<SimpleFoldingCellState>();
                    foldingCellState?.toggleFold();
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Initial Qty: $iq',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      'Current Qty: $cq',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Qty Sold: ${iq - cq}',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('CP: $cpVal'),
                    Text('SP: $spVal'),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.info, color: Color(0XFFA6277C)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 0.0,
                        child: Container(
                          height: 320.0,
                          padding: EdgeInsets.all(16.0),
                          child: Form(
                            key: _updateFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    "Update incoming prints",
                                    style: TextStyle(
                                      color: Color(0XFFA6277C).withOpacity(0.6),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 270.0,
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: controllerProduct,
                                    decoration: kAddProductDecoration.copyWith(
                                        hintText: "$name"),
                                  ),
                                ),
                                Container(
                                  width: 200.0,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    validator: (val) =>
                                    val.length == 0 ? "Enter number of yards" : null,
                                    onChanged: (value) {
                                      controllerQty.text = value;
                                    },
                                    onSaved: (value) {
                                      controllerQty.text = value;
                                    },
                                    decoration: kAddProductDecoration.copyWith(
                                        hintText: "Number of Yards"),
                                  ),
                                ),
                                Container(
                                  width: 150.0,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    validator: (val) =>
                                    val.length == 0 ? "Enter cost price" : null,
                                    onChanged: (value) {
                                      controllerCp.text = value;
                                      controllerSp.text = value;
                                    },
                                    onSaved: (value) {
                                      controllerCp.text = value;
                                      controllerSp.text = value;
                                    },
                                    decoration: kAddProductDecoration
                                        .copyWith(hintText: "$cp"),
                                  ),
                                ),
                                SizedBox(
                                  height: 24.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: FlatButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // To close the dialog
                                        },
                                        textColor: Color(0XFFA6277C),
                                        child: Text('CANCEL'),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: FlatButton(
                                        onPressed: () {
                                          if (this._updateFormKey.currentState.validate()) {
                                            _updateFormKey.currentState.save();
                                          } else {
                                            return null;
                                          }

                                          double initialQty = double.parse(controllerQty.text) + iq;
                                          double currentQty =  double.parse(controllerQty.text) + cq;

                                          var productHistoryDetails = ProductHistoryDetails();
                                          productHistoryDetails.initialQty = cq.toString();
                                          productHistoryDetails.qtyReceived = controllerQty.text.toString();
                                          productHistoryDetails.currentQty = currentQty.toString();
                                          productHistoryDetails.collectedAt = DateTime.now().toString();

                                          _updateProduct(
                                              productHistoryDetails,
                                              id,
                                              name.toString(),
                                              controllerProduct.text.toString(),
                                              initialQty,
                                              double.parse(controllerCp.text),
                                              double.parse(controllerSp.text),
                                              currentQty
                                          );


                                          _refreshData();

                                          Navigator.of(context)
                                              .pop(); // To close the dialog
                                        },
                                        textColor: Color(0XFFA6277C),
                                        child: Text('SAVE'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      barrierDismissible: false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Function to check whether a product exists or not
  /// It returns true if it does and false if it does not
  Future<bool> _checkIfProductExists(String name) async {
    bool response = false;
    Future<List<Product>> productNames = futureValue.getAllProductsFromDB();
    await productNames.then((value) {
      print(name);
      for (int i = 0; i < value.length; i++){
        if(name == value[i].productName){
          var productHistoryDetails = ProductHistoryDetails();
          productHistoryDetails.initialQty = value[i].initialQuantity;
          productHistoryDetails.qtyReceived = _initialQuantity.toString();
          productHistoryDetails.currentQty = (double.parse(value[i].currentQuantity) + _initialQuantity).toString();
          productHistoryDetails.collectedAt = DateTime.now().toString();

          _updateProduct(
            productHistoryDetails,
            value[i].id,
            name,
            value[i].productName,
            _initialQuantity + double.parse(value[i].initialQuantity),
            _costPrice,
            _sellingPrice,
            double.parse(value[i].currentQuantity) + _initialQuantity,
          );
          response = true;
        }
      }
    }).catchError((onError){
      throw (onError.toString());
    });
    print(response);
    return response;
  }

  /// Function that adds new product to the database by calling
  /// [addProduct] in the [RestDataSource] class
  void _saveNewProduct() async {
    var now = DateTime.now();
    var api = new RestDataSource();
    var product = Product();
    var productHistoryDetails = ProductHistoryDetails();

    Future<bool> exists = _checkIfProductExists(Constants.capitalize(_productName));
    await exists.then((value) async {
      if(value == false) {
        try {
          product.productName = Constants.capitalize(_productName);
          product.costPrice = _costPrice.toString();
          product.sellingPrice = _sellingPrice.toString();
          product.initialQuantity = _initialQuantity.toString();
          product.currentQuantity = _initialQuantity.toString();
          product.createdAt = now.toString();

          productHistoryDetails.initialQty = 0.toString();
          productHistoryDetails.qtyReceived = _initialQuantity.toString();
          productHistoryDetails.currentQty = _initialQuantity.toString();
          productHistoryDetails.collectedAt = now.toString();

          api.addProduct(product).then((value) {
            api.addProductHistory(Constants.capitalize(_productName), productHistoryDetails).then((result) {
              Constants.showMessage("${product.productName} was added");
            }).catchError((error) {
              print(error);
              Constants.showMessage(error.toString());
            });
          }).catchError((error) {
            print(error);
            Constants.showMessage(error.toString());
          });
        } catch (e) {
          print(e);
          Constants.showMessage(e.toString());
        }
      }
    }).catchError((onError){
      print(onError.toString());
      Constants.showMessage(onError.toString());
    });

  }

  /// Function to update the details of a product in the database by calling
  /// [updateProduct] in the [RestDataSource] class
  void _updateProduct(ProductHistoryDetails details, String id, String name, String updateName, double initialQty, double cp, double sp, double currentQty,){
    var api = new RestDataSource();
    var product = Product();

    String productHistoryId;
    for(int i = 0; i <_productHistory.length; i++){
      if(_productHistory[i].productName == name) {
        setState(() {
          productHistoryId = _productHistory[i].id;
        });
      }
    }

    try {
      if(updateName == ""){
        product.productName = name;
      }else{
        product.productName = Constants.capitalize(updateName);
        api.updateReportName(name, Constants.capitalize(updateName)).then((value) {
          api.updateProductHistoryName(productHistoryId,
              Constants.capitalize(updateName)).then((value) {
            print("Updated name in history successfully");
          }).catchError((error) {
            print(error);
            Constants.showMessage(error.toString());
          });
          print("$name is updated in reports");
        }).catchError((error) {
          print(error);
          Constants.showMessage(error.toString());
        });
      }

      product.costPrice = cp.toString();
      product.sellingPrice = sp.toString();
      product.initialQuantity = initialQty.toString();
      product.currentQuantity = currentQty.toString();

      api.updateProduct(product, id).then((value){
        if(double.parse(details.qtyReceived) != 0){
          api.addHistoryToProduct(productHistoryId, details).then((value) {
            Constants.showMessage( "$name is updated");
          }).catchError((error) {
            print(error);
            Constants.showMessage(error.toString());
          });
        }
      }).catchError((error) {
        print(error);
        Constants.showMessage(error.toString());
      });
    } catch (e) {
      print(e);
      Constants.showMessage( "Error in updating data");
    }
  }

}
