import 'package:chess/chess.dart' as chess;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:swipedetector/swipedetector.dart';
import 'dart:io';
import 'global.dart' as globals;
import './pgndisplay.dart';
import './setlevel.dart';

class AnalyzedGamesPage extends StatefulWidget {
  AnalyzedGamesPage(this.startGameId);

  final startGameId;

  @override
  _AnalyzedGamesPageState createState() => _AnalyzedGamesPageState();
}

class Principle {
  String principle;
  String description;
}

class _AnalyzedGamesPageState extends State<AnalyzedGamesPage> {

  Map iconList = {
    '!' : Icons.battery_alert,
    '?' : Icons.battery_unknown,
    '' : null,
    'overwrite' : Icons.add_to_photos_rounded, //Icons.all_out_outlined,
    'go' : Icons.add, //Icons.add_circle_outline,
    'back' :  Icons.arrow_back,
    'right' : Icons.arrow_right,
    'down' : Icons.arrow_drop_down,
    'close' : Icons.close,
    'separator' : Icons.keyboard_arrow_right,
    'main': Icons.call_missed_outgoing , // Icons.present_to_all, //Icons.arrow_upward,
    'add' : Icons.alt_route, //Icons.add_to_photos_outlined,
    'prev' : Icons.skip_previous,
    'next' : Icons.skip_next,
    'comment' : Icons.comment_outlined,
    'save': Icons.save,
    'new' : Icons.create_new_folder_outlined,
  };

  double _treeFontSize = 13.0;
  double _rowHeight = 20.0;
  double _menuIconHeight = 18;

  double _nextButtonHeight = 23.0;
  double _commentHeight = 64.0;
  double _anHeight = 100.0;
  double _appBarHeight = 60.0;

  double _commentLine = 16.0;
  double _commentIncrement = 0;

  Color _background = Color.fromARGB(255, 255, 237, 213); //a=255 = opaque
  Color _mocha = Color.fromARGB(255, 192, 107, 0);

  String _treeSep = '\u26A1';
  //String _treeSep = '\u263D';
  //String _treeSep = '\u2688';


  List<Color> colorList = [
    Color.fromARGB(255, 192, 107, 0),
    Color.fromARGB(255, 192, 107, 0),
    Color.fromARGB(255, 192, 107, 0),
    Color.fromARGB(255, 192, 107, 0),
    Color.fromARGB(255, 192, 107, 0),
    Color.fromARGB(255, 192, 107, 0),
    Color.fromARGB(255, 192, 107, 0),
  ];

  Color _highlight = Color.fromARGB(170, 255, 147, 0); // Colors.amberAccent;

  Map decorationList = {
    '!': '!Strong',
    '?': '?Weak',
    '' : '',
  };

  Map decorationColor = {
    '!': Color.fromARGB(255, 255, 237, 213),
    '?': Color.fromARGB(255, 255, 237, 213),
    '' : Color.fromARGB(255, 255, 237, 213),
  };

  List<DocumentSnapshot> gamedocs;
  List<DocumentSnapshot> principledocs;

  int _currGame = 1;
  String gameid = '';
  String gametitle = '';
  String gamepgn = '';
  String gamefen = '';
  String gamecolor = '';
  String gameresult = '';
  int gamelevel = 1;

  final String _initAnnounce = 'Click to see moves';
  final String _checkAnnounce = 'Check';
  final String _endAnnounce = 'End of game';
  final String _varAnnounce = 'For variation click below';
  final String _announceVarEnd = 'To end variation press';
  final String _endVarAnnounce = 'End of variation';
  final String _mainState = 'Main Line';
  final String _varState = 'Variation';

  String _stateText = '';

  String _announce = '';
  String _callout = '';

  String _decoration = '';

  int _currentIndex = 0; // for bottom navigation tabs
  Map principles = Map<String,String>();
  List<Principle> prinList = new List<Principle>();
  bool _userMoveState=false;

  //ChessBoard _board;
  chess.Chess _game = new chess.Chess();
  ChessBoardController gmController = new ChessBoardController();

  final _listScrollController = ScrollController();
  final _commentScrollController = ScrollController();

  MoveController mvController; // = new AllMoves();

  List<String> principleCollection = ['beginnerprinciples','noviceprinciples','intermediateprinciples',
    'advancedprinciples','masterprinciples'];

  void _loadPrincipleList() async {
    CollectionReference collectionReference = await globals.firestore.collection(principleCollection[gamelevel]);

    collectionReference.snapshots().listen((snapshot) {
      setState(() {
        principledocs = snapshot.documents;

        Map p;

        for (int i=0; i < principledocs.length; i++) {
          p = principledocs[i].data;

          String id = p['ID'];
          String pr = p['Principle'];
          String desc = p['Description'];
          //print(id);
          //print(pr);

          principles.putIfAbsent(id, () => pr);

          Principle prin = new Principle();
          prin.principle = pr;
          prin.description = desc;
          prinList.add(prin);
        }
      });
    });
  }

  void _loadNextGame() {
    setState(() {
      if (_currGame < gamedocs.length) {
        _currGame++;
      } else { //wrap around
        _currGame = 1;
      }
      _loadGame();
    });
  }

  void _loadPrevGame() {
    setState(() {
      if (_currGame > 1) {
        _currGame--;
      } else { //wrap around
        _currGame = gamedocs.length;
      }
      _loadGame();
    });
  }

  initDisplayTextFields() {
    _callout = '';
    _announce = _initAnnounce;
    //_announceIconVisible = false;
    _decoration = '';

    _userMoveState = false;
  }

  Future<bool> _loadFirstGame() async {
    //print ('In _loadFirstGame');
    CollectionReference collectionReference = await globals.firestore.collection('chessprofanalyzedgames');

    if (globals.uid.authuserid == null || globals.uid.authuserid.isEmpty)
      return false;

    //print (widget.startGameId);

    DocumentSnapshot doc = await collectionReference.document(widget.startGameId).get();

    if (doc == null || !doc.exists) {
      print ('Could not find document');
      return false;
    }

    setState(() {

      Map loadedgame = doc.data;

      if (loadedgame.isEmpty)
        return false;

      gameid = loadedgame['ID'];
      gametitle = loadedgame['title'];
      gamepgn = loadedgame['moves'];
      gamefen = loadedgame['fen'];
      gamecolor = loadedgame['color'];
      gameresult = loadedgame['result'];
      String lev = loadedgame['level'];

      //print (gametitle);

      if (lev.isNotEmpty) {
        gamelevel = int.parse(lev);
      }

      _loadFenAndPgn();

    });

    return true;
  }

  void _loadFenAndPgn() {
    bool noFen = true;
    var game = _game;

    game.resetToBeginning();

    if (gamefen != null && gamefen.isNotEmpty) {
      gmController.clearBoard();
      game.load(gamefen);
      noFen = false;
    }

    game.load_pgn_variations(gamepgn, noFen);

    mvController.loadFromChessPgn(gamepgn, noFen);

    initDisplayTextFields();
  }

  void _loadGame() {

    Map loadedgame;

    loadedgame = gamedocs[_currGame-1].data;
    gametitle = loadedgame['title'];
    gamepgn = loadedgame['moves'];
    gamefen = loadedgame['fen'];

    _loadFenAndPgn();

    globals.setAndSaveUserPosition(loadedgame['ID']);
  }

  updateDisplayTextFields()
  {
    setState(() {

      MoveNode move = mvController.getCurrentMove();
      String c, d;

      if (move == null) {
        c = '';
        d = '';
      } else {
        c = move.comment;
        d = move.quality;
      }

      _callout = c.isNotEmpty ? c : '';
      _decoration = d.isNotEmpty ? d : '';

      int lastmovestate = mvController.isLastMove();
      switch (lastmovestate) {
        case 1:
          _announce = _endAnnounce;
          break;
        case 2:
          _announce = _endVarAnnounce;
          break;
        case -1:
          _announce = _initAnnounce;
          break;
        case 0:
        default:
          if (mvController.hasVariations())
            _announce = _varAnnounce;
          else
            _announce = _initAnnounce;
          break;
      }

    });
  }

  void _compareMoveWithTT(context) {
    String resultStr = '';

    /* compare with PGN for current move played on chessboard by user*/
    MoveNode nextMove = mvController.getNextMove();

    setState(() {
      String played = gmController.getLastPgn();
      if (nextMove != null) {
        if (nextMove.pgn == played) {
          resultStr='Congrats correct move!';
        }
        else {
          /* message if incorrect, wait 3 seconds, go back, wait 1 second, play correct move */
          resultStr = 'Incorrect. You played ' + played + ' but the correct move is ' + nextMove.pgn + '.';
          gmController.undoMove();
        }
      }

      _userMoveState=false;
      _doNextMove(context);
      _callout = resultStr + _callout;

    });

  }

  void _doNextMove(BuildContext context) {
    /* are we in Tactics Time */
    if(_userMoveState)
      return;

    MoveNode move = mvController.doNextMove();
    if (move == null)
      return;

    setState(() {
      updateDisplayTextFields();

      String pid = move.principleid;
      if ( pid != null && pid.isNotEmpty && principles.containsKey(pid) ) {
        showDialog(
          context: context,
          builder: (_) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              AlertDialog(
                title:
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'KEY PRINCIPLE\n\n',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      TextSpan(
                        text: principles[pid],
                        style: TextStyle(
                          fontSize: 16,
                          color: _mocha,
                        ),
                      ),
                    ],
                  ),
                ),

                elevation: 24.0,
                backgroundColor: _background,
                //barrierDismissible: true,
                //shape: CircleBorder(),
              ),
            ],
          ),
        );
      }

      /* if next move has TT, disable next button, enable user moves, set _callout */
      MoveNode nextMove = mvController.getNextMove();
      if( nextMove != null && nextMove.tt == true) {

        _userMoveState=true;
        _callout='Tactics Time! Try to guess the next move by playing it on the board. You only have one chance, so take your time and only move when you are sure';
        _announce = 'Test yourself';

      }

    });
  }

  void _doPreviousMove() {
    /* are we in Tactics Time */
    if(_userMoveState)
      return;

    if (mvController.doPrevMove() == false)
      return;

    setState(() {
      updateDisplayTextFields();


    });
  }

  void _loadAll() {
    if (widget.startGameId.isNotEmpty) {
      //print (widget.startGameId);

      _loadFirstGame();
      // _doNextMove(context);
      _loadPrincipleList();
    }
  }

  @override
  void initState() {
    super.initState();

    mvController = new MoveController(gmController);

    initDisplayTextFields();

    if (globals.tablet) {
      _treeFontSize = globals.tabFontsize[globals.tid];
      _rowHeight = globals.tabRowHeight[globals.tid];
      _menuIconHeight = globals.tabIconsize[globals.tid];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<bool> _onBackPressed() {
//    Navigator.pop(context);
    Navigator.pop(context);
    //Navigator.popUntil(context, ModalRoute.withName('/'));
  }


  @override
  Widget build(BuildContext context) {

    double _multiplier = globals.chessboardMultipier;

// //    double _scrollHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).size.width *0.91 - _navBarHeight - _nextButtonHeight - _nextButtonHeight - 5 - 115;
//     double
//     _scrollHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).size.width * _multiplier - _nextButtonHeight - _nextButtonHeight - _commentHeight - globals.appBarHeight;
//
//     if (_scrollHeight >= globals.minPgnHeight) {
//       _scrollHeight -= MediaQuery.of(context).size.width * (1 - _multiplier);
//       _multiplier = 1;
//     }


    double _scrollHeight ;

    if (globals.tablet) {
      _multiplier = globals.tabMultiplier[globals.tid]; //0.7;

      // _buttonHeight = globals.tabButtonHeight[globals.tid];//60;

      _nextButtonHeight = globals.tabNextButtonHeight[globals.tid];//50;
      _scrollHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).size.width * _multiplier - _nextButtonHeight - _nextButtonHeight - _commentHeight - globals.appBarHeight;

    } else {
      _scrollHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).size.width * _multiplier - _nextButtonHeight - _nextButtonHeight - _commentHeight - globals.appBarHeight;

      if (_scrollHeight >= globals.minPgnHeight) {
        _scrollHeight -= MediaQuery
            .of(context)
            .size
            .width * (1 - _multiplier);
        _multiplier = 1;
      }
    }


    _commentIncrement = 0;

    if (_scrollHeight >= globals.minPgnHeight) { // increase comment height by 1 line
      _scrollHeight -= _commentLine;
      _commentIncrement += _commentLine;
    }

    if (_scrollHeight >= globals.minPgnHeight) { // increase comment height by 1 line
      _scrollHeight -= _commentLine;
      _commentIncrement += _commentLine;
    }

    if (globals.tablet) {
      if (_scrollHeight >= globals.minPgnHeight * 1.5) { // increase comment height by 1 line
        _scrollHeight -= _commentLine;
        _commentIncrement += _commentLine;
      }
      if (_scrollHeight >= globals.minPgnHeight * 1.5) { // increase comment height by 1 line
        _scrollHeight -= _commentLine;
        _commentIncrement += _commentLine;
      }
    }

    AppBar getAppBar() {
      if (globals.tablet) {
        return
          AppBar(
            centerTitle: true,
            title: Text(
              'ChessProf Analysis',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: globals.appBarTextFlex,
              ),
            ),
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
            ],
          );
      } else {
        return
          AppBar(
            centerTitle: true,
            title: Text(
              'ChessProf Analysis',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: globals.appBartextSize,
              ),
            ),
            actions: <Widget> [
            ],
          );
      }
    }

    return
      WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          backgroundColor: _background,
          resizeToAvoidBottomPadding: false,
          body:
          /* Practice Games tab */
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children : <Widget> [
                SizedBox(
                  height: globals.appBarHeight,
                  child: getAppBar(),
                ),

                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget> [

                      SizedBox(height: globals.tablet? 5 : 1),

                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget> [

                            Text('$gametitle',
                              style: TextStyle(
                                fontSize: globals.tablet ? _treeFontSize + 4 : 16,
                              ),
                            ),


                          ]
                      ),

                      SizedBox(height: globals.tablet? 5 : 1),

                      SwipeDetector(
                        child:
                        ChessBoard(
                          size: MediaQuery.of(context).size.width * _multiplier,
                          onMove: (move) {
                            //print(move);
                            _compareMoveWithTT(context);

                          },
                          onCheckMate: (color) {
                            //print(color);
                          },
                          onDraw: () {
                            //print("DRAW!");
                          },
                          chessBoardController: gmController,
                          enableUserMoves: _userMoveState,
                          game: _game,
                          whiteSideTowardsUser: gameresult == "black" ? false : true,
                        ),
                        onSwipeLeft: () {
                          _loadNextGame();
                        },
                        onSwipeRight: () {
                          _loadPrevGame();
                        },
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget> [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget> [
                              Container(
                                height: _nextButtonHeight,
                                child:
                                ButtonTheme(
                                  minWidth: 30,
                                  child:
                                  FlatButton.icon(
                                    onPressed: () {
                                      _doPreviousMove();
                                    },
                                    icon: Icon(Icons.skip_previous, color: _mocha,
                                      size: globals.tablet? _menuIconHeight + 2 : _menuIconHeight,
                                    ),
                                    label: Text(''),
                                  ),
                                ),
                              ),
                              Container(
                                width: globals.tablet ? MediaQuery.of(context).size.width * _multiplier * 0.7 : 170,
                                color: _userMoveState == true? _highlight : _background,
                                child: Center(
                                  child: Text(
                                    '$_announce',
                                    style: TextStyle(
                                      color: _userMoveState == true? Colors.black: _mocha,
                                      fontSize: globals.tablet ? _treeFontSize + 2 : 14,
                                    ),
                                  ),

                                ),
                              ),
                              Container(
                                height: _nextButtonHeight,
                                child:
                                ButtonTheme(
                                  minWidth: 30,
                                  child:
                                  FlatButton.icon(
                                    onPressed: () {
                                      _doNextMove(context);
                                    },
                                    icon: Icon(Icons.skip_next, color: _mocha,
                                      size: globals.tablet? _menuIconHeight + 2 : _menuIconHeight,
                                    ),
                                    label: Text(''),
                                  ),
                                ),
                              ),
                            ],
                          ),


                          PgnDisplay(
                            mvController,
                            _scrollHeight,
                            MediaQuery.of(context).size.width,
                            updateDisplayTextFields,
                            false, // do not compress display
                          ),


                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: _commentHeight + _commentIncrement,
                            color: _userMoveState == true? _highlight : _background,
                            child:
                            Scrollbar(
                              controller: _commentScrollController,
                              isAlwaysShown: true,
                              child: SingleChildScrollView(
                                controller: _commentScrollController,
                                child:
                                Text('$_callout',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 10,
                                  style: TextStyle(
                                    fontSize: globals.tablet ? _treeFontSize : 14,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ]
                ),

              ],
            ),
          ),

        ),
      );
  }
}
