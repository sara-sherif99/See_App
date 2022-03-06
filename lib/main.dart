import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graduation/NavBar.dart';
import 'package:flutter/services.dart';
//import 'package:graduation/icons.dart';
import 'package:graduation/see.dart';
import 'package:location/location.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flash/flash.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geol;
import 'package:geocoding/geocoding.dart' as geoc;
import 'package:intl/intl.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as per;
//import 'package:agora_rtc_engine/agora_rtc_engine_web.dart';
//import 'package:agora_rtc_engine/agora_rtc_engine_web.ng.dart';
//import 'package:agora_rtc_engine/rtc_channel.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:universal_io/io.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:platform_device_id/platform_device_id.dart';
//import 'package:agora_rtm/agora_rtm.dart';


const APP_ID="06bae84557cd443ab0b17be7e0374fd8";
//const APP_ID = "ea1e88e713414163ade91d064d7c8707";
//const Token ="006ea1e88e713414163ade91d064d7c8707IADe7VDYJ5xOv0ljg9AB1gz6k3jK9dVaZ7Zot4HBIc3U/c5D6bQAAAAAEAAqKWnBwugkYgEAAQDB6CRi";



var theme;
Future themeData() async {
  var info = FirebaseFirestore.instance;
  await for (var snapshot
      in info.collection('users').doc(currentUser.uid).snapshots()) {
    dc = snapshot.get('Default Contact');
    df = snapshot.get('Default Friend');
    theme = snapshot.get('Theme');
    if (theme == "true") {
      theme = true;
    } else if (theme == "false") {
      theme = false;
    }
  }
}

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}

class LocationProvider with ChangeNotifier {
  BitmapDescriptor _pinLocationIcon;
  BitmapDescriptor get pinLocationIcon => _pinLocationIcon;
  Map<MarkerId, Marker> _marker;
  Map<MarkerId, Marker> get marker => _marker;

  final MarkerId markerId = MarkerId("1");

  Location _location;
  Location get location => _location;
  LatLng _locationPosition;
  LatLng get locationPosition => _locationPosition;

  bool locationServiceActive = true;

  LocationProvider() {
    _location = Location();
  }

  initialization() async {
    await getUserLocation();
    await setCustomMapPin();
  }

  getUserLocation() async {
    bool _serviceEnable;
    PermissionStatus _permissionGranted;

    _serviceEnable = await location.serviceEnabled();
    if (!_serviceEnable) {
      _serviceEnable = await location.requestService();

      if (!_serviceEnable) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();

      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLocation) {
      _locationPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);

      print(_locationPosition);

      _marker = <MarkerId, Marker>{};
      Marker marker = Marker(
        markerId: markerId,
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        icon: (pinLocationIcon),
        draggable: true,
        onDragEnd: ((newPosition) {
          _locationPosition =
              LatLng(newPosition.latitude, newPosition.longitude);
          notifyListeners();
        }),
      );

      _marker[markerId] = marker;
      notifyListeners();
    });
  }

  setCustomMapPin() async {
    _pinLocationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/person.png',
    );
  }
}

String address;

var currentUser = FirebaseAuth.instance.currentUser;
String finalEmail;
final FlutterTts tts = FlutterTts();

var usersList = <String>[];
Future getUsers() async {
  var info = FirebaseFirestore.instance;
  await for (var snapshot in info.collection('users').snapshots()) {
    for (var f in snapshot.docs) {
      usersList.add(f.get("email"));
    }
    print(usersList);
  }
}

var fuid;
Future getUid() async {
  var info = FirebaseFirestore.instance;
  await for (var snapshot in info.collection('users').snapshots()) {
    for (var f in snapshot.docs) {
      if(f.get("email")==df){
        fuid = f.get("userid");
      }
    }
    print(fuid);
  }
}

var sortedUsers = <String>[];
/*Future sendRequest(email) async {
  var info = FirebaseFirestore.instance;
  await for (var snapshot in info.collection('users').snapshots()) {
    for (var f in snapshot.docs) {
      if(f.get("email")== email){
        var userInfo = FirebaseFirestore
            .instance
            .collection('users')
            .doc(f.id)
            .update({
          'Requests':
          FieldValue.arrayUnion(
              [finalEmail])
        });
      }
    }
  }
}
Future removeFriend(email) async {
  var info = FirebaseFirestore.instance;
  await for (var snapshot in info.collection('users').snapshots()) {
    for (var f in snapshot.docs) {
      if(f.get("email")== email){
        var userInfo = FirebaseFirestore
            .instance
            .collection('users')
            .doc(f.id)
            .update({
          'Linked Accounts':
          FieldValue.arrayRemove(
              [finalEmail])
        });
      }
    }
  }
}*/

var requestsList = <String>[];
var sentrequestsList = <String>[];
/*Future acceptRequest(email) async {
  var info = FirebaseFirestore.instance;
  await for (var snapshot in info.collection('users').snapshots()) {
    for (var f in snapshot.docs) {
      if(f.get("email")== email){
        var userInfo = FirebaseFirestore
            .instance
            .collection('users')
            .doc(f.id)
            .update({
          'Linked Accounts':
          FieldValue.arrayUnion(
              [finalEmail])
        });
      }
    }
  }

}*/

var friendsList = <String>[];
/*Future getFriends() async {
  var info = FirebaseFirestore.instance;
  await for (var snapshot
      in info.collection('users').doc(currentUser.uid).snapshots()) {
    for (var f in snapshot.get('Linked Accounts')) {
      if (friendsList.contains(f)) {
      } else {
        friendsList.add(f);
      }
    }
    print("friendsList");
    print(friendsList);
  }
}*/

var contactsList = <String>[];
Future getC() async {
  var info1 = FirebaseFirestore.instance;
  await for (var snapshot in info1.collection('users').snapshots()) {
    for (var f in snapshot.docs) {
      var e = f.get("email");
      var c = f.get("Phone Number");
      for (var i = 0; i < friendsList.length; i++) {
        if (e == friendsList[i]) {
          if (c != "") {
            var userInfo = FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .update({
              'Contacts': FieldValue.arrayUnion([c])
            });
          }
        }
      }
    }
  }
}

Future getContacts() async {
  getC();
  var info = FirebaseFirestore.instance;
  await for (var snapshot
      in info.collection('users').doc(currentUser.uid).snapshots()) {
    for (var f in snapshot.get('Contacts')) {
      if (contactsList.contains(f)) {
      } else {
        contactsList.add(f);
      }
    }
  }
}

Future goHome() async {
  var lat, long;
  var info = FirebaseFirestore.instance;
  await for (var snapshot
      in info.collection('users').doc(currentUser.uid).snapshots()) {
    lat = snapshot.get('Home latitude');
    print("lat");
    print(lat);
    long = snapshot.get('Home longitude');
    print("long");
    print(long);
    MapUtils.openMap(lat, long);
  }
}

var un, pn, bt, mc, db, ni, pp, accountType, dc,df,u;
Future profileInfo() async {
  var info = FirebaseFirestore.instance;
  await for (var snapshot
      in info.collection('users').doc(currentUser.uid).snapshots()) {
    un = snapshot.get('Username');
    pn = snapshot.get('Phone Number');
    bt = snapshot.get('Blood Type');
    mc = snapshot.get('Medical Conditions');
    db = snapshot.get('Date of Birth');
    ni = snapshot.get('National ID');
  }
}

void showToast(msg) async {
  Fluttertoast.showToast(
    msg: msg,
    fontSize: 18,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.white,
    textColor: Colors.black,
  );
  if (accountType != 'Friend') {
    await tts.setSpeechRate(0.5);
    await tts.speak(msg);
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");

  AwesomeNotifications().createNotificationFromJsonData(message.data);
}

void notify() async {
  // local notification
  AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: 'Simple Notification',
        body: 'Simple body',
        showWhen: true,
        displayOnBackground: true,
        displayOnForeground: true,
        autoDismissible: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: "OPEN",
          label: "open",
          autoDismissible: true,
          enabled: true,
          buttonType: ActionButtonType.Default,
        )
      ]);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Basic notifications',
      channelDescription: 'Notification channel for basic tests',
      defaultColor: Color(0xFF9D50DD),
      ledColor: Colors.white,
      importance: NotificationImportance.High,
      channelShowBadge: true,
      enableVibration: true,
    )
  ]);
  AwesomeNotifications().actionStream.listen((event) {
    print("event");
    print(event.toMap().toString());
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LocationProvider(),
          child: tracking(),
        )
      ],
      child: MaterialApp(
        title: 'Email And Password Login',
        theme: ThemeData(primarySwatch: Colors.amber),
        debugShowCheckedModeBanner: false,
        home: Splash(),
      ),
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({Key key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    getValidationData().whenComplete(() async {
      Timer(
          Duration(seconds: 1),
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => (finalEmail == null)
                      ? FirstScreen()
                      : (accountType == "Blind")
                          ? Home()
                          : (accountType == "Friend")
                              ? HomeF()
                              : FirstScreen())));
    });
    super.initState();
  }

  Future getValidationData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var obtainedEmail = sharedPreferences.getString("email");
    currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      finalEmail = obtainedEmail;
    });
    friendsList = [];
    requestsList = [];
    themeData();
    //getFriends();
    contactsList = [];
    sortedUsers = [];
    getContacts();
    print("finalEmail");
    print(finalEmail);
    print(currentUser.uid);
    await for (var snapshot in FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()) {
      un = snapshot.get('Username');
      pp = snapshot.get('Profile Picture');
      accountType = snapshot.get('account type');
      pn = snapshot.get('Phone Number');
      db = snapshot.get('Date of Birth');
      ni = snapshot.get('National ID');
      bt = snapshot.get('Blood Type');
      mc = snapshot.get('Medical Conditions');
      print(un);
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              //colorFilter: new ColorFilter.mode(Colors.white24.withOpacity(0.9), BlendMode.dstATop),
              image: AssetImage("assets/images/bg5.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 100,
                child: Icon(
                  See.see,
                  size: 150,
                  color: Colors.white,
                  //color: Color(0xff4F7F8F),
                ),
              ),
              Text(
                'See',
                style: TextStyle(
                  fontSize: 60,
                  fontFamily: 'Lobster',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FirstScreen extends StatefulWidget {
  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEE',
      home: Scaffold(
        body: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              //colorFilter: new ColorFilter.mode(Colors.white24.withOpacity(0.9), BlendMode.dstATop),
              image: AssetImage("assets/images/bg5.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 100,
                child: Icon(
                  See.see,
                  size: 150,
                  color: Colors.white,
                  //color: Color(0xff4F7F8F),
                ),
              ),
              Text(
                'See',
                style: TextStyle(
                  fontSize: 60,
                  fontFamily: 'Lobster',
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              MaterialButton(
                height: 50,
                minWidth: 300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                onLongPress: () async {
                  await tts.setSpeechRate(0.5);
                  await tts.speak("log in");
                },
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LogIn()));
                },
                color: Colors.white,
                child: Text(
                  "LOG IN",
                  style: TextStyle(
                    color: Color(0xff061c36),
                    fontFamily: 'RedHatBold',
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              MaterialButton(
                height: 50,
                onLongPress: () async {
                  await tts.setSpeechRate(0.5);
                  await tts.speak("sign up");
                },
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Sign()));
                },
                minWidth: 300,
                child: Text(
                  "SIGN UP",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'RedHatMedium',
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  side: BorderSide(
                    color: Colors.white,
                    width: 2,
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

class LogIn extends StatefulWidget {
  @override
  _LogIn createState() => _LogIn();
}

class _LogIn extends State<LogIn> {
  void initState() {
    super.initState();
  }

  final _formkey = GlobalKey<FormState>();

  TextEditingController _emailcontroller = TextEditingController();

  TextEditingController _passwordcontroller = TextEditingController();

  //bool firstValue = false;
  //bool secondValue = false;
  bool e = false;
  @override
  void dispose() {
    _emailcontroller.dispose();

    _passwordcontroller.dispose();

    super.dispose();
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(
            "LOG IN",
            style: TextStyle(
              fontFamily: 'RedHatMedium',
              fontSize: 25,
              color: Color(0xff96D5EB),
            ),
          ),
          backgroundColor: Colors.white,
          // Color(0xff96D5EB),
          leading: IconButton(
            icon: Icon(Icons.keyboard_backspace),
            color: Color(0xff96D5EB),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FirstScreen()));
            },
            iconSize: 30,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Form(
              key: _formkey,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                    height: 65,
                    child: Icon(
                      See.see,
                      size: 100,
                      color: Color(0xff96D5EB),
                      //color: Color(0xff4F7F8F),
                    ),
                  ),
                  Text(
                    'See',
                    style: TextStyle(
                      fontSize: 50,
                      fontFamily: 'Lobster',
                      color: Color(0xff96D5EB),
                      //color: Color(0xff4F7F8F),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    child: TextFormField(
                      onTap: () async {
                        await tts.setSpeechRate(0.5);
                        await tts.speak("Email");
                      },
                      controller: _emailcontroller,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 5.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color(0xff96D5EB),
                            width: 2,
                          ),
                        ),
                        labelText: "Email",
                        hintText: "*****@abc.com",
                        prefixIcon: Icon(
                          Icons.person,
                          color: Color(0xff96D5EB),
                        ),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          showToast('Please enter email');
                          return 'Please enter email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Container(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      onTap: () async {
                        await tts.setSpeechRate(0.5);
                        await tts.speak("password");
                      },
                      controller: _passwordcontroller,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 5.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color(0xff96D5EB),
                            width: 2,
                          ),
                        ),
                        labelText: 'Password',
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Color(0xff96D5EB),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          showToast("please enter password");
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 12,
                      ),
                      /*Checkbox(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3)),),
                        checkColor: Colors.white,
                        value: this.firstValue,
                        onChanged: (bool value) {
                          setState(() {

                            this.firstValue = value;
                          });
                        },
                      ),
                      Text(
                        "Remember me",
                        style: TextStyle(fontSize: 17, color: Colors.grey),
                      ),*/
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MaterialButton(
                      height: 40,
                      minWidth: 200,
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(
                            width: 0,
                            color: Color(0xff96D5EB),
                          )),
                      color: Color(0xff96D5EB),
                      child: Text(
                        'LOG IN',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'RedHatBold',
                          color: Colors.white,
                        ),
                      ),
                      onLongPress: () async {
                        await tts.setSpeechRate(0.5);
                        await tts.speak("LOG IN");
                      },
                      onPressed: () async {
                        try {
                          if (_formkey.currentState.validate()) {
                            var result = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: _emailcontroller.text,
                                    password: _passwordcontroller.text);
                            if (result != null) {
                              print(result);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Splash()),
                              );
                            } else {
                              showToast("User Not Found");
                              print('user not found');
                            }
                          }
                          final SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          sharedPreferences.setString(
                              "email", _emailcontroller.text);
                        } on FirebaseAuthException catch (error) {
                          var message =
                              'An error occurred, please check your credentials!';
                          if (error.message != null) {
                            message = error.message;
                            showToast(message);
                          }
                          print(message);
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Sign extends StatefulWidget {
  @override
  _SignUp createState() => _SignUp();
}

class _SignUp extends State<Sign> {
  //bool _value = false;
  Hash hasher = sha512;
  int val = -1;
  bool _isObscure = true;
  void initState() {
    super.initState();
  }

  final _formkey = GlobalKey<FormState>();

  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  TextEditingController _accounttypecontroller = TextEditingController();
  TextEditingController _checkpasscontroller = TextEditingController();

  @override
  void dispose() {
    _emailcontroller.dispose();

    _passwordcontroller.dispose();

    _checkpasscontroller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Sign up",
            style: TextStyle(
              fontFamily: "RedHatMedium",
              fontSize: 30,
              color: Color(0xff96D5EB),
            ),
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.keyboard_backspace),
            color: Color(0xff96D5EB),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FirstScreen()));
            },
            iconSize: 30,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Form(
              key: _formkey,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 60,
                    child: Icon(
                      See.see,
                      color: Color(0xff96D5EB),
                      size: 80,
                    ),
                  ),
                  Text(
                    'See',
                    style: TextStyle(
                      color: Color(0xff96D5EB),
                      fontSize: 40,
                      fontFamily: 'Lobster',
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    child: TextFormField(
                      onTap: () async {
                        await tts.setSpeechRate(0.5);
                        await tts.speak("Email");
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 5.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color(0xff96D5EB),
                            width: 2,
                          ),
                        ),
                        labelText: "Email",
                        hintText: "*****@abc.com",
                        prefixIcon: Icon(
                          Icons.person,
                          color: Color(0xff96D5EB),
                        ),
                      ),
                      controller: _emailcontroller,
                      validator: (value) {
                        if (value.isEmpty || !value.contains('@')) {
                          showToast("please enter a valid email address");
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Container(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      onTap: () async {
                        await tts.setSpeechRate(0.5);
                        await tts.speak("password");
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 5.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color(0xff96D5EB),
                            width: 2,
                          ),
                        ),
                        labelText: 'Password',
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Color(0xff96D5EB),
                        ),
                      ),
                      obscureText: true,
                      controller: _passwordcontroller,
                      validator: (value) {
                        if (value.isEmpty || value.length < 6) {
                          showToast("password must be at least 6 characters");
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Container(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      onTap: () async {
                        await tts.setSpeechRate(0.5);
                        await tts.speak("Confirm password");
                      },
                      controller: _checkpasscontroller,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 5.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color(0xff96D5EB),
                            width: 2,
                          ),
                        ),
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Color(0xff96D5EB),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value.isEmpty ||
                            value != _passwordcontroller.text) {
                          showToast("password does not match");
                          return 'Password does not match.';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                            "Blind",
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                          leading: Radio(
                            value: 1,
                            groupValue: val,
                            onChanged: (value) async {
                              setState(() {
                                val = value;
                                _accounttypecontroller.text = "Blind";
                              });
                              await tts.setSpeechRate(0.5);
                              await tts.speak("Blind");
                            },
                            activeColor: Color(0xff96D5EB),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(
                            "Friend",
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                          leading: Radio(
                            value: 2,
                            groupValue: val,
                            onChanged: (value) async {
                              setState(() {
                                val = value;
                                _accounttypecontroller.text = "Friend";
                              });
                              await tts.setSpeechRate(0.5);
                              await tts.speak("friend");
                            },
                            activeColor: Color(0xff96D5EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  MaterialButton(
                    height: 40,
                    minWidth: 200,
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(
                          width: 0,
                          color: Color(0xff96D5EB),
                        )),
                    color: Color(0xff96D5EB),
                    child: Text(
                      'SIGN UP',
                      style: TextStyle(
                        fontFamily: "RedHatBold",
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    onLongPress: () async {
                      await tts.setSpeechRate(0.5);
                      await tts.speak("Sign up");
                    },
                    onPressed: () async {
                      try {
                        if (_accounttypecontroller.text.isEmpty) {
                          showToast("Choose account type");
                        }
                        final Random _random = Random.secure();
                        String salting([int length = 2]) {
                          var values = List<int>.generate(
                              length, (i) => _random.nextInt(256));

                          return base64Url.encode(values);
                        }

                        String salt = salting().toString();
                        String hashedPass = salt + _passwordcontroller.text;
                        var bytes =
                            utf8.encode(hashedPass); // data being hashed
                        var digest = hasher.convert(bytes);

                        final SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        sharedPreferences.setString(
                            "email", _emailcontroller.text);

                        if (_formkey.currentState.validate() &&
                            _passwordcontroller.text ==
                                _checkpasscontroller.text &&
                            _accounttypecontroller.text.isNotEmpty) {
                          var result = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: _emailcontroller.text,
                                  password: _passwordcontroller.text);
                          User user = result.user;
                          print(hashedPass);
                          if (result != null) {
                            var userInfo = FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .set({
                              'email': _emailcontroller.text,
                              'userid': user.uid,
                              'Username': _emailcontroller.text.split("@")[0],
                              'salt': salt,
                              'password': digest.toString(),
                              'account type': _accounttypecontroller.text,
                              'Contacts': [],
                              'Phone Number': "",
                              'Date of Birth': "",
                              'National ID': "",
                              'Blood Type': "",
                              'Medical Conditions': "",
                              'Profile Picture': "",
                              'Theme': "true",
                              'Default Contact': "",
                              'Default Friend': "",
                            });
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Splash()),
                            );
                          } else {
                            print('please try later');
                          }
                        }
                      } on FirebaseAuthException catch (error) {
                        var message =
                            'An error occurred, please check your credentials!';
                        if (error.message != null) {
                          message = error.message;
                          showToast(message);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeF extends StatefulWidget {
  @override
  _HomeFState createState() => _HomeFState();
}

class _HomeFState extends State<HomeF> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme ? Colors.white : Colors.black,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme ? Colors.white : Colors.black,
        leading: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Icon(
            Icons.view_headline,
            color: Color(0xff96D5EB),
            size: 30,
          ),
        ),
        title: Text(
          'See',
          style: TextStyle(
            fontFamily: 'Lobster',
            color: Color(0xff96D5EB),
            fontSize: 40,
          ),
        ),
        actions: <Widget>[
          Icon(
            See.see,
            size: 60,
            color: Color(0xff96D5EB),
          ),
        ],
      ),
      drawer: NavBar(),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            MaterialButton(
              height: 150,
              minWidth: 300,
              color: theme ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  side: BorderSide(
                    color: Color(0xff96D5EB),
                    width: 2,
                  )),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.call,
                    color: Color(0xff96D5EB),
                    size: 40,
                  ),
                  Text(
                    "Call",
                    style: TextStyle(
                      color: Color(0xff96D5EB),
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<Home> {
  bool b1 = false;
  bool b2 = false;
  bool b3 = false;
  bool b4 = false;
  bool b5 = false;
  bool b6 = false;
  _launchCaller() async {
    String phoneNumber = dc;
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
    //var url = "tel:"+dc;
    //const url = 'tel:9876543210';
    //await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        backgroundColor: theme ? Colors.white : Colors.black,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: theme ? Colors.white : Colors.black,
          leading: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Icon(
              Icons.view_headline,
              color: Color(0xff96D5EB),
              size: 30,
            ),
          ),
          title: Text(
            'See',
            style: TextStyle(
              fontFamily: 'Lobster',
              color: Color(0xff96D5EB),
              fontSize: 40,
            ),
          ),
          actions: <Widget>[
            Icon(
              See.see,
              size: 60,
              color: Color(0xff96D5EB),
            ),
          ],
        ),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    height: 150,
                    minWidth: 150,
                    color: theme ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(
                          color: b1 ? Colors.red : Color(0xff96D5EB),
                          width: 2,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.power_settings_new,
                          color: b1 ? Colors.red : Color(0xff96D5EB),
                          size: 40,
                        ),
                        Text(
                          "Power",
                          style: TextStyle(
                            color: b1 ? Colors.red : Color(0xff96D5EB),
                            fontSize: 20,
                            fontFamily: "RedHatMedium",
                          ),
                        ),
                      ],
                    ),
                    onLongPress: () async {
                      await tts.setSpeechRate(0.5);
                      await tts.speak("power");
                    },
                    onPressed: () {
                      setState(() {
                        b1 = !b1;
                      });
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Led()));
                    },
                  ),
                  MaterialButton(
                    height: 150,
                    minWidth: 150,
                    color: theme ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(
                          color: b2 ? Colors.red : Color(0xff96D5EB),
                          width: 2,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.search,
                          color: b2 ? Colors.red : Color(0xff96D5EB),
                          size: 40,
                        ),
                        Text(
                          "Search",
                          style: TextStyle(
                            color: b2 ? Colors.red : Color(0xff96D5EB),
                            fontSize: 20,
                            fontFamily: "RedHatMedium",
                          ),
                        ),
                      ],
                    ),
                    onLongPress: () async {
                      await tts.setSpeechRate(0.5);
                      await tts.speak("search");
                    },
                    onPressed: () {
                      setState(() {
                        b2 = !b2;
                      });
                      //Navigator.push(context,
                        //  MaterialPageRoute(builder: (context) => Rtm()));
                    },
                  ),
                  MaterialButton(
                    height: 150,
                    minWidth: 150,
                    color: theme ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(
                          color: b3 ? Colors.red : Color(0xff96D5EB),
                          width: 2,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.video_call,
                          color: b3 ? Colors.red : Color(0xff96D5EB),
                          size: 40,
                        ),
                        Text(
                          "Online Call",
                          style: TextStyle(
                            color: b3 ? Colors.red : Color(0xff96D5EB),
                            fontSize: 20,
                            fontFamily: "RedHatMedium",
                          ),
                        ),
                      ],
                    ),
                    onLongPress: () async {
                      await tts.setSpeechRate(0.5);
                      await tts.speak("online call");
                    },
                    onPressed: ()  {
                      setState(() {
                        b3 = !b3;
                      });
                      setState(() {
                         Timer(
                          Duration(seconds: 2),
                          () => setState(() {
                            b3 = !b3;
                          }),
                        );
                      });
                      getUid();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Test()));
                    },
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    height: 150,
                    minWidth: 150,
                    color: theme ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(
                          color: b4 ? Colors.red : Color(0xff96D5EB),
                          width: 2,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.location_on,
                          color: b4 ? Colors.red : Color(0xff96D5EB),
                          size: 40,
                        ),
                        Text(
                          "Location",
                          style: TextStyle(
                            color: b4 ? Colors.red : Color(0xff96D5EB),
                            fontSize: 20,
                            fontFamily: "RedHatMedium",
                          ),
                        ),
                      ],
                    ),
                    onLongPress: () async {
                      await tts.setSpeechRate(0.5);
                      await tts.speak("location");
                    },
                    onPressed: () {
                      setState(() {
                        b4 = !b4;
                      });
                    },
                  ),
                  MaterialButton(
                    height: 150,
                    minWidth: 150,
                    color: theme ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(
                          color: b5 ? Colors.red : Color(0xff96D5EB),
                          width: 2,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.home,
                          color: b5 ? Colors.red : Color(0xff96D5EB),
                          size: 40,
                        ),
                        Text(
                          "Go Home",
                          style: TextStyle(
                            color: b5 ? Colors.red : Color(0xff96D5EB),
                            fontSize: 20,
                            fontFamily: "RedHatMedium",
                          ),
                        ),
                      ],
                    ),
                    onLongPress: () async {
                      await tts.setSpeechRate(0.5);
                      await tts.speak("go home");
                    },
                    onPressed: () {
                      setState(() {
                        b5 = !b5;
                      });
                      Timer(
                        Duration(seconds: 2),
                        () => setState(() {
                          b5 = !b5;
                        }),
                      );
                      goHome();
                    },
                  ),
                  MaterialButton(
                    height: 150,
                    minWidth: 150,
                    color: theme ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(
                          color: b6 ? Colors.red : Color(0xff96D5EB),
                          width: 2,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.call,
                          color: b6 ? Colors.red : Color(0xff96D5EB),
                          size: 40,
                        ),
                        Text(
                          "Call",
                          style: TextStyle(
                            color: b6 ? Colors.red : Color(0xff96D5EB),
                            fontSize: 20,
                            fontFamily: "RedHatMedium",
                          ),
                        ),
                      ],
                    ),
                    onLongPress: () async {
                      await tts.setSpeechRate(0.5);
                      await tts.speak("call");
                    },
                    onPressed: () async {
                      setState(() {
                        b6 = !b6;
                      });
                      Timer(
                        Duration(seconds: 2),
                        () => setState(() {
                          b6 = !b6;
                        }),
                      );
                      if (dc != "") {
                        _launchCaller();
                      } else {
                        showToast("No default contact");
                      }
                      print(dc);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        drawer: NavBar(),
        floatingActionButton: Container(
          width: 200,
          height: 50,
          child: new FloatingActionButton.extended(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              label: Text(
                "Scan",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "RedHatBold",
                  color: Colors.white,
                ),
              ),
              icon: Icon(
                Icons.settings_overscan,
                size: 30,
                color: Colors.white,
              ),
              backgroundColor: new Color(0xff96D5EB),
              onPressed: () {
                tts.speak("scan");
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Barcode()));
              }),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

}

class Friends extends StatefulWidget {
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final fb = FirebaseDatabase.instance;
  String retrievedName;
  int _selectedIndex = 0;
  FirebaseMessaging messaging;

  bool p = true;
  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.ref().onValue.listen((event) {
      friendsList = [];
      sentrequestsList = [];
      final data = event.snapshot;
      if (data.value != null) {
        requestsList = [];
        p = true;
        data.children.forEach((element) {
          print(element.child('to').value);
          setState(() {
            if (element.child('from').value == finalEmail) {
              sentrequestsList.add(element.child('to').value);
            }
            retrievedName = element.child('from').value;
            if (element.child('to').value == finalEmail) {
              requestsList.add(retrievedName);
            }
            if (element.child('1').value == finalEmail) {
              friendsList.add(element.child('2').value);
            }
            if (element.child('2').value == finalEmail) {
              friendsList.add(element.child('1').value);
            }
            getC();
          });
        });
      }
    });
    print("friendsList");
    print(friendsList);
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      print(value);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message received");
      print(event.notification.body);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Notification"),
              content: Text(event.notification.body),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  Widget build(BuildContext context) {
    final ref = fb.ref();
    return MaterialApp(
      home: Scaffold(
        backgroundColor: theme ? Colors.white : Colors.black,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: theme ? Colors.white : Colors.black,
          leading: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Icon(
              Icons.view_headline,
              color: Color(0xff96D5EB),
              size: 30,
            ),
          ),
          title: Text(
            'See',
            style: TextStyle(
              fontFamily: 'Lobster',
              color: Color(0xff96D5EB),
              fontSize: 40,
            ),
          ),
          actions: <Widget>[
            Icon(
              See.see,
              size: 60,
              color: Color(0xff96D5EB),
            ),
          ],
        ),
        drawer: NavBar(),
        body: SingleChildScrollView(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              Center(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        'Friends',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "RedHatRegular",
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: theme ? Colors.black : Colors.white,
                        ),
                      ),
                      Container(
                        padding: new EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            friendsList.isNotEmpty
                                ? listOfWidgets(friendsList)
                                : SizedBox(
                                    height: 10,
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      MaterialButton(
                        height: 40,
                        minWidth: 200,
                        shape: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(
                              width: 0,
                              color: Color(0xff96D5EB),
                            )),
                        color: Color(0xff96D5EB),
                        child: Text(
                          '+ Add Friend',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "RedHatBold",
                            color: Colors.white,
                          ),
                        ),
                        onLongPress: () async {
                          if (accountType == 'Blind') {
                            await tts.setSpeechRate(0.5);
                            await tts.speak("Add friend");
                          }
                        },
                        onPressed: () {
                          usersList.clear();
                          sortedUsers.clear();
                          getUsers();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Add()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Center(
                  child: Container(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: requestsList.length,
                      itemBuilder: (connectionContext, index) {
                        return Container(
                          color: theme ? Colors.white : Colors.black,
                          padding: EdgeInsets.all(30),
                          height: 100.0,
                          width: double.maxFinite,
                          //color: Colors.orange,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                requestsList[index].toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontFamily: "RedHatRegular"),
                              ),
                              SizedBox(
                                width: 150,
                              ),
                              TextButton(
                                  style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100.0),
                                    side: BorderSide(color: Colors.blue),
                                  )),
                                  child: Text(
                                    "Accept",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontFamily: 'RedHatMedium'),
                                  ),
                                  onLongPress: () async {
                                    if (accountType == 'Blind') {
                                      await tts.setSpeechRate(0.5);
                                      await tts.speak(
                                          "Accept " + requestsList[index]);
                                    }
                                  },
                                  onPressed: () async {
                                    //acceptRequest(requestsList[index]);
                                    setState(() {
                                      p = !p;
                                      print(p);
                                    });
                                    /*FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(currentUser.uid)
                                        .update({
                                      'Requests':
                                      FieldValue.arrayRemove([requestsList[index]])
                                    });
                                    FirebaseFirestore
                                        .instance
                                        .collection('users')
                                        .doc(currentUser.uid)
                                        .update({
                                      'Linked Accounts':
                                      FieldValue.arrayUnion(
                                          [requestsList[index]])
                                    });*/
                                    ref
                                        .child(finalEmail.split("@")[0] +
                                            requestsList[index].split("@")[0])
                                        .set({
                                      '1': requestsList[index],
                                      '2': finalEmail,
                                    });
                                    ref
                                        .child(
                                            requestsList[index].split("@")[0] +
                                                finalEmail.split("@")[0])
                                        .remove();
                                    requestsList.remove(requestsList[index]);
                                    //getFriends();
                                  }),
                              TextButton(
                                  style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100.0),
                                    side: BorderSide(color: Colors.red),
                                  )),
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontFamily: 'RedHatMedium'),
                                  ),
                                  onLongPress: () async {
                                    if (accountType == 'Blind') {
                                      await tts.setSpeechRate(0.5);
                                      await tts.speak(
                                          "Delete " + requestsList[index]);
                                    }
                                  },
                                  onPressed: () async {
                                    ref
                                        .child(
                                            requestsList[index].split("@")[0] +
                                                finalEmail.split("@")[0])
                                        .remove();
                                    requestsList.remove(requestsList[index]);
                                  }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: theme ? Colors.white : Colors.black,
          selectedItemColor: Color(0xff96D5EB),
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: " ",
            ),
            BottomNavigationBarItem(
              label: "",
              icon: Stack(
                children: <Widget>[
                  Icon(
                    Icons.notifications,
                  ),
                  if (requestsList.isNotEmpty)
                    Positioned(
                      top: 0.0,
                      right: 0.0,
                      child: new Icon(Icons.brightness_1,
                          size: 8.0, color: Colors.redAccent),
                    ),
                ],
              ),
            ),
          ],
          currentIndex: _selectedIndex, //New
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget listOfWidgets(List<String> item) {
    final ref = fb.ref();
    List<Widget> list = [];
    for (var i = 0; i < item.length; i++) {
      list.add(Container(
          child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(
              color: Color(0xff96D5EB),
              width: 2,
            )),
        color: theme ? Colors.white : Colors.black,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            new ListTile(
              leading: Icon(
                Icons.person,
                size: 30,
                color: Color(0xff96D5EB),
              ),
              title: Text(item[i],
                  style: TextStyle(
                    fontSize: 25.0,
                    fontFamily: "RedHatRegular",
                    color: Color(0xff96D5EB),
                  )),
            ),
            MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Colors.red,
                    width: 2,
                  )),
              color: Colors.red,
              child: Text(
                'Remove',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "RedHatBold",
                ),
              ),
              onLongPress: () async {
                if (accountType == 'Blind') {
                  await tts.setSpeechRate(0.5);
                  await tts.speak("remove" + item[i]);
                }
              },
              onPressed: () async {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    content: Text(
                      'Remove ' + item[i] + ' ?',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontFamily: 'RedHatRegular',
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onLongPress: () async {
                          if (accountType == 'Blind') {
                            await tts.setSpeechRate(0.5);
                            await tts.speak("cancel");
                          }
                        },
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onLongPress: () async {
                          if (accountType == 'Blind') {
                            await tts.setSpeechRate(0.5);
                            await tts.speak("Remove" + item[i]);
                          }
                        },
                        onPressed: () async {
                          ref
                              .child(finalEmail.split("@")[0] +
                                  item[i].split("@")[0])
                              .remove();
                          ref
                              .child(item[i].split("@")[0] +
                                  finalEmail.split("@")[0])
                              .remove();
                          //removeFriend(friendsList[i]);
                          /*setState(() {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .update({
                        'Linked Accounts':
                        FieldValue.arrayRemove([friendsList[i]]),
                      });
                      friendsList.remove(friendsList[i]);
                      //getFriends();
                    });*/
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Friends()));
                        },
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (item[i] != df)
              MaterialButton(
                onLongPress: () async {
                  if (accountType == 'Blind') {
                    await tts.setSpeechRate(0.2);
                    await tts.speak("set" + item[i] + "as default friend");
                  }
                },
                onPressed: () {
                  df = item[i].toString();
                  var userInfo = FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .update({
                    'Default Friend': item[i].toString(),
                  });
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Friends()));
                },
                child: Text(
                  "Set as default",
                  style: TextStyle(
                    color: Color(0xff96D5EB),
                    fontFamily: "RedHatBold",
                  ),
                ),
              ),
            if (item[i] == df)
              Text(
                "Default",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "RedHatBold",
                ),
              ),
          ],
        ),
      )));
    }
    return Wrap(
        spacing: 5.0, // gap between adjacent chips
        runSpacing: 2.0, // gap between lines
        children: list);
  }
}

class Add extends StatefulWidget {
  @override
  _AddState createState() => _AddState();
}

class _AddState extends State<Add> {
  final fb = FirebaseDatabase.instance;

  int _selectedIndex = 0;
  bool _isLoading = false;
  TextEditingController friends = TextEditingController();

  void clearText() {
    friends.clear();
  }

  bool p = true;
  @override
  Widget build(BuildContext context) {
    final ref = fb.ref();
    return MaterialApp(
        home: Scaffold(
      backgroundColor: theme ? Colors.white : Colors.black,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme ? Colors.white : Colors.black,
        title: const Text(
          'Add Friend',
          style: TextStyle(
            fontFamily: "RedHatMedium",
            fontSize: 30,
            color: Color(0xff96D5EB),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace),
          color: Color(0xff96D5EB),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Friends()));
          },
          iconSize: 30,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            child: Column(children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Container(
                width: 300,
                child: TextFormField(
                  onTap: () async {
                    if (accountType == 'Blind') {
                      await tts.setSpeechRate(0.5);
                      await tts.speak("friend email");
                    }
                  },
                  style: TextStyle(color: theme ? Colors.black : Colors.white),
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color(0xff96D5EB),
                        width: 2,
                      ),
                    ),
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Color(0xff96D5EB),
                    ),
                  ),
                  controller: friends,
                  onChanged: (writeText) {
                    if (mounted) {
                      setState(() {
                        sortedUsers.clear();
                        print('Available Users: $usersList');
                        for (var i = 0; i < usersList.length; i++) {
                          if (usersList[i]
                                  .toLowerCase()
                                  .startsWith('${writeText.toLowerCase()}') &&
                              usersList[i] != currentUser.email.toString()) {
                            sortedUsers.add(usersList[i]);
                          }
                        }
                      });
                    }
                    print(sortedUsers);
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10.0),
                height: 300,
                width: double.maxFinite,
                //color: Colors.red,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sortedUsers.length,
                  itemBuilder: (connectionContext, index) {
                    if (friends.text != "") {
                      return Container(
                        padding: EdgeInsets.all(30),
                        height: 100.0,
                        width: double.maxFinite,
                        //color: Colors.orange,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              sortedUsers[index].toString(),
                              style: TextStyle(
                                  color: theme ? Colors.black : Colors.white,
                                  fontSize: 20.0,
                                  fontFamily: "RedHatRegular"),
                            ),
                            TextButton(
                                style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                  side: BorderSide(
                                      color: sentrequestsList
                                              .contains(sortedUsers[index])
                                          ? Colors.red
                                          : Colors.blue),
                                )),
                                child: sentrequestsList
                                        .contains(sortedUsers[index])
                                    ? Text(
                                        "Pending",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontFamily: 'RedHatMedium'),
                                      )
                                    : (friendsList.contains(sortedUsers[index]))
                                        ? Text(
                                            "friend",
                                            style: TextStyle(
                                                fontFamily: 'RedHatMedium'),
                                          )
                                        : Text(
                                            "ADD",
                                            style: TextStyle(
                                                fontFamily: 'RedHatMedium'),
                                          ),
                                onLongPress: () async {
                                  if (accountType == 'Blind') {
                                    await tts.setSpeechRate(0.5);
                                    await tts
                                        .speak("Add " + sortedUsers[index]);
                                  }
                                },
                                onPressed: () async {
                                  if (sentrequestsList.contains(sortedUsers[index])){
                                    showToast("Already Sent");
                                  }
                                  else{
                                    ref
                                        .child(finalEmail.split("@")[0] +
                                        sortedUsers[index].split("@")[0])
                                        .set({
                                      'to': sortedUsers[index],
                                      'from': finalEmail,
                                    });
                                    //sendRequest(sortedUsers[index]);
                                    setState(() {
                                      sentrequestsList.add(sortedUsers[index]);
                                      p = !p;
                                    });
                                  }

                                }),
                          ],
                        ),
                      );
                      //return connectionShowUp(index);
                    } else {
                      return null;
                    }
                  },
                ),
              ),

              /*MaterialButton(
                          color: Color(0xff96D5EB),
                          child: Text(
                            'Add',
                            style: TextStyle(color: Colors.white),
                          ),
                          onLongPress: () async {
                            if (accountType == 'Blind') {
                              await tts.setSpeechRate(0.5);
                              await tts.speak("Add");
                            }
                          },
                          onPressed: () {
                            //ref.child("name").set(friends.text);
                          },
                        ),*/
            ]),
          ),
        ),
      ),
    ));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    friends.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController number = TextEditingController();

  bool isSwitched = !theme;
  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
        theme = !theme;
        var userInfo = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'Theme': theme.toString(),
        });
      });
    } else {
      setState(() {
        isSwitched = false;
        theme = !theme;
        var userInfo = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'Theme': theme.toString(),
        });
      });
    }
  }

  void clearText() {
    number.clear();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: theme ? Colors.white : Colors.black,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: theme ? Colors.white : Colors.black,
          leading: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Icon(
              Icons.view_headline,
              color: Color(0xff96D5EB),
              size: 30,
            ),
          ),
          title: Text(
            'See',
            style: TextStyle(
              fontFamily: 'Lobster',
              color: Color(0xff96D5EB),
              fontSize: 40,
            ),
          ),
          actions: <Widget>[
            Icon(
              See.see,
              size: 60,
              color: Color(0xff96D5EB),
            ),
          ],
        ),
        drawer: NavBar(),
        body: Container(
          padding: EdgeInsets.only(left: 16, top: 25, right: 16),
          child: ListView(
            children: [
              Center(
                child: Text(
                  "Settings",
                  style: TextStyle(
                      fontFamily: "RedHatRegular",
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: theme ? Colors.black : Colors.white),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: SizedBox(
                  width: 200,
                  child: MaterialButton(
                    onLongPress: () async {
                      if (accountType == 'Blind') {
                        await tts.setSpeechRate(0.2);
                        await tts.speak("Edit profile");
                      }
                    },
                    height: 45,
                    onPressed: () {
                      profileInfo();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Profile()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontFamily: "RedHatBold",
                            color: Color(0xff96D5EB),
                            fontSize: 20,
                          ),
                        ),
                        Icon(
                          Icons.edit,
                          size: 20,
                          color: Color(0xff96D5EB),
                        )
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      side: BorderSide(
                        color: Color(0xff96D5EB),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: theme ? Colors.black : Colors.white,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Account",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "RedHatMedium",
                      color: theme ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
              Divider(
                height: 15,
                thickness: 2,
              ),
              SizedBox(
                height: 10,
              ),
              buildAccountOptionRow(context, "Contacts", "Remove", "Contact"),
              buildDeactivateAccountOptionRow(context, "Deactivate Account"),
              SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  Icon(
                    Icons.security,
                    color: theme ? Colors.black : Colors.white,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "General",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "RedHatMedium",
                      color: theme ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
              Divider(
                height: 15,
                thickness: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dark Mode",
                    style: TextStyle(
                        color: Colors.grey,
                        fontFamily: "RedHatMedium",
                        fontSize: 18),
                  ),
                  Transform.scale(
                      scale: 1.5,
                      child: Switch(
                        onChanged: toggleSwitch,
                        value: isSwitched,
                        activeColor: Color(0xff96D5EB),
                        activeTrackColor: Color(0xff96D5EB),
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector buildAccountOptionRow(
      BuildContext context, String title, String label, String option) {
    return GestureDetector(
      onLongPress: () async {
        if (accountType == 'Blind') {
          await tts.setSpeechRate(0.2);
          await tts.speak(title);
        }
      },
      onTap: () {
        contactsList = [];
        getContacts();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: AlertDialog(
                  title: Text(
                    title,
                    style: TextStyle(
                      fontFamily: "RedHatMedium",
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: new EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            contactsList.isNotEmpty
                                ? listOfWidgets(context, contactsList)
                                : SizedBox(
                                    height: 10,
                                  ),
                          ],
                        ),
                      ),
                      MaterialButton(
                        onLongPress: () async {
                          if (accountType == 'Blind') {
                            await tts.setSpeechRate(0.5);
                            await tts.speak("Add" + option);
                          }
                        },
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(
                                        width: 0,
                                        color: Colors.white,
                                      )),
                                  scrollable: true,
                                  title: Text(
                                    'Add Contact',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontFamily: "RedHatMedium",
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  content: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Form(
                                      child: Column(
                                        children: <Widget>[
                                          TextFormField(
                                            onTap: () async {
                                              if (accountType == 'Blind') {
                                                await tts.setSpeechRate(0.5);
                                                await tts.speak("Phone number");
                                              }
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'Phone Number',
                                              icon: Icon(
                                                Icons.call,
                                                color: Color(0xff96D5EB),
                                              ),
                                            ),
                                            controller: number,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    Center(
                                      child: MaterialButton(
                                        color: Color(0xff96D5EB),
                                        child: Text(
                                          'Add',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "RedHatBold",
                                          ),
                                        ),
                                        onLongPress: () async {
                                          if (accountType == 'Blind') {
                                            await tts.setSpeechRate(0.5);
                                            await tts.speak("Add");
                                          }
                                        },
                                        onPressed: () {
                                          contactsList = [];
                                          if (number.text != "" &&
                                              number.text.length == 11) {
                                            var userInfo = FirebaseFirestore
                                                .instance
                                                .collection('users')
                                                .doc(currentUser.uid)
                                                .update({
                                              'Contacts': FieldValue.arrayUnion(
                                                  [number.text])
                                            });
                                          } else if (number.text.length != 11) {
                                            showToast("enter valid number");
                                          }
                                          Navigator.pop(context);
                                          clearText();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              });
                        },
                        child: Text(
                          "+ Add",
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: "RedHatBold",
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    MaterialButton(
                        onLongPress: () async {
                          if (accountType == 'Blind') {
                            await tts.setSpeechRate(0.2);
                            await tts.speak("close");
                          }
                        },
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        elevation: 0,
                        color: Colors.white,
                        child: Text(
                          "Close",
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: "RedHatBold",
                          ),
                        )),
                  ],
                ),
              );
            });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget listOfWidgets(BuildContext context, List<String> item) {
    List<Widget> list = [];
    for (var i = 0; i < item.length; i++) {
      list.add(Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(item[i],
                      style: TextStyle(
                        color: Colors.black,
                      )),
                  MaterialButton(
                    child: Text(
                      'Remove',
                      style: TextStyle(
                        color: Colors.red,
                        fontFamily: "RedHatBold",
                      ),
                    ),
                    onLongPress: () async {
                      if (accountType == 'Blind') {
                        await tts.setSpeechRate(0.5);
                        await tts.speak("remove" + item[i]);
                      }
                    },
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Settings()));
                      contactsList = [];
                      setState(() {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .update({
                          'Contacts': FieldValue.arrayRemove([item[i]])
                        });
                        contactsList.remove(contactsList[i]);
                        if (item[i] == dc) {
                          dc = "";
                          var userInfo = FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .update({
                            'Default Contact': "",
                          });
                        }
                      });
                    },
                  ),
                ],
              ),
              if (item[i] != dc)
                MaterialButton(
                  onLongPress: () async {
                    if (accountType == 'Blind') {
                      await tts.setSpeechRate(0.2);
                      await tts.speak("set" + item[i] + "as default contact");
                    }
                  },
                  onPressed: () {
                    dc = item[i].toString();
                    var userInfo = FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .update({
                      'Default Contact': item[i].toString(),
                    });
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Settings()));
                  },
                  child: Text(
                    "Set as default",
                    style: TextStyle(
                      color: Color(0xff96D5EB),
                      fontFamily: "RedHatBold",
                    ),
                  ),
                ),
              if (item[i] == dc)
                Text(
                  "Default",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "RedHatBold",
                  ),
                ),
              Divider(
                height: 15,
                thickness: 2,
              ),
            ],
          ),
        ),
      ));
    }
    return Wrap(
        spacing: 5.0, // gap between adjacent chips
        runSpacing: 2.0, // gap between lines
        children: list);
  }

//remove
  GestureDetector buildPrivacyAndSecurityOptionRow(
    BuildContext context,
    String title,
  ) {
    return GestureDetector(
      onLongPress: () async {
        if (accountType == 'Blind') {
          await tts.setSpeechRate(0.2);
          await tts.speak(title);
        }
      },
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Privacy"),
                        MaterialButton(
                          onPressed: () {},
                          child: Text(
                            "edit",
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Security"),
                        MaterialButton(
                          onPressed: () {},
                          child: Text(
                            "edit",
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                actions: [
                  MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      color: Colors.red,
                      child: Text(
                        "Close",
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              );
            });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector buildDeactivateAccountOptionRow(
    BuildContext context,
    String title,
  ) {
    return GestureDetector(
      onLongPress: () async {
        if (accountType == 'Blind') {
          await tts.setSpeechRate(0.2);
          await tts.speak("Deactivate account");
        }
      },
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [],
                ),
                actions: [
                  Center(
                    child: MaterialButton(
                        onLongPress: () async {
                          if (accountType == 'Blind') {
                            await tts.setSpeechRate(0.2);
                            await tts.speak("Deactivate account");
                          }
                        },
                        onPressed: () async {
                          try {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser.uid)
                                .delete();
                            FirebaseAuth.instance.currentUser.delete();
                            FirebaseAuth.instance.signOut();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FirstScreen()));
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.remove("email");
                          } catch (e) {
                            print(e);
                            print("e");
                          }
                        },
                        color: Colors.red,
                        elevation: 0,
                        child: Text(
                          "Deactivate Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "RedHatBold",
                          ),
                        )),
                  ),
                ],
              );
            });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File image;
  Future uploadPP() async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('PP/${Path.basename(image.path)}}');
    UploadTask uploadTask = storageReference.putFile(image);
    print('File Uploaded');
    print(image.toString());
    TaskSnapshot taskSnapshot = await uploadTask;
    String url = await taskSnapshot.ref.getDownloadURL();
    print(url);
    FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
      'Profile Picture': url,
    });
    setState(() {
      pp = url;
    });
  }

  void displayBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            height: 155,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: 50,
                    child: Center(
                        child: Text(
                      "Choose option",
                      style:
                          TextStyle(fontFamily: "RedHatMedium", fontSize: 20),
                    ))),
                SizedBox(
                  width: double.infinity,
                  child: MaterialButton(
                    minWidth: 150,
                    height: 50,
                    onLongPress: () async {
                      if (accountType == 'Blind') {
                        await tts.setSpeechRate(0.2);
                        await tts.speak("Take a photo");
                      }
                    },
                    onPressed: () async {
                      PickedFile picked = await ImagePicker.platform
                          .pickImage(source: ImageSource.camera);
                      setState(() {
                        image = File(picked.path);
                      });
                      uploadPP();
                    },
                    color: Color(0xff96D5EB),
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: Text(
                      "Take a Photo",
                      style: TextStyle(
                        fontFamily: "RedHatBold",
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: double.infinity,
                  child: MaterialButton(
                    minWidth: 150,
                    height: 50,
                    onLongPress: () async {
                      if (accountType == 'Blind') {
                        await tts.setSpeechRate(0.2);
                        await tts.speak("upload from gallery");
                      }
                    },
                    onPressed: () async {
                      PickedFile picked = await ImagePicker.platform
                          .pickImage(source: ImageSource.gallery);
                      setState(() {
                        image = File(picked.path);
                      });
                      uploadPP();
                    },
                    color: Color(0xff96D5EB),
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: Text(
                      "Upload from Gallery",
                      style: TextStyle(
                          fontFamily: "RedHatBold",
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  bool showPassword = false;
  TextEditingController username = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController phoneNum = TextEditingController();
  TextEditingController blood = TextEditingController();
  TextEditingController medical = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController id = TextEditingController();
  Future editProfile() async {
    void fire(var field, var controller) {
      if (field == 'password' && controller != "") {
        Hash hasher = sha512;
        final Random _random = Random.secure();
        String salting([int length = 2]) {
          var values = List<int>.generate(length, (i) => _random.nextInt(256));
          return base64Url.encode(values);
        }

        String salt = salting().toString();
        String hashedPass = salt + controller;
        var bytes = utf8.encode(hashedPass); // data being hashed
        var digest = hasher.convert(bytes);
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'salt': salt,
          'password': digest.toString(),
        });
        currentUser.updatePassword(controller).then((_) {
          showToast("Successfully changed password");
        }).catchError((error) {
          showToast("Password can't be changed" + error.toString());
        });
      } else if (controller != "") {
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          field: controller,
        });
        showToast("Successfully changed");
      } else if (controller == "") {}
    }

    fire('Username', username.text);
    fire('password', pass.text);
    fire('Phone Number', phoneNum.text);
    fire('Date of Birth', dob.text);
    fire('National ID', id.text);
    fire('Blood Type', blood.text);
    fire('Medical Conditions', medical.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme ? Colors.white : Colors.black,
      drawer: NavBar(),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: ListView(
          children: [
            Center(
              child: Text(
                "Edit Profile",
                style: TextStyle(
                  fontFamily: "RedHatRegular",
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: theme ? Colors.black : Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 4,
                            color: Theme.of(context).scaffoldBackgroundColor),
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.1),
                              offset: Offset(0, 10))
                        ],
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: (pp == "")
                              ? AssetImage("assets/images/user.jpg")
                              : NetworkImage(pp),
                        )),
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 2,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            color: Color(0xff96D5EB),
                          ),
                          child: IconButton(
                              onPressed: () async {
                                if (accountType == 'Blind') {
                                  await tts.setSpeechRate(0.2);
                                  await tts.speak("edit photo");
                                }
                                displayBottomSheet(context);
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              )))),
                ],
              ),
            ),
            SizedBox(
              height: 25,
            ),
            buildTextField(username, un, "Username", "###", false),
            buildTextField(
                pass, "********", "Change Password", "********", true),
            buildTextField(phoneNum, pn, "Phone Number", "+010", false),
            buildTextField(
                blood, bt, "Blood Type", "A+,A-,B+,B-,AB+,AB-,O+,O-", false),
            buildTextField(medical, mc, "Medical Conditions", "...", false),
            buildTextField(dob, db, "Date of Birth", "DD/MM/YYYY", false),
            buildTextField(id, ni, "National ID", "***", false),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MaterialButton(
            minWidth: 150,
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 50),
            shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Color(0xff96D5EB),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20)),
            onLongPress: () async {
              if (accountType == 'Blind') {
                await tts.setSpeechRate(0.2);
                await tts.speak("cancel");
              }
            },
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Settings()));
            },
            child: Text("CANCEL",
                style: TextStyle(
                  fontFamily: "RedHatMedium",
                  fontSize: 14,
                  letterSpacing: 2.2,
                  color: Color(0xff96D5EB),
                )),
          ),
          MaterialButton(
            minWidth: 150,
            height: 50,
            onPressed: () {
              editProfile();
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Settings()));
            },
            onLongPress: () async {
              if (accountType == 'Blind') {
                await tts.setSpeechRate(0.2);
                await tts.speak("Save");
              }
            },
            color: Color(0xff96D5EB),
            padding: EdgeInsets.symmetric(horizontal: 50),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Text(
              " SAVE ",
              style: TextStyle(
                  fontFamily: "RedHatMedium",
                  fontSize: 14,
                  letterSpacing: 2.2,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController control, var x, String labelText,
      String placeholder, bool isPasswordTextField) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        onTap: () async {
          if (accountType == 'Blind') {
            await tts.setSpeechRate(0.2);
            await tts.speak(labelText);
          }
        },
        controller: control,
        obscureText: isPasswordTextField ? showPassword : false,
        decoration: InputDecoration(
            fillColor: theme ? Colors.black : Colors.white,
            suffixIcon: isPasswordTextField
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  )
                : null,
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: labelText,
            labelStyle: TextStyle(
              fontFamily: "RedHatMedium",
              fontSize: 25,
              color: Color(0xff96D5EB),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: (x == "") ? placeholder : x,
            hintStyle: TextStyle(
              fontSize: 18,
              color: (x == "")
                  ? Colors.grey
                  : theme
                      ? Colors.black
                      : Colors.white,
            )),
      ),
    );
  }
}

class getLocation extends StatefulWidget {
  @override
  _getLocationState createState() => _getLocationState();
}

class _getLocationState extends State<getLocation> {
  /*Position _currentPosition;
  String _currentAddress;
  GoogleMapController mapController;
  final LatLng _center = new LatLng( 37.421998333333335,-122.084);
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }*/
  String _currentAddress;
  GoogleMapController _controller;
  Location currentLocation = Location();
  Set<Marker> _markers = {};
  double x, y;

  void getLocation() async {
    var loc = await currentLocation.getLocation();
    _controller
        ?.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
      target: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
      zoom: 12.0,
    )));
    //print(loc.latitude);
    //print(loc.longitude);
    x = loc.latitude;
    y = loc.longitude;
    setState(() {
      _getAddressFromLatLng();
      _markers.add(Marker(
          markerId: MarkerId('Home'),
          position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: theme ? Colors.white : Colors.black,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: theme ? Colors.white : Colors.black,
          leading: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Icon(
              Icons.view_headline,
              color: Color(0xff96D5EB),
              size: 30,
            ),
          ),
          title: Text(
            'See',
            style: TextStyle(
              fontFamily: 'Lobster',
              color: Color(0xff96D5EB),
              fontSize: 40,
            ),
          ),
          actions: <Widget>[
            Icon(
              See.see,
              size: 60,
              color: Color(0xff96D5EB),
            ),
          ],
        ),
        drawer: NavBar(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(children: [
            if (_currentAddress != null)
              Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  _currentAddress,
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: "RedHatRegular",
                    color: theme ? Colors.black : Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: GoogleMap(
                mapType: MapType.hybrid,
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: LatLng(48.8561, 2.2930),
                  zoom: 12.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
                markers: _markers,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: MaterialButton(
                  onLongPress: () async {
                    if (accountType == 'Blind') {
                      await tts.setSpeechRate(0.2);
                      await tts.speak("Save location");
                    }
                  },
                  color: Color(0xff96D5EB),
                  child: Text(
                    "Save Location",
                    style: TextStyle(
                      fontFamily: "RedHatMedium",
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .update({
                      'Home latitude': x,
                      'Home longitude': y,
                    });
                    //MapUtils.openMap(x,y);
                  }),
            ),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: theme ? Colors.white : Colors.black,
          child: Icon(
            Icons.location_searching,
            color: Color(0xff96D5EB),
          ),
          onPressed: () async {
            if (accountType == 'Blind') {
              await tts.setSpeechRate(0.2);
              await tts.speak("Current location");
              getLocation();
            }
          },
        ),
      ),
      /*Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _center,
                            zoom: 11.0,
                          ),
                        ),
              ),
              if (_currentAddress != null) Text(
                  _currentAddress
              ),
              if (_currentPosition != null) Text(
                  "LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}"
              ),
              MaterialButton(
                child: Text("Get location"),
                onPressed: () {

                  _getCurrentLocation();
                },
              )
            ],
          ),
        ),*/
    );
  }

  /* _getCurrentLocation() async{
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();
      });
    }).catchError((e) {
      print(e);
    });
    print(_currentPosition);
  }*/
  _getAddressFromLatLng() async {
    try {
      List<geoc.Placemark> placemarks =
          await geoc.placemarkFromCoordinates(x, y);

      geoc.Placemark place = placemarks[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
        address = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }
}

class userInfo extends StatefulWidget {
  @override
  _userInfoState createState() => _userInfoState();
}

class _userInfoState extends State<userInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme ? Colors.white : Colors.black,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme ? Colors.white : Colors.black,
        leading: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Icon(
            Icons.view_headline,
            color: Color(0xff96D5EB),
            size: 30,
          ),
        ),
        title: Text(
          'See',
          style: TextStyle(
            fontFamily: 'Lobster',
            color: Color(0xff96D5EB),
            fontSize: 40,
          ),
        ),
        actions: <Widget>[
          Icon(
            See.see,
            size: 60,
            color: Color(0xff96D5EB),
          ),
        ],
      ),
      drawer: NavBar(),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "Personal Info",
                style: TextStyle(
                  fontFamily: "RedHatRegular",
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: theme ? Colors.black : Colors.white,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 4,
                        color: Theme.of(context).scaffoldBackgroundColor),
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.1),
                          offset: Offset(0, 10))
                    ],
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: (pp == "")
                          ? AssetImage("assets/images/user.jpg")
                          : NetworkImage(pp),
                    )),
              ),
              SizedBox(
                height: 10,
              ),

              /*Row(
                children: [
                  IconButton(onPressed: ()async{
                    await tts.setSpeechRate(0.2);
                    await tts.speak("username" + un);
                    }, icon: Icon(Icons.volume_down,color: Colors.orange,)),
                  Text("Username: $un",style: TextStyle(
                    fontSize: 25,
                  ),),
                ],
              ),*/
              TextButton(
                onPressed: () async {
                  if (accountType == 'Blind') {
                    await tts.setSpeechRate(0.2);
                    await tts.speak("username" + un);
                  }
                },
                child: Text(
                  "Username: $un",
                  style: TextStyle(
                    fontSize: 25,
                    color: theme ? Colors.black : Colors.white,
                    fontFamily: "RedHatMedium",
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (accountType == 'Blind') {
                    await tts.setSpeechRate(0.2);
                    await tts.speak("E mail" + finalEmail);
                  }
                },
                child: Text(
                  "Email: $finalEmail",
                  style: TextStyle(
                      fontSize: 25,
                      color: theme ? Colors.black : Colors.white,
                      fontFamily: "RedHatMedium"),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (accountType == 'Blind') {
                    await tts.setSpeechRate(0.2);
                    await tts.speak("account type" + accountType);
                  }
                },
                child: Text(
                  "Account type: $accountType",
                  style: TextStyle(
                      fontSize: 25,
                      color: theme ? Colors.black : Colors.white,
                      fontFamily: "RedHatMedium"),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (accountType == 'Blind') {
                    await tts.setSpeechRate(0.2);
                    await tts.speak("Phone Number" + pn);
                  }
                },
                child: Text(
                  "Phone Number: $pn",
                  style: TextStyle(
                      fontSize: 25,
                      color: theme ? Colors.black : Colors.white,
                      fontFamily: "RedHatMedium"),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (accountType == 'Blind') {
                    await tts.setSpeechRate(0.2);
                    await tts.speak("Date of birth" + db);
                  }
                },
                child: Text(
                  "Date of Birth: $db",
                  style: TextStyle(
                      fontSize: 25,
                      color: theme ? Colors.black : Colors.white,
                      fontFamily: "RedHatMedium"),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (accountType == 'Blind') {
                    await tts.setSpeechRate(0.2);
                    await tts.speak("National ID" + ni);
                  }
                },
                child: Text(
                  "National ID: $ni",
                  style: TextStyle(
                      fontSize: 25,
                      color: theme ? Colors.black : Colors.white,
                      fontFamily: "RedHatMedium"),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (accountType == 'Blind') {
                    await tts.setSpeechRate(0.2);
                    await tts.speak("Blood type" + bt);
                  }
                },
                child: Text(
                  "Blood Type: $bt",
                  style: TextStyle(
                      fontSize: 25,
                      color: theme ? Colors.black : Colors.white,
                      fontFamily: "RedHatMedium"),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (accountType == 'Blind') {
                    await tts.setSpeechRate(0.2);
                    await tts.speak("Medical conditions" + mc);
                  }
                },
                child: Text(
                  "Medical Conditions: $mc",
                  style: TextStyle(
                      fontSize: 25,
                      color: theme ? Colors.black : Colors.white,
                      fontFamily: "RedHatMedium"),
                ),
              ),
              (accountType == "Blind")
                  ? TextButton(
                      onPressed: () async {
                        if (accountType == 'Blind') {
                          await tts.setSpeechRate(0.2);
                          await tts.speak("Home Address" + address);
                        }
                      },
                      child: Text(
                        "Home Address: $address",
                        style: TextStyle(
                            fontSize: 25,
                            color: theme ? Colors.black : Colors.white,
                            fontFamily: "RedHatMedium"),
                      ),
                    )
                  : SizedBox(
                      height: 10,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class tracking extends StatefulWidget {
  @override
  _trackingState createState() => _trackingState();
}

class _trackingState extends State<tracking> {
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  GoogleMapController _controller;
  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/person.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  void getCurrentLocation() async {
    try {
      List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target: LatLng(newLocalData.latitude, newLocalData.longitude),
                  tilt: 0,
                  zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme ? Colors.white : Colors.black,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme ? Colors.white : Colors.black,
        leading: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Icon(
            Icons.view_headline,
            color: Color(0xff96D5EB),
            size: 30,
          ),
        ),
        title: Text(
          'See',
          style: TextStyle(
            fontFamily: 'Lobster',
            color: Color(0xff96D5EB),
            fontSize: 40,
          ),
        ),
        actions: <Widget>[
          Icon(
            See.see,
            size: 60,
            color: Color(0xff96D5EB),
          ),
        ],
      ),
      drawer: NavBar(),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: initialLocation,
        markers: Set.of((marker != null) ? [marker] : []),
        circles: Set.of((circle != null) ? [circle] : []),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.location_searching),
          onPressed: () {
            getCurrentLocation();
          }),
    );
  }
}

class AboutDevice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: theme ? Colors.white : Colors.black,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: theme ? Colors.white : Colors.black,
          leading: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Icon(
              Icons.view_headline,
              color: Color(0xff96D5EB),
              size: 30,
            ),
          ),
          title: Text(
            'See',
            style: TextStyle(
              fontFamily: 'Lobster',
              color: Color(0xff96D5EB),
              fontSize: 40,
            ),
          ),
          actions: <Widget>[
            Icon(
              See.see,
              size: 60,
              color: Color(0xff96D5EB),
            ),
          ],
        ),
        drawer: NavBar(),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "About Device",
                style: TextStyle(
                  fontFamily: "RedHatRegular",
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: theme ? Colors.black : Colors.white,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              if (accountType == "Blind")
                IconButton(
                    onPressed: () async {
                      if (accountType == 'Blind') {
                        await tts.setSpeechRate(0.2);
                        await tts.speak("About Device");
                      }
                    },
                    icon: Icon(
                      Icons.volume_down,
                      color: Colors.orange,
                      size: 40,
                    )),
              Text(
                "qwertyuuiopasdfghjkkfjjfffffffffffffffffjfffffffffff",
                style: TextStyle(
                    fontFamily: "RedHatMedium",
                    color: theme ? Colors.black : Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutUs extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: theme ? Colors.white : Colors.black,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: theme ? Colors.white : Colors.black,
          leading: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Icon(
              Icons.view_headline,
              color: Color(0xff96D5EB),
              size: 30,
            ),
          ),
          title: Text(
            'See',
            style: TextStyle(
              fontFamily: 'Lobster',
              color: Color(0xff96D5EB),
              fontSize: 40,
            ),
          ),
          actions: <Widget>[
            Icon(
              See.see,
              size: 60,
              color: Color(0xff96D5EB),
            ),
          ],
        ),
        drawer: NavBar(),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "About Us",
                style: TextStyle(
                  fontFamily: "RedHatRegular",
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: theme ? Colors.black : Colors.white,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              if (accountType == "Blind")
                IconButton(
                    onPressed: () async {
                      if (accountType == 'Blind') {
                        await tts.setSpeechRate(0.2);
                        await tts.speak("About Device");
                      }
                    },
                    icon: Icon(
                      Icons.volume_down,
                      color: Colors.orange,
                      size: 40,
                    )),
              Text(
                "qwertyuuiopasdfghjkkfjjfffffffffffffffffjfffffffffff",
                style: TextStyle(
                    fontFamily: "RedHatMedium",
                    color: theme ? Colors.black : Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Barcode extends StatefulWidget {
  @override
  _Barcode createState() => _Barcode();
}

class _Barcode extends State<Barcode> {
  String _scanBarcode = 'Unknown';
  List barcodes = ["none"];
  final player = AudioCache();


  @override
  void initState() {
    super.initState();
  }

  Future<void> startBarcodeScanStream() async {
    barcodes.clear();
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)
        .listen((barcode) {
      print(barcode);
      player.play('audios/audio.wav');
      barcodes.add(barcode);
      _scanBarcode = barcode;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    barcodes.clear();
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
      player.play('audios/audio.wav');
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      _scanBarcode = barcodeScanRes;
    });
    launchURL(barcodeScanRes);
  }

  void launchURL(url) async {
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: theme ? Colors.white : Colors.black,
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              backgroundColor: theme ? Colors.white : Colors.black,
              title: const Text(
                'Barcode scan',
                style: TextStyle(
                  fontFamily: "RedHatMedium",
                  fontSize: 30,
                  color: Color(0xff96D5EB),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.keyboard_backspace),
                color: Color(0xff96D5EB),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Home()));
                },
                iconSize: 30,
              ),
            ),
            body: Builder(builder: (BuildContext context) {
              return Container(
                  alignment: Alignment.center,
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        MaterialButton(
                          onLongPress: () async {
                            if (accountType == 'Blind') {
                              await tts.setSpeechRate(0.2);
                              await tts.speak("Start single scan");
                            }
                          },
                          height: 50,
                          minWidth: 300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          onPressed: () {
                            scanBarcodeNormal();
                          },
                          color: Color(0xff96D5EB),
                          child: Text(
                            'Start single scan',
                            style: TextStyle(
                              fontFamily: "RedHatMedium",
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        MaterialButton(
                          onLongPress: () async {
                            if (accountType == 'Blind') {
                              await tts.setSpeechRate(0.2);
                              await tts.speak("Start scan stream");
                            }
                          },
                          height: 50,
                          minWidth: 300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          onPressed: () {
                            startBarcodeScanStream();
                          },
                          color: Color(0xff96D5EB),
                          child: Text(
                            'Start scan stream',
                            style: TextStyle(
                              fontFamily: "RedHatMedium",
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        MaterialButton(
                            onLongPress: () async {
                              if (accountType == 'Blind') {
                                await tts.setSpeechRate(0.2);
                                await tts.speak("scan stream results");
                              }
                            },
                            height: 50,
                            minWidth: 300,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              side: BorderSide(
                                color: Color(0xff96D5EB),
                                width: 2,
                              ),
                            ),
                            color: theme ? Colors.white : Colors.black,
                            child: Text(
                              'Scan stream results',
                              style: TextStyle(
                                fontFamily: "RedHatMedium",
                                color: Color(0xff96D5EB),
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text(
                                    'Scan Stream Results',
                                    style: TextStyle(
                                      fontFamily: 'RedHatRegular',
                                    ),
                                  ),
                                  content: InkWell(
                                      child: Text(
                                        '$barcodes\n',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.red,
                                          fontFamily: 'RedHatRegular',
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      onTap: () {
                                        launchURL(barcodes);
                                      }),
                                  actions: <Widget>[
                                    IconButton(
                                        onPressed: () async {
                                          if (accountType == 'Blind') {
                                            await tts.setSpeechRate(0.2);
                                            await tts.speak(
                                                "Scan stream results" +
                                                    barcodes.toString());
                                          }
                                        },
                                        icon: Icon(
                                          Icons.volume_down,
                                          color: Colors.orange,
                                        )),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'OK'),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        SizedBox(
                          height: 30,
                        ),
                        IconButton(
                            onPressed: () async {
                              if (accountType == 'Blind') {
                                await tts.setSpeechRate(0.2);
                                await tts.speak("Scan result" + _scanBarcode);
                              }
                            },
                            icon: Icon(
                              Icons.volume_down,
                              color: Colors.orange,
                              size: 40,
                            )),
                        Text(
                          'Scan result:',
                          style: TextStyle(
                              fontSize: 25,
                              fontFamily: 'RedHatRegular',
                              color: theme ? Colors.black : Colors.white),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                            child: Text(
                              '$_scanBarcode\n',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.red,
                                fontFamily: 'RedHatRegular',
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            onTap: () {
                              if (_scanBarcode != 'Unknown') {
                                launchURL(_scanBarcode);
                              }
                            }),
                      ]));
            })));
  }
}


class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}
class IndexState extends State<IndexPage> {
  /*final fb = FirebaseDatabase.instance;
  void initState() {
    super.initState();
    FirebaseDatabase.instance.ref().onValue.listen((event) {
      final data = event.snapshot;
      if (data.value != null) {
        data.children.forEach((element) {
          u=element.child("Sender");
          if(element.key.contains(currentUser.uid)){
            onJoin();
          }
          print(element.key);
        });
      }
    });
  }*/

  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();

  /// if channel textField is validated to have error
  bool _validateError = false;

  ClientRole _role = ClientRole.Broadcaster;

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final ref = fb.ref();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme ? Colors.white : Colors.black,
        title: const Text(
          'Online Call',
          style: TextStyle(
            fontFamily: "RedHatMedium",
            fontSize: 30,
            color: Color(0xff96D5EB),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace),
          color: Color(0xff96D5EB),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home()));
          },
          iconSize: 30,
        ),
      ),
      backgroundColor: theme ? Colors.white : Colors.black,
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 400,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    controller: _channelController,
                    decoration: InputDecoration(
                      errorText:
                          _validateError ? 'Channel name is mandatory' : null,
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      hintText: 'Channel name',
                    ),
                  ))
                ],
              ),
              Column(
                children: [
                  ListTile(
                    title: Text(ClientRole.Broadcaster.toString()),
                    leading: Radio(
                      value: ClientRole.Broadcaster,
                      groupValue: _role,
                      onChanged: (ClientRole value) {
                        setState(() {
                          _role = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(ClientRole.Audience.toString()),
                    leading: Radio(
                      value: ClientRole.Audience,
                      groupValue: _role,
                      onChanged: (ClientRole value) {
                        setState(() {
                          _role = value;
                        });
                      },
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onJoin,
                        child: Text('Join'),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blueAccent),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white)),
                      ),
                    ),
                    /*Row(
                      children: [
                        MaterialButton(
                          child: Text("Call"),
                            onPressed: (){
                              ref
                                  .child(currentUser.uid+" "+fuid)
                                  .set({
                                'State': "sent",
                                'Channel name': "See",
                                'Token': Token,
                                'AppID':APP_ID,
                                'Sender':currentUser.email,
                                'Receiver':df,
                              });
                            })
                      ],
                    ),*/
                    // Expanded(
                    //   child: RaisedButton(
                    //     onPressed: onJoin,
                    //     child: Text('Join'),
                    //     color: Colors.blueAccent,
                    //     textColor: Colors.white,
                    //   ),
                    // )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    // update input validation
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    //if (_channelController.text.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
       await _handleCameraAndMic(per.Permission.camera);
       await _handleCameraAndMic(per.Permission.microphone);
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: _channelController.text,
            role: _role,
          ),
        ),
      );
    //}
  }

  Future<void> _handleCameraAndMic(per.Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}
class CallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;

  /// non-modifiable client role of the page
  final ClientRole role;

  /// Creates a call page with given channel name.
  const CallPage({Key key, this.channelName, this.role}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}
class _CallPageState extends State<CallPage> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  RtcEngine _engine;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid,channelId: null,)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return Text(
                    "null"); // return type can't be null, a widget was required
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    /*final fb = FirebaseDatabase.instance;
    final ref = fb.ref();
    if (u==currentUser.email) {
      ref
          .child(currentUser.uid + " " + fuid)
          .remove();
    }
    else {
      ref
          .child(fuid + " " + currentUser.uid)
          .remove();
    }*/
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agora Flutter QuickStart'),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}

/*audioplayers: ^0.20.1
  import 'package:audioplayers/audioplayers.dart';
  final player = AudioCache();
  player.play('audio.wav');*/

/*class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "SCAN",
          style: TextStyle(
            fontFamily: "RubikItalic",
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xff96D5EB),
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(context,MaterialPageRoute(builder: (context) => Home()));
          },
          iconSize: 30,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                      overlay: QrScannerOverlayShape(
                        borderWidth: 10,
                        borderLength: 20,
                        borderRadius: 10,
                        cutOutSize: MediaQuery.of(context).size.width*0.8,
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red,
                            width: 4,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text('Scan QR or Barcode'),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }


  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      if (await canLaunch(scanData.code)) {
        await launch(scanData.code);
        controller.resumeCamera();
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Could not find viable url'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Barcode Type: ${describeEnum(scanData.format)}'),
                    Text('Data: ${scanData.code}'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        ).then((value) => controller.resumeCamera());
      }
    });
  }
}*/
class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  int _remoteUid;
   RtcEngine _engine;
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  final fb = FirebaseDatabase.instance;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.ref().onValue.listen((event) {
      final data = event.snapshot;
      if (data.value != null) {
        data.children.forEach((element) {
          u=element.child("Sender").value;
          if(element.key.contains(currentUser.uid)){
          }
          print(element.key);
          print(u);
        });
      }
    });
    final ref = fb.ref();
    ref
        .child(currentUser.uid+" "+fuid)
        .set({
      'State': "sent",
      'Channel name': "See",
      //'Token': Token,
      'AppID':APP_ID,
      'Sender':currentUser.email,
      'Receiver':df,
    });
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [per.Permission.microphone, per.Permission.camera].request();

    //create the engine
    _engine = await RtcEngine.create("06bae84557cd443ab0b17be7e0374fd8");
    await _engine.enableVideo();
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print("local user $uid joined");
        },
        userJoined: (int uid, int elapsed) {
          print("remote user $uid joined");
          setState(() {
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          print("remote user $uid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.joinChannel(null, "test", null, 0);
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Wrap( //will break to another line on overflow
        direction: Axis.horizontal, //use vertical to show  on vertical axis
        children: <Widget>[
          Container(
              margin:EdgeInsets.all(10),
              child: FloatingActionButton(
                onPressed: _onToggleMute,
                child: Icon(
                  muted ? Icons.mic_off : Icons.mic,
                  color: muted ? Colors.white : Colors.blueAccent,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,

                backgroundColor: muted ? Colors.blueAccent : Colors.white,
              )
          ), //button first
          Container(
              margin:EdgeInsets.all(10),
              child: FloatingActionButton(
                onPressed: () => _onCallEnd(context),
                child: Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 35.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                backgroundColor: Colors.redAccent,
              )
          ), // button second
          Container(
              margin:EdgeInsets.all(10),
              child: FloatingActionButton(
                onPressed: _onSwitchCamera,
                child: Icon(
                  Icons.switch_camera,
                  color: Colors.blueAccent,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                backgroundColor: Colors.white,
              )
          ), // button third// Add more buttons here
        ],
      ),
      body: Stack(
        children: [
          Center(
                child: _remoteVideo(),
              ),
        ],
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(uid: _remoteUid);
    } else {
      return Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
  void _onCallEnd(BuildContext context) {
    if (u==currentUser.email) {
      FirebaseDatabase.instance.ref()
          .child(currentUser.uid + " " + fuid)
          .remove();
    }
    else {
      FirebaseDatabase.instance.ref()
          .child(fuid + " " + currentUser.uid)
          .remove();
    }
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }
}

class Led extends StatefulWidget {

  @override
  _LedState createState() => _LedState();
}

class _LedState extends State<Led> {
  int _counter = 0;
  bool newStatus = false;

  void toggleSwitch(switchStatus) {
    var client = http.Client();
    try{
      var url = "http://192.168.1.5:3000/switchLed";
      client.post(Uri.parse(url), body: json.encode({'status': newStatus}),
          headers: {'Content-type':'application/json'}).then((response){
        print('status: ${newStatus.toString()}');
      });
    }
    finally{
      client.close();
    }
    setState(() {
      newStatus = !newStatus;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: theme ? Colors.white : Colors.black,
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              backgroundColor: theme ? Colors.white : Colors.black,
              title: const Text(
                'Test',
                style: TextStyle(
                  fontFamily: "RedHatMedium",
                  fontSize: 30,
                  color: Color(0xff96D5EB),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.keyboard_backspace),
                color: Color(0xff96D5EB),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Home()));
                },
                iconSize: 30,
              ),
            ),
            body: Builder(builder: (BuildContext context) {
              return Center(
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
                child: Column(
                  // Column is also a layout widget. It takes a list of children and
                  // arranges them vertically. By default, it sizes itself to fit its
                  // children horizontally, and tries to be as tall as its parent.
                  //
                  // Invoke "debug painting" (press "p" in the console, choose the
                  // "Toggle Debug Paint" action from the Flutter Inspector in Android
                  // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                  // to see the wireframe for each widget.
                  //
                  // Column has various properties to control how it sizes itself and
                  // how it positions its children. Here we use mainAxisAlignment to
                  // center the children vertically; the main axis here is the vertical
                  // axis because Columns are vertical (the cross axis would be
                  // horizontal).
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Turn the led ${newStatus!=true?'on':'off'}',
                      style: TextStyle(fontSize: 32),
                    ),
                    Transform.scale(
                      scale: 3.0,
                      child: new Switch(onChanged: toggleSwitch, value: newStatus),
                    ),
                  ],
                ),
              );
            })));
  }
}


/*class Rtm extends StatefulWidget {
  @override
  _RtmState createState() => _RtmState();
}

class _RtmState extends State<Rtm> {
  bool _isLogin = false;
  bool _isInChannel = false;

  final _userNameController = TextEditingController();
  final _peerUserIdController = TextEditingController();
  final _peerMessageController = TextEditingController();
  final _invitationController = TextEditingController();
  final _channelNameController = TextEditingController();
  final _channelMessageController = TextEditingController();

  final _infoStrings = <String>[];

  AgoraRtmClient _client;
  AgoraRtmChannel _channel;

  @override
  void initState() {
    super.initState();
    _createClient();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme ? Colors.white : Colors.black,
        title: const Text(
          'Online Call',
          style: TextStyle(
            fontFamily: "RedHatMedium",
            fontSize: 30,
            color: Color(0xff96D5EB),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace),
          color: Color(0xff96D5EB),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home()));
          },
          iconSize: 30,
        ),
      ),
          body: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildLogin(),
                _buildQueryOnlineStatus(),
                _buildSendPeerMessage(),
                _buildSendLocalInvitation(),
                _buildJoinChannel(),
                _buildGetMembers(),
                _buildSendChannelMessage(),
                _buildInfoList(),
              ],
            ),
          )),
    );
  }

  void _createClient() async {
    _client = await AgoraRtmClient.createInstance(APP_ID);
    _client?.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      _log("Peer msg: " + peerId + ", msg: " + (message.text));
    };
    _client?.onConnectionStateChanged = (int state, int reason) {
      _log('Connection state changed: ' +
          state.toString() +
          ', reason: ' +
          reason.toString());
      if (state == 5) {
        _client?.logout();
        _log('Logout.');
        setState(() {
          _isLogin = false;
        });
      }
    };
    _client?.onLocalInvitationReceivedByPeer =
        (AgoraRtmLocalInvitation invite) {
      _log(
          'Local invitation received by peer: ${invite.calleeId}, content: ${invite.content}');
    };
    _client?.onRemoteInvitationReceivedByPeer =
        (AgoraRtmRemoteInvitation invite) {
      _log(
          'Remote invitation received by peer: ${invite.callerId}, content: ${invite.content}');
    };
  }

  Future<AgoraRtmChannel> _createChannel(String name) async {
    AgoraRtmChannel channel = await _client?.createChannel(name);
    if (channel != null) {
      channel.onMemberJoined = (AgoraRtmMember member) {
        _log("Member joined: " +
            member.userId +
            ', channel: ' +
            member.channelId);
      };
      channel.onMemberLeft = (AgoraRtmMember member) {
        _log(
            "Member left: " + member.userId + ', channel: ' + member.channelId);
      };
      channel.onMessageReceived =
          (AgoraRtmMessage message, AgoraRtmMember member) {
        _log("Channel msg: " + member.userId + ", msg: " + message.text);
      };
    }
    return channel;
  }

  static TextStyle textStyle = TextStyle(fontSize: 18, color: Colors.blue);

  Widget _buildLogin() {
    return Row(children: <Widget>[
      _isLogin
          ? new Expanded(
          child: new Text('User Id: ' + _userNameController.text,
              style: textStyle))
          : new Expanded(
          child: new TextField(
              controller: _userNameController,
              decoration: InputDecoration(hintText: 'Input your user id'))),
      new OutlineButton(
        child: Text(_isLogin ? 'Logout' : 'Login', style: textStyle),
        onPressed: _toggleLogin,
      )
    ]);
  }

  Widget _buildQueryOnlineStatus() {
    if (!_isLogin) {
      return Container();
    }
    return Row(children: <Widget>[
      new Expanded(
          child: new TextField(
              controller: _peerUserIdController,
              decoration: InputDecoration(hintText: 'Input peer user id'))),
      new OutlineButton(
        child: Text('Query Online', style: textStyle),
        onPressed: _toggleQuery,
      )
    ]);
  }

  Widget _buildSendPeerMessage() {
    if (!_isLogin) {
      return Container();
    }
    return Row(children: <Widget>[
      new Expanded(
          child: new TextField(
              controller: _peerMessageController,
              decoration: InputDecoration(hintText: 'Input peer message'))),
      new OutlineButton(
        child: Text('Send to Peer', style: textStyle),
        onPressed: _toggleSendPeerMessage,
      )
    ]);
  }

  Widget _buildSendLocalInvitation() {
    if (!_isLogin) {
      return Container();
    }
    return Row(children: <Widget>[
      new Expanded(
          child: new TextField(
              controller: _invitationController,
              decoration:
              InputDecoration(hintText: 'Input invitation content'))),
      new OutlineButton(
        child: Text('Send local invitation', style: textStyle),
        onPressed: _toggleSendLocalInvitation,
      )
    ]);
  }

  Widget _buildJoinChannel() {
    if (!_isLogin) {
      return Container();
    }
    return Row(children: <Widget>[
      _isInChannel
          ? new Expanded(
          child: new Text('Channel: ' + _channelNameController.text,
              style: textStyle))
          : new Expanded(
          child: new TextField(
              controller: _channelNameController,
              decoration: InputDecoration(hintText: 'Input channel id'))),
      new OutlineButton(
        child: Text(_isInChannel ? 'Leave Channel' : 'Join Channel',
            style: textStyle),
        onPressed: _toggleJoinChannel,
      )
    ]);
  }

  Widget _buildSendChannelMessage() {
    if (!_isLogin || !_isInChannel) {
      return Container();
    }
    return Row(children: <Widget>[
      new Expanded(
          child: new TextField(
              controller: _channelMessageController,
              decoration: InputDecoration(hintText: 'Input channel message'))),
      new OutlineButton(
        child: Text('Send to Channel', style: textStyle),
        onPressed: _toggleSendChannelMessage,
      )
    ]);
  }

  Widget _buildGetMembers() {
    if (!_isLogin || !_isInChannel) {
      return Container();
    }
    return Row(children: <Widget>[
      new OutlineButton(
        child: Text('Get Members in Channel', style: textStyle),
        onPressed: _toggleGetMembers,
      )
    ]);
  }

  Widget _buildInfoList() {
    return Expanded(
        child: Container(
            child: ListView.builder(
              itemExtent: 24,
              itemBuilder: (context, i) {
                return ListTile(
                  contentPadding: const EdgeInsets.all(0.0),
                  title: Text(_infoStrings[i]),
                );
              },
              itemCount: _infoStrings.length,
            )));
  }

  void _toggleLogin() async {
    if (_isLogin) {
      try {
        await _client?.logout();
        _log('Logout success.');

        setState(() {
          _isLogin = false;
          _isInChannel = false;
        });
      } catch (errorCode) {
        _log('Logout error: ' + errorCode.toString());
      }
    } else {
      String userId = _userNameController.text;
      if (userId.isEmpty) {
        _log('Please input your user id to login.');
        return;
      }

      try {
        await _client?.login(null, userId);
        _log('Login success: ' + userId);
        setState(() {
          _isLogin = true;
        });
      } catch (errorCode) {
        _log('Login error: ' + errorCode.toString());
      }
    }
  }

  void _toggleQuery() async {
    String peerUid = _peerUserIdController.text;
    if (peerUid.isEmpty) {
      _log('Please input peer user id to query.');
      return;
    }
    try {
      Map<dynamic, dynamic> result =
      await _client?.queryPeersOnlineStatus([peerUid]);
      _log('Query result: ' + result.toString());
    } catch (errorCode) {
      _log('Query error: ' + errorCode.toString());
    }
  }

  void _toggleSendPeerMessage() async {
    String peerUid = _peerUserIdController.text;
    if (peerUid.isEmpty) {
      _log('Please input peer user id to send message.');
      return;
    }

    String text = _peerMessageController.text;
    if (text.isEmpty) {
      _log('Please input text to send.');
      return;
    }

    try {
      AgoraRtmMessage message = AgoraRtmMessage.fromText(text);
      _log(message.text);
      await _client?.sendMessageToPeer(peerUid, message, false);
      _log('Send peer message success.');
    } catch (errorCode) {
      _log('Send peer message error: ' + errorCode.toString());
    }
  }

  void _toggleSendLocalInvitation() async {
    String peerUid = _peerUserIdController.text;
    if (peerUid.isEmpty) {
      _log('Please input peer user id to send invitation.');
      return;
    }

    String text = _invitationController.text;
    if (text.isEmpty) {
      _log('Please input content to send.');
      return;
    }

    try {
      AgoraRtmLocalInvitation invitation =
      AgoraRtmLocalInvitation(peerUid, content: text);
      _log(invitation.content ?? '');
      await _client?.sendLocalInvitation(invitation.toJson());
      _log('Send local invitation success.');
    } catch (errorCode) {
      _log('Send local invitation error: ' + errorCode.toString());
    }
  }

  void _toggleJoinChannel() async {
    if (_isInChannel) {
      try {
        await _channel?.leave();
        _log('Leave channel success.');
        if (_channel != null) {
          _client?.releaseChannel(_channel.channelId);
        }
        _channelMessageController.clear();

        setState(() {
          _isInChannel = false;
        });
      } catch (errorCode) {
        _log('Leave channel error: ' + errorCode.toString());
      }
    } else {
      String channelId = _channelNameController.text;
      if (channelId.isEmpty) {
        _log('Please input channel id to join.');
        return;
      }

      try {
        _channel = await _createChannel(channelId);
        await _channel?.join();
        _log('Join channel success.');

        setState(() {
          _isInChannel = true;
        });
      } catch (errorCode) {
        _log('Join channel error: ' + errorCode.toString());
      }
    }
  }

  void _toggleGetMembers() async {
    try {
      List<AgoraRtmMember> members = await _channel?.getMembers();
      _log('Members: ' + members.toString());
    } catch (errorCode) {
      _log('GetMembers failed: ' + errorCode.toString());
    }
  }

  void _toggleSendChannelMessage() async {
    String text = _channelMessageController.text;
    if (text.isEmpty) {
      _log('Please input text to send.');
      return;
    }
    try {
      await _channel?.sendMessage(AgoraRtmMessage.fromText(text));
      _log('Send channel message success.');
    } catch (errorCode) {
      _log('Send channel message error: ' + errorCode.toString());
    }
  }

  void _log(String info) {
    print(info);
    setState(() {
      _infoStrings.insert(0, info);
    });
  }
}*/