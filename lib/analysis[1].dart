import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'global.dart' as globals;

import './signin.dart';


class CommentValue {
  String pgn;
  String comment;
  int quality;
}

class CommentDialog extends StatefulWidget {
  const CommentDialog(this.onValueChange, this.initialValue);

  final CommentValue initialValue;
  final void Function(CommentValue) onValueChange;

  @override
  State createState() => new CommentDialogState();
}

class CommentDialogState extends State<CommentDialog> {
  CommentValue _selectedId = new CommentValue();

  double _treeFontSize = 13.0;
  double _rowHeight = 20.0;
  double _menuIconHeight = 18;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialValue;

    if (globals.tablet) {
      _treeFontSize = globals.tabFontsize[globals.tid];
      _rowHeight = globals.tabRowHeight[globals.tid];
      _menuIconHeight = globals.tabIconsize[globals.tid];
    }

  }

  @override
  Widget build(BuildContext context) {

    TextEditingController _textFieldController = TextEditingController();
    _textFieldController.text = _selectedId.comment;

    void _setNodeQuality(int value) {
      setState(() {
        _selectedId.quality = value;
      });
    }

    return AlertDialog(
      title: Text('Enter move quality and comment',
        style: TextStyle(
          fontSize: globals.tablet ? _treeFontSize + 4 : 16,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ButtonTheme(
                minWidth: 70,
                child:
                FlatButton(
                    child: Text('?',
                      style: TextStyle(
                          fontSize: globals.tablet ? _treeFontSize : 14),

                    ),
                    color : _selectedId.quality == 0 ? globals.highlight : globals.background,
                    onPressed: () {
                      _setNodeQuality(0);
                    }
                ),
              ),
              ButtonTheme(
                minWidth: 70,
                child:
                FlatButton(
                    child: Text('!',
                      style: TextStyle(
                          fontSize: globals.tablet ? _treeFontSize : 14),

                    ),
                    color : _selectedId.quality == 1 ? globals.highlight : globals.background,
                    onPressed: () {
                      _setNodeQuality(1);
                    }
                ),
              ),
              ButtonTheme(
                minWidth: 70,
                child:
                FlatButton(
                    child: Text('None',
                      style: TextStyle(
                          fontSize: globals.tablet ? _treeFontSize : 14),
                    ),
                    color : _selectedId.quality == 2 ? globals.highlight : globals.background,
                    onPressed: () {
                      _setNodeQuality(2);
                    }
                ),
              ),
            ],
          ),
          TextField(
            style: TextStyle(
                fontSize: globals.tablet ? _treeFontSize : 14),
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 12,
            controller: _textFieldController,
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(
                hintText: "Enter comment"),
          ),
        ],
      ),
      elevation: 24.0,
      backgroundColor: globals.background,
      actions: [
        FlatButton(onPressed: () {
          _selectedId.comment = _textFieldController.text;
          widget.onValueChange(_selectedId);
          _textFieldController.clear();
          Navigator.of(context).pop(); // dismiss dialog
        }, child: Text('Save',
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

class SaveValue {
  String title;
  bool white;
  int won;
  String submitstatus;
}

class SaveDialog extends StatefulWidget {
  const SaveDialog(this.onValueChange, this.initialValue, this.announce);

  final SaveValue initialValue;
  final String announce;
  final void Function(SaveValue, bool) onValueChange;

  @override
  State createState() => new SaveDialogState();
}

class SaveDialogState extends State<SaveDialog> {
  SaveValue _selected = new SaveValue();
  bool showSubmitButton = false;
  String _announce = '';

  double _treeFontSize = 13.0;
  double _rowHeight = 20.0;
  double _menuIconHeight = 18;


  @override
  void initState() {

    super.initState();

    if (globals.tablet) {
      _treeFontSize = globals.tabFontsize[globals.tid];
      _rowHeight = globals.tabRowHeight[globals.tid];
      _menuIconHeight = globals.tabIconsize[globals.tid];
    }

    _selected = widget.initialValue;
    if (_selected.submitstatus != '1' && _selected.submitstatus != '2') {
      showSubmitButton = true;
    }

    if (widget.announce.isNotEmpty) {
      _announce = widget.announce;
    }
    else {
      _announce = 'Enter game title and details';
    }
  }

  @override
  Widget build(BuildContext context) {

    TextEditingController _titleController = TextEditingController();
    _titleController.text = _selected.title;

    void _setColor(bool value) {
      setState(() {
        _selected.white = value;
        _selected.title = _titleController.text;
      });
    }

    void _setResult(int value) {
      setState(() {
        _selected.won = value;
        _selected.title = _titleController.text;
      });
    }

    return AlertDialog(
      //contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.all(0.0),
      insetPadding: EdgeInsets.all(0.0),
      title: Text('$_announce',
        style: TextStyle(
          fontSize: globals.tablet ? _treeFontSize + 4 : 14,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
//          Text('Enter game title and details'),
          TextField(
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 2,
            controller: _titleController,
            textInputAction: TextInputAction.go,
            style: TextStyle(
              fontSize: globals.tablet ? _treeFontSize + 4 : 14,
            ),
            decoration: InputDecoration(
                hintText: "Enter Title"),
          ),
          SizedBox(
            height: globals.tablet? 15 : 5,
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 38,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.brown,
                  ),
                ),
                child:
                Row(
                  children: <Widget>[
                    ButtonTheme(
                      minWidth: 30,
                      height: 30,
                      child:
                      FlatButton(
                          child: Text('White',
                            style: TextStyle(
                                fontSize: globals.tablet ? _treeFontSize : 14),
                          ),
                          color : _selected.white == true ? globals.highlight : globals.background,
                          onPressed: () {
                            _setColor(true);
                          }
                      ),
                    ),
                    ButtonTheme(
                      minWidth: 30,
                      height: 30,
                      child:
                      FlatButton(
                          child: Text('Black',
                            style: TextStyle(
                                fontSize: globals.tablet ? _treeFontSize: 14),
                          ),
                          color : _selected.white == true ? globals.background : globals.highlight,
                          onPressed: () {
                            _setColor(false);
                          }
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: globals.tablet? 15 : 5,
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 38,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.brown,
                  ),
                ),
                child:
                Row(
                  children: <Widget>[
                    ButtonTheme(
                      minWidth: 30,
                      height: 30,
                      child:
                      FlatButton(
                          child: Text('Won',
                            style: TextStyle(
                                fontSize: globals.tablet ? _treeFontSize: 14),
                          ),

                          color : _selected.won == 0 ? globals.highlight : globals.background,
                          onPressed: () {
                            _setResult(0);
                          }
                      ),
                    ),
                    ButtonTheme(
                      minWidth: 30,
                      height: 30,
                      child:
                      FlatButton(
                          child: Text('Lost',
                            style: TextStyle(
                                fontSize: globals.tablet ? _treeFontSize: 14),
                          ),
                          color : _selected.won == 1 ? globals.highlight : globals.background,
                          onPressed: () {
                            _setResult(1);
                          }
                      ),
                    ),
                    ButtonTheme(
                      minWidth: 20,
                      height: 30,
                      child:
                      FlatButton(
                          child: Text('Draw',

                            style: TextStyle(
                                fontSize: globals.tablet ? _treeFontSize: 14),
                          ),

                          color : _selected.won == 2 ? globals.highlight : globals.background,
                          onPressed: () {
                            _setResult(2);
                          }
                      ),
                    ),
                    ButtonTheme(
                      minWidth: 20,
                      height: 30,
                      child:
                      FlatButton(
                          child: Text('Line',
                            style: TextStyle(
                                fontSize: globals.tablet ? _treeFontSize: 14),
                          ),

                          color : _selected.won == 3 ? globals.highlight : globals.background,
                          onPressed: () {
                            _setResult(3);
                          }
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),


        ],
      ),
      elevation: 24.0,
      backgroundColor: globals.background,
      actions: [

        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Visibility(
              visible: showSubmitButton,
              child: FlatButton(onPressed: () {
                _selected.title = _titleController.text;
                if (_selected.submitstatus != '1' && _selected.submitstatus != '2') {
                  _selected.submitstatus = '1';
                }
                widget.onValueChange(_selected, true);
                _titleController.clear();
                Navigator.of(context).pop(); // dismiss dialog
              }, child: Text('ChessProf Analysis',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                style: TextStyle(
                    fontSize: globals.tablet ? _treeFontSize : 14),
              ), color: Colors.black),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FlatButton(onPressed: () {
                  _selected.title = _titleController.text;
                  widget.onValueChange(_selected, true);
                  _titleController.clear();
                  Navigator.of(context).pop(); // dismiss dialog
                },
                    child: Text('Save',
                      style: TextStyle(
                          fontSize: globals.tablet ? _treeFontSize : 14),
                    ),
                    color: Colors.black
                ),

                SizedBox(width: 10),

                FlatButton(onPressed: () {
                  _titleController.clear();
                  widget.onValueChange(_selected, false);
                  Navigator.of(context).pop(); // dismiss dialog
                },
                  child: Text('Cancel',
                    style: TextStyle(
                        fontSize: globals.tablet ? _treeFontSize : 14),
                  ),
                  color: Colors.black,
                )
              ],
            ),

          ],
        ),
      ],
    );
  }
}

class ChessState {
  List<MoveNode> moves;
  int currNode;
  bool played;
}

class MoveNode {
  int moveNum;
  String pgn;
  String fromAlgebraic;
  String toAlgebraic;
  int prev;
  int next;
  bool inactive;
  List<int> vars;
  String comment;
  String quality;
  int level;
  String promoPiece;
}

class Analysis extends StatefulWidget {
  Analysis(this.sourceScreen, this.startGameId);

  final sourceScreen; //  0 - homepage, 1 - My Saved
  final startGameId;

  @override
  _AnalysisState createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {

  /*************************/

  //String _userid = 'asanjiv@hotmail.com';
  String _timestamp = '';
  int _numSaves = 0;
  int _docRef = -1;
  List<DocumentSnapshot> _anDocs;
  bool changed = false;

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
    'undo' : Icons.undo,
    'hascomment' : Icons.font_download,
    'flip': Icons.flip_camera_android_rounded,
  };

  int _currentIndex = 0;

  chess.Chess _anGame = new chess.Chess();
  ChessBoardController _anController = new ChessBoardController();

  double _nextButtonHeight = 20.0;
  double _buttonHeight = 40;
  double _treeFontSize = 13.0;
  double _rowHeight = 20.0;
  double _menuIconHeight = 22;
  double _commentHeight = 64.0;
  double _commentLine = 16.0;
  double _commentIncrement = 0;


  Color _mocha = Color.fromARGB(255, 192, 107, 0);
  List<Color> _anTextColor = [Colors.black, Colors.black54, Colors.black45, Colors.black38, Colors.black87,];


  ChessState _chessState = new ChessState();
  List<MoveNode> allMoves = List<MoveNode>();
  int _currNode = -1; // curr node
  int _currRow = 0;

  List<Widget> widList = new List<Widget>();
  List<List<Widget>> rowList = new List<List<Widget>>();
  int rowNum = 0;

  double rowWid = 0;
  double objWid = 0;
  double margin = 1.0;
  double maxRowLength = 0;

  String _currIndent = '';

  List<String> indent = ['', '  ', '    ','     ','      ',];
  //List<String> dot = ['.', '...'];
  //List<FontStyle> style = [FontStyle.normal, FontStyle.italic, FontStyle.italic, FontStyle.italic, FontStyle.italic ];
  List<FontStyle> style = [FontStyle.normal, FontStyle.normal, FontStyle.normal, FontStyle.normal, FontStyle.normal ];
  List<int> _delList = new List<int>();
  List<String> qualityList = ['?', '!', ''];

  final _scrollController = ScrollController();
  final _commentScrollController = ScrollController();

  String pgnStr = '';

  List<DocumentSnapshot> gamedocs;
  String gamepgn = '';
  SaveValue params = new SaveValue();

  bool justStarted = true;
  bool flipped = false;

  int addMove(chess.Move mv, int lev) {
    int newNode;

    /* if _currNode is empty, use it, else create new one */
    if (_currNode != -1 && allMoves[_currNode].fromAlgebraic != null && allMoves[_currNode].fromAlgebraic.isEmpty) {
      allMoves[_currNode].pgn = mv.pgn;
      allMoves[_currNode].fromAlgebraic = mv.fromAlgebraic;
      allMoves[_currNode].toAlgebraic = mv.toAlgebraic;
    } else {
      MoveNode node = new MoveNode();
      node.inactive = false;
      node.fromAlgebraic = mv.fromAlgebraic;
      node.toAlgebraic = mv.toAlgebraic;
      node.next = -1;
      node.vars = new List<int>();
      node.level = lev;
      if (_currNode == -1 || allMoves[_currNode].level == lev)
        node.prev = _currNode;
      else
        node.prev = allMoves[_currNode].prev; // variation should go in with prev as the previous node of parent
      if (_currNode == -1)
        node.moveNum = 0;
      else
        node.moveNum = (allMoves[_currNode].level == lev) ? allMoves[_currNode].moveNum + 1 : allMoves[_currNode].moveNum;
      node.quality = mv.decoration != null ? mv.decoration : '';
      node.pgn = mv.pgn;
      node.comment = mv.comment != null ? mv.comment : '';
      if (mv.promotion != null)
        node.promoPiece = mv.promotion.toLowerCase();

      allMoves.add(node);
      newNode = allMoves.length - 1;
      if (_currNode != -1 && allMoves[_currNode].level == lev) {
        allMoves[_currNode].next = newNode;
      }
      _currNode = newNode;
    }

    return _currNode;
  }

  void loadMoves(chess.Move mv, int lev) {
    /* add move */
    int parent = addMove(mv, lev);

    /* if variations exist, add them as well */
    if (mv.variations != null && mv.variations.isNotEmpty)
    {
      for (int v = 0; v < mv.variations.length; v++) {

        _currNode = parent;

        List<chess.Move> varMoves = mv.variations[v].varMoves;
        if (varMoves != null && varMoves.isNotEmpty) {
          for (int m = 0; m < varMoves.length; m++) {
            loadMoves(varMoves[m], lev+1);
            if (m == 0) {
              // add first move in variation as child of parent node
              allMoves[parent].vars.add(_currNode);
            }
          }
        }
      }
    }

    // after variations are loaded, reset currNode to parent so the rest of the load can continue from there
    _currNode = parent;

  }

  void loadFromChessPgn(String gamepgnStr) {
    chess.Chess game = _anController.game;
    List<chess.Move> moves = game.getHistoryAndReset();
    allMoves.clear();
    _currNode = -1;
    for (int i=0; i < moves.length; i++) {
      loadMoves(moves[i], 0);
    }
    _currNode = -1;
  }

  void _loadPgn() {
    var game = _anController.game;

//    setState(() {
    game.resetToBeginning();

    game.load_pgn_variations(gamepgn, true); // no fen

    loadFromChessPgn(gamepgn);

    _goToMove(allMoves.length - 1);

    _numSaves = 1;

//    });
  }

  void _loadGame() async {
    Map loadedgame;

    /* if a startgame was specified, look that up and load it */
    if (widget.startGameId.isNotEmpty) {
      var collectionReference = await globals.firestore.collection('analysisgames')
          .where('userid', isEqualTo: globals.uid.authuserid)
          .where('timestamp', isEqualTo: widget.startGameId);

      if (collectionReference == null)
        return;

      collectionReference.snapshots().listen((snapshot) {
        gamedocs = snapshot.documents;

        if (justStarted) {
          Map nextgame;
          String resultStr;
          nextgame = gamedocs[0].data; // only 1 match expected

          _timestamp = widget.startGameId;
          params.title = nextgame['title'];
          params.white = nextgame['color'] == "white" ? true : false;
          resultStr = nextgame['result'];
          params.submitstatus = nextgame['submitstatus'];
          params.won = 0;
          if (globals.result.contains(resultStr))
            params.won = globals.result.indexOf(resultStr);
          gamepgn = nextgame['pgn'];

          if (_timestamp.isNotEmpty)
            _loadPgn();

          justStarted = false;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _resetSaveParams();

    if (globals.tablet) {
      _treeFontSize = globals.tabFontsize[globals.tid]; //22;//globals.smallTextFlex;
      _rowHeight = globals.tabRowHeight[globals.tid]; //26;
      // _commentLine = 20;
      _menuIconHeight = globals.tabIconsize[globals.tid]; //32;
      // print ('fontSize = ' + _treeFontSize.toString() + ', iconheight = ' + _menuIconHeight.toString());
    }

    _chessState.moves = new List<MoveNode>();

    if (widget.startGameId.isNotEmpty) {
      _loadGame();
    }
  }

  void _doMove() {
    _doMoveAtIndex(_currNode);
  }


  void _doPrevMove() {
    setState(() {
      if (_currNode >= 0 && _currNode < allMoves.length && allMoves[_currNode].inactive == false) {
        int prevNode = allMoves[_currNode].prev;
        _anController.undoMove();
        _currNode = prevNode;
      }
    });
  }

  void _doNextMove() {
    setState(() {
      int nextNode = _currNode == -1 ? _getFirstMove() : allMoves[_currNode].next;
      if (nextNode != -1 && allMoves[nextNode].inactive == false) {
        _currNode = nextNode;
        _doMove();
      }
    });
  }

  void _doMoveAtIndex(int index) {
    setState(() {
      if (index >= 0 && index < allMoves.length && allMoves[index].fromAlgebraic.isNotEmpty && allMoves[index].toAlgebraic.isNotEmpty && allMoves[index].inactive == false) {
        if (allMoves[index].promoPiece != null && allMoves[index].promoPiece.isNotEmpty)
          _anController.makeMoveWithPromotion(allMoves[index].fromAlgebraic, allMoves[index].toAlgebraic, allMoves[index].promoPiece);
        else
          _anController.makeMove(allMoves[index].fromAlgebraic, allMoves[index].toAlgebraic);
      }
    });
  }

  void _goToMove(int index) {
    setState(() {
      List<int> _toMove = new List<int>();

      for (int m = index; m >= 0 && m < allMoves.length && allMoves[m].inactive == false; m = allMoves[m].prev) {
        _toMove.insert(0, m); // insert at beginning so in reverse order
      }
      _anController.resetBoard();
      for (int m in _toMove) {
        _doMoveAtIndex(m);
      }
      _currNode = index;
    });
  }

  void _doDelete() {
    if (_currNode == -1)
      return;

    _saveState();

    setState(() {
      allMoves[_currNode].inactive = true;
      int prevNode = allMoves[_currNode].prev;

      if (prevNode != -1) {
        int prevnext = allMoves[prevNode].next;

        if (prevnext == _currNode) { // same line
          _currNode = prevNode;
          allMoves[prevNode].next = -1;
          _anController.undoMove();
        } else {
          /* if this is the beginning of variation, delete from parent (prevnext), and then move to parent */
          allMoves[prevnext].vars.remove(_currNode);
          // _currNode = prevNode;
          // _doNextMove();
          _goToMove(prevnext);
        }
      }
      else {
        allMoves.clear();
        _currNode = -1;
        _anController.resetBoard();
      }



    });
  }

  void _doPromote() {
    if (_currNode == -1)
      return;

    if (allMoves[_currNode].fromAlgebraic.isEmpty)
      return;

    _saveState();

    setState(() {

      int savecurr = _currNode;
      int prevnode;
      int parentnode;

      /* find parent node from either current or a predecessor*/
      while (_currNode >= 0 && _currNode < allMoves.length) {
        prevnode = allMoves[_currNode].prev;
        if (prevnode == -1) {
          _currNode = savecurr; // restore curr node before exiting
          return;
        }
        parentnode = allMoves[prevnode].next;
        if (parentnode != _currNode) {
          break; // found it
        } else {
          _currNode = prevnode;
        }
      }

      /* make current node the parent */
      allMoves[prevnode].next = _currNode;
      allMoves[_currNode].vars = allMoves[parentnode].vars;
      allMoves[_currNode].vars = allMoves[parentnode].vars.map((element)=>element).toList();
      allMoves[parentnode].vars.clear();

      /* remove current node from variations and add former parent node in  variation list */
      allMoves[_currNode].vars.add(parentnode);
      allMoves[_currNode].vars.remove(_currNode);

      _currNode = savecurr; // restore curr node before exiting

    });
  }

  void _setNodeComment(String text) {
    if (_currNode == -1)
      return;

    allMoves[_currNode].comment = text;
  }

  void _saveComment(CommentValue input) {
    setState(() {
      if (_currNode == -1)
        return;

      allMoves[_currNode].comment = input.comment;
      allMoves[_currNode].quality = qualityList[input.quality];

      changed = true;

    });
  }

  _updateSave(Map<String, dynamic> sData) async {
    Map a;
    if (_docRef == -1) {

      CollectionReference collectionReference = await globals.firestore.collection('analysisgames');
      QuerySnapshot querySnapshot = await collectionReference.getDocuments();
      _anDocs = querySnapshot.documents;

      for (int r = 0; r < _anDocs.length; r++) {
        a = _anDocs[r].data;
        if (a['userid'] == globals.uid.authuserid && a['timestamp'] == _timestamp)
          _docRef = r;
      }
    }
    if (_docRef == -1) {
      print("Could not find document");
      return;
    }

    if (_anDocs.isNotEmpty)
      _anDocs[_docRef].reference.updateData(sData);

  }

  void _saveGame(SaveValue input, bool doSave) {

    setState(() {

      if (doSave) {

        params.title = input.title;
        params.white = input.white;
        params.won = input.won;
        params.submitstatus = input.submitstatus;

        _saveToDb();
      }

    });
  }

  void _doFlip() {
    setState(() {
      flipped = flipped ? false : true;
    });
  }
  void _doSave(BuildContext context, String announce, bool action) async {

    if (allMoves.isEmpty) {
      changed = false;
      return;
    }

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new SaveDialog(_saveGame, params, announce);
        }
    );

    setState(()  {
    });

    if (action)
      _goToPrevScreen(context);
  }

  void _saveToDb() async {
    String thisPgn = getPgn(context);

    List<String> namL = new List<String>();
    namL.add('timestamp');
    namL.add('userid');
    namL.add('pgn');
    namL.add('title');
    namL.add('color');
    namL.add('result');
    namL.add('submitstatus');
    namL.add('level');
    List<String> valL = new List<String>();

    valL.add(_timestamp);
    valL.add(globals.uid.authuserid);
    valL.add(thisPgn);
    valL.add(params.title);
    valL.add(params.white ? 'white' : 'black');
    valL.add(globals.result[params.won]);
    valL.add(params.submitstatus);
    valL.add(globals.skillLevel.toString());

    Map<String, dynamic> pData = new Map.fromIterables(namL, valL);


    if (_numSaves == 0) { // first save, insert
      CollectionReference collectionReference = await globals.firestore.collection('analysisgames');

      if (collectionReference == null) {
        print ('Invalid collection reference');
      }
      try {
        collectionReference.add(pData);
      } on PlatformException catch (e) {
        print(globals.getMessageFromErrorCode(e.code));
      }
    } else { // update previously saved record
      _updateSave(pData);
    }

    _numSaves++;
    changed = false;
  }

  void _resetSaveParams() {
    _timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    _numSaves = 0;
    _docRef = -1;
    params.title = '';
    params.white = true;
    params.won = 0;
    params.submitstatus = '0';
    changed = false;
  }

  void _doNew() {
    setState(() {
      _clearMoves();
      _anController.resetBoard();
      _resetSaveParams();
    });
  }

  void _captureComment() {

    if (_currNode == -1)
      return;

    CommentValue cv = new CommentValue();
    cv.comment = allMoves[_currNode].comment;
    cv.quality = allMoves[_currNode].quality.isEmpty ? 2 : qualityList.indexOf(allMoves[_currNode].quality);

    showDialog(
        context: context,
        barrierDismissible: true,
        //builder: (_) => CommentDialog(_saveComment, cv),
        builder: (BuildContext context) {
          return new CommentDialog(_saveComment, cv);
        }
    );

  }

  void _doReplace() {
    if (_currNode == -1)
      return;
    setState(() {
      /* find parent node */
      int prevnode = allMoves[_currNode].prev;
      if (prevnode == -1)
        return;
      int parentnode = allMoves[prevnode].next;
      if (parentnode == _currNode)
        return;

      /* make current node the parent */
      allMoves[prevnode].next = _currNode;
      allMoves[_currNode].vars = allMoves[parentnode].vars;
      allMoves[_currNode].vars = allMoves[parentnode].vars.map((element)=>element).toList();
      allMoves[parentnode].vars.clear();

      /* remove current node from variations */
      allMoves[_currNode].vars.remove(_currNode);

    });
  }

  int _getFirstMove() {
    int first = -1;

    for (int i = 0; i < allMoves.length; i++) {
      if (allMoves[i].inactive == false) {
        first = i;
        break;
      }
    }

    return first;
  }


  void moveWasPlayed(BuildContext context) {

    changed = true;

    _saveState();

    int first = _getFirstMove();

    if ((_currNode == -1 && first != -1) ||
        (_currNode != -1 && allMoves[_currNode].next != -1 && allMoves[allMoves[_currNode].next].inactive == false) ) {

      int next = _currNode == -1 ? first : allMoves[_currNode].next;

      /* check if move is already in main line or variation, if so go to it */
      chess.Move mv = _anGame.getLastMove();

      if (allMoves[next].fromAlgebraic == mv.fromAlgebraic &&
          allMoves[next].toAlgebraic == mv.toAlgebraic) {
        // matches next move, just play the move
        _doNextMove();
      } else {
        bool matchesVar = false;
        int v;

        if (allMoves[next].vars.isNotEmpty) {
          for (v in allMoves[next].vars) {
            if (allMoves[v].fromAlgebraic == mv.fromAlgebraic &&
                allMoves[v].toAlgebraic == mv.toAlgebraic) {
              matchesVar = true;
              break;
            }
          }
        }

        if (matchesVar) {
          // matches variation next move, just play the variation by going to it
          _goToMove(v);
        }
        else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) =>
                Container(
                  child: AlertDialog(
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
                                  child: Text("Replace Main",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  onPressed: () {
                                    _doNextMove();
                                    _initVariation();
                                    completeMoveWasPlayed(context);
                                    _doPromote();
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
                                  child: Text("Add Variation",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  onPressed: () {
                                    _doNextMove();
                                    _initVariation();
                                    completeMoveWasPlayed(context);
                                    Navigator.of(context)
                                        .pop(); // dismiss dialog
                                  },
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 0.0,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                _anController.undoMove();
                              },
                              child: Align(
                                alignment: Alignment.topRight,
                                child: CircleAvatar(
                                  radius: 8.0,
                                  backgroundColor: globals.background,
                                  child: Icon(
                                      Icons.close, color: Colors.black,
                                      size: 19),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ], // end actions
                  ),
                ),
          );
        }
      }
    } else {
      completeMoveWasPlayed(context);
    }
  }

  void completeMoveWasPlayed(BuildContext context) {
    setState(() {
      int newNode;
      chess.Move mv = _anGame.getLastMove();
      mv.pgn = _anGame.getLastPgn();

      /* if currNode is empty, use it, else create new one */
      if (_currNode != -1 && allMoves[_currNode].fromAlgebraic.isEmpty) {
        allMoves[_currNode].pgn = mv.pgn;
        allMoves[_currNode].fromAlgebraic = mv.fromAlgebraic;
        allMoves[_currNode].toAlgebraic = mv.toAlgebraic;
      } else {
        MoveNode node = new MoveNode();
        node.inactive = false;
        node.pgn = mv.pgn;
        node.fromAlgebraic = mv.fromAlgebraic;
        node.toAlgebraic = mv.toAlgebraic;
        node.prev = _currNode;
        node.next = -1;
        node.vars = new List<int>();
        node.moveNum = (_currNode == -1) ? 0 : allMoves[_currNode].moveNum + 1;
        node.quality = '';
        node.comment = '';
        if (mv.promotion != null)
          node.promoPiece = mv.promotion.toLowerCase();

        allMoves.add(node);
        newNode = allMoves.length - 1;
        if (_currNode != -1) {
          allMoves[_currNode].next = newNode;
        }
        _currNode = newNode;
      }

    });

  }

  void _initVariation() {
    if (_currNode == -1)
      return;
    /* create new empty node */
    MoveNode node = new MoveNode();
    node.inactive = false;
    node.pgn = ' ';
    node.fromAlgebraic = '';
    node.toAlgebraic = '';
    node.prev = allMoves[_currNode].prev;
    node.next = -1;
    node.vars = new List<int>();
    node.moveNum = (node.prev == -1) ? 0 : allMoves[_currNode].moveNum;
    node.comment = '';
    node.quality = '';

    /* add new node to end of allMoves */
    allMoves.add(node);
    int newNode = allMoves.length - 1;

    /* assign to new variation group in current node */
    allMoves[_currNode].vars.add(newNode);

    /* set currNode to new node */
    _currNode = newNode;

  }
  void _startVariation() {

    _saveState();

    setState(() {
      _initVariation();

      /* undo current move on current Line */
      _anController.undoMove();
    });
  }

  String getPgn(BuildContext context) {
    pgnStr = '';
    getWidgetsForLine(context, 0, 0, false, true);
    return pgnStr;
  }

  Color getButtonColor(int m) {
    if (m == _currNode) {
      _currRow = rowNum;
      return globals.highlight;
    }
    else
      return globals.background;
  }

  String getNumStr(int num) {
    String str;
    int c = (num ~/ 2) + 1;
    str = c.toString() + globals.dot[num%2] + ' ';
    return str;
  }

  int containsUpper(String str) {
    bool result = false;

    if (str.contains('R') || str.contains('N') || str.contains('B') || str.contains('K') || str.contains('Q'))
      return 1;

    return 0;
  }

  void addRowBeginning(int start, int lev, bool returnPgn) {
    if (start == -1 || start > allMoves.length - 1)
      return;

    String _begStr = getNumStr(allMoves[start].moveNum);

    _currIndent = '';

    if (lev > 0) {
      _begStr = '(' + _begStr;
      if (!returnPgn) {
        _begStr = indent[lev] + _begStr;
        _currIndent = globals.indent[lev];
      }
    }

    objWid = globals.getRenderLength(_begStr);

    if ( rowWid + objWid + margin > maxRowLength) {
      addRowForWrap(returnPgn, objWid, lev);
    } else {
      rowWid += objWid;
    }

    if (returnPgn)
      pgnStr = pgnStr + _begStr;
    else
      rowList[rowNum].add(
        ButtonTheme(
          minWidth: globals.minCharBox,
          height: 20,
          child: FlatButton(
            onPressed: () {},
            padding: const EdgeInsets.all(0.0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Text(_begStr,
              style: TextStyle(
                fontSize: _treeFontSize,
                fontStyle: style[lev],
                color: _anTextColor[lev],
              ),
            ),
          ),
        ),
      );

  }

  void _saveState() {
    _chessState.moves.clear();

    for (int m = 0; m < allMoves.length; m++) {
      MoveNode node = MoveNode();
      node.moveNum = allMoves[m].moveNum;
      node.pgn = allMoves[m].pgn;
      node.fromAlgebraic = allMoves[m].fromAlgebraic;
      node.toAlgebraic = allMoves[m].toAlgebraic;
      node.prev = allMoves[m].prev;
      node.next = allMoves[m].next;
      node.inactive = allMoves[m].inactive;
      node.comment = allMoves[m].comment;
      node.quality = allMoves[m].quality;
      node.vars = new List<int>();

      for (int v = 0; v < allMoves[m].vars.length; v++) {
        node.vars.add(allMoves[m].vars[v]);
      }
      _chessState.moves.add(node);
    }
    _chessState.currNode = _currNode;
  }

  void _restorePrevState() {
    if (_chessState.moves == null)
      return;

    allMoves.clear();

    for (int m = 0; m < _chessState.moves.length; m++) {
      MoveNode node = MoveNode();
      node.moveNum = _chessState.moves[m].moveNum;
      node.pgn = _chessState.moves[m].pgn;
      node.fromAlgebraic = _chessState.moves[m].fromAlgebraic;
      node.toAlgebraic = _chessState.moves[m].toAlgebraic;
      node.prev = _chessState.moves[m].prev;
      node.next = _chessState.moves[m].next;
      node.inactive = _chessState.moves[m].inactive;
      node.comment = _chessState.moves[m].comment;
      node.quality = _chessState.moves[m].quality;
      node.vars = new List<int>();

      for (int v = 0; v < _chessState.moves[m].vars.length; v++) {
        node.vars.add(_chessState.moves[m].vars[v]);
      }
      allMoves.add(node);
    }
    _currNode = _chessState.currNode;

    _goToMove(_currNode);
  }

  void _clearMoves() {
    allMoves.clear();
    _currNode = -1;
  }

  void _clearWidgets() {
    widList.clear();
    rowList.clear();
    rowNum = 0;
    rowWid = 0;
  }


  Widget getAnalysisWidgets(BuildContext context) {

    if (allMoves.isEmpty)
      return null;

    String s = '   ';

    //maxRowLength = (MediaQuery.of(context).size.width / globals.characterwidth).floor();
    maxRowLength = MediaQuery.of(context).size.width;

    /* clear up widget list and row list to be populated with moves pgn */
    _clearWidgets();

    rowList.add(new List<Widget>());

    getWidgetsForLine(context, 0, 0, false, false);

    return
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widList,
      );

  }

  void getWidgetsForLine(BuildContext context, int start, int lev, bool leaveRowOpen, bool returnPgn) {

    if (start == -1)
      return;

    addRowBeginning(start, lev, returnPgn);

    bool showNum = false;
    bool showIndent = false;

    for (int m = start; m >= 0 && m < allMoves.length && allMoves[m].inactive == false; m = allMoves[m].next) {
      int num = allMoves[m].moveNum;
      String _pgn = '';
      String _numStr = '';
      String _dotStr = '.';

      if (m != start && (num) % 2 == 0) {
        showNum = true;
      }

      if (showNum) {
        _numStr = getNumStr(num);
      }

      if (showIndent && !returnPgn) {
        _numStr = indent[lev] + _numStr;
      }

      objWid = globals.getRenderLength(_numStr);

      if ( rowWid + objWid + margin > maxRowLength) {
        addRowForWrap(returnPgn, objWid, lev);
      } else {
        rowWid += objWid;
      }


      if (showNum) {
        if (returnPgn)
          pgnStr = pgnStr + _numStr;
        else {
          rowList[rowNum].add(
            ButtonTheme(
              minWidth: globals.minCharBox,
              height: 20,
              child: FlatButton(
                onPressed: () {},
                padding: const EdgeInsets.all(0.0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Text('$_numStr',
                  style: TextStyle(
                    fontSize: _treeFontSize,
                    fontStyle: style[lev],
                    color: _anTextColor[lev],
                  ),
                ),
              ),
            ),
          );

        }
      }

      showNum = false;
      showIndent = false;

      bool hasComment = false;
      objWid = 0;

      _pgn = allMoves[m].pgn + allMoves[m].quality + ' ';
      if (allMoves[m].comment != null && allMoves[m].comment.isNotEmpty ) {
        if (returnPgn) {
          _pgn = _pgn + '{' + allMoves[m].comment + '}';
        } else {
          hasComment = true;
          objWid += globals.sizeIcon;
        }
      }

      objWid += globals.getRenderLength(_pgn);

      if ( rowWid + objWid + margin > maxRowLength) {
        addRowForWrap(returnPgn, objWid, lev);
      } else {
        rowWid += objWid;
      }

      if (returnPgn) {
        pgnStr = pgnStr + _pgn ;
      }
      else {
        if (hasComment) {
          rowList[rowNum].add(
              Icon(iconList['comment'], color: _mocha,
                size: globals.tablet ? globals.tabCommentIcon : 15,
              )
          );
        }
        rowList[rowNum].add(
          ButtonTheme(
            minWidth: globals.minCharBox,
            height: 20,
            buttonColor: getButtonColor(m),
            child: FlatButton(
              onPressed: () {
                _goToMove(m);
              },
              padding: const EdgeInsets.all(0.0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

              child: Text('$_pgn',
                style: TextStyle(
                  fontSize: _treeFontSize,
                  backgroundColor: getButtonColor(m),
                  fontStyle: style[lev],
                  color: _anTextColor[lev],
                ),
              ),
            ),
          ),
        );
      }
      if (allMoves[m].vars.isNotEmpty) { // has variation lines under it
        for (int v in allMoves[m].vars) {
          if (allMoves[v].inactive)
            continue;

          addRow(returnPgn, 0);
          bool leaveOpen = false;
          if (allMoves[m].next == -1 || allMoves[allMoves[m].next].inactive == true) {
            leaveOpen = true;
          }

          getWidgetsForLine(context, v, lev+1, leaveOpen, returnPgn);
        }
        showNum = true;
        showIndent = true;
      }
      else {
        showNum = false;
      }

    } // end while

    if (lev > 0) {
      String _endStr = '';
      if (rowList[rowNum].isEmpty && !returnPgn) {
        _endStr = indent[lev];
      }
      _endStr = _endStr + ')';


      objWid = globals.getRenderLength(_endStr);

      if ( rowWid + objWid + margin > maxRowLength) {
        addRowForWrap(returnPgn, objWid, lev);
      } else {
        rowWid += objWid;
      }

      if (returnPgn)
        pgnStr = pgnStr + _endStr;
      else
        rowList[rowNum].add(
          // ButtonTheme(
          //   minWidth: globals.minCharBox,
          //   height: 20,
          //   child: FlatButton(
          //     onPressed: () {},
          //     padding: const EdgeInsets.all(0.0),
          //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //     child:
          Text(_endStr,
            style: TextStyle(
              fontSize: _treeFontSize,
              fontStyle: style[lev],
              color: _anTextColor[lev],
            ),
          ),
          //   ),
          // ),
        );
    }

    // add last row into widList
    if (leaveRowOpen == false)
      addRow(returnPgn, 0);

  }

  // void addRowForWrap(bool returnPgn, int objRemaining, int hasCaps, int lev) {
  void addRowForWrap(bool returnPgn, double objRemaining, int lev) {
    addRow(returnPgn, objWid);

    if (!returnPgn && _currIndent.isNotEmpty) {
      rowWid += _currIndent.length;
      rowList[rowNum].add(
        // ButtonTheme(
        //   minWidth: globals.minCharBox,
        //   height: 20,
        //   child: FlatButton(
        //     onPressed: () {},
        //     padding: const EdgeInsets.all(0.0),
        //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //     child:
        Text('$_currIndent',
          style: TextStyle(
            fontSize: globals.treeFontSize,
            fontStyle: globals.style[lev],
            color: globals.anTextColor[lev],
          ),
        ),
        //   ),
        // ),
      );
    }

  }

  void addRow(bool returnPgn, double objRemaining) {

    if (rowList[rowNum].isEmpty)
      return;

    if (returnPgn)
      pgnStr = pgnStr + ' ';
    else {
      widList.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: rowList[rowNum],
        ),
      );
      rowNum++;
      rowList.add(new List<Widget>());
      rowWid = objRemaining;
      // numCaps = 0;
    }
  }

  String getCurrentComment() {
    if (_currNode == -1 || _getFirstMove() == -1)
      return '';

    return allMoves[_currNode].comment;
  }

  /*************************/

  _goToPrevScreen(BuildContext context) {
    if (widget.sourceScreen == 1) {
      Navigator.pop(context);
    } else {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  }

  Future<bool> _onBackPressed() async {

    if (allMoves.isEmpty || changed == false) {
      _goToPrevScreen(context);
    }
    else {
      await _doSave(context, 'Do you want to save current game before leaving this screen?', true);
    }
  }

  @override
  Widget build(BuildContext context) {

    double _multiplier = globals.chessboardMultipier;

    double _scrollHeight ; //= MediaQuery.of(context).size.height - MediaQuery.of(context).size.width * _multiplier - globals.appBarHeight - _buttonHeight - _nextButtonHeight - _commentHeight - 3.5;

    if (globals.tablet) {
      _multiplier = globals.tabMultiplier[globals.tid]; //0.7;
      _buttonHeight = globals.tabButtonHeight[globals.tid];//60;
      _nextButtonHeight = globals.tabNextButtonHeight[globals.tid];//50;
      _scrollHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).size.width * _multiplier - globals.appBarHeight - _buttonHeight - _nextButtonHeight - _commentHeight - 3.5;
    } else {
      _scrollHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).size.width * _multiplier - globals.appBarHeight - _buttonHeight - _nextButtonHeight - _commentHeight - 3.5;

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


    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (_scrollController.hasClients) {
        double offset = _scrollController.offset;
        if ((_currRow + 1)* _rowHeight > _scrollHeight + offset) {
          _scrollController.jumpTo((_currRow + 1) * _rowHeight - _scrollHeight);
        }
        else if (_currRow  * _rowHeight < offset) {
          _scrollController.jumpTo(offset - (_currRow + 1) * _rowHeight);
        }
      }

    });

    AppBar getAppBar() {
      if (globals.tablet) {
        return
          AppBar(

            centerTitle: true,
            title: Text('Analyse : ' + (params.title.isEmpty ? 'New Game' : params.title),
              textAlign: TextAlign.center,
              style: TextStyle(
                //fontSize: globals.tablet ? globals.menuFontsize : globals.submenuFontsize,
                //fontSize: globals.appBartextSize,
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
          );
      } else
        return
          AppBar(
              centerTitle: true,
              title: Text('Analyse : ' + (params.title.isEmpty ? 'New Game' : params.title),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: globals.appBartextSize,
                ),
              )
          );
    }

    Widget getNextButtons() {

    }

    return
      WillPopScope(
        onWillPop: _onBackPressed,
        child:
        Scaffold(
          backgroundColor: Color.fromARGB(255, 255, 237, 213), //a=255 = opaque
          resizeToAvoidBottomPadding: false,
          body:
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children : <Widget> [
                SizedBox(
                  height: globals.appBarHeight,
                  child: getAppBar(),
                ),

                //********* Analysis buttons

                SizedBox(
                  height: _buttonHeight,
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget> [

                      ButtonTheme(
                        minWidth: 30,
                        child:
                        FlatButton(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.all(0.0),
                          onPressed: () {
                            _startVariation();
                          },
                          child: Column(
                            children: <Widget> [
                              Icon(iconList['add'], color: _mocha, size: _menuIconHeight,
                              ),
                              Text(
                                'Branch',
                                style: TextStyle(
                                  fontSize: _treeFontSize,
                                  color: _mocha,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                      ButtonTheme(
                        minWidth: 30,
                        child:
                        FlatButton(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.all(0.0),
                          onPressed: () {
                            _doPromote();
                          },
                          child: Column(
                            children: <Widget> [

                              Icon(iconList['main'], color: _mocha, size: _menuIconHeight,
                              ),
                              Text(
                                'Promote',
                                style: TextStyle(
                                  fontSize: _treeFontSize,
                                  color: _mocha,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      ButtonTheme(
                        minWidth: 30,
                        child:
                        FlatButton(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.all(0.0),
                          onPressed: () {
                            _doDelete();
                          },
                          child: Column(
                            children: <Widget> [
                              Icon(iconList['close'], color: _mocha, size: _menuIconHeight,
                              ),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: _treeFontSize,
                                  color: _mocha,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      ButtonTheme(
                        minWidth: 30,
                        child:
                        FlatButton(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.all(0.0),
                          onPressed: () {
                            _restorePrevState();
                          },
                          child: Column(
                            children: <Widget> [
                              Icon(iconList['undo'], color: _mocha, size: _menuIconHeight,
                              ),
                              Text(
                                'Undo',
                                style: TextStyle(
                                  fontSize: _treeFontSize,
                                  color: _mocha,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      ButtonTheme(
                        minWidth: 30,
                        child:
                        FlatButton(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.all(0.0),
                          onPressed: () {
                            _captureComment();
                          },
                          child: Column(
                            children: <Widget> [
                              Icon(iconList['comment'], color: _mocha, size: _menuIconHeight,
                              ),
                              Text(
                                'Comments',
                                style: TextStyle(
                                  fontSize: _treeFontSize,
                                  color: _mocha,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

                //********* Analysis buttons finished

                ChessBoard(
                  size: MediaQuery.of(context).size.width * _multiplier,
                  onMove: (move) {
                    moveWasPlayed(context);
                  },
                  onCheckMate: (color) {
                  },
                  onDraw: () {
                  },
                  chessBoardController: _anController,
                  enableUserMoves: true,
                  game: _anGame,
                  whiteSideTowardsUser: !flipped,
                ),

                //******** Next and Previous buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget> [
                    Container(
                      height: _nextButtonHeight,
                      width: MediaQuery.of(context).size.width/5,
                      child: FlatButton.icon(
                        onPressed: () {
                          if (changed) {
                            _doSave(context, 'Do you want to save current game before starting a new one?', false);
                          }
                          _doNew();
                        },
                        icon: Icon(iconList['go'], color: _mocha,
                          size: _menuIconHeight + 2,
                        ),
                        label: Text(''),
                      ),
                    ),
                    Container(
                      height: _nextButtonHeight,
                      width: MediaQuery.of(context).size.width/5,
                      child: FlatButton.icon(
                        onPressed: () {
                          _doPrevMove();
                        },
                        icon: Icon(iconList['prev'], color: _mocha,
                          size: _menuIconHeight + 2,
                        ),
                        label: Text(''),
                      ),
                    ),
                    Container(
                      height: _nextButtonHeight,
                      width: MediaQuery.of(context).size.width/5,
                      child: FlatButton.icon(
                        onPressed: () {
                          _doFlip();
                        },
                        icon: Icon(iconList['flip'], color: _mocha,
                          size: _menuIconHeight + 2,
                        ),
                        label: Text(''),
                      ),
                    ),
                    Container(
                      height: _nextButtonHeight,
                      width: MediaQuery.of(context).size.width/5,
                      child: FlatButton.icon(
                        onPressed: () {
                          _doNextMove();
                        },
                        icon: Icon(iconList['next'], color: _mocha,
                          size: _menuIconHeight + 2,
                        ),
                        label: Text(''),
                      ),
                    ),
                    Container(
                      height: _nextButtonHeight,
                      width: MediaQuery.of(context).size.width/5,
                      child: FlatButton.icon(
                        onPressed: () {
                          _doSave(context, '', false);
                        },
                        icon: Icon(iconList['save'], color: _mocha,
                          size: _menuIconHeight + 2,
                        ),
                        label: Text(''),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 2,
                ),

                //******** Next and Previous buttons Finished

                Container(
                  width: MediaQuery.of(context).size.width,
                  height: _scrollHeight, //_anHeight,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.amber,
                    ),
                    //borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    isAlwaysShown: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: getAnalysisWidgets(context),
                    ),
                  ),
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  height: _commentHeight + _commentIncrement,
                  //color: _userMoveState == true? _highlight : _background,
                  child:
                  Scrollbar(
                    controller: _commentScrollController,
                    isAlwaysShown: true,
                    child: SingleChildScrollView(
                      controller: _commentScrollController,
                      child:
                      Text(getCurrentComment(),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 10,
                        style: TextStyle(
                          fontSize: _treeFontSize, //14,
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      );


  }
}
