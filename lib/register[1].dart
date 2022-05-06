import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'global.dart' as globals;

import './analysis.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage(this.screenNum);
  final int screenNum; // 1 - Analysis

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  Color _background = Color.fromARGB(255, 255, 237, 213); //a=255 = opaque
  Color _mocha = Color.fromARGB(255, 192, 107, 0);
  Color _highlight = Color.fromARGB(170, 255, 147, 0); // Colors.amberAccent;

  double _navBarHeight = 40.0;
  int _currentIndex = 0;
  double _selectButtonHeight = 40.0;
  double _buttonWidth = 300.0;
  double _gap = 20.0;

  double _treeFontSize = 13.0;
  double _rowHeight = 20.0;
  double _menuIconHeight = 18;
  double _nextButtonHeight = 23.0;

  String _display = '';

  String emailField = '';
  String pwd1Field = '';
  String pwd2Field = '';

  //final GoogleSignIn googleSignIn = new GoogleSignIn();
  //final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  TextEditingController _tec1 = TextEditingController();
  TextEditingController _tec2 = TextEditingController();
  TextEditingController _tec3 = TextEditingController();

  _nextScreen() {
    switch (widget.screenNum) {
      case 1 :
      default:
        //Navigator.popUntil(context, ModalRoute.withName('/'));
//      Navigator.pop(context);
//      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Analysis(0, ''),
          ));
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _display = '';


    if (globals.tablet) {
      _treeFontSize = globals.tabFontsize[globals.tid];
      _rowHeight = globals.tabRowHeight[globals.tid];
      _menuIconHeight = globals.tabIconsize[globals.tid];
      _nextButtonHeight = globals.tabNextButtonHeight[globals.tid];
    }


  }

  _registerUser(String email, String pwd1, String pwd2) async {

    _display = '';

    emailField = _tec1.text;
    pwd1Field = _tec2.text;
    pwd2Field = _tec3.text;

    if (globals.validateEmail(email) == false) {
      setState(() {
        _display = 'Invalid email';
      });
      return;
    }
    if (pwd1 != pwd2) {
      setState(() {
        _display = 'Passwords do not match';
      });
      return;
    }

    setState(() {
//      _display = 'Sending request...';
    });
    FirebaseUser firebaseUser;

    if (globals.firebaseAuthGlobal == null)
      return;

    try {
      await globals.firebaseAuthGlobal.createUserWithEmailAndPassword(email: email, password: pwd1).then((authResult) {
        setState(() {
          firebaseUser = authResult.user;
          globals.uid.authuserid = firebaseUser.email;
          _display = globals.uid.authuserid;
          globals.saveUserPosition();
        });
        _loginWithUserPwd(email, pwd1);
        _nextScreen();
      });
    } on PlatformException catch (e) {
      print ('exception' + '|' + e.code + '|' + e.message);
      setState(() {
        _display = getMessageFromErrorCode(e.code);
      });
    }
  }

  _loginWithUserPwd(String emailStr, String passwordStr) async {

    if (globals.firebaseAuthGlobal == null)
      return;

    print (emailStr + ' / ' + passwordStr);
    _display = '';
    FirebaseUser firebaseUser;
    try {
      await globals.firebaseAuthGlobal.signInWithEmailAndPassword(email: emailStr, password: passwordStr).then((authResult) {
        setState(() {
          firebaseUser = authResult.user;
          globals.uid.authuserid = firebaseUser.email;
        });
      });
    } on PlatformException catch (e) {
      setState(() {
        _display = getMessageFromErrorCode(e.code);
      });
    }
  }

  String getMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return "Email already used. Go to login page.";
        break;
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        return "Wrong email/password combination.";
        break;
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return "No user found with this email.";
        break;
      case "ERROR_USER_DISABLED":
      case "user-disabled":
        return "User disabled.";
        break;
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return "Too many requests to log into this account.";
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
      case "operation-not-allowed":
        return "Server error, please try again later.";
        break;
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return "Email address is invalid.";
        break;
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return "No account found with this email";
        break;
      case "ERROR_NETWORK_REQUEST_FAILED":
      case "network-request-failed":
        return "Could not connect. Please try again in a few minutes.";
        break;
      default:
        return "Login failed. Please try again.";
        break;
    }
  }

  String getUserId() {
    if (_display != null && _display.isNotEmpty)
      return _display;
    else if (globals.uid.authuserid != null && globals.uid.authuserid.isNotEmpty)
      return 'Signed in with ' + globals.uid.authuserid;
    else
      return '';
  }

  @override
  Widget build(BuildContext context) {
    _tec1.text = emailField;
    _tec2.text = pwd1Field;
    _tec3.text = pwd2Field;

    AppBar getAppBar() {
      if (globals.tablet) {
        return AppBar(
          //iconTheme: IconThemeData( color: _mocha,),
          //backgroundColor: Colors.transparent,
          //elevation: 0,
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back,
                  // size: globals.tablet ? globals.menuFontsize * 1.5 : globals.submenuFontsize,
                  size: globals.appBarIconFlex, //globals.iconFlex,
                  color: Colors.white),
              onPressed: () => {
                Navigator.pop(context)
              }
          ),
          centerTitle: true,
          title: Text('Chess Prof Registration',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: globals.appBarTextFlex,
            ),
          ), //, style: TextStyle(color: _mocha),)
        );
      } else {
        return AppBar(
          //iconTheme: IconThemeData( color: _mocha,),
          //backgroundColor: Colors.transparent,
          //elevation: 0,
          centerTitle: true,
          title: Text('Chess Prof Registration',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: globals.appBartextSize,
            ),
          ), //, style: TextStyle(color: _mocha),)
        );
      }

    }

    return
      Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 237, 213),
      resizeToAvoidBottomPadding: false,
      body:
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

            //appBar:
            SizedBox(
              height: globals.appBarHeight,
              child: getAppBar(),
            ),


            /* login button */
            SizedBox(
              height: _gap,
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                Container(
                  width: globals.tablet ? MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.9, //_buttonWidth,
                  height: globals.tablet ? _selectButtonHeight * 1.25 : _selectButtonHeight,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.brown,
                    ),
                  ),
                  child:
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints.expand(width: 1000),
                      child:
                      TextField(
                    style: TextStyle(
                      fontSize: globals.tablet ? _treeFontSize  : 16,
                    ),
                    keyboardType: TextInputType.text,
                    controller: _tec1,
                    textInputAction: TextInputAction.go,
                    onEditingComplete: () {
                      if (globals.validateEmail(_tec1.text) == false) {
                          _display = 'Invalid email';
                      }
                    },
                    decoration: InputDecoration(
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.brown)),
                        //labelText: 'Username',
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.brown,
                          size: globals.tablet ? _menuIconHeight : 20,
                        ),
                        hintText: "Email"),
                  ),
      ),
      ),
                ),
                SizedBox(height: _gap),
                Container(
                  width: globals.tablet ? MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.9, //_buttonWidth,
                  height: globals.tablet ? _selectButtonHeight * 1.25 : _selectButtonHeight,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.brown,
                    ),
                  ),
                  child:
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints.expand(width: 1000),
                      child:
                  TextField(
                    style: TextStyle(
                      fontSize: globals.tablet ? _treeFontSize  : 16,
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    controller: _tec2,
                    textInputAction: TextInputAction.go,
                    decoration: InputDecoration(
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.brown)),
                        //labelText: 'Password',
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.brown,
                          size: globals.tablet ? _menuIconHeight : 20,
                        ),
                        hintText: "Password"),
                  ),
                        ),
    ),

                ),
                SizedBox(height: _gap),
                Container(
                  width: globals.tablet ? MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.9, //_buttonWidth,
                  height: globals.tablet ? _selectButtonHeight * 1.25 : _selectButtonHeight,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.brown,
                    ),
                  ),
                  child:
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints.expand(width: 1000),
                      child:
                  TextField(
                    style: TextStyle(
                      fontSize: globals.tablet ? _treeFontSize  : 16,
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    controller: _tec3,
                    textInputAction: TextInputAction.go,
                    decoration: InputDecoration(
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.brown)),
                        //labelText: 'Password',
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.brown,
                          size: globals.tablet ? _menuIconHeight : 20,
                        ),
                        hintText: "Re-enter Password"),
                  ),
    ),
    ),


                ),
                SizedBox(height: _gap),

                Container(
                  width: globals.tablet ? MediaQuery.of(context).size.width * 0.5 : _buttonWidth,
                  height: globals.tablet ? _selectButtonHeight * 1.25 : _selectButtonHeight,
                  child: RaisedButton(
                    onPressed: ()
                    {
                      _registerUser(_tec1.text, _tec2.text, _tec3.text);
                    },
                    child: Text('Register',
                      style: TextStyle(
                        fontSize: globals.tablet ? _treeFontSize  : 16,
                      ),
                    ),
                    color: Color.fromARGB(255, 238, 163, 94),
                    //color: Color.fromARGB(255, 240, 131, 49),
                    elevation: 5,
                  ),
                ),

              ],
            ),

            SizedBox(height: _gap),

            Text(getUserId()),

          ],
        ),
      ),
    );
  }
}
