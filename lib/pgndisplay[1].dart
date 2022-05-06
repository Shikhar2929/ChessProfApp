import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'global.dart' as globals;

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
  String principleid;
  bool tt;
  bool seen;
  String promoPiece;
}

class ChessState {
  List<MoveNode> moves;
  int currNode;
  bool played;
}

class MoveController {
  String gamepgn = '';
  String startTurn = 'w';
  bool noFen = true;
  List<MoveNode> allMoves = List<MoveNode>();
  int currNode = -1; // curr node
  //String pgnStr = '';
  ChessState _chessState = new ChessState();
  final ChessBoardController _anController;

  MoveController(this._anController);

  MoveNode getCurrentMove() {
    MoveNode node = null;

    if (currNode != -1 && currNode < allMoves.length && allMoves[currNode].inactive == false)
      node = allMoves[currNode];

    return node;
  }

  MoveNode getNextMove() {

    if (isLastMove() != 0) // this is the last move
      return null;

    return allMoves[allMoves[currNode].next];
  }

  bool isVisibleMove(int m) {
    if (m == -1)
      return false;

    if (allMoves[m].inactive == true)
      return false;

    if (allMoves[m].level == 0 && allMoves[m].seen == false)
      return false;

    return true;
  }

  void loadMoves(chess.Move mv, int lev) {
    /* add move */
    int parent = addMove(mv, lev);

    /* if variations exist, add them as well */
    if (mv.variations != null && mv.variations.isNotEmpty)
    {
      for (int v = 0; v < mv.variations.length; v++) {

        currNode = parent;

        List<chess.Move> varMoves = mv.variations[v].varMoves;
        if (varMoves != null && varMoves.isNotEmpty) {
          for (int m = 0; m < varMoves.length; m++) {
            loadMoves(varMoves[m], lev+1);
            if (m == 0) {
              // add first move in variation as child of parent node
              allMoves[parent].vars.add(currNode);
            }
          }
        }
      }
    }

    // after variations are loaded, reset currNode to parent so the rest of the load can continue from there
    currNode = parent;

  }

  void loadFromChessPgn(String gamepgnStr, bool noFenFlag) {
    chess.Chess game = _anController.game;
    List<chess.Move> moves = game.getHistoryAndReset();
    allMoves.clear();
    currNode = -1;
    startTurn = game.turn.toString();

    for (int i=0; i < moves.length; i++) {
      loadMoves(moves[i], 0);
    }
    currNode = -1;
    noFen = noFenFlag;
    gamepgn = gamepgnStr;
  }

  int addMove(chess.Move mv, int lev) {
    int newNode;
//      chess.Move mv = _anGame.getLastMove();
//      mv.pgn = _anGame.getLastPgn();

    /* if currNode is empty, use it, else create new one */
    if (currNode != -1 && allMoves[currNode].fromAlgebraic != null && allMoves[currNode].fromAlgebraic.isEmpty) {
      allMoves[currNode].pgn = mv.pgn;
      allMoves[currNode].fromAlgebraic = mv.fromAlgebraic;
      allMoves[currNode].toAlgebraic = mv.toAlgebraic;
    } else {
      MoveNode node = new MoveNode();
      node.inactive = false;
      node.fromAlgebraic = mv.fromAlgebraic;
      node.toAlgebraic = mv.toAlgebraic;
      node.next = -1;
      node.vars = new List<int>();
      if (currNode == -1 || allMoves[currNode].level == lev)
        node.prev = currNode;
      else
        node.prev = allMoves[currNode].prev; // variation should go in with prev as the previous node of parent
      if (currNode == -1) {
        node.moveNum = startTurn == 'b' ? 1 : 0;
        // print (startTurn);
        // print (node.moveNum);
      }
      else {
        node.moveNum = (allMoves[currNode].level == lev) ? allMoves[currNode].moveNum + 1 : allMoves[currNode].moveNum;
      }
      node.quality = mv.decoration != null ? mv.decoration : '';
      node.pgn = mv.pgn;
      node.comment = mv.comment != null ? mv.comment : '';
      node.level = lev;
      node.principleid = mv.principleid != null ? mv.principleid : '';
      node.tt = mv.tt;
      node.seen = false;
      if (mv.promotion != null)
        node.promoPiece = mv.promotion.toLowerCase();

      allMoves.add(node);
      newNode = allMoves.length - 1;
      if (currNode != -1 && allMoves[currNode].level == lev) {
        allMoves[currNode].next = newNode;
      }
      currNode = newNode;
    }

    return currNode;
  }

  /******** TO BE UPDATED
  void initVariation() {

    if (currNode == -1)
      return;
    /* create new empty node */
    MoveNode node = new MoveNode();
    node.inactive = false;
    node.pgn = ' ';
    node.fromAlgebraic = '';
    node.toAlgebraic = '';
    node.prev = allMoves[currNode].prev;
    node.next = -1;
    node.vars = new List<int>();
    node.moveNum = (node.prev == -1) ? 0 : allMoves[currNode].moveNum;
    node.comment = '';
    node.quality = '';

    /* add new node to end of allMoves */
    allMoves.add(node);
    int newNode = allMoves.length - 1;

    /* assign to new variation group in current node */
    allMoves[currNode].vars.add(newNode);

    /* set currNode to new node */
    currNode = newNode;
  }

  void startVariation() {

    saveState();

//    setState(() {
    initVariation();

    /* undo current move on current Line */
    _anController.undoMove();
//    });
  }

  void saveState() {
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
    _chessState.currNode = currNode;
  }

  void restorePrevState() {
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
    currNode = _chessState.currNode;

    goToMove(currNode);
  }

  ******** TO BE UPDATED   ****/

  void clearMoves() {
    allMoves.clear();
    currNode = -1;
  }

  void goToMove(int index) {
    List<int> _toMove = new List<int>();

    for (int m = index; m >= 0 && m < allMoves.length && allMoves[m].inactive == false; m = allMoves[m].prev) {
      _toMove.insert(0, m); // insert at beginning so in reverse order
    }

    if (noFen) {
      _anController.resetBoard();
    } else {
      _anController.game.resetToBeginning();
      //_anController.game.load_pgn_variations(gamepgn, noFen);
    }

    for (int m in _toMove) {
      doMoveAtIndex(m);
    }

    currNode = index;
  }

  /******** TO BE UPDATED
  void doDelete() {
    if (currNode == -1)
      return;

    saveState();

//    setState(() {
    allMoves[currNode].inactive = true;
    int prevNode = allMoves[currNode].prev;


    if (prevNode != -1) {
      if (allMoves[prevNode].next == currNode) {
        currNode = prevNode;
        allMoves[prevNode].next = -1;
        _anController.undoMove();
      } else {
        /* if this is the beginning of variation, move back to parent */
        currNode = prevNode;
        doNextMove();
      }
    }
    else {
      allMoves.clear();
      currNode = -1;
      _anController.resetBoard();
    }

//    });
  }
      ******** TO BE UPDATED ***/

  void doMove() {
    doMoveAtIndex(currNode);
    allMoves[currNode].seen = true;
  }

  bool hasVariations() {
    if (currNode == -1) {
      return false;
    }

    if (allMoves[currNode].vars.isNotEmpty)
      return true;
    else
      return false;
  }

  int isLastMove() {
    /* 0 - not last move, 1 - end of game, 2 - end of variation */

    if (currNode == -1) {
      return -1;
    }

    int result = 1;
    if (currNode >= 0 && currNode < allMoves.length) {
      var nxt = allMoves[currNode].next;
      if (nxt != -1 && allMoves[nxt].inactive == false) {
        // there is a valid next move
        result = 0;
      }
    }

    if (result == 1) {
      result = allMoves[currNode].level > 0 ? 2 : 1;
    }

    return result;
  }

  bool doPrevMove() {

    bool result = false;

    if (currNode >= 0 && currNode < allMoves.length && allMoves[currNode].inactive == false) {
      int prevNode = allMoves[currNode].prev;
      _anController.undoMove();
      currNode = prevNode;
      result = true;
    }
    return result;

  }

  MoveNode doNextMove() {
    MoveNode result = null;

    if (allMoves.length == 0)
      return null;

    int nextNode = currNode == -1 ? 0 : allMoves[currNode].next;
    if (nextNode != -1 && allMoves[nextNode].inactive == false) {
      currNode = nextNode;
      doMove();
      result = allMoves[currNode];
    }
    return result;

  }

  void doMoveAtIndex(int index) {
//    setState(() {
    if (index >= 0 && index < allMoves.length && allMoves[index].fromAlgebraic.isNotEmpty && allMoves[index].toAlgebraic.isNotEmpty && allMoves[index].inactive == false) {
      if (allMoves[index].promoPiece != null && allMoves[index].promoPiece.isNotEmpty)
        _anController.makeMoveWithPromotion(allMoves[index].fromAlgebraic, allMoves[index].toAlgebraic, allMoves[index].promoPiece);
      else
        _anController.makeMove(allMoves[index].fromAlgebraic, allMoves[index].toAlgebraic);
    }
//    });
  }

  /******** TO BE UPDATED
  void doPromote() {
    if (currNode == -1)
      return;
    if (allMoves[currNode].fromAlgebraic.isEmpty)
      return;

    saveState();

//    setState(() {
    /* find parent node */
    int prevnode = allMoves[currNode].prev;
    if (prevnode == -1)
      return;
    int parentnode = allMoves[prevnode].next;
    if (parentnode == currNode)
      return;

    /* make current node the parent */
    allMoves[prevnode].next = currNode;
    allMoves[currNode].vars = allMoves[parentnode].vars;
    allMoves[currNode].vars = allMoves[parentnode].vars.map((element)=>element).toList();
    allMoves[parentnode].vars.clear();

    /* remove current node from variations and add former parent node in  variation list */
    allMoves[currNode].vars.add(parentnode);
    allMoves[currNode].vars.remove(currNode);

//    });
  }
      ******** TO BE UPDATED ***/


}

/*****************************************************************************************/

class PgnDisplay extends StatefulWidget {
  const PgnDisplay(this.mc, this.height, this.width, this.updateDisplay, this.compressDisplay);

  final bool compressDisplay;
  final MoveController mc;
  final height;
  final width;
  final void Function() updateDisplay;
//  final ChessBoardController initialAnController;
//  final void Function(int) onSelectPgnMove;
  @override
  _PgnDisplayState createState() => _PgnDisplayState();
}

class _PgnDisplayState extends State<PgnDisplay> {

  List<Widget> widList = new List<Widget>();
  List<List<Widget>> rowList = new List<List<Widget>>();
  int rowNum = 0;

  double rowWid = 0;
  double objWid = 0;
  double margin = 1.0;
  double maxRowLength = 0;

  int _currRow = 0;
  int ancestor = -1;
  String _currIndent = '';

  double _treeFontSize = 13.0;
  double _rowHeight = 20.0;
  double _menuIconHeight = 18;

  final _scrollController = ScrollController();

  /* variables passed in with constructor */
//  List<MoveNode> allMoves = List<MoveNode>();
//  int currNode = -1; // curr node
  String pgnStr = ''; // = '';
  //ChessBoardController _anController;

  @override
  void initState() {
    super.initState();

    if (globals.tablet) {
      _treeFontSize = globals.tabFontsize[globals.tid];
      _rowHeight = globals.tabRowHeight[globals.tid];
      _menuIconHeight = globals.tabIconsize[globals.tid];
    }

  }

  String getPgn(BuildContext context) {
    pgnStr = '';
    getWidgetsForLine(context, 0, 0, false, true, false);
    return pgnStr;
  }

  Color getButtonColor(int m) {
    if (m == widget.mc.currNode) {
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

    if (str.contains('R') || str.contains('N') || str.contains('B') || str.contains('K') || str.contains('Q') )
      return 1;

    if (str.contains('O-O'))
     return 2;

    if (str.contains('O-O-O'))
      return 3;

    return 0;
  }

  void addRowBeginning(int start, int lev, bool returnPgn, bool compressed) {
    if (start == -1 || start > widget.mc.allMoves.length - 1)
      return;

    String _begStr = getNumStr(widget.mc.allMoves[start].moveNum);

    _currIndent = '';

    if (lev > 0) {
      _begStr = '(' + _begStr;
      if (!returnPgn && !compressed)
      {
        _begStr = globals.indent[lev] + _begStr;
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
    else {
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
                fontStyle: lev == 0 ? globals.style[0] : globals.style[1],
                color: lev <= 4 ? globals.anTextColor[lev] : globals
                    .anTextColor[4],
              ),
            ),
          ),
        ),
      );

      //MediaQuery.of(rowList[rowNum][rowList[rowNum].length-1])
    }
  }

  void _clearWidgets() {
    widList.clear();
    rowList.clear();
    rowNum = 0;
    rowWid = 0;
  }

  int getAncestor(int index) {
    //print ('getAncestor called with index = ' + index.toString());
    if (index == -1 || widget.mc.allMoves == null || index > widget.mc.allMoves.length - 1)
      return -1;

    //print ('getAncestor ' + widget.mc.allMoves[index].pgn + ' level ' + widget.mc.allMoves[index].level.toString());

    if (widget.mc.allMoves[index].level == 0) // if this is level 0, we have found the ancestor
      return index;

    int prevnode = widget.mc.allMoves[index].prev;

    if (prevnode == -1 || prevnode > widget.mc.allMoves.length - 1) // not expected
      return -1;

    if (widget.mc.allMoves[index].level == widget.mc.allMoves[prevnode].level)
      return getAncestor(prevnode);
    else { // moving to parent level
      if (widget.mc.allMoves[prevnode].next == -1)
        return -1; // not expected
      else
        return getAncestor(widget.mc.allMoves[prevnode].next); // branch prev points to node prior to parent for navigation
    }

  }

  Widget getAnalysisWidgets(BuildContext context, bool compressed) {

    if (widget.mc.allMoves.isEmpty)
      return null;

    // maxRowLength = (MediaQuery.of(context).size.width / globals.characterwidth).floor();
    maxRowLength = MediaQuery.of(context).size.width;

    /* clear up widget list and row list to be populated with moves pgn */
    _clearWidgets();
    ancestor = getAncestor(widget.mc.currNode);

    rowList.add(new List<Widget>());

    getWidgetsForLine(context, 0, 0, false, false, compressed);

    addRow(false, 0, false);

    return
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widList,
      );

  }

  void getWidgetsForLine(BuildContext context, int start, int lev, bool leaveRowOpen, bool returnPgn, bool compressed) {
    if (start == -1)
      return;

//    if (widget.mc.currNode == -1)
//      return;

    if (compressed && widget.mc.isVisibleMove(start) == false)
      return;

    addRowBeginning(start, lev, returnPgn, compressed);

    bool showNum = false;
    bool showIndent = false;

    int cnt = 0;
    for (int m = start; m >= 0 && m < widget.mc.allMoves.length && widget.mc.allMoves[m].inactive == false; m = widget.mc.allMoves[m].next) {
      // if (widget.mc.allMoves[m].pgn == 'O-O')
      //   print ('Reached point');

      if (compressed && lev > 0 && cnt > 0)
        break;
      cnt++;

      if (compressed && lev == 0 && widget.mc.allMoves[m].seen != true) {
        break;
      }

      int num = widget.mc.allMoves[m].moveNum;
      String _pgn = '';
      String _numStr = '';
      String _dotStr = '.';

      if (m != start && (num) % 2 == 0) {
        showNum = true;
      }

      if (showNum) {
        _numStr = getNumStr(num);
      }

      if (showIndent && !returnPgn && !compressed) {
        _numStr = globals.indent[lev] + _numStr;
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
        else
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
                    fontStyle: globals.style[lev],
                    color: globals.anTextColor[lev],
                  ),
                ),
              ),
            ),
          );
      }

      showNum = false;
      showIndent = false;

      bool hasComment = false;
      objWid = 0;

      _pgn = widget.mc.allMoves[m].pgn + widget.mc.allMoves[m].quality  + ' ';

      if (widget.mc.allMoves[m].comment != null && widget.mc.allMoves[m].comment.isNotEmpty ) {
        if (returnPgn) {
          _pgn = _pgn + '{' + widget.mc.allMoves[m].comment + '}';
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

      if (returnPgn)
        pgnStr = pgnStr + _pgn ;
      else {
        if (hasComment) {
          rowList[rowNum].add(
              Icon(globals.iconList['comment'], color: globals.mocha,
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
                setState(() {
                  widget.mc.goToMove(m);
                  widget.updateDisplay();
                });
              },
              padding: const EdgeInsets.all(0.0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

              child: Text('$_pgn',
                style: TextStyle(
                  fontSize: _treeFontSize,
                  backgroundColor: getButtonColor(m),
                  fontStyle: globals.style[lev],
                  color: globals.anTextColor[lev],
                ),
              ),
            ),
          ),
        );
      }

      if (widget.mc.allMoves[m].vars.isNotEmpty) { // has variation lines under it

        for (int v in widget.mc.allMoves[m].vars) {
          if (widget.mc.allMoves[v].inactive)
            continue;

          bool leaveOpen = false;
          if (widget.mc.allMoves[m].next == -1 || widget.mc.allMoves[widget.mc.allMoves[m].next].inactive == true) {
            leaveOpen = true;
          }

          bool childCompressed = compressed;
          if (compressed && getAncestor(v) == ancestor)
            childCompressed = false; // expand the variations under the currNode

          addRow(returnPgn, 0, childCompressed);
          getWidgetsForLine(context, v, lev+1, leaveOpen, returnPgn, childCompressed);
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
      if (rowList[rowNum].isEmpty && !returnPgn && !compressed) {
        _endStr = globals.indent[lev];
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
//          ButtonTheme(
//            minWidth: globals.minCharBox,
//            height: 20,
//            child:
//            FlatButton(
//              onPressed: () {},
//              padding: const EdgeInsets.all(0.0),
//              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//              child:
              Text(_endStr,
                style: TextStyle(
                  fontSize: _treeFontSize,
                  fontStyle: globals.style[lev],
                  color: globals.anTextColor[lev],
                ),
              ),
//            ),
//          ),
        );
    }

    // add last row into widList
    if (leaveRowOpen == false) {
      addRow(returnPgn, 0, compressed);
    }

  }

  void addRowForWrap(bool returnPgn, double objRemaining, int lev) {
    addRow(returnPgn, objWid, false);
    rowWid = objRemaining;

    if (!returnPgn && _currIndent.isNotEmpty) {
      rowWid += _currIndent.length;
      rowList[rowNum].add(
//        ButtonTheme(
//          minWidth: globals.minCharBox,
//          height: 20,
//          child: FlatButton(
//            onPressed: () {},
//            padding: const EdgeInsets.all(0.0),
//            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//            child:
            Text('$_currIndent',
              style: TextStyle(
                fontSize: _treeFontSize,
                fontStyle: globals.style[lev],
                color: globals.anTextColor[lev],
              ),
            ),
//          ),
//        ),
      );
    }

  }

  void addRow(bool returnPgn, double objRemaining, bool compressed) {
    if (compressed)
      return;

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
    }
  }


  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (_scrollController.hasClients) {
        double offset = _scrollController.offset;
        if ((_currRow + 1)* globals.rowHeight > widget.height + offset) {
          _scrollController.jumpTo((_currRow + 1) * globals.rowHeight - widget.height);
        }
        else if (_currRow  * globals.rowHeight < offset) {
          _scrollController.jumpTo(offset - (_currRow + 1) * globals.rowHeight);
        }
      }

    });

    return

      Container(
        width: widget.width,
        height: widget.height, //_anHeight,
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
            child: getAnalysisWidgets(context, widget.compressDisplay), // true
          ),
        ),
      )
    ;
  }
}
