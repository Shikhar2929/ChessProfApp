import 'dart:core';
import 'package:chess_principles/analysis.dart';
import 'package:chess_principles/principles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'global.dart' as globals;

//Pages
import './about.dart';
import './howto.dart';
import './feedback.dart';
import './setlevel.dart';
import './practicelist.dart';
import './analysislist.dart';
import './signin.dart';

Color _background = Color.fromARGB(255, 255, 237, 213); //a=255 = opaque
Color _highlight = Colors.amberAccent;
Color _mocha = Color.fromARGB(255, 192, 107, 0);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chess Prof',
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.light,
        primaryColor: Color.fromARGB(255, 192, 107, 0),
        accentColor: Color.fromARGB(255, 148, 82, 0),

        // Define the default font family.
        fontFamily: 'Calibri', // Georgia

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 70.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 34.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 12.0, fontFamily: 'Calibri'),   //Hind
        ),
      ),
      home: MyHomePage(title: 'Chess Prof'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _currentIndex = 0;

  //String _welcome = 'Welcome to the ChessProf app. Here you can:\n    Learn key principles of chess\n    See principles in action in practice games\n    Analyze and save your games\n    Submit games for analysis';
  String _welcome = 'Welcome to ChessProf';

  double _commentHeight = 40.0;
  double _panelHeight = 100.0;


  final _scrollController = ScrollController();


  void _loadConfig() async {
    Map loaded;
    List<DocumentSnapshot> configdocs;

    if (globals.firestore == null) {
      //wait 2 seconds and try again 5 times
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 2000));
        if (globals.firestore != null)
          break;
      }
      // if (globals.firestore == null) {
      //   setState(() {
      //     globals.initComplete = true;
      //   });
      //   return;
      // }
    }

    try {

      CollectionReference collectionReference = await globals.firestore.collection('configs');

      collectionReference.snapshots().listen((snapshot) {

        configdocs = snapshot.documents;

        if (configdocs != null && configdocs.isNotEmpty) {

          Map loaded;

          loaded = configdocs[0].data; // expect only 1 record

          if (loaded != null) {
            // setState(() {

            String about;
            String howto;
            String feedback;
            // String capsmult;
            // String characterwidth;
            String levels;
            String desc0;
            String desc1;
            String desc2;
            String desc3;
            String desc4 = '';

            about = loaded['about'];
            if (about != null && about.isNotEmpty)
              globals.aboutText = about.replaceAll("\\n", "\n");

            howto = loaded['how1'];
            if (howto != null && howto.isNotEmpty)
              globals.howtoText1 = howto.replaceAll("\\n", "\n");

            howto = loaded['how2'];
            if (howto != null && howto.isNotEmpty)
              globals.howtoText2 = howto.replaceAll("\\n", "\n");

            howto = loaded['how3'];
            if (howto != null && howto.isNotEmpty)
              globals.howtoText3 = howto.replaceAll("\\n", "\n");

            howto = loaded['how3para2'];
            if (howto != null && howto.isNotEmpty)
              globals.howtoText3_para2 = howto.replaceAll("\\n", "\n");

            howto = loaded['how4'];
            if (howto != null && howto.isNotEmpty)
              globals.howtoText4 = howto.replaceAll("\\n", "\n");

            howto = loaded['how4para2'];
            if (howto != null && howto.isNotEmpty)
              globals.howtoText4_para2 = howto.replaceAll("\\n", "\n");

            feedback = loaded['feedback'];
            if (feedback != null && feedback.isNotEmpty)
              globals.feedbackText = feedback;

            // capsmult = loaded['capsmult'];
            //
            // characterwidth = loaded['capsmult'];

            levels = loaded['levels'];
            if (levels != null && levels == '5')
              globals.numLevelsAllowed = 5;

            desc0 = loaded['level0desc'];
            if (desc0 != null && desc0.isNotEmpty)
              globals.level0desc = desc0;

            desc1 = loaded['level1desc'];
            if (desc1 != null && desc1.isNotEmpty)
              globals.level1desc = desc1;

            desc2 = loaded['level2desc'];
            if (desc2 != null && desc2.isNotEmpty)
              globals.level2desc = desc2;

            desc3 = loaded['level3desc'];
            if (desc3 != null && desc3.isNotEmpty)
              globals.level3desc = desc3;

            desc4 = loaded['level4desc'];
            if (desc4 != null && desc4.isNotEmpty)
              globals.level4desc = desc4;

            // globals.initComplete = true;
            // });

          }
        }

      });

    } on PlatformException catch (e) {
      print(globals.getMessageFromErrorCode(e.code));
      // setState(() {
      //   globals.initComplete = true;
      // });
    }

  }


  /// Did Change Dependencies
  @override
  void didChangeDependencies() {
    // print ('In didChangeDependencies');

    precacheImage(AssetImage('assets/darksquare_selected.png'), context);
    precacheImage(AssetImage('assets/d_selected_learn.png'), context);
    precacheImage(AssetImage('assets/d_selected_analyze.png'), context);
    precacheImage(AssetImage('assets/d_selected_startlesson.png'), context);
    precacheImage(AssetImage('assets/d_selected_browsegames.png'), context);
    precacheImage(AssetImage('assets/d_selected_principles.png'), context);
    precacheImage(AssetImage('assets/w_selected_selfanalysis.png'), context);
    precacheImage(AssetImage('assets/w_selected_mysavedgames.png'), context);
    precacheImage(AssetImage('assets/w_selected_chessprofanalysis.png'), context);

    super.didChangeDependencies();

  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey _keyUpper = GlobalKey();
  GlobalKey _keyLower = GlobalKey();
  GlobalKey _keySmall = GlobalKey();
  GlobalKey _keyDot = GlobalKey();
  GlobalKey _keySpace = GlobalKey();
  GlobalKey _keyIcon = GlobalKey();
  GlobalKey _keyAnalyze32 = GlobalKey();
  GlobalKey _keyAnalyze30 = GlobalKey();
  GlobalKey _keyAnalyze28 = GlobalKey();
  GlobalKey _keyAnalyze26 = GlobalKey();
  GlobalKey _keyAnalyze23 = GlobalKey();
  GlobalKey _keyAnalyze21 = GlobalKey();
  GlobalKey _keyAnalyze20 = GlobalKey();

  double _panelWidth = 100.0; // initial value, will be changed on running build
  // double menuFontsize = 26.0; // to be updated based on available size
  // double submenuFontsize = 18.0;

  _getSizes() {


    RenderBox renderBoxUpper = _keyUpper.currentContext.findRenderObject();
    globals.sizeUpper = renderBoxUpper.size.width / 6;
    // print("SIZE of Upper: " + globals.sizeUpper.toString());

    RenderBox renderBoxLower = _keyLower.currentContext.findRenderObject();
    globals.sizeLower = renderBoxLower.size.width / 15;
    // print("SIZE of Lower: " + globals.sizeLower.toString());

    RenderBox renderBoxSmall = _keySmall.currentContext.findRenderObject();
    globals.sizeSmall = renderBoxSmall.size.width / 2;
    // print("SIZE of Small: " + globals.sizeSmall.toString());

    RenderBox renderBoxDot = _keyDot.currentContext.findRenderObject();
    globals.sizeDot = renderBoxDot.size.width;
    // print("SIZE of Dot: " + globals.sizeDot.toString());

    RenderBox renderBoxSpace = _keySpace.currentContext.findRenderObject();
    globals.sizeSpace = renderBoxSpace.size.width;
    // print("SIZE of Space: " + globals.sizeSpace.toString());

    RenderBox renderBoxIcon = _keyIcon.currentContext.findRenderObject();
    globals.sizeIcon = renderBoxIcon.size.width;
    // print("SIZE of Icon: " + globals.sizeIcon.toString());

    if (globals.tablet == true) {
      RenderBox renderBoxAnalyze32 = _keyAnalyze32.currentContext
          .findRenderObject();
      globals.sizeAnalyze32 = renderBoxAnalyze32.size.width;

      RenderBox renderBoxAnalyze30 = _keyAnalyze30.currentContext
          .findRenderObject();
      globals.sizeAnalyze30 = renderBoxAnalyze30.size.width;
    }

    RenderBox renderBoxAnalyze28 = _keyAnalyze28.currentContext.findRenderObject();
    globals.sizeAnalyze28 = renderBoxAnalyze28.size.width;

    RenderBox renderBoxAnalyze26 = _keyAnalyze26.currentContext.findRenderObject();
    globals.sizeAnalyze26 = renderBoxAnalyze26.size.width;

    RenderBox renderBoxAnalyze23 = _keyAnalyze23.currentContext.findRenderObject();
    globals.sizeAnalyze23 = renderBoxAnalyze23.size.width;

    RenderBox renderBoxAnalyze21 = _keyAnalyze21.currentContext.findRenderObject();
    globals.sizeAnalyze21 = renderBoxAnalyze21.size.width;

    RenderBox renderBoxAnalyze20 = _keyAnalyze20.currentContext.findRenderObject();
    globals.sizeAnalyze21 = renderBoxAnalyze21.size.width;

    double targetSize = _panelWidth;

    // print ('In getSizes targetSize = ' + targetSize.toString());
    // print ('In getSizes globals.sizeAnalyze26 = ' + globals.sizeAnalyze26.toString());
    // print ('In getSizes globals.sizeAnalyze23 = ' + globals.sizeAnalyze23.toString());
    // print ('In getSizes globals.sizeAnalyze21 = ' + globals.sizeAnalyze21.toString());

    if (globals.tablet == true) {
      if (globals.sizeAnalyze32 <= targetSize)
        globals.menuFontsize = 32.0;
      else if (globals.sizeAnalyze30 <= targetSize)
        globals.menuFontsize = 30.0;
    }
    else if (globals.sizeAnalyze28 <= targetSize)
      globals.menuFontsize = 28.0;
    else if (globals.sizeAnalyze26 <= targetSize)
      globals.menuFontsize = 26.0;
    else if (globals.sizeAnalyze23 <= targetSize)
      globals.menuFontsize = 23.0;
    else if (globals.sizeAnalyze21 <= targetSize)
      globals.menuFontsize = 21.0;
    else if (globals.sizeAnalyze20 <= targetSize)
      globals.menuFontsize = 20.0;
    else
      globals.menuFontsize = 19.0;

    globals.submenuFontsize = globals.menuFontsize - 7;
    globals.regularTextFlex = globals.submenuFontsize - 2;
    globals.appBarTextFlex = globals.tablet ? globals.menuFontsize : globals.submenuFontsize;
    globals.appBarIconFlex = globals.tablet ? globals.menuFontsize * 1.25 : globals.submenuFontsize * 1.25;

    // print ('menuFontSize after calibration = ' + globals.menuFontsize.toString());
  }

  _connect() async {
    _getSizes();

    // setState(() {
    globals.initComplete = true;
    // });

    await globals.initConnections();
    // Future.delayed(const Duration(milliseconds: 5000), ()
    // {
    await _loadConfig();
    // });

    // if (globals.initComplete == false) { // should not happen
    //   //wait 1 seconds and try again
    //   for (int i = 0; i < 6; i++) {
    //     await Future.delayed(const Duration(milliseconds: 1000));
    //     if (globals.initComplete == false)
    //       break;
    //   }
    //   if (globals.initComplete == false) {
    //     setState(() {
    //       globals.initComplete = true;
    //     });
    //   }
    // }
  }

  @override
  void initState() {

    // print ('In initstate');
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
    // print ('Initstate completed');
  }

  List<Color> boxColors = [
    _background,
    _mocha,
    _background,

    _mocha,
    _background,
    _mocha,

    _background,
    _mocha,
    _background,

    _mocha,
    _background,
    _mocha,
  ];

  List<Color> textColors = [
    _mocha,
    Colors.white,
    _mocha,

    _background,
    _mocha,
    _background,

    Colors.black,
    _background,
    Colors.black,

    Colors.white,
    Colors.black,
    Colors.white,
  ];

  List<String> boxStr = [
    '',
    '',
    '',
    'Analyze',
    '',
    'Learn',
    '',
    '',
    '',
    '',
    '',
    '',
  ];

  List<String> learnSubmenu = [
    'Principles',
    'Browse Games',
    'Start Lesson',
  ];

  List<String> analyzeSubmenu = [
    'Self Analysis',
    'My Saved Games',
    'ChessProf Analysis',
  ];


  int _submenu = 0; //0 - none, 1 - learn sub items, 2 - analyze sub items

/*  _getSubmenuBySelection(int ind) {  // //0 - none, 1 - learn sub items, 2 - analyze sub items
    if (_submenu == 1)
      return learnSubmenu[ind];
    else if (_submenu == 2)
      return analyzeSubmenu[ind];
    else
      return '';
  }*/

  double _getTextSize(int index) {

    switch (index) {
      case 6:
      case 7:
      case 8:
      case 9:
      case 10:
      case 11:
        return globals.submenuFontsize;
      default:
      // print ('menu text size = ' + _mainMenuFontsize.toString());
        return globals.menuFontsize;
    }
  }

  String _getBoxText(int index) {
    String result = '';
    switch (index) {
      case 6:
        result = _submenu == 2 ? 'Self Analysis' : ''; break;
      case 8:
        result = _submenu == 2 ? 'ChessProf Analysis' : ''; break;
      case 10:
        result = _submenu == 2 ? 'My Saved Games' : ''; break;
      case 7:
        result = _submenu == 1 ? 'Start Lesson' : ''; break;
      case 9:
        result = _submenu == 1 ? 'Principles' : ''; break;
      case 11:
        result = _submenu == 1 ? 'Browse Games' : ''; break;
      case 5:
      case 3:
        result = boxStr[index];
        break;
      default:
        result = '';
        break;
    }
    return result;
  }

  String _getBoxImage(int index) {
    bool white = index % 2 == 1 ? false : true;

    String img;

    if (white) {
      if (_submenu == 2 && (index == 6 || index == 8 || index == 10)) {
        switch (index) {
          case 6:
            img = 'assets/w_selected_selfanalysis.png';
            break;
          case 8:
            img = 'assets/w_selected_chessprofanalysis.png';
            break;
          case 10:
            img = 'assets/w_selected_mysavedgames.png';
            break;
          default:
            img = 'assets/whitesquare_selected.png'; break;
        }
      }
      else
        img = 'assets/whitesquare.png';
    } else {
      if (_submenu == 1 &&
          (index == 7 || index == 5 || index == 9 || index == 11)) {
        switch (index) {
          case 7:
            img = 'assets/d_selected_startlesson.png';
            break;
          case 9:
            img = 'assets/d_selected_principles.png';
            break;
          case 11:
            img = 'assets/d_selected_browsegames.png';
            break;
          case 5:
            img = 'assets/d_selected_learn.png';
            break;
          default:
            img = 'assets/darksquare_selected.png';
            break;
        }
      }
      else if (_submenu == 2 && (index == 3)) {
        img = 'assets/d_selected_analyze.png';
      }
      else if (index == 3)
        img = 'assets/darksquare_analyze.png';
      else if (index == 5)
        img = 'assets/darksquare_learn.png';
      else
        img = 'assets/darksquare.png';
    }

    return img;
  }

/*
  String _getBoxText(int index) {
    String result = '';
    switch (index) {
      case 6:
      case 7:
      case 8:
        result = _getSubmenuBySelection(index - 6);
        break;
      case 3:
      case 5:
        result = boxStr[index];
        break;
      default:
        result = '';
        break;
    }
    return result;
  }
   */

/*
  Color _getBoxColor(int index) {
    if (_submenu == 1 && (index == 5 || index == 7))
      return Colors.brown;
    if (_submenu == 2 && (index == 3 || index == 7))
      return Colors.brown;

    return boxColors[index];
  }
*/

// String _getBoxImage(int index) {
//   bool white = index % 2 == 1 ? false : true;
//
//   String img;
//
//   if (white) {
//     if ( _submenu == 2 && (index == 6 || index == 8 || index == 10 ) )
//       img = 'assets/whitesquare_selected.png';
//     else
//       img = 'assets/whitesquare.png';
//   } else {
//     if ( (_submenu == 1 && (index == 7 || index == 5 || index == 9 || index == 11))
//         || (_submenu == 2 && (index == 3))
//     )
//       img = 'assets/darksquare_selected.png';
//     else
//       img = 'assets/darksquare.png';
//   }
//
//   return img;
// }

/*  String _getBoxImage(int index) {
    bool white = index % 2 == 1 ? false : true;

    String img;

    if (white) {
      if (   (_submenu == 1 && (index == 6 || index == 8))  ||
          (_submenu == 2 && (index == 6))
      )
        img = 'assets/whitesquare_selected.png';
      else
        img = 'assets/whitesquare.png';
    } else {
      if (   (_submenu == 1 && (index == 7 || index == 5))  ||
          (_submenu == 2 && (index == 7 || index == 3))
      )
        img = 'assets/darksquare_selected.png';
      else
        img = 'assets/darksquare.png';
    }

    return img;
  }*/

  browsePractice() {
    // Browse practice games
    if (globals.skillLevel == -1) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => SetLevel(3),
          ));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ListPracticeGames(),
          ));
    }

  }
  selfAnalysis() {
    // Self analysis
    if (globals.isLoggedIn() == false) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => SigninPage(1),
          ));
    }
    else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Analysis(0, ''),
          ));
    }
  }
  principles() {
    if (globals.skillLevel == -1) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => SetLevel(1),
          ));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ListPrinciple(),
          ));
    }
  }
  mySavedGames() {
    if (globals.isLoggedIn() == false) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => SigninPage(2),
          ));
    }
    else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ListAnalysisGames(),
          ));
    }
  }
  doPractice() async {
    if (globals.skillLevel == -1) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => SetLevel(2),
          ));
    } else {
      globals.gotoPracticePage(context, globals.skillLevel, globals.getLastSavedGame());
    }
  }

  setSkill() {

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => SetLevel(0),
        ));

  }

  _callPage(int i) {

    switch (i) {
      case 3: //Analyze top menu
      //Toggle Analyze sub menu items
        setState(() {
          if (_submenu != 2)
            _submenu = 2;
          else
            _submenu = 0;
        });
        break;

      case 5: //Learn top menu
      //Toggle Learn sub menu items
        setState(() {
          if (_submenu != 1)
            _submenu = 1;
          else
            _submenu = 0;
        });

        break;
      case 9:
        if (_submenu == 1) // learn
          principles();
        break;

      case 11:
        if (_submenu == 1) // learn
          browsePractice();
        break;

      case 7:
        if (_submenu == 1) // learn
          doPractice();
        break;

      case 6:
        if (_submenu == 2)
          selfAnalysis();
        break;

      case 8:
      case 10:
        if (_submenu == 2) // analyze
          mySavedGames();
        break;

      default:
        break;

    }
  }

  Table getTable(BuildContext context) {
    if (globals.tablet) {

      double cornerPanelWidth = ( MediaQuery.of(context).size.width - (3 * _panelWidth) ) / 2;

      return
        Table(
          columnWidths: {
            0: FlexColumnWidth(cornerPanelWidth),
            1: FlexColumnWidth(_panelWidth),
            2: FlexColumnWidth(_panelWidth),
            3: FlexColumnWidth(_panelWidth),
            4: FlexColumnWidth(cornerPanelWidth),
          },
          textDirection: TextDirection.rtl,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          //border:TableBorder.all(width: 2.0,color: Colors.brown),
          children: getTabletBoxes(cornerPanelWidth),
        );
    } else {
      return
        Table(
          textDirection: TextDirection.rtl,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          //border:TableBorder.all(width: 2.0,color: Colors.brown),
          children: getBoxes(),
        );
    }
  }

  List<TableRow> getTabletBoxes(double cornerWidth) {
    int nRow = 4;
    int nCol = 3;

    List<TableRow> widList = new List<TableRow>();

    for (int r = 0; r < nRow; r++) {
      List<Widget> rowList = new List<Widget>();
      rowList.clear();

      rowList.add(
        Container(
          margin: EdgeInsets.zero,
          width : cornerWidth,
          height: _panelWidth,
          alignment: Alignment(0.0,0.0),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(r % 2 == 0 ? 'assets/darksquare.png' : 'assets/whitesquare.png'),
              fit: BoxFit.fitHeight,
            ),
          ),
          child:
          ButtonTheme(
            minWidth: 10,
            child: FlatButton(
              //color: _getBoxColor(index),
              onPressed: () {
              },
              child:
              Text('',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                // style: TextStyle(
                //   fontSize: _getTextSize(index),
                //   color: textColors[index],
                // ),
              ),
            ),
          ),
        ),
      );

      for (int c = 0; c < nCol; c++) {

        int index = (3*r) + c;
        //print (index.toString() + ':' + boxStr[index]);

        rowList.add(
          Container(
            margin: EdgeInsets.zero,
            width : _panelWidth,
            height: _panelWidth,
            alignment: Alignment(0.0,0.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_getBoxImage(index)),
                fit: BoxFit.cover,
              ),
            ),
            child:
            ButtonTheme(
              minWidth : _panelWidth,
              height: _panelWidth,
              child: FlatButton(
                //color: _getBoxColor(index),
                onPressed: () {
                  _callPage(index);
                },
                // child:
                // Text(_getBoxText(index),
                //   textAlign: TextAlign.center,
                //   overflow: TextOverflow.ellipsis,
                //   maxLines: 3,
                //   style: TextStyle(
                //     fontSize: _getTextSize(index),
                //     color: textColors[index],
                //   ),
                // ),
              ),
            ),
          ),
        );

      }

      rowList.add(
        Container(
          margin: EdgeInsets.zero,
          width : cornerWidth,
          height: _panelWidth,
          alignment: Alignment(0.0,0.0),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(r % 2 == 0 ? 'assets/darksquare.png' : 'assets/whitesquare.png'),
              fit: BoxFit.fitHeight,
            ),
          ),
          child:
          ButtonTheme(
            minWidth: 10,
            child: FlatButton(
              //color: _getBoxColor(index),
              onPressed: () {
              },
              child:
              Text('',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                // style: TextStyle(
                //   fontSize: _getTextSize(index),
                //   color: textColors[index],
                // ),
              ),
            ),
          ),
        ),
      );

      widList.add(
          TableRow(
            children: rowList,
          )
      );
    }

    return (widList);
  }

  List<TableRow> getBoxes() {
    int nRow = 4;
    int nCol = 3;

    List<TableRow> widList = new List<TableRow>();

    for (int r = 0; r < nRow; r++) {
      List<Widget> rowList = new List<Widget>();
      rowList.clear();

      for (int c = 0; c < nCol; c++) {

        int index = (3*r) + c;
        //print (index.toString() + ':' + boxStr[index]);
        rowList.add(
          Container(
            margin: EdgeInsets.zero,
            width : _panelWidth,
            height: _panelWidth,
            alignment: Alignment(0.0,0.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_getBoxImage(index)),
                fit: BoxFit.cover,
              ),
            ),
            child:
            ButtonTheme(
              minWidth: _panelWidth,
              height: _panelWidth,
              child: FlatButton(
                //color: _getBoxColor(index),
                onPressed: () {
                  _callPage(index);
                },
                // child:
                // Text(_getBoxText(index),
                //   textAlign: TextAlign.center,
                //   overflow: TextOverflow.ellipsis,
                //   maxLines: 3,
                //   style: TextStyle(
                //     fontSize: _getTextSize(index),
                //     color: textColors[index],
                //   ),
                // ),
              ),
            ),
          ),
        );

      }

      widList.add(
          TableRow(
            children: rowList,
          )
      );
    }

    return (widList);
  }


  Widget displayRenderBoxes(BuildContext context) {

    return
      // Visibility(
      //   visible: globals.initComplete == false,
      //   child:

      // Expanded(
      //   child:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          // SizedBox(
          //   height: MediaQuery.of(context).size.width *0.25,
          //   width: MediaQuery.of(context).size.width *0.25,
          //   child: CircularProgressIndicator() ,
          // ),
          //
          // SizedBox(height: 20,),
          //
          // Text('Loading',
          //   style: TextStyle(
          //     color: Colors.brown,
          //     fontSize: 22,
          //   ),
          // ),

          Row(
            children: [
              Text('RNBQKO', style: TextStyle(
                  fontSize: globals.tablet ? globals.tabFontsize[globals.tid] : globals.treeFontSize,
                  color: globals.background),
                key: _keyUpper,
              ),

              Text('!1', style: TextStyle(
                  fontSize: globals.tablet ? globals.tabFontsize[globals.tid] : globals.treeFontSize,
                  color: globals.background),
                key: _keySmall,
              ),

              Text('.', style: TextStyle(
                  fontSize: globals.tablet ? globals.tabFontsize[globals.tid] : globals.treeFontSize,
                  color: globals.background),
                key: _keyDot,
              ),

              Text(' ', style: TextStyle(
                  fontSize: globals.tablet ? globals.tabFontsize[globals.tid] : globals.treeFontSize,
                  color: globals.background),
                key: _keySpace,
              ),


              Icon(globals.iconList['comment'], color: globals.background,
                size: globals.tablet ? globals.tabCommentIcon : 15,
                key: _keyIcon,
              ),

              Text('abcdefgh2345678', style: TextStyle(
                  fontSize: globals.tablet ? globals.tabFontsize[globals.tid] : globals.treeFontSize,
                  color: globals.background),
                key: _keyLower,
              ),
            ],
          ),


          Row(
            children: [

              FlatButton(
                //color: _getBoxColor(index),
                onPressed: () {
                },
                child:
                Text('Analyze',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 26,
                    color: globals.background,
                  ),
                ),
                key: _keyAnalyze26,
              ),

              FlatButton(
                //color: _getBoxColor(index),
                onPressed: () {
                },
                child:
                Text('Analyze',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 23,
                    color: globals.background,
                  ),
                ),
                key: _keyAnalyze23,
              ),
            ],
          ),

          Row(
            children: [

              FlatButton(
                //color: _getBoxColor(index),
                onPressed: () {
                },
                child:
                Text('Analyze',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 21,
                    color: globals.background,
                  ),
                ),
                key: _keyAnalyze21,
              ),


            ],
          ),

          Row(
            children: [


              FlatButton(
                //color: _getBoxColor(index),
                onPressed: () {
                },
                child:
                Text('Analyze',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 28,
                    color: globals.background,
                  ),
                ),
                key: _keyAnalyze28,
              ),

              FlatButton(
                //color: _getBoxColor(index),
                onPressed: () {
                },
                child:
                Text('Analyze',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 20,
                    color: globals.background,
                  ),
                ),
                key: _keyAnalyze20,
              ),

            ],
          ),


          Visibility(
            visible: globals.tablet == true,
            child: Row(
              children: [
                FlatButton(
                  //color: _getBoxColor(index),
                  onPressed: () {
                  },
                  child:
                  Text('Analyze',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 30,
                      color: globals.background,
                    ),
                  ),
                  key: _keyAnalyze30,
                ),

                FlatButton(
                  //color: _getBoxColor(index),
                  onPressed: () {
                  },
                  child:
                  Text('Analyze',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 32,
                      color: globals.background,
                    ),
                  ),
                  key: _keyAnalyze32,
                ),
              ],
            ),
          ),

        ],
      )
    // )
        ;

    // ),

  }

  @override
  Widget build(BuildContext context) {

    // print('In build');

    if (globals.tablet == false) {
      // Adjust App Bar and Button height based on phone size
      if (MediaQuery
          .of(context)
          .size
          .height < 800) {
        globals.smallText = true;
        globals.appBarHeight = globals.smallAppBarHeight;
        // print ('Small Height');
      }

      if (MediaQuery
          .of(context)
          .size
          .width < 390) {
        globals.smallText = true;
        // print ('Small Width');
      }

      if (MediaQuery
          .of(context)
          .size
          .height > 800) {
        globals.nextButtonHeight = globals.nextButtonHeightLarge;
        globals.bottomPadding = globals.bottomPaddingLarge;
      } else if (MediaQuery
          .of(context)
          .size
          .height > 750) {
        globals.appBarHeight = globals.mediumAppBarHeight;
      }
    }
    _panelWidth = MediaQuery.of(context).size.width *0.33;

    if (MediaQuery.of(context).size.width > 550) {

      globals.tablet = true;

      // if (MediaQuery.of(context).size.width > 900)
      //   _panelWidth = 225;
      // else if (MediaQuery.of(context).size.width > 800)
      //   _panelWidth = 200;
      // else
      //   _panelWidth = (MediaQuery.of(context).size.width) > 700 ? 175 : 150;
      //

      if (MediaQuery.of(context).size.width >= 950)
        globals.tid = 3;
      else if (MediaQuery.of(context).size.width >= 800)
        globals.tid = 2;
      else if (MediaQuery.of(context).size.width >= 725)
        globals.tid = 1;
      else
        globals.tid = 0;

      _panelWidth = globals.tabPanelWidth[globals.tid];

      if (MediaQuery.of(context).size.width > 5*_panelWidth) {
        _panelWidth = MediaQuery.of(context).size.width/5;
      }

      //print ('tid = ' + globals.tid.toString());
    }

    // print ('In build, _panelWidth = ' + _panelWidth.toString() + ', menuFontSize = ' + globals.menuFontsize.toString());

    double topSpace = (MediaQuery.of(context).size.height - (_panelWidth * 4) - globals.appBarHeight - globals.bottomPadding);
    double _imageHeight = topSpace * 0.75;

    // print ('Screen width: ' + MediaQuery.of(context).size.width.toString() + ' Screen height: ' + MediaQuery.of(context).size.height.toString());
    // print ('AppBar height' + globals.appBarHeight.toString());

    /*
    AppBar appBar;

      if (globals.tablet) {
        appBar = AppBar(
          centerTitle: true,
          title: Text(widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: globals.tablet ? globals.menuFontsize : globals
                  .appBartextSize,
            ),
          ),

          leading: new IconButton(
              icon: new Icon(Icons.arrow_back,
                  // size: globals.tablet ? globals.menuFontsize * 1.5 : globals.submenuFontsize,
                  size: globals.appBarIconFlex, //globals.iconFlex,
                  color: Colors.white),
              onPressed: () => {
                _scaffoldKey.currentState.openDrawer(),
              }
          ),

          actions: <Widget>[

            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => SetLevel(0),
                    ));
              },
              icon: Icon(Icons.settings, color: Colors.white,
                size: globals.appBarIconFlex,
              ),
            ),
          ],
        );
      } else {
        appBar = AppBar(
          centerTitle: true,
          title: Text(widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: globals.tablet ? globals.menuFontsize : globals.appBartextSize,

            ),
          ),

          actions: <Widget>[

            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => SetLevel(0),
                    ));
              },
              icon: Icon(Icons.settings, color: Colors.white),
            ),
          ],
        );
      }

     */

    //print ('Height of AppBar: ' + appBar.preferredSize.height.toString());

    return Scaffold(
      //backgroundColor: Color.fromARGB(255, 255, 237, 213), //a=255 = opaque
      //backgroundColor: _mocha,
      key: _scaffoldKey,
      backgroundColor: _background,
      resizeToAvoidBottomPadding: false,
      drawer: new Drawer(
        child:
        Container(
          color: globals.background,
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text('Chess Prof',
                  style: TextStyle(
                    fontSize: globals.tablet ? globals.menuFontsize : globals.submenuFontsize, //18,
                  ),
                ),
                accountEmail: Text(''),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('assets/logo.png'),
                  backgroundColor: globals.background,
                ),
              ),
              ListTile(
                title: Text('How To',
                  style: TextStyle(
                    fontSize: globals.regularTextFlex, //18,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => HowtoPage(),
                      ));
                },
              ),

              Divider(
                color: Colors.black,
                height: 3.0,
              ),

              ListTile(
                title: Text('About Page',
                  style: TextStyle(
                    fontSize: globals.regularTextFlex, //18,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => AboutPage(),
                      ));
                },
              ),

              Divider(
                color: Colors.black,
                height: 3.0,
              ),
              ListTile(
                title: Text('Feedback',
                  style: TextStyle(
                    fontSize: globals.regularTextFlex, //18,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => FeedbackPage(),
                      ));
                },
              ),
              Divider(
                color: Colors.black,
                height: 3.0,
              ),
              ListTile(
                title: Text('Sign Out',
                  style: TextStyle(
                    fontSize: globals.regularTextFlex, //18,
                  ),
                ),
                onTap: () {
                  setState(() {
                    globals.logout();
                  });
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        ),
      ),
      body:
      Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            SizedBox(
              height: globals.appBarHeight,
              child: AppBar(
                centerTitle: true,
                title: Text(widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: globals.tablet ? globals.menuFontsize : globals.appBartextSize,
                  ),
                ),

                leading: new IconButton(
                    icon: new Icon(Icons.menu,
                        // size: globals.tablet ? globals.menuFontsize * 1.5 : globals.submenuFontsize,
                        //size: globals.appBarIconFlex, //globals.iconFlex,
                        size: globals.tablet ? globals.menuFontsize : globals.appBarIconFlex + 3,
                        color: Colors.white),
                    onPressed: () => {
                      //Scaffold.of(context).openDrawer(),
                      _scaffoldKey.currentState.openDrawer(),
                    }
                ),

                actions: <Widget>[

                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => SetLevel(0),
                          ));
                    },
                    icon: Icon(Icons.settings, color: Colors.white,
                      size: globals.tablet ? globals.appBarIconFlex : 24,
                    ),
                  ),
                ],

              ),
            ),

            // SizedBox(height: 5,),

            // CircleAvatar(
            //   backgroundImage: AssetImage('assets/logo.jpeg'),
            // ),

            Container(
              margin: const EdgeInsets.all(10.0),
              height: MediaQuery.of(context).size.height - globals.appBarHeight - 20,
              child:
              // Scrollbar(
              //   controller: _scrollController,
              //   //isAlwaysShown: true,
              //   child: SingleChildScrollView(
              //     controller: _scrollController,

              ListView(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  // child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      Container(
                        height: topSpace,
                        child:
                        Center(
                          child: Image.asset('assets/logo_display.png',
                            height: _imageHeight,
                            width: _imageHeight,
                          ),
                        ),
                      ),

                      // SizedBox(height: 5,),


                      //
                      // Visibility(
                      //   visible: globals.initComplete == true,
                      //   child:

                      // Expanded(
                      //   child:
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[

                          Container(
                            width: MediaQuery.of(context).size.width,
                            //_panelWidth*3,
                            margin: EdgeInsets.zero,
                            child: getTable(context),
                          ),

                          SizedBox(height: globals.bottomPadding),

                        ],
                      ),
                      // ),

                      // ),

                      displayRenderBoxes(context),

                    ],
                  ),

                  //   ),
                  // ),
                ],
              ),
            ),


          ],
        ),


      ),

    );

  }
}
