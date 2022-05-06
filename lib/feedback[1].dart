import 'package:flutter/material.dart';
import './global.dart' as globals;

class FeedbackPage extends StatefulWidget {
  FeedbackPage({Key key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  ScrollController _scrollController = new ScrollController();
  double _treeFontSize = 13.0;

  @override
  void initState() {
    super.initState();
    if (globals.tablet) {
      _treeFontSize = globals.tabFontsize[globals.tid];
    }
  }

  AppBar getAppBar() {
    if (globals.tablet) {
      return
      AppBar(
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
        title: Text(
          'Feedback',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: globals.appBarTextFlex,
          ),
        ),
      );
    } else {
      return
        AppBar(
          centerTitle: true,
          title: Text(
            'Feedback',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: globals.appBartextSize,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: globals.background,
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

            Container(
              margin: const EdgeInsets.all(10.0),
              height: MediaQuery.of(context).size.height - globals.appBarHeight - 20,
              child:
              Scrollbar(
                controller: _scrollController,
                //isAlwaysShown: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child:
                Text(globals.feedbackText,
                  style : TextStyle (
                    fontSize: globals.tablet ? _treeFontSize + 2 : globals.textsize,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 100,
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
