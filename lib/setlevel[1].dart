import 'package:chess_principles/analysis.dart';
import 'package:chess_principles/practicelist.dart';
import 'package:chess_principles/principles.dart';
import 'package:flutter/material.dart';
import 'global.dart' as globals;

//Pages
import './about.dart';
import './beginner.dart';
import './intermediate.dart';
import './novice.dart';
import './advanced.dart';
import './master.dart';

import './signin.dart';

class SetLevel extends StatefulWidget {

  SetLevel(this.screenNum);

  final int screenNum; //1 - Principles, 2 - Practice

  @override
  _SetLevelState createState() => _SetLevelState();
}

class _SetLevelState extends State<SetLevel> {

  double _treeFontSize = 13.0;
  double _rowHeight = 20.0;
  double _menuIconHeight = 18;
  double _nextButtonHeight = 23.0;
  double _selectButtonHeight = 25.0;

  @override
  void initState() {
    super.initState();

    // print (globals.tablet);

    if (globals.tablet) {
      _treeFontSize = globals.tabFontsize[globals.tid];
      _rowHeight = globals.tabRowHeight[globals.tid];
      _menuIconHeight = globals.tabIconsize[globals.tid];
      _nextButtonHeight = globals.tabNextButtonHeight[globals.tid];

      globals.widgeButtonMultipler = 0.5;
    }
  }

  _nextScreen(BuildContext context, int skill) {

    globals.skillLevel = skill;

    switch (widget.screenNum) {
      case 3: // game list
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ListPracticeGames(),
            ));
        break;
      case 2: // practice
        globals.gotoPracticePage(context, skill, '');
        break;
      case 1: // principle list
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ListPrinciple(),
            ));
        break;
      case 0 :
      default:
        Navigator.popUntil(context, ModalRoute.withName('/'));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    ScrollController _scrollController = new ScrollController();

    AppBar getAppBar() {
      if (globals.tablet) {
        return AppBar(
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
          title: Text('Skill level',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: globals.appBarTextFlex,
            ),
          )
          // actions: <Widget>[
          //   IconButton(
          //     onPressed: () {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (BuildContext context) => SetLevel(2),
          //           ));
          //     },
          //     icon: Icon(Icons.settings, color: Colors.white,
          //       size: globals.appBarIconFlex,
          //     ),
          //   ),
          // ],
        );
      } else {
        return AppBar(
          centerTitle: true,
          title: Text('Skill level',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: globals.appBartextSize,
            ),
          ),
          // actions: <Widget>[
          //   IconButton(
          //     onPressed: () {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (BuildContext context) => SetLevel(2),
          //           ));
          //     },
          //     icon: Icon(Icons.settings, color: Colors.white),
          //   ),
          // ],
        );
      }
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 237, 213), //a=255 = opaque
      resizeToAvoidBottomPadding: false,
      body:
      Center(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

            //appBar:
            SizedBox(
              height: globals.appBarHeight,
              child: getAppBar(),
            ),

            // SizedBox(
            //   height: globals.gap,
            // ),

            Text('Select the level you want to browse with',
              style: TextStyle(
                fontSize: globals.tablet ? _treeFontSize + 2: globals.textsize,
              ),
            ),

            SizedBox(
              height: globals.tablet ? 15: 2,
            ),

            Container(
              margin: EdgeInsets.zero,
              height: MediaQuery.of(context).size.height - globals.appBarHeight - globals.nextButtonHeight - (globals.tablet ? 20 : 8),
              child: Scrollbar(
                controller: _scrollController,
                //isAlwaysShown: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[

                      // divider
                      Container(
                        color: globals.mocha,
                        width: MediaQuery.of(context).size.width,
                        height: 1,
                      ),

                      SizedBox(height: globals.tablet ? 15: 1,),

                      Text(globals.level0desc,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 6,
                        style: TextStyle (
                          fontSize: globals.tablet ? _treeFontSize : globals.textsizeMedium,
                        ),
                      ),

                      SizedBox(height: globals.tablet ? 15:1,),

                      Container(
                        width: MediaQuery.of(context).size.width * globals.widgeButtonMultipler,
                        height: globals.tablet ? _nextButtonHeight : _selectButtonHeight,
                        child: RaisedButton(
                          onPressed: () {
                            _nextScreen(context, 0);
                          },
                          child: Text('Beginner',
                            style: TextStyle(
                              fontSize: globals.tablet ? _treeFontSize + 4  : 16,
                              color: globals.skillLevel == 0 ? Colors.white : Colors.black,
                            ),
                          ),
                          color: globals.skillLevel == 0 ? Colors.brown : Color.fromARGB(255, 238, 163, 94),
                          elevation: 10,
                        ),
                      ),

                      SizedBox(height: globals.tablet ? 15: 5,),

                      // divider
                      Container(
                        color: globals.mocha,
                        width: MediaQuery.of(context).size.width,
                        height: 1,
                      ),

                      SizedBox(height: globals.tablet ? 15: 1,),

                      Text(globals.level1desc,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 6,
                        style: TextStyle (
                          fontSize: globals.tablet ? _treeFontSize : globals.textsizeMedium,
                        ),
                      ),

                      SizedBox(height: globals.tablet ? 15: 1,),

                      Container(
                        width: MediaQuery.of(context).size.width * globals.widgeButtonMultipler,
                        height: globals.tablet ? _nextButtonHeight : _selectButtonHeight,
                        child: RaisedButton(
                          onPressed: ()
                          {
                            _nextScreen(context, 1);
                          },
                          child: Text('Novice',
                            style: TextStyle(
                              fontSize: globals.tablet ? _treeFontSize + 4  : 16,
                              color: globals.skillLevel == 1 ? Colors.white : Colors.black,
                            ),
                          ),
                          color: globals.skillLevel == 1 ? Colors.brown : Color.fromARGB(255, 238, 163, 94),
                          elevation: 5,
                        ),
                      ),

                      SizedBox(height: globals.tablet ? 15:5,),

                      // divider
                      Container(
                        color: globals.mocha,
                        width: MediaQuery.of(context).size.width,
                        height: 1,
                      ),

                      SizedBox(height: globals.tablet ? 15:1,),

                      Text(globals.level2desc,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 6,
                        style: TextStyle (
                          fontSize: globals.tablet ? _treeFontSize : globals.textsizeMedium,
                        ),
                      ),

                      SizedBox(height: globals.tablet ? 15:1,),

                      Container(
                        width: MediaQuery.of(context).size.width * globals.widgeButtonMultipler,
                        height: globals.tablet ? _nextButtonHeight : _selectButtonHeight,
                        child: RaisedButton(
                          onPressed: ()
                          {
                            _nextScreen(context, 2);
                          },
                          child: Text('Intermediate',
                            style: TextStyle(
                              fontSize: globals.tablet ? _treeFontSize + 4  : 16,
                              color: globals.skillLevel == 2 ? Colors.white : Colors.black,
                            ),
                          ),
                          color: globals.skillLevel == 2 ? Colors.brown : Color.fromARGB(255, 238, 163, 94),
                          elevation: 5,
                        ),
                      ),

                      SizedBox(height: globals.tablet ? 15:5,),

                      // divider
                      Container(
                        color: globals.mocha,
                        width: MediaQuery.of(context).size.width,
                        height: 1,
                      ),

                      SizedBox(height: globals.tablet ? 15:1,),

                      Text(globals.level3desc,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 6,
                        style: TextStyle (
                          fontSize: globals.tablet ? _treeFontSize : globals.textsizeMedium,
                        ),
                      ),

                      SizedBox(height: globals.tablet ? 15:1,),

                      Container(
                        width: MediaQuery.of(context).size.width * globals.widgeButtonMultipler,
                        height: globals.tablet ? _nextButtonHeight : _selectButtonHeight,
                        child: RaisedButton(
                          onPressed: ()

                          {
                            _nextScreen(context, 3);
                          },
                          child: Text('Advanced',
                            style: TextStyle(
                              fontSize: globals.tablet ? _treeFontSize + 4  : 16,
                              color: globals.skillLevel == 3 ? Colors.white : Colors.black,
                            ),
                          ),
                          color: globals.skillLevel == 3 ? Colors.brown : Color.fromARGB(255, 238, 163, 94),
                          elevation: 5,
                        ),
                      ),

                      Visibility(
                        visible: globals.numLevelsAllowed > 4 ,
                        child: Column(
                          children: <Widget> [

                            SizedBox(height: globals.tablet ? 15:5,),

                            // divider
                            Container(
                              color: globals.mocha,
                              width: MediaQuery.of(context).size.width,
                              height: 1,
                            ),

                            SizedBox(height: globals.tablet ? 15:1,),
                            Text(globals.level4desc,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 6,
                              style: TextStyle (
                                fontSize: globals.tablet ? _treeFontSize : globals.textsizeMedium,
                              ),
                            ),

                            SizedBox(height: globals.tablet ? 15:1,),

                            Container(
                              width: MediaQuery.of(context).size.width * globals.widgeButtonMultipler,
                              height: globals.tablet ? _nextButtonHeight : _selectButtonHeight,
                              child: RaisedButton(
                                onPressed: ()
                                {
                                  _nextScreen(context, 4);
                                },
                                child: Text('Master',
                                  style: TextStyle(
                                    fontSize: globals.tablet ? _treeFontSize + 4  : 16,
                                    color: globals.skillLevel == 4 ? Colors.white : Colors.black,
                                  ),
                                ),
                                color: globals.skillLevel == 4 ? Colors.brown : Color.fromARGB(255, 238, 163, 94),
                                elevation: 5,
                              ),
                            ),

                            // SizedBox(height: 1,),
                            //
                            // // divider
                            // Container(
                            //   color: globals.mocha,
                            //   width: MediaQuery.of(context).size.width,
                            //   height: 1,
                            // ),

                          ],
                        ),
                      ),

                    ],
                  ),

                ),
              ),
            ),
          ],
        ),
      ),
    );

  }


}
