import 'dart:io';

import 'package:chess_principles/analysislist.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'global.dart' as globals;

import './register.dart';
import './analysis.dart';

class SigninPage extends StatefulWidget {
//  SigninPage({Key key, this.title, this.screenNum}) : super(key: key);
  SigninPage(this.screenNum);

  final int screenNum; // 1 - Analysis
  bool processingState = false;
//  final String title;

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {

  Color _background = Color.fromARGB(255, 255, 237, 213); //a=255 = opaque
  Color _mocha = Color.fromARGB(255, 192, 107, 0);
  Color _highlight = Color.fromARGB(170, 255, 147, 0); // Colors.amberAccent;

  double _selectButtonHeight = 40.0;
  double _buttonWidth = 300.0;
  double _gap = 20.0;

  double _treeFontSize = 13.0;
  double _rowHeight = 20.0;
  double _menuIconHeight = 18;
  double _nextButtonHeight = 23.0;

  String _message = '';

  //final GoogleSignIn googleSignIn = new GoogleSignIn();
  //final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    if (globals.tablet) {
      _treeFontSize = globals.tabFontsize[globals.tid];
      _rowHeight = globals.tabRowHeight[globals.tid];
      _menuIconHeight = globals.tabIconsize[globals.tid];
      _nextButtonHeight = globals.tabNextButtonHeight[globals.tid];
    }

    if(Platform.isIOS){
      //check for ios if developing for both android & ios
      AppleSignIn.onCredentialRevoked.listen((_) {
        print("Credentials revoked");
      });
    }

    _message = '';
  }

  _nextScreen() {
    switch (widget.screenNum) {
      case 2 :
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ListAnalysisGames(),
            ));
        break;
      case 1 :
      default:
      //Navigator.popUntil(context, ModalRoute.withName('/'));
//      Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => Analysis(0, ''),
            ));
        break;
    }
  }

  _loginWithApple() async {

    setState(() {
      _message = 'Processing...';
    });

    if(await AppleSignIn.isAvailable()) {
      final AuthorizationResult result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      switch (result.status) {
        case AuthorizationStatus.authorized:
          print('Credential.user=' +
              result.credential.user); //All the required credentials

          // final AppleIdCredential _auth = result.credential;
          // final OAuthProvider oAuthProvider = new OAuthProvider(providerId: "apple.com");
          // final AuthCredential credential = oAuthProvider.getCredential(
          //     idToken: String.fromCharCodes(_auth.identityToken),
          //     accessToken: String.fromCharCodes(_auth.authorizationCode),
          // );
          //
          // await globals.firebaseAuthGlobal.signInWithCredential(credential);
          //
          // if (_auth.fullName != null) {
          // globals.firebaseAuthGlobal.currentUser().then((value) async {
          setState(() {
            globals.uid.authuserid = result.credential.user; //_auth.email;
            globals.uid.authtype = 4;
            _message = 'Signed in!';
          });
          // });
          // }

          break;
        case AuthorizationStatus.error:
          setState(() {
            _message = "Sign-in failed: " + result.error.localizedDescription;
          });
          break;
        case AuthorizationStatus.cancelled:
          setState(() {
            _message = 'Cancelled';
          });
          break;
        default:
          setState(() {
            _message = 'Apple SignIn is not available for your device';
          });
          break;
      }
    } else {
      setState(() {
        _message = 'Apple SignIn is not available for your device';
      });
    }

    if (globals.uid.authuserid.isNotEmpty) {
      bool present = await globals.checkRetrieveUserRecord();
      if (present == false)
        globals.saveUserPosition();

      _nextScreen();
    }

  }

  _loginWithGoogle() async {
    setState(() {
      _message = 'Processing...';
    });

    final GoogleSignInAccount googleUser = await globals.googleSignInGlobal.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

    if (globals.firebaseAuthGlobal == null)
      return;

    final FirebaseUser user = (await globals.firebaseAuthGlobal.signInWithCredential(credential)).user;
    setState(() {
      globals.uid.authuserid = user.email;
      globals.uid.authtype = 1;
      _message = 'Signed in!';
    });

    bool present = await globals.checkRetrieveUserRecord();
    if (present == false)
      globals.saveUserPosition();

    _nextScreen();

    //print (globals.uid.authuserid);
  }

  _forgotPassword(String emailStr) async {
    _message = '';

    if (emailStr == null || emailStr.isEmpty || globals.validateEmail(emailStr) == false) {
      setState(() {
        _message = 'Invalid email, please try again';
      });
    }

    if (globals.firebaseAuthGlobal == null)
      return;

    FirebaseUser firebaseUser;
    try {
      await globals.firebaseAuthGlobal.sendPasswordResetEmail(email: emailStr).then((authResult) {
        setState(() {
//        firebaseUser = authResult.user;
//        globals.uid.authuserid = firebaseUser.email;
          _message = 'Password reset message sent to email, please reset and try to login.';
        });

//        _nextScreen();

      });
    } on PlatformException catch (e) {
      setState(() {
        _message = globals.getMessageFromErrorCode(e.code);
      });
    }
  }

  _loginWithUserPwd(String emailStr, String passwordStr) async {

    if (globals.firebaseAuthGlobal == null)
      return;

    _message = '';
    FirebaseUser firebaseUser;
    try {
      await globals.firebaseAuthGlobal.signInWithEmailAndPassword(email: emailStr, password: passwordStr).then((authResult) {
//        setState(() {
        firebaseUser = authResult.user;
        globals.uid.authuserid = firebaseUser.email;
        globals.uid.authtype = 3;
//        });

      });
    } on PlatformException catch (e) {
      //print ('exception' + '|' + e.code + '|' + e.message);
      setState(() {
        _message = globals.getMessageFromErrorCode(e.code);
        return;
      });
    }

    bool present = await globals.checkRetrieveUserRecord();
    if (present == false)
      globals.saveUserPosition();

    _nextScreen();

  }

  _loginWithDevice() async {
//    String deviceName;
//    String deviceVersion;
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
//        deviceName = build.model;
//        deviceVersion = build.version.toString();
        identifier = build.androidId;  //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
//        deviceName = data.name;
//        deviceVersion = data.systemVersion;
        identifier = data.identifierForVendor;  //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
      return;
    }

    setState(() {
      globals.uid.authuserid = identifier;
      globals.uid.authtype = 2;
    });

    bool present = await globals.checkRetrieveUserRecord();
    if (present == false)
      globals.saveUserPosition();

    _nextScreen();
  }



  String getUserId() {
    if (_message.trim().isNotEmpty)
      return _message;
    else if (globals.uid.authuserid != null && globals.uid.authuserid.isNotEmpty)
      return 'Signed in!'; // with ' + globals.uid.authuserid;
    else
      return '';
  }


  @override
  Widget build(BuildContext context) {
    TextEditingController _tec1 = TextEditingController();
    TextEditingController _tec2 = TextEditingController();

    if (globals.tablet) {
      _buttonWidth = MediaQuery.of(context).size.width *0.7;
    }

    if (_buttonWidth > MediaQuery.of(context).size.width) {
      _buttonWidth = MediaQuery.of(context).size.width * 0.99;
    }

    AppBar getAppBar() {
      if (globals.tablet) {
        return
          AppBar(
            //iconTheme: IconThemeData( color: _mocha,),
            //backgroundColor: Colors.transparent,
            //elevation: 0,
            centerTitle: true,
            leading: new IconButton(
                icon: new Icon(Icons.arrow_back,
                    // size: globals.tablet ? globals.menuFontsize * 1.5 : globals.submenuFontsize,
                    size: globals.appBarIconFlex, //globals.iconFlex,
                    color: Colors.white),
                onPressed: () => {
                Navigator.pop(context)
                }
            ),
            title: Text('Chess Prof Sign In',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: globals.appBarTextFlex,
              ),
            ), //, style: TextStyle(color: _mocha),)
          );
      } else {
        return
          AppBar(
            //iconTheme: IconThemeData( color: _mocha,),
            //backgroundColor: Colors.transparent,
            //elevation: 0,
            centerTitle: true,
            title: Text('Chess Prof Sign In',
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

              Container(
                width: _buttonWidth,
                height: globals.tablet ? _selectButtonHeight * 1.25 : _selectButtonHeight,
                child: RaisedButton(
                  onPressed: ()
                  {
                    _loginWithDevice();
                  },
                  child: Text('Sign-in with this Device',
                    style: TextStyle(
                      fontSize: globals.tablet ? _treeFontSize + 4  : 16,
                    ),
                  ),
                  color: Color.fromARGB(255, 238, 163, 94),
                  //color: Color.fromARGB(255, 240, 131, 49),
                  elevation: 5,
                ),
              ),

              SizedBox(height: _selectButtonHeight),

              Container(
                width: _buttonWidth,
                height: globals.tablet ? _selectButtonHeight * 1.25 : _selectButtonHeight,
                child: RaisedButton(
                  //icon: Icon(Icons.Google, color: Colors.brown),
                  onPressed:  () async {
                    _loginWithGoogle();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(FontAwesomeIcons.google,
                          size: globals.tablet ? _treeFontSize + 4 : 18),
                      SizedBox(width: 10),
                      Text('Sign-in using Google',
                        style: TextStyle(
                          fontSize: globals.tablet ? _treeFontSize + 4  : 16,
                        ),
                      ),
                    ],
                  ),
                  color: Color.fromARGB(255, 238, 163, 94),
                  //color: Color.fromARGB(255, 240, 131, 49),
                  elevation: 5,
                ),
              ),

              SizedBox(height: _selectButtonHeight),


              Visibility(
                visible: Platform.isIOS,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    Container(
                      width: _buttonWidth,
                      height: globals.tablet ? _selectButtonHeight * 1.25 : _selectButtonHeight,
                      child: RaisedButton(
                        //icon: Icon(Icons.Google, color: Colors.brown),
                        onPressed:  () async {
                          _loginWithApple();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(FontAwesomeIcons.apple,
                                size: globals.tablet ? _treeFontSize + 4 : 18),
                            SizedBox(width: 10),
                            Text('Sign-in using Apple',
                              style: TextStyle(
                                fontSize: globals.tablet ? _treeFontSize + 4  : 16,
                              ),
                            ),
                          ],
                        ),
                        color: Color.fromARGB(255, 238, 163, 94),
                        //color: Color.fromARGB(255, 240, 131, 49),
                        elevation: 5,
                      ),
                    ),

                    SizedBox(height: _selectButtonHeight),
                  ],
                ),
              ),


              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Text('Sign-in with username/password',
                    style: TextStyle(
                      fontSize: globals.tablet ? _treeFontSize + 4  : 16,
                    ),
                  ),
                  SizedBox(height: 5),

                  Container(
                    width: _buttonWidth,
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
                      decoration: InputDecoration(
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.brown)),
                          //labelText: 'Username',
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.brown,
                            size: globals.tablet ? _menuIconHeight : 20,
                          ),
                          hintText: "Email"
                      ),
//                      onTap: () {
//                        _message = '';
//                      }
                    ),
                  ),
        ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: _buttonWidth,
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
                        fontSize: globals.tablet ? _treeFontSize   : 16,
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
                  SizedBox(height: 5),

                  Container(
                    width: _buttonWidth,
                    height: globals.tablet ? _selectButtonHeight * 1.25 : _selectButtonHeight,
                    child: RaisedButton(
                      onPressed: ()
                      {
                        _loginWithUserPwd(_tec1.text, _tec2.text);
                      },
                      child: Text('Login',
                        style: TextStyle(
                          fontSize: globals.tablet ? _treeFontSize + 4  : 16,
                        ),
                      ),
                      color: Color.fromARGB(255, 238, 163, 94),
                      //color: Color.fromARGB(255, 240, 131, 49),
                      elevation: 5,
                    ),
                  ),

                  SizedBox(height: 5),


                  Container(
                    width: _buttonWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget> [
                        Container(
                          width: _buttonWidth *.49,
                          height: globals.tablet ? _selectButtonHeight * 1.25 *.75 : _selectButtonHeight*.75,

                          child: RaisedButton(
                            onPressed: ()
                            {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>RegisterPage(1),
                                  ));
                            },
                            child: Text('Register',
                              style: TextStyle(
                                fontSize: globals.tablet ? _treeFontSize  : 14,
                              ),
                            ),
                            color: Color.fromARGB(255, 238, 163, 94),
                            elevation: 5,
                          ),
                        ),
                        Container(
                          width: _buttonWidth *.49,
                          height: globals.tablet ? _selectButtonHeight * 1.25 *.75 : _selectButtonHeight*.75,
                          child: RaisedButton(
                            onPressed: ()
                            {
                              _forgotPassword(_tec1.text);
                            },
                            child: Text('Forgot Password',
                              style: TextStyle(
                                fontSize: globals.tablet ? _treeFontSize  : 14,
                              ),
                            ),
                            color: Color.fromARGB(255, 238, 163, 94),
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),

              SizedBox(height: _gap),

              Text(getUserId(),
                style: TextStyle(
                  fontSize: globals.tablet ? _treeFontSize  : 16,
                ),
              ),

            ],
          ),
        ),
//    ),
      );
  }
}
