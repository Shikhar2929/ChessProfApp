import 'package:flutter/material.dart';
import './global.dart' as globals;

class HowtoPage extends StatefulWidget {
  HowtoPage({Key key}) : super(key: key);

  @override
  _HowtoPageState createState() => _HowtoPageState();
}

class _HowtoPageState extends State<HowtoPage> {
  ScrollController _scrollController = new ScrollController();
  // TabController _tabController = new TabController();

  double _treeFontSize = 13.0;

  @override
  void initState() {
    super.initState();
    if (globals.tablet) {
      _treeFontSize = globals.tabFontsize[globals.tid];
    }
  }

  //double _textSize = 16;

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
            'How to use ChessProf',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: globals.appBarTextFlex,
            ),
          ),
          //automaticallyImplyLeading: false, // hides leading widget
          bottom: TabBar(
            indicatorColor: Colors.brown,
            labelColor: Colors.brown,
            unselectedLabelColor: globals.background,
            labelPadding: const EdgeInsets.all(0.0),
            labelStyle: TextStyle(
            fontSize: _treeFontSize + 2, //globals.appBartextSize,
          ),
            indicator: BoxDecoration(
              //borderRadius: BorderRadius.circular(50),
                color: globals.background),
            tabs: <Widget> [
              Tab(text: 'Summary'),
              Tab(text: 'Learn'), //icon: Icon(Icons.music_note)),
              Tab(text: 'Analyze'), //icon: Icon(Icons.search)),
              Tab(text: 'Save &\nSubmit'), //icon: Icon(Icons.search)),
            ],
          ),
        );
    } else {
      return
        AppBar(
          centerTitle: true,
          title: Text(
            'How to use ChessProf',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: globals.appBartextSize,
            ),
          ),
          //automaticallyImplyLeading: false, // hides leading widget
          bottom: TabBar(
            indicatorColor: Colors.brown,
            labelColor: Colors.brown,
            unselectedLabelColor: globals.background,
            labelPadding: const EdgeInsets.all(0.0),
            indicator: BoxDecoration(
              //borderRadius: BorderRadius.circular(50),
                color: globals.background),
            tabs: <Widget> [
              Tab(text: 'Summary'), //icon: Icon(Icons.favorite)),
              Tab(text: 'Learn'), //icon: Icon(Icons.music_note)),
              Tab(text: 'Analyze'), //icon: Icon(Icons.search)),
              Tab(text: 'Save &\nSubmit'), //icon: Icon(Icons.search)),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: globals.background,
          resizeToAvoidBottomPadding: false,
          appBar:
          PreferredSize(
              preferredSize:  Size.fromHeight(globals.smallAppBarHeight * 1.75),
              child:
              getAppBar(),
          ),

          body: TabBarView(
            // controller: _tabController,
            children: [

              // Summary
              Container(
                margin: const EdgeInsets.all(10.0),
                height: MediaQuery.of(context).size.height - (globals.appBarHeight * 2) - 50,
                child:
                Scrollbar(
                  controller: _scrollController,
                  //isAlwaysShown: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child:
                    Text(globals.howtoText1,
                      style : TextStyle (
                        fontSize: globals.tablet ? _treeFontSize + 2 : globals.textsize,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 100,
                    ),
                  ),
                ),
              ),

              // Learn
              Container(
                margin: const EdgeInsets.all(10.0),
                height: MediaQuery.of(context).size.height - (globals.appBarHeight * 2) - 50,
                child:
                Scrollbar(
                  controller: _scrollController,
                  //isAlwaysShown: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child:
                    Text(globals.howtoText2,
                      style : TextStyle (
                        fontSize: globals.tablet ? _treeFontSize + 2 : globals.textsize,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 100,
                    ),
                  ),
                ),
              ),

              // Analyze
              Container(
                margin: const EdgeInsets.all(10.0),
                height: MediaQuery.of(context).size.height - (globals.appBarHeight * 2) - 50,
                child:
                Scrollbar(
                  controller: _scrollController,
                  //isAlwaysShown: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Text(globals.howtoText3,
                          style : TextStyle (
                            fontSize: globals.tablet ? _treeFontSize + 2 : globals.textsize,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 100,
                        ),

                        SizedBox(height: 15),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.brown,
                            border: Border.all(
                              width: 1,
                            ),
                          ),
                          child: Image.asset('assets/analysisbuttons.png',
                            // height: _imageHeight,
                            // width: _imageHeight,
                          ),
                        ),

                        SizedBox(height: 15),

                        Text(globals.howtoText3_para2,
                          style : TextStyle (
                            fontSize: globals.tablet ? _treeFontSize + 2 : globals.textsize,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 100,
                        ),

                      ],
                    ),
                  ),
                ),
              ),


              // Save/Submit
              Container(
                margin: const EdgeInsets.all(10.0),
                height: MediaQuery.of(context).size.height - (globals.appBarHeight * 2) - 50,
                child:
                Scrollbar(
                  controller: _scrollController,
                  //isAlwaysShown: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Text(globals.howtoText4,
                          style : TextStyle (
                            fontSize: globals.tablet ? _treeFontSize + 2 : globals.textsize,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 100,
                        ),

                        SizedBox(height: 10),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.brown,
                            border: Border.all(
                              width: 1,
                            ),
                          ),
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Image.asset('assets/saveoptions.png',
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(globals.howtoText4_para2,
                          style : TextStyle (
                            fontSize: globals.tablet ? _treeFontSize + 2 : globals.textsize,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 100,
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
