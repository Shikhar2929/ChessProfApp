library globals;

import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:device_info/device_info.dart';
import 'package:intl/intl.dart';

import './about.dart';
import './beginner.dart';
import './intermediate.dart';
import './novice.dart';
import './advanced.dart';
import './master.dart';
import './setlevel.dart';

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
};

Map resultList = {
  'won' : '1-0',
  'lost' : '0-1',
  'draw' : '1/2-1/2',
  'line' : '',
  '' : '',
};

class Userid {
  String authuserid = '';
  int authtype = 0; // 0 - Guest, 1 - Google, 2 - Device, 3 - Password
}

Userid uid = new Userid();
String lastSavedGame = '';

int skillLevel = -1; // 0 - Beginner, 1 - Novice, 2 - Intermediate, 3 - Advanced, 4 - Master
List<String> skillList = ['Beginner', 'Novice', 'Intermediate', 'Advanced', 'Master'];
int numLevelsAllowed = 4;

//StreamController streamControllerUserid = new StreamController();

bool validateEmail(String emailStr) {
  return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailStr);
}

bool isLoggedIn() {
  return (uid.authuserid != null && uid.authuserid.isNotEmpty);
}

String getuser() {
  return ((uid.authuserid == null || uid.authuserid.isEmpty) ? "Guest" : uid.authuserid);
}

String getSkillLevelTitle() {
  if (skillLevel == -1)
    return '';
  else
    return skillList[skillLevel];
}

String getUserText() {
  String text;
  switch (uid.authtype) {
    case 1:
    case 3:
      text = 'Logged in as ' + uid.authuserid;
      break;
    case 2:
      text = 'Logged in this device';
      break;
    case 0 :
    default:
      text = 'Guest';
      break;
  }
  return ((uid.authuserid == null || uid.authuserid.isEmpty) ? "Guest" : uid.authuserid);
}

String logout() {
  uid.authuserid = '';
  uid.authtype = 0;
}

Color background = Color.fromARGB(255, 255, 237, 213); //a=255 = opaque FFEDD5
Color highlight = Colors.amberAccent;
Color mocha = Color.fromARGB(255, 192, 107, 0);
//List<Color> anTextColor = [Colors.black, Colors.black54, Colors.black45, Colors.black38, Colors.black38, Colors.black38, Colors.black38,];
List<Color> anTextColor = [Colors.black, Colors.black54, Colors.black45, Colors.black38, Colors.black38, Colors.black38, Colors.black38,];


List<String> indent = ['', '  ', '    ','      ','        ', '          ', '            ', '              ',];
List<String> dot = ['.', '...'];
//List<FontStyle> style = [FontStyle.normal, FontStyle.italic, FontStyle.italic, FontStyle.italic, FontStyle.italic, FontStyle.italic, FontStyle.italic, FontStyle.italic ];
List<FontStyle> style = [FontStyle.normal, FontStyle.normal, FontStyle.normal, FontStyle.normal, FontStyle.normal, FontStyle.normal, FontStyle.normal, FontStyle.normal ];
List<int> _delList = new List<int>();
List<String> qualityList = ['?', '!', ''];

double nextButtonHeight = 20.0;
double nextButtonHeightLarge = 30.0;
double nextButtonWidth = 50.0;
double appBarHeight = 85; // 90.0;
double mediumAppBarHeight = 65; // 60.0;
double smallAppBarHeight = 55; // 60.0;
double appBartextSize = 18.0;
double bottomPadding = 2;
double bottomPaddingLarge = 25;
double navBarHeight = 40.0;
double spacer = 25.0;
double buttonHeight = 40;
double treeFontSize = 13.0; //
double menuIconHeight = 18;
double rowHeight = 20.0;
double selectButtonHeight = 40;
double gap = 20.0;
double textsize = 16.0; //
double textsizeMedium = 13.0; //
double textheight = 60.0;
double welcometextheight = 80.0;
double smallspacer = 5.0;
double widebutton = 300.0;
double minPgnHeight = 112.0;
double characterwidth = 6.6;
double capsMult = 0.25;
double minCharBox = 10.0;

double menuFontsize = 26.0; // to be updated based on available size
double submenuFontsize = 18.0;
double regularTextFlex = 18.0;
double appBarTextFlex = 18.0;
double appBarIconFlex = 18.0;

// TABLET parameters
bool tablet = false;
int tid = 0; // type of tablet
List<double> tabPanelWidth = [150.0, 175.0, 200.0, 225.0];
List<double> tabFontsize = [18, 18, 20, 22];
List<double> tabIconsize = [26, 28, 32, 32];
List<double> tabMultiplier = [0.8, 0.7, 0.8, 0.7];
List<double> tabButtonHeight = [50, 50, 60, 60];
List<double> tabNextButtonHeight = [30, 35, 50, 50];
List<double> tabRowHeight = [21, 21, 23.5, 26];
double tabCommentIcon = 22;


double sizeUpper;
double sizeLower;
double sizeIcon;
double sizeSmall;
double sizeDot;
double sizeSpace;
double sizeAnalyze32;
double sizeAnalyze30;
double sizeAnalyze28;
double sizeAnalyze26;
double sizeAnalyze23;
double sizeAnalyze21;
double sizeAnalyze20;

Map initGamesTitle = {
  'beginner' : 'Point Value of Pieces',
  'novice' : 'Develop and Attack',
  'intermediate' : 'Dominating with Catalan',
  'master' : 'Benoni and space',
  'advanced' : 'Capablanca vs. Villegas',
};

Map initGamesMoves = {
  'beginner' : '[Event "?"] [Site "?"] [Date "2020.11.12"] [Round "?"] [White "Point Values of the pieces "] [Black "?"] [Result "*"] [ECO "C50"] [PlyCount "19"]  1. e4 {The game today will talk about piece values. As a beginner, it can be difficult to make decisions without a clear knowledge of what each piece is valued at. In this game, I will outline the value of pieces and show some trades to help you begin to count and begin to value each piece accurately.} e5 {A pawn is the weakest piece, valued at only 1 point. They are the most expendable pieces and can often be used as sacrificial material. But they are important! Take care of your pawns, because 8 pawns are 8 points.} 2. Nf3 { Following pawns, Knights are least valuable at 3 points. Knights  struggle to move across the entire board quickly, which can make them weaker than other pieces.} Nc6 3. Bc4 {Bishops are value at 3.5 points. This means that they are slightly more valuable than knights, because they have long range mobility. However, they can only remain on one type of square (white or dark) so they are not as powerful as rooks or queens.} Bc5 4. O-O {What about the king? The King generally is not given a value because you cant trade the king- otherwise you lose the game!} Nf6 5. Nc3 O-O 6. Re1 {The rooks are worth 5 points, because they can access any square on the chessboard and are usually stronger than bishops. Since they can only go through the rows and columns, they are not as strong as the queen, which is the ultimate piece.} d6 7. d3 Bg4 {Would trading the white squared bishop for the knight be favorable? White would get 3.5 points for 3, so there is a slight advantage. However, the trade is about equal} 8. h3 Bxf3 9. Qxf3 Nd7 10. Be3 {/Trade/ White is offering a trade of the bishops. They are approximately equal in value, so the trade is the same value for both white and black.} (10. Bxf7+ {/Count attackers and defenders/ In chess, there is a general rule: There must be more attackers than defenders to win a piece. Here, the bishop and queen make two attackers for white. But black has 2 defenders: rook and king so white cannot take the pawn successfully. I will go over this concept in depth in the next game.} Rxf7 {Black got 3 white points, whereas white only got 1 black point. This means that black won the trade.}) (10. d4)',
  'novice' : '[Event "?"] [Site "?"] [Date "2020.10.25"] [Round "?"] [White "Shikhar"] [Black "?"] [Result "1-0"] [ECO "C01"] [PlyCount "47"]  1. d4 e5 2. e3 (2. dxe5 {is a good move- NO FEAR} Nc6 3. Nf3 Qe7 4. Bf4 Qb4+ 5. Bd2 Qxb2 6. Nc3 {And white will win very easily}) 2... exd4 3. exd4 Nf6 4. Nf3 d5 {So far my opponent has played very well- better than me. He has developed his pieces and taken the center} 5. c4 Be6 6. cxd5 Qxd5 {Weak Move. Dont move queen out early, blocks pieces and loses tempos.} 7. Nc3 {/3/} Bb4 8. Bd3 {/1/ I think this move is a very mature move for the rating level that I was at. Outdeveloping is how you win games.} Bxc3+ {Weak move, because white has a weakness on d4. Taking on c3 allows white to reinforce the weak pawn.} 9. bxc3 Nc6 10. O-O {I am now better because I have outdeveloped my opponent. Higher king safety and easy mobility for the pieces.} Ng4 \$2 {What does this move accomplish? Attacking before Development- not good.} (10... O-O {And white is better but has to prove it. Possible continuations are Bf4, Bg5, Re1, and Ne5}) 11. Ng5 \$1 {/4/This may seem the same as Ng4, but it is very different. It has an immediate threat which is difficult for black to stop. Black pays for under development.} h6 \$2 12. Nxe6 {/TT/} fxe6 13. Qxg4 O-O-O 14. Re1 Rhe8 15. Bf4 { Continue to develop} h5 16. Qxg7 Ne7 17. Rab1 Rd7 18. Be4 {/2/} Qc4 19. Bxb7+ Kd8 20. Qe5 h4 21. Qxe6 Qxc3 22. Bc6 {Nice cute tactics to finish the game off} Qxc6 (22... Nxc6 23. Qxe8#) (22... Rd6 23. Rb8+) 23. Rb8+ Nc8 24. Qxe8#',
  'intermediate' : '[Event "Intermediate 4"] [Site "?"] [Date "2018.07.22"] [Round "?"] [White "Shikhar"] [Black "Chinnambeti , A."] [Result "1-0"] [ECO "E08"] [PlyCount "53"]  1. d4 Nf6 2. c4 e6 3. Nf3 d5 4. g3 Be7 5. Bg2 O-O 6. O-O Nbd7 \$6 (6... dxc4 { Why is this necessary? Look at whites plan. Qc2, Nbd2, and e4. Now, this plan takes time to happen, because black takes the center}) 7. Qc2 a6 \$6 (7... c5 { Is the only reasonable move, challenging the center} 8. cxd5 Nxd5 9. a3 cxd4 10. Nxd4 N7b6 11. Rd1 Bd7 12. e4 Rc8 13. Qe2 Nf6 14. Nc3 {And white is slightly better}) 8. Nbd2 c5 {Too late} 9. cxd5 Nxd5 (9... exd5 10. dxc5 { Gives black IQP}) 10. a3 {/1/} (10. Rd1 \$6 Nb4 11. Qb1 {Wastes time and space}) 10... cxd4 11. Nxd4 Bf6 12. N2b3 (12. N4b3) 12... Qb6 13. Rd1 Bxd4 14. Rxd4 { Great Move, for several reasons.   1. e5 cant happen because of Rxd5. Preventing and Avoiding opponents counterplay.   2. Immediate threat on Knight d5. Gains a Tempo   3. Takes the open file  4. Allows Knight to have options of c5.} Qc7 (14... N7f6 15. Nc5 {All pieces are coordinating and attacking, white is +-}) 15. Qxc7 Nxc7 16. Na5 \$1 {/TT/ It is important to be careful and slow, even when you are winning. The alternative, Bxb7, wins a pawn but makes the endgame much harder to win. Why develop your opponents pieces for them?} ( 16. Bxb7 \$2 Bxb7 17. Rxd7 Rad8 \$1 {White pieces are undeveloped} 18. Rxd8 Rxd8 19. Be3 Nd5 20. Na5 Ba8 \$14) 16... Nb5 17. Rd1 Nc5 18. Be3 Na4 19. Rab1 e5 20. Nxb7 Rb8 21. Nc5 Nxc5 22. Bxc5 Re8 23. Bc6 {/1/} Bf5 24. Bxe8 {/TT/ Just pure tactics and calculation here} Bxb1 25. Bxb5 Bc2 26. Rd2 axb5 27. Rxc2',
  'master' : '[Event "ICC"] [Site "Internet Chess Club"] [Date "2020.10.14"] [Round "?"] [White "fork321"] [Black "oranalyst"] [Result "1-0"] [ECO "A75"] [WhiteElo "1919"] [BlackElo "1773"] [PlyCount "71"] [EventDate "2020.??.??"] [TimeControl "3600"]  1. d4 Nf6 2. c4 e6 3. Nf3 c5 4. d5 exd5 5. cxd5 d6 6. Nc3 a6 7. a4 {Point of a4 is to prevent b5, permanently. It is a trade off: black gains some potential weakness but white keeps a large space advantage} g6 8. e4 (8. h3 { Avoids Bg4, which might be the best way to go. Might seem like a waste of time, but Bishop can go directly to e3.}) 8... Bg4 9. Be2 Bxf3 10. Bxf3 {Another trade off between Bishop Pair and Knights. Knights seem to be more favorable, but he gaveup white squared bishop which is good bishop} Nbd7 11. O-O Bg7 12. a5 O-O 13. Bf4 {/3/ Plan is to play Re1, Qc2, h3, Be3 or Bh2, Be2, and f4. May seem long term, but blac needs to prove that the position is legitimate} (13. Be3 {is more accurate. Bishop has no use on f4 after Ne5 and has to retreat to e3. This saves a tempo.}) 13... Qe7 14. Re1 Ne5 15. Be2 Rfe8 16. h3 Rac8 17. Qc2 Qc7 18. Ra4 \$1 {I thought that this was a creative and interesting idea for a couple of reasons.   1. Rook stays on a-file protecting the pawn.   2. Rook activates itself without any loss of tempos bc trade of bishop for knight 3. White overprotects e4, the main weak point in the game  4. White stops opponents counterplay, which is to play c4.} h5 \$2 {What does this move accomplish? Creates weakness along f-file for my pawns to attack. Stops g4, which is not a primary plan. At this point, evaluation should be +-} 19. Be3 Nh7 20. f4 Nd7 21. e5 {/TT/} (21. f5) 21... dxe5 {/3/ Idea is to play f5, and then Ne4.} 22. f5 e4 \$2 (22... Nhf8 {Cant give back pawn, which is the only black compensation in the position. Position is terrible, but at least white must play accurately to win}) 23. fxg6 fxg6 24. Nxe4 Qe5 25. Bd3 c4 26. Rxc4 Rxc4 27. Qxc4 Kh8 28. d6 Qe6 29. Qxe6 Rxe6 30. Rc1 Be5 31. Rc7 Nhf8 32. Ng5 Rf6 33. Rxb7 Bxd6 34. b4 (34. Bd4 Bc5) 34... Bf4 35. Bxf4 Rxf4 36. Bxa6',
  'advanced' : '[Event "?"] [Site "?"] [Date "2017.02.13"] [Round "?"] [White "Capablanca"] [Black "Villegas"] [Result "1-0"] [ECO "D11"] [PlyCount "65"]  1. d4 d5 2. Nf3 Nf6 3. e3 {Some Context to this game. This is a game by Capablanca, who was one of the early World Champions. He was a monster endgame player, so he tried to trade off pieces in order to get to the endgame as fast as possible. His openings are not the best, but his endings are very instructive} c6 4. Bd3 Bg4 5. c4 e6 6. Nbd2 Nbd7 7. O-O Be7 8. Qc2 {Here white is slightly better. Black has a decent position, which is slightly passive, mainly with the threat of e4 coming in. This move develops and unpins the queen, and continues to take the center} Bh5 9. b3 Bg6 10. Bb2 Bxd3 11. Qxd3 { In the last three moves, black has develop 0 pieces, and white has develop his dark squared bishop. The While Black got to get rid of the white squared bishop, his lack of central development will be exploited soon} O-O 12. Rae1 { /5/ The reason he played the rook on a to e1 is to support a future f4 f5 try. Rooks have no purpose on the c and d files, because they are not opening up} Qc7 13. e4 {All of whites pieces are fully developed, so it is time to take the center with e4} dxe4 14. Nxe4 Nxe4 15. Rxe4 {Allowing the other rook to potentially be develop into the c, d, or e-files} Bf6 16. Qe3 c5 17. Ne5 { Activating the knight to a better square, and keeping black in a cramped position} cxd4 18. Nxd7 {Black cant take on d3 because of Nxf6 followed by checkmate with the coordination of the three pieces} (18. Qxd4) 18... Qxd7 ( 18... dxe3 19. Nxf6+ Kh8 (19... gxf6 20. Rg4+ Kh8 21. Bxf6#) 20. Rh4 h6 21. Rxh6+ \$1 gxh6 22. Nd5+ Kg8 23. Nxc7) 19. Bxd4 Bxd4 20. Rxd4 {/1/} Qc7 21. Rfd1 {Taking full control of the d-file} Rfd8 22. b4 \$1 {White can now proceed to turn the queenside majority into passed pawns} (22. Rxd8+ Rxd8 23. Rxd8+ Qxd8 24. Qxa7 Qd1#) 22... Rxd4 23. Qxd4 b6 {The black rook must activate} 24. g3 Rc8 25. Rc1 Rd8 26. Qe3 \$1 {Capablanca is using the method, as shown here  He has let go of his control of a now useless d file  He has given his passed pawn a clear path  Blacks counterplay is not clear, as Black cannot get to the second rank, leaving Black with little counterplay} Kf8 27. c5 bxc5 (27... Qc6 {would stop the pawn in its track and freeze whites pieces}) 28. Qe4 \$1 { Takes the a8-h1 diagonal, which could have been a potential mate in the future. White also prevents a queen blockade on c6} Rd5 29. bxc5 g6 (29... Rxc5 \$2 30. Qb4) 30. c6 Kg7 (30... Ke7 31. Qh4+ Kd6 32. Qb4+ Ke5 33. Qf4#) 31. a4 \$1 {Idea is to allow the Qb4 idea, because at the end of the variation black had Rb5} ( 31. Qb4 h6 32. Qb7 Qxb7 33. cxb7 Rb5) 31... Rd6 {Seems to be a blockade.....} 32. Qe5+ Kf8 33. Qxd6+ \$1 {/TT/ And white is easily promoting} (33. Qxd6+ Qxd6 34. c7)',
};

String errorStr = 'Sorry your device is not able to connect to Google Firestore. Please report this to chessprof.chess@gmail.com with the OS version of your device.';

double getRenderLength(String s) {
  if (s.isEmpty)
    return 0;

  double len = 0;

  for (int i = 0; i < s.length; i++) {
    // String letter = s.substring(i,i);
    String letter = s[i];
    switch (letter) {
      case 'R':
      case 'N':
      case 'B':
      case 'Q':
      case 'K':
      case 'O':
        len += sizeUpper + 0.5;
        break;
      case '1':
      case '!':
        len += sizeSmall + 0.5;
        break;
      case '.':
        len += sizeDot + 0.5;
        break;
      case ' ':
        len += sizeSpace + 0.5;
        break;
      default:
        len += sizeLower + 0.5;
        break;
    }
  }

  return len;
}
bool smallText = false;

double widgeButtonMultipler = 0.80;
double chessboardMultipier = 0.91;

List<String> result = ['won','lost','draw','line'];

FirebaseApp firebaseApp; // = new FirebaseApp(name: 'chessprinciplescoach-33205');
FirebaseAuth firebaseAuthGlobal; // = FirebaseAuth.fromApp(firebaseApp);
Firestore firestore; // = Firestore(app: firebaseApp);
GoogleSignIn googleSignInGlobal = new GoogleSignIn();


bool initComplete = false;

void initConnections() async {
  firebaseApp = await FirebaseApp.configure(
    name: 'ChessPrinciplesCoach',
    options: FirebaseOptions(
      projectID: 'chessprinciplescoach-33205',
      bundleID: 'com.nj.montgomery.chessprinciples',
      apiKey: 'AIzaSyDasV9QE0FPVRkXAe31KpFynRXvFpiJfLE',
      googleAppID: Platform.isAndroid ? '1:257699013416:android:e64cf31f8ddc28f3c4661d' : '1:257699013416:ios:06bbaa4c50463ed9c4661d',

    ),
  );

//  firebaseApp = await FirebaseApp.appNamed('1:257699013416:android:e64cf31f8ddc28f3c4661d');
//  await Future.delayed(Duration(seconds: 2));
  firestore = await Firestore(app: firebaseApp);
  firebaseAuthGlobal = await FirebaseAuth.fromApp(firebaseApp);
  //googleSignInGlobal = await GoogleSignIn();
  await loginWithUserPwd('chessprinciples.chess@gmail.com', 'Kajsdhkjshdfkasdhflaskjdhf98978979797kjhkahkhkjshdf97987978kjkjhjkh');

}


void emailPgn(String to, String pgn, String docId, bool external) async {
  // print ('In emailPgn');
  // print(pgn);

  String _stamp = DateFormat.yMd().add_jm().format(DateTime.now());
  String _subject;

  if (external == true) {
    _subject = uid.authuserid + ' has sent you a chess game to review';
  } else {
    _subject = 'Submitted for ChessProf analysis, docId =  ' + docId;
  }
  // attachments: [
  // {   // utf-8 string as an attachment
  // filename: 'text1.txt',
  // content: 'hello world!'
  // },

  String _filename = _stamp + '.pgn'; //uid.authuserid +
  List<String> namAttachment = new List<String>();
  namAttachment.add('filename');
  namAttachment.add('content');

  List<String> valAttachment = new List<String>();
  valAttachment.add(_filename);
  valAttachment.add(pgn);

  Map<String, dynamic> attachmentData = new Map.fromIterables(namAttachment, valAttachment);


  List<String> namMessage = new List<String>();
  namMessage.add('subject');
  namMessage.add('html');
  namMessage.add('attachments');


  List<dynamic> valMessage = new List<dynamic>();
  valMessage.add(_subject);
  valMessage.add(pgn);
  valMessage.add(attachmentData);

  Map<String, dynamic> messageData = new Map.fromIterables(namMessage, valMessage);
  //print(messageData['html']);

  List<String> namL = new List<String>();
  namL.add('timestamp');
  namL.add('to');
  namL.add('from');
  namL.add('replyTo');
  namL.add('message');

  List<dynamic> valL = new List<dynamic>();
  valL.add(_stamp);
  valL.add(to);
  valL.add('chessprof.chess@gmail.com');
  valL.add('chessprof.chess@gmail.com');
  valL.add(messageData);

  Map<String, dynamic> pData = new Map.fromIterables(namL, valL);

  CollectionReference collectionReference = await firestore.collection('chessmail');

  if (collectionReference == null) {
    print ('Invalid collection reference');
  }
  try {
    collectionReference.add(
        pData
    );
    //print ('Sent mail');
  } on PlatformException catch (e) {
    print(getMessageFromErrorCode(e.code));
  }

}

loginWithUserPwd(String emailStr, String passwordStr) async {
  FirebaseUser firebaseUser;
  try {
    await firebaseAuthGlobal.signInWithEmailAndPassword(email: emailStr, password: passwordStr).then((authResult) {
    });
  } on PlatformException catch (e) {
    print ('exception' + '|' + e.code + '|' + e.message);
  }
}

gotoPracticePage(BuildContext context, int skill, String startGame) {
  skillLevel = skill;

  // 0 - Beginner, 1 - Novice, 2 - Intermediate, 3 - Advanced, 4 - Master
  switch (skill) {
    case 0 :
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => BeginnerPage(startGame),
          ));
      break;
    case 2 :
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => IntermediatePage(startGame),
          ));
      break;
    case 3 :
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => AdvancedPage(startGame),
          ));
      break;
    case 4 :
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MasterPage(startGame),
          ));
      break;
    case 1:
    default:
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => NovicePage(startGame),
          ));
      break;
  }
}

String getMessageFromErrorCode(String errorCode) {
  switch (errorCode) {
    case "ERROR_EMAIL_ALREADY_IN_USE":
    case "account-exists-with-different-credential":
    case "email-already-in-use":
      return "Email already used. Go to login page.";
      break;
    case "ERROR_WRONG_PASSWORD":
    case "wrong-password":
      return "Wrong email/password combination.";
      break;
    case "ERROR_USER_NOT_FOUND":
    case "user-not-found":
      return "No user found with this email.";
      break;
    case "ERROR_USER_DISABLED":
    case "user-disabled":
      return "User disabled.";
      break;
    case "ERROR_TOO_MANY_REQUESTS":
    case "operation-not-allowed":
      return "Too many requests to log into this account.";
      break;
    case "ERROR_OPERATION_NOT_ALLOWED":
    case "operation-not-allowed":
      return "Server error, please try again later.";
      break;
    case "ERROR_INVALID_EMAIL":
    case "invalid-email":
      return "Email address is invalid.";
      break;
    case "ERROR_USER_NOT_FOUND":
    case "user-not-found":
      return "No account found with this email";
      break;
    default:
      return "Login failed. Please try again.";
      break;
  }
}

void setAndSaveUserPosition(String id) async {
  if (id == null || id.isEmpty)
    return;

  lastSavedGame = id;

  saveUserPosition();
}

void saveUserPosition() async {
  //print ('In saveUserPosition, ' + skillLevel.toString() + ',' + lastSavedGame);

  CollectionReference collectionReference = await firestore.collection('users');

  if (uid.authuserid == null || uid.authuserid.isEmpty)
    return;

  //print ('Saving');
  await collectionReference.document(uid.authuserid).setData({
    'level': skillLevel.toString(),
    'lastgame' : lastSavedGame,
  });
}

String getLastSavedGame() {
  return lastSavedGame == null ? '' : lastSavedGame;
}

Future<bool> checkRetrieveUserRecord() async {
  CollectionReference collectionReference = await firestore.collection('users');

  if (uid.authuserid == null || uid.authuserid.isEmpty)
    return false;

  DocumentSnapshot doc = await collectionReference.document(uid.authuserid).get();

  if (doc == null)
    return false;

  Map val = doc.data;
  String last;
  String lev;
  int level;

  if (val == null || val.isEmpty)
    return false;

  last = val['lastgame'];
  lev = val['level'];

  // overwrite only if not already set in this session
  if (lastSavedGame.isEmpty)
    lastSavedGame = last;

  if (skillLevel == -1) {
    level = int.parse(lev);
    if (level >= 0 && level < numLevelsAllowed)
      skillLevel = level;
  }

  return true;
}

String feedbackText = 'I highly encourage you to give me any feedback at chessprof.chess@gmail.com. I would love any comments, reviews, questions on chess, or anything else.';

String aboutText = '''My name is Shikhar Ahuja, and I am a 1919 USCF rated Chess player. I have been playing chess since I was 4 years old and competitively since I was 8 years old. Throughout my years, I have struggled to improve at every level and know the major lessons or “principles” that must be learned at every stage.

The Goal of my app ChessProf is to help guide the way that people view Chess. At every level, the thought process must be simplified so that it is doable. 

Winning Chess is not something that can be learned in a day, a week, and is an ongoing process to improve your skill level. However, improvement comes from PRACTICE. There are two main ways to practice: play games and analyzing games. 

There are many other apps that I recommend to play games, including chess.com and lichess which are completely free and can give you some free insight. The other main way to learn is to analyze games by reading books and going to a professional teacher. 

The analysis of games is the way I intend to teach. Learning how to think is the first step, and the more you practice, the more you will improve. I think it is especially important to learn in a guided way, because it is very difficult to instantly understand the nuances of chess.

I have gone through this process and I believe this app can be a supplement to a teacher, and can allow chess players to begin to think about how they approach chess. It is an ongoing process and I highly encourage you to give me any feedback at chessprof.chess@gmail.com. I would love any comments, reviews, questions on chess, or anything else. ''';

String howtoText4 = '''When saving a game that you have entered, there are 4 options for the result: Win, Loss, Draw, or Line. Line can be any analysis that is not from a game, and does not have a definitive result. Additionally, when saving, the Color must be saved. Simply enter whether you were white or black in the game. Finally, save the title by typing any name that you wish. If you want to submit the game for ChessProf analysis, just press the submit button and I will analyze that game. 
''';

String howtoText4_para2 = '''If you want to view your previous analysis, you can go to the My Saved Games option. This can allow you to see your previous analysis. This is also where you will see the completed ChessProf analysis after I have finished analyzing a game you have submitted. If you want to submit or unsubmit a game, you can also do that in the Browse Games feature.
''';

String howtoText3 = '''The Analyze Mode allows the user to save games with variations, which is a feature that many other chess apps do not have. 
''';

String howtoText3_para2 = '''In the self analysis mode, there are 5 buttons. Branch creates a new variation which is not part of the mainline. The promote option upgrades a variation into the mainline. The Delete button allows you to delete a move or variation. The Undo button goes into the last screen, in case you clicked a button accidentally. The Comments section allows you to save your comments after every move, and you can see the comments through the comments symbol.
''';

String howtoText1 = '''There are two main features categories in the app: Learning and Self Analysis. 

Learning allows you to view games that I have annotated and analyzed through a principle guided lens. Each game was taken for a specific purpose that suits the level of the player. Often times, grandmaster games can be very difficult for beginners to understand, so it is important that the games presented are more relevant to the level of the player.
''';

String howtoText2 = '''When clicking on the Learn button, three options will appear. Start Lesson, Browse Games, and Principles. 
In the entire Learning Mode, the first option is to set the skill level. I highly recommend starting at Beginner or Novice unless you have tournament experience, because the intermediate and advanced games are more complex and require a vision that must be acquired in the lower levels.   
The Start Lesson immediately takes the user to the  The entire game is not shown at once; the user must click the next move to see each move. These games are not meant to be viewed quickly and I highly encourage playing them out on a board to think about these games at a higher level. 

In each game, there is at least one moment where the game goes into “Tactics Mode.” This is a time in the game when there is one clear move that must be played to retain an advantage. The “Tactics Mode” can be unlocked when the user plays a move, right or wrong. There is only one chance, so only move when you are sure!

The Browse Games gives the option to view the entire list of ChessProf games, which are increasing day by day for every level. Each game will be titled, so users can look at specific games if they have any main questions.  

The Principles Option gives an overall list of the Principles covered in each level, and each level has a different list of Principles.
''';

String level0desc = 'You are at the beginning of your chess career. Chessprof does not teach the rules of the game, but it does teach some of the exceptions like promotion and en passant. The Beginner Level can allow you to gain a familiarity with simple checkmates and tactics';
String level1desc = 'As a Novice Player, you should have a larger familiarity of the game including a basic understanding of tactics and such. If you played in tournaments, at this point it would be around a 1000 USCF rating. The lessons taught in Novice are meant to help further develop the tactical instincts and to learn the strategic approaches that will last throughout your chess career';
String level2desc = 'The Intermediate player is usually at least USCF 1300 and having a target rating of 1500. At this point, you should be quite familiar with the game and have a decently developed tactical vision. Chess Prof will work on the next step: the beginning of a positional play. Positional Play is about the coordination of pieces and pawns and requires a certain tactical vision to occur.';
String level3desc = 'At this level, you should have played in multiple tournaments and be around 1800+. At this point, the games demonstrated will be grandmaster games, which are often difficult to understand and significantly more complex. The principles at this stage will talk about weaknesses, tension, centralization, and stopping opponent’s counterplay ';
String level4desc = 'Master';
