import 'package:chess/chess.dart' as chess;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'dart:io';
import 'global.dart' as globals;
import './pgndisplay.dart';
import './setlevel.dart';
import './analysis.dart';
import './analyzedgames.dart';

class CommentDialog extends StatefulWidget {
  const CommentDialog(this.onValueChange, this.initialValue, this.messageId, this.initialEmail);

  final String initialValue;
  final void Function(String, String, int) onValueChange;
  final int messageId;
  final String initialEmail;

  @override
  State createState() => new CommentDialogState();
}

class CommentDialogState extends State<CommentDialog> {
  String _selectedId;
  int _messageId;
  String _email;

  double _treeFontSize = 13.0;
  double _rowHeight = 20.0;
  double _menuIconHeight = 18;

  List<String> message = [
    'Enter email address to send this game to',
    'Submit this game to ChessProf for analysis',
  ];

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialValue;
    _messageId = widget.messageId;
    _email = widget.initialEmail;

    if (globals.tablet) {
      _treeFontSize = globals.tabFontsize[globals.tid];
      _rowHeight = globals.tabRowHeight[globals.tid];
      _menuIconHeight = globals.tabIconsize[globals.tid];
    }

  }

  @override
  Widget build(BuildContext context) {

    TextEditingController _textFieldController = TextEditingController();
    _textFieldController.text = _email;

    return AlertDialog(
      title: Text(message[_messageId],
        style: TextStyle(
          fontSize: globals.tablet ? _treeFontSize + 4 : 16,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Visibility(
            visible: _messageId == 0, // only for Email dialog
            child: TextField(
              style: TextStyle(
                  fontSize: globals.tablet ? _treeFontSize : 14),
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 12,
              controller: _textFieldController,
              textInputAction: TextInputAction.go,
              decoration: InputDecoration(
                  hintText: "Email"),
            ),
          ),
        ],
      ),
      elevation: 24.0,
      backgroundColor: globals.background,
      actions: [
        FlatButton(onPressed: () {
          String _sendTo = _textFieldController.text;
          widget.onValueChange(_selectedId, _sendTo, _messageId);
          _textFieldController.clear();
          Navigator.of(context).pop(); // dismiss dialog
        }, child: Text('Send',
          style: TextStyle(
              fontSize: globals.tablet ? _treeFontSize : 14),
        ), color: Colors.black),
        FlatButton(onPressed: () {
          _textFieldController.clear();
          Navigator.of(context).pop(); // dismiss dialog
        }, child: Text('Cancel',
          style: TextStyle(
              fontSize: globals.tablet ? _treeFontSize : 14),
        ), color: Colors.black)
      ],
    );
  }
}


class ListAnalysisGames extends StatefulWidget {
  @override
  _ListAnalysisGamesState createState() => _ListAnalysisGamesState();
}

class AnalysisGame {
  String documentID;
  String id;
  String title;
  String submitstatus;
  String color;
  String result;
}

class _ListAnalysisGamesState extends State<ListAnalysisGames> {

  String _welcome = 'Click game title to view it in the Analysis screen. You can also submit to ChessProf for expert analysis.';

  Map gameMap = Map<String,String>();
  List<AnalysisGame> gameList = new List<AnalysisGame>();
  List<String> submitButtonText = ['Submit for\nChessProf analysis', 'Under Analysis\nby ChessProf', 'Analysis available\nClick to view']; // ['Submit', 'Unsubmit', 'View'];
  //List<String> submitMessageText = ['Submit for ChessProf analysis', 'Under analysis by ChessProf', 'Analysis availablew'];
  List<DocumentSnapshot> gamedocs;

  double _treeFontSize = 13.0;
  double _rowHeight = 20.0;
  double _menuIconHeight = 18;
  double _nextButtonHeight = 23.0;

  void _loadList() async {

//    print ('In _loadList');

    if (globals.firestore == null)
      return;

    var collectionReference = await globals.firestore.collection('analysisgames').where('userid', isEqualTo: globals.uid.authuserid);

    collectionReference.snapshots().listen((snapshot) {

//      print ('Snapshot called');

        gamedocs = snapshot.documents;

        if (gamedocs != null && gamedocs.isNotEmpty) {
          setState(() {
            gameList.clear();
            gameMap.clear();


            Map g;

            for (int i = 0; i < gamedocs.length; i++) {
              g = gamedocs[i].data;

              String id = g['timestamp'];
              String title = g['title'];
              String userid = g['userid'];
              String submitstatus = g['submitstatus'];
              String color = g['color'];
              String result = g['result'];

              // if (userid != globals.uid.authuserid) {
              //   //print ('userid = ' + userid + ', globals userid = ' + globals.uid.authuserid);
              //   continue;
              // }

              gameMap.putIfAbsent(id, () => title);

              AnalysisGame game = new AnalysisGame();
              game.documentID = gamedocs[i].documentID;
              game.title = title == null ? '' : title;
              game.id = id == null ? '' : id;
              game.submitstatus = submitstatus == null ? '' : submitstatus;
              game.color = color == null ? '' : color;
              game.result = result == null ? '' : result;

              gameList.add(game);
            }
          });
        }
    });
  }


  _updateSubmitStatus(String id, String submitStatus, String sendToEmail, bool emailOnly) async {
    Map a;
    bool external = true;

    String _event = '';
    String _color = '';
    String _result = '';
    String _pgn = '';
    String _username = '';
    String _docId = '';
    String _id = '';
    String _userid = '';
    String _level = '';

    for (int r = 0; r < gamedocs.length; r++) {
      a = gamedocs[r].data;
      if (a['userid'] == globals.uid.authuserid && a['timestamp'] == id) {
        _docId = gamedocs[r].documentID;
        _pgn = a['pgn'];
        _event = a['title'];
        _id = a['timestamp'];
        _userid = a['userid'];
        _color = a['color'];
        _result = a['result'];
        _level = a['level'];
        _userid = a['userid'];

        if (emailOnly == false) {
          a['submitstatus'] = submitStatus;
          //a['coachid'] = globals.uid.coachId;
          gamedocs[r].reference.updateData(a);

          if (submitStatus == '1') {
            // make a placeholder entry in chessprofanalyzedgames, to be populated with annotated pgn later by expert
            List<String> namL = new List<String>();
            namL.add('ID');
            namL.add('color');
            namL.add('fen');
            namL.add('level');
            namL.add('moves');
            namL.add('result');
            namL.add('title');
            namL.add('userid');

            List<dynamic> valL = new List<dynamic>();
            valL.add(_id);
            valL.add(_color);
            valL.add('');
            valL.add(_level);
            valL.add(_pgn);
            valL.add(_result);
            valL.add(_event);
            valL.add(_userid);

            Map<String, dynamic> pData = new Map.fromIterables(namL, valL);

            await insertAnalyzedGame(_docId, pData);

            external = false;
          }
        }

        break;
      }
    }


    if (sendToEmail == null || sendToEmail.isEmpty)
      return;

    /* append Event details to PGN */

    String _whiteplayer = '', _blackplayer = '';

    if (_color == "white") {
      _whiteplayer = _username;
      // _blackplayer = _opp;
    }
    else {
      // _whiteplayer = _opp;
      _blackplayer = _username;
    }

    if (_blackplayer.isNotEmpty)
      _pgn = '[Black "$_blackplayer"] \n' + _pgn;

    if (_whiteplayer.isNotEmpty)
      _pgn = '[White "$_whiteplayer"] \n' + _pgn;

    //===

    // if (_round.isNotEmpty)
    //   _pgn = '[Round "$_round"] \n' + _pgn;
    //
    // if (_eventdate.isNotEmpty)
    //   _pgn = '[Date "$_eventdate"] \n' + _pgn;

    if (_event.isNotEmpty)
      _pgn = '[Event "$_event"] \n' + _pgn;

    if (_result.isNotEmpty)
      _pgn = _pgn + ' ' + globals.resultList[_result];

    //print(_pgn);

    globals.emailPgn(sendToEmail, _pgn, _docId, external);

    //print(sendToEmail);
  }

  insertAnalyzedGame(String docId, Map<String, dynamic> pData) async
  {
    CollectionReference collectionReference = await globals.firestore.collection('chessprofanalyzedgames'); //chessprofanalyzedgames

    if (collectionReference == null) {
      print ('Invalid collection reference');
      return false;
    }
    try {
      // collectionReference.add(pData);
        collectionReference.document(docId).setData(pData);
      //print ('Sent mail');
    } on PlatformException catch (e) {
      print(globals.getMessageFromErrorCode(e.code));
      return false;
    }

    return true;
  }

  _confirmDelete(String id) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) =>
          Container(
            child: AlertDialog(
              title: Text('Are you sure you want to delete',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              backgroundColor: globals.background,
              actions: [
                Stack(
                  children: <Widget>[
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[

                        ButtonTheme(
                          //minWidth: 10,
                          height: 30,
                          child:
                          RaisedButton(
                            color: Colors.orangeAccent,
                            child: Text("Delete",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () {
                              _delete(id);
                              Navigator.of(context).pop(); // dismiss dialog
                            },
                          ),
                        ),

                        ButtonTheme(
                          //minWidth: 10,
                          height: 30,
                          child:
                          RaisedButton(
                            color: Colors.orangeAccent,
                            child: Text("Cancel",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // dismiss dialog
                            },
                          ),
                        ),

                      ],
                    ),

                  ],
                ),
              ], // end actions
            ),
          ),
    );

  }

  _delete(String id) async {
    Map a;

    // setState(() {

    for (int r = 0; r < gamedocs.length; r++) {
      a = gamedocs[r].data;
      if (a['userid'] == globals.uid.authuserid && a['timestamp'] == id) {
        gamedocs[r].reference.delete();
        return;
      }
    }

    // });

  }

  Color getSubmitColor(String id) {
    int messageType = getSubmitType(id);

    switch (messageType) {
      case 2:
        return
          //Colors.blue;
          //Color.fromARGB(255, 255, 223, 207); // light pink
          //Color.fromARGB(255, 225, 255, 214); // light green
          Color.fromARGB(255, 225, 255, 214); // light green
        break;
      case 1:
        return
          //Colors.lightGreen;
          //Color.fromARGB(255, 255, 225, 143); // yellow
          //Color.fromARGB(255, 212, 255, 221); // light blue
          //Color.fromARGB(255, 220, 242, 255); // grey blue
          Color.fromARGB(255, 220, 242, 255); // grey blue
        break;
      case 0:
      default:
        return
          Color.fromARGB(255, 238, 163, 94); // default button
    //Color.fromARGB(255, 255, 231, 175); // beige
    }
  }

  int getSubmitType(String id) {

    int position = getPosition(id);

    if (position < 0 || position > gameList.length - 1)
      return 0;

    if (gameList[position].submitstatus == null || gameList[position].submitstatus.isEmpty)
      return 0;

    if (gameList[position].submitstatus == "1")
      return 1;

    if (gameList[position].submitstatus == "2")
      return 2;

    return 0;
  }

  String getSubmitButtonText(String id) {

    return submitButtonText[getSubmitType(id)];
  }

  // String getSubmitMessageText(String id) {
  //
  //   return submitMessageText[getSubmitType(id)];
  // }

  int getPosition(String id) {

    for (int i = 0; i < gameList.length; i++) {
      if (gameList[i].id == id)
        return i;
    }

    return 0;

  }

  Widget getColorPiece(String color, double size) {
    return color == 'white' ? WhiteKing(size: size) : BlackKing(size: size);
  }

  Icon getResultIcon(String result, double size) {
    switch (result) {
      case 'won': return Icon(Icons.thumb_up_outlined, size: size, color: Colors.black54); break; // Icons.done
      case 'lost': return Icon(Icons.thumb_down_outlined, size: size, color: Colors.black54); break;
      case 'draw': return Icon(Icons.thumbs_up_down_outlined, size: size, color: Colors.black54); break; // Icons.group, Icons.unfold_less, Icons.sports_hockey_rounded
      default: return Icon(null, size: size); break;
    }
  }

  void _share(String id) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new CommentDialog(_sendMail, id, 0, ''); // message 0
        }
    );
  }

  void _sendMail(String id, String email, int messageId) {

    if (email == null || email.isEmpty || messageId != 0)
      return;

    _updateSubmitStatus(id, '0', email, true); // last parameter indicates email only
  }

  void _submit(String id) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new CommentDialog(_submitCall, id, 1, ''); //message 1
        }
    );
  }

  void _submitCall(String id, String email, int messageId)
  {
    if (messageId != 1)
      return;

    _updateSubmitStatus(id, '1', 'chessprof.chess@gmail.com', false);
  }


  buildGameList(BuildContext context) {
    return
      ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: gameList.length,
          itemBuilder: (context, position) {
            String _title = gameList[position].title == '' ? 'Game' : gameList[position].title;
            int len;
            len = _title.length > 32 ? 32 : _title.length;
            _title = _title.substring(0, len);
            return Column (
              mainAxisAlignment: MainAxisAlignment.start,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // divider
                Visibility(
                  visible: position == 0,
                  child: Container(
                    color: globals.mocha,
                    width: MediaQuery.of(context).size.width,
                    height: 1,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    ButtonTheme(
                      minWidth: 20,
                      height: (globals.tablet ? globals.buttonHeight * 1.25 : globals.buttonHeight) - 5,
                      padding: const EdgeInsets.all(0.0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: FlatButton(
                        onPressed: () {
                          _confirmDelete(gameList[position].id);
                          // setState(() {
                          //
                          // });
                        },
                        child: Icon(Icons.close, color: globals.mocha,
                            size: globals.tablet ? _menuIconHeight + 4: 22),
                      ),
                    ),


                    Container(
                      width: MediaQuery.of(context).size.width - 21 - 28 - 25 - (globals.tablet ? 50 : 10),
                      height: (globals.tablet ? globals.buttonHeight * 1.25 : globals.buttonHeight),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => Analysis(1, gameList[position].id),
                              ));
                        },
                        child:
                        Text('$_title',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: globals.tablet ? _treeFontSize + 4 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    ),


                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: [

                    getColorPiece(gameList[position].color,
                        globals.tablet ? _menuIconHeight + 6: 28.0),

                    getResultIcon(gameList[position].result,
                        globals.tablet ? _menuIconHeight + 4: 25),

                    //   ],
                    // ),

                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      //height: globals.buttonHeight,
                      height: globals.tablet ? globals.buttonHeight * 1.25 : globals.buttonHeight * 0.75,
                      child: RaisedButton(
                        //icon: Icon(Icons.Google, color: Colors.brown),
                        onPressed: () {
                          if (gameList[position].submitstatus == '1') {
                            //_updateSubmitStatus(gameList[position].id, '0', '', false);
                          } else if (gameList[position].submitstatus == '2') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => AnalyzedGamesPage(gameList[position].documentID),
                                ));
                          } else {
                            //_updateSubmitStatus(gameList[position].id, '1', 'chessprof.chess@gmail.com', false)
                            _submit(gameList[position].id);
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child:
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   children: <Widget>[
                        Text(getSubmitButtonText(gameList[position].id),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: globals.tablet ? _treeFontSize + 2: 12
                          ),
                        ),
                        //   ],
                        // ),
                        color: getSubmitColor(gameList[position].id),
                        elevation: 5,
                      ),
                    ),

                      SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      ),

                    ButtonTheme(
                      height: (globals.tablet ? globals.buttonHeight * 1.25 : globals.buttonHeight) - 5,
                      minWidth: 20,
                      padding: const EdgeInsets.all(0.0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: FlatButton(
                        onPressed: () {
                          _share(gameList[position].id);
                        },
                        child: Icon(
                            Icons.email_outlined,
                            //Icons.share,
                            color: globals.mocha,
                            size: globals.tablet ? _menuIconHeight + 4: 22),
                      ),
                    ),

                    SizedBox(
                      width: 25,
                    ),

                  ],
                ),

                SizedBox(
                  height: globals.tablet ? 15 : 5,
                ),

                // divider
                Container(
                  color: globals.mocha,
                  width: MediaQuery.of(context).size.width,
                  height: 1,
                ),
              ],
            );
          }
      );

  }

  @override
  void initState() {
    super.initState();

    if (globals.tablet) {
      _treeFontSize = globals.tabFontsize[globals.tid];
      _rowHeight = globals.tabRowHeight[globals.tid];
      _menuIconHeight = globals.tabIconsize[globals.tid];
      _nextButtonHeight = globals.tabNextButtonHeight[globals.tid];
    }


    _loadList();
  }

  Future<bool> _onBackPressed() {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {

    AppBar getAppBar() {
      if (globals.tablet) {
        return
        AppBar(
          centerTitle: true,
          title: Text('My Saved Games',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: globals.appBarTextFlex, //globals.appBartextSize,
            ),
          ), //, style: TextStyle(color: _mocha),)

          leading: new IconButton(
              icon: new Icon(Icons.arrow_back,
                  // size: globals.tablet ? globals.menuFontsize * 1.5 : globals.submenuFontsize,
                  size: globals.appBarIconFlex, //globals.iconFlex,
                  color: Colors.white),
              onPressed: () => {
                _onBackPressed()
              }
          ),

          actions: <Widget> [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => SetLevel(3),
                    ));
              },
              icon: Icon(Icons.settings, color: Colors.white,
                size: globals.appBarIconFlex,
              ),
            ),
          ],
        );

      } else {

        return
        AppBar(
          centerTitle: true,
          title: Text('My Saved Games',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: globals.appBartextSize,
            ),
          ), //, style: TextStyle(color: _mocha),)
          actions: <Widget> [

            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => SetLevel(3),
                    ));
              },
              icon: Icon(Icons.settings, color: Colors.white),
            ),
          ],
        );
      }

    }

    return
      WillPopScope(
        onWillPop: _onBackPressed,
        child:
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

                SizedBox(
                  height: globals.smallspacer,
                ),

                Container(
                  height: globals.textheight,
                  margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text('$_welcome',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: globals.tablet ? _treeFontSize + 2 : globals.textsize,
                    ),
                  ),
                ),

                // SizedBox(
                //   height: globals.smallspacer,
                // ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      //icon: Icon(Icons.Google, color: Colors.brown),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => Analysis(1, ''),
                            ));
                      },
                      child:
                      Icon(Icons.add, color: globals.mocha,
                        size: globals.tablet ? _menuIconHeight + 4 : 26,
                      ),
                      // SizedBox(width: 10),
                      // Text('Analyze New Game',
                      //   style: TextStyle(
                      //   color: Colors.white,
                      //     fontSize: 14,
                      //   ),
                      // ),

                      //color: Color.fromARGB(255, 238, 163, 94),
                      //color: Color.fromARGB(255, 240, 131, 49),
                      //color: globals.mocha,
                      //elevation: 5,
                    ),
                  ],
                ),


                Container(
                  margin: EdgeInsets.zero,
                  height: MediaQuery.of(context).size.height - globals.appBarHeight - globals.smallspacer - globals.smallspacer
                      - 10 - globals.welcometextheight - globals.buttonHeight,
                  child: Scrollbar(
                    child:
                    buildGameList(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );;
  }
}
