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


class ListPracticeGames extends StatefulWidget {
  @override
  _ListPracticeGamesState createState() => _ListPracticeGamesState();
}

class PracticeGame {
  String id;
  String title;
}

class _ListPracticeGamesState extends State<ListPracticeGames> {

  List<DocumentSnapshot> gamedocs;

  Map gameMap = Map<String,String>();
  List<PracticeGame> gameList = new List<PracticeGame>();

  List<String> gameCollection = ['beginnergames','novicegames','intermediategames',
    'advancedgames','mastergames'];

  double _treeFontSize = 13.0;
  double _rowHeight = 20.0;
  double _menuIconHeight = 18;


  void _loadList() async {
    if (globals.firestore == null)
      return;


    CollectionReference collectionReference = await globals.firestore.collection(gameCollection[globals.skillLevel]);

    collectionReference.snapshots().listen((snapshot) {


        gamedocs = snapshot.documents;

        if (gamedocs != null && gamedocs.isNotEmpty) {
          setState(() {
            gameList.clear();

            Map g;

            for (int i = 0; i < gamedocs.length; i++) {
              g = gamedocs[i].data;

              String id = g['ID'];
              String title = g['title'];

              gameMap.putIfAbsent(id, () => title);

              PracticeGame game = new PracticeGame();
              game.title = title;
              game.id = id;
              gameList.add(game);
            }
          });
        }
    });
  }


  buildGameList(BuildContext context) {
    if (gamedocs == null || gamedocs.isEmpty) {
      String _msg = globals.errorStr;
      return
        Container(
          margin: EdgeInsets.all(10.0),
          child: Text('$_msg',
            style: TextStyle(
              fontSize: globals.tablet ? _treeFontSize + 4 : 16,
            ),
          ),
        );
    } else
    return
      ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: gameList.length,
          itemBuilder: (context, position) {
            String _title = gameList[position].title;
            return Column (
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: globals.tablet ? 15 : 5,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  // height: globals.selectButtonHeight,
                  child: FlatButton(
                    onPressed: () {
                      globals.gotoPracticePage(context, globals.skillLevel, gameList[position].id);
                    },
                    child:
                    Text('$_title',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: TextStyle(
                          fontSize: globals.tablet ? _treeFontSize + 4 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: globals.tablet ? 15 : 5,
                ),
                Container(
                  color: globals.mocha,
                  width: MediaQuery.of(context).size.width,
                  height: 2,
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
    }

    _loadList();

  }

  Future<bool> _onBackPressed() {
//    Navigator.pop(context);
//    Navigator.pop(context);
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }


  @override
  Widget build(BuildContext context) {

    AppBar getAppBar() {

      if (globals.tablet) {
        return
          AppBar(
            //iconTheme: IconThemeData( color: _mocha,),
            //backgroundColor: Colors.transparent,
            //elevation: 0,
            centerTitle: true,
            title: Text(globals.getSkillLevelTitle() + ' Practice Games',
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

            actions: <Widget>[

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
            //iconTheme: IconThemeData( color: _mocha,),
            //backgroundColor: Colors.transparent,
            //elevation: 0,
            centerTitle: true,
            title: Text(globals.getSkillLevelTitle() + ' Practice Games',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: globals.appBartextSize,
              ),
            ), //, style: TextStyle(color: _mocha),)
            actions: <Widget>[

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


                /* login button */
                SizedBox(
                  height: globals.gap,
                ),

                Container(
                  height: MediaQuery.of(context).size.height - globals.appBarHeight -globals.gap - 10,
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
