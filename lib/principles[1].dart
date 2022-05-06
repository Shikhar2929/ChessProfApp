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


class ListPrinciple extends StatefulWidget {
  @override
  _ListPrincipleState createState() => _ListPrincipleState();
}

class Principle {
  String principle;
  String description;
}

class _ListPrincipleState extends State<ListPrinciple> {

  List<DocumentSnapshot> principledocs;

  Map principles = Map<String,String>();
  List<Principle> prinList = new List<Principle>();

  List<String> principleCollection = ['beginnerprinciples','noviceprinciples','intermediateprinciples',
    'advancedprinciples','masterprinciples'];

  double _treeFontSize = 13.0;
  double _rowHeight = 20.0;
  double _menuIconHeight = 18;

  void _loadPrincipleList() async {
    if (globals.firestore == null)
      return;

    CollectionReference collectionReference = await globals.firestore.collection(principleCollection[globals.skillLevel]);

    collectionReference.snapshots().listen((snapshot) {

        principledocs = snapshot.documents;

        if (principledocs != null && principledocs.isNotEmpty) {
          setState(() {
            Map p;

            for (int i = 0; i < principledocs.length; i++) {
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
        }
    });
  }


  buildPrincipleList(BuildContext context) {
    if (principles == null || principles.isEmpty) {
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
          itemCount: principles.length,
          itemBuilder: (context, position) {
            String _pr = prinList[position].principle;
            String _desc = prinList[position].description;
            return Column (
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: globals.tablet ? 15 : 5,
                ),
                Text('$_pr',
                  style: TextStyle(
                      fontSize: globals.tablet ? _treeFontSize + 8 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown
                  ),
                ),
                SizedBox(
                  height: globals.tablet ? 15 : 5,
                ),
                Text('$_desc',
                  style: TextStyle(
                    fontSize: globals.tablet ? _treeFontSize + 2 : 16,
                  ),
                ),
                SizedBox(
                  height: globals.tablet ? 15 : 10,
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

    _loadPrincipleList();

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
            title: Text('Key Chess Principles',
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
                        builder: (BuildContext context) => SetLevel(1),
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
            title: Text('Key Chess Principles',
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
                        builder: (BuildContext context) => SetLevel(1),
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


                // /* login button */
                // SizedBox(
                //   height: globals.gap,
                // ),

                Container(
                  height: MediaQuery.of(context).size.height - globals.appBarHeight - 10,
                  child: Scrollbar(
                    child:
                    buildPrincipleList(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );;
  }
}
