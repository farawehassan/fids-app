import 'package:fids_apparel/model/create_user.dart';
import 'package:fids_apparel/networking/rest_data.dart';
import 'package:fids_apparel/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

/// A StatefulWidget class that creates a new user (worker) that can have access
/// to read and write data in the application except from viewing the business's
/// profile [Profile]
class CreateWorker extends StatefulWidget {

  static const String id = 'create_worker_page';

  @override
  _CreateWorkerState createState() => _CreateWorkerState();
}

class _CreateWorkerState extends State<CreateWorker> {

  /// A [GlobalKey] to hold the form state of my form widget for form validation
  final _formKey = GlobalKey<FormState>();

  /// A [TextEditingController] to control the input text for the user's name
  TextEditingController _nameController = new TextEditingController();

  /// A [TextEditingController] to control the input text for the user's phone
  TextEditingController _phoneController = new TextEditingController();

  /// A [TextEditingController] to control the input text for the user's pin
  TextEditingController _pinController = new TextEditingController();

  /// A [TextEditingController] to control the input text for the user's
  /// confirmation pin
  TextEditingController _confirmPinController = new TextEditingController();

  /// A boolean variable to hold the [inAsyncCall] value in my
  /// [ModalProgressHUD] widget
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Create Worker')),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: TextFormField(
                        decoration: kAddProductDecoration.copyWith(hintText: "Name"),
                        keyboardType: TextInputType.text,
                        controller: _nameController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter a name';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: TextFormField(
                        decoration: kAddProductDecoration.copyWith(hintText: "Phone Number"),
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter a phone number';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: TextFormField(
                        decoration: kAddProductDecoration.copyWith(hintText: "Pin"),
                        keyboardType: TextInputType.number,
                        controller: _pinController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter a pin';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: TextFormField(
                        decoration: kAddProductDecoration.copyWith(hintText: "Confirm Pin"),
                        keyboardType: TextInputType.number,
                        controller: _confirmPinController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Confirm your pin';
                          }
                          else if(_pinController.text != _confirmPinController.text){
                            return 'Pin not equal';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    color: Color(0XFFA6277C)
                  ),
                  child: MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Color(0XFFA6277C),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 21.0),
                        child: Text(
                          'SUBMIT',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0
                          ),
                        ),
                      ),
                      onPressed: () {
                        if(_formKey.currentState.validate()){
                          setState(() {
                            showSpinner = true;
                          });
                          createUser(_nameController.text, _phoneController.text, _pinController.text, _confirmPinController.text);
                        }
                      }
                  ),
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }

  /// Function that creates a new user by calling
  /// [signUp] in the [RestDataSource] class
  void createUser(String name, String phoneNumber, String pin, String confirmPin){
    var user = CreateUser();
    var api = new RestDataSource();
    try {
      user.name = Constants.capitalize(name);
      user.phoneNumber = phoneNumber;
      user.pin = pin;
      user.confirmPin = confirmPin;

      api.signUp(user).then((value) {
        _nameController.clear();
        _phoneController.clear();
        _pinController.clear();
        _confirmPinController.clear();

        setState(() {
          showSpinner = false;
        });
        Constants.showMessage('User successfully created');
      }).catchError((Object error) {
        _phoneController.clear();
        _pinController.clear();
        _confirmPinController.clear();
        Constants.showMessage(error.toString());
      });

    } catch (e) {
      print(e);
      Constants.showMessage(e.toString());
    }
  }

}
