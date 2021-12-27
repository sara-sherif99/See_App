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
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

String finalEmail;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email And Password Login',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      home: Splash(),
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
  void initState(){
    getValidationData().whenComplete(() async{
      Timer(Duration(seconds: 2),()=>Navigator.push(context,MaterialPageRoute(builder: (context) => finalEmail == null? FirstScreen():Home())));
    });
    super.initState();
  }
  Future getValidationData() async{
    final SharedPreferences sharedPreferences= await SharedPreferences.getInstance();
    var obtainedEmail = sharedPreferences.getString("email");
    setState(() {
      finalEmail = obtainedEmail;
    });
    print(finalEmail);
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
              SizedBox(
                height: 40,
              ),
              MaterialButton(
                height: 50,
                minWidth: 300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LogIn()));
                },
                color: Colors.white,
                child: Text(
                  "Log in",
                  style: TextStyle(
                    color: Color(0xff061c36),
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              MaterialButton(
                height: 50,
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Sign()));
                },
                minWidth: 300,
                child: Text(
                  "Sign up",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
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
  void initState()
  {
    super.initState();
  }
  final _formkey = GlobalKey<FormState>();

  TextEditingController _emailcontroller = TextEditingController();

  TextEditingController _passwordcontroller = TextEditingController();

  bool firstValue = false;
  bool secondValue = false;
  @override
  void dispose()
  {
    _emailcontroller.dispose();

    _passwordcontroller.dispose();

    super.dispose();
  }
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "LOG IN",
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
                      color: Colors.black,
                      //color: Color(0xff4F7F8F),
                    ),
                  ),
                  Text(
                    'See',
                    style: TextStyle(
                      fontSize: 50,
                      fontFamily: 'Lobster',
                      color: Colors.black,
                      //color: Color(0xff4F7F8F),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    child: TextFormField(
                      controller: _emailcontroller,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Colors.grey,
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
                        labelText: "Email or Username",
                        hintText: "*****@abc.com",
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      controller: _passwordcontroller,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Colors.grey,
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
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
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
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                      onPressed: () async {
                        if(_formkey.currentState.validate()){
                          var result = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailcontroller.text, password: _passwordcontroller.text);
                          if(result != null){
                            print(result);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          }else{
                            print('user not found');
                          }
                        }
                        final SharedPreferences sharedPreferences= await SharedPreferences.getInstance();
                        sharedPreferences.setString("email", _emailcontroller.text);
                      }
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

class Sign extends StatefulWidget {
  @override
  _SignUp createState() => _SignUp();
}

class _SignUp extends State<Sign> {
  //bool _value = false;
  Hash hasher = sha512;
  int val = -1;
  bool _isObscure = true;
  void initState()
  {
    super.initState();
  }

  final _formkey = GlobalKey<FormState>();

  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  TextEditingController _accounttypecontroller = TextEditingController();
  TextEditingController _checkpasscontroller = TextEditingController();

  @override

  void dispose()
  {
    _emailcontroller.dispose();

    _passwordcontroller.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Sign up",
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
                      size: 80,
                    ),
                  ),
                  Text(
                    'See',
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: 'Lobster',
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Colors.grey,
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
                        labelText: "Email or Username",
                        hintText: "*****@abc.com",
                        prefixIcon: Icon(Icons.person),
                      ),
                      controller: _emailcontroller,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Colors.grey,
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
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                        controller: _passwordcontroller,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: TextField(
                      controller: _checkpasscontroller,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Colors.grey,
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
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
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
                            onChanged: (value) {
                              setState(() {
                                val = value;
                                _accounttypecontroller.text="Blind";
                              });
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
                            onChanged: (value) {
                              setState(() {
                                val = value;
                                _accounttypecontroller.text="Friend";
                              });
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
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async{

                      final Random _random = Random.secure();
                      String salting([int length = 2]) {
                        var values = List<int>.generate(length, (i) => _random.nextInt(256));

                        return base64Url.encode(values);
                      }
                      String salt=salting().toString();
                      String hashedPass=salt+_passwordcontroller.text;
                      var bytes = utf8.encode(hashedPass); // data being hashed
                      var digest = hasher.convert(bytes);

                      final SharedPreferences sharedPreferences= await SharedPreferences.getInstance();
                      sharedPreferences.setString("email", _emailcontroller.text);

                      if(_checkpasscontroller!=_passwordcontroller){
                        print("wrong password");
                      }
                      if(_formkey.currentState.validate()){
                        var result = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailcontroller.text, password: _passwordcontroller.text);
                        User user = result.user;
                        print(hashedPass);
                        if(result != null)
                        {
                          var userInfo = FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                            'email':_emailcontroller.text,
                            'account type':_accounttypecontroller.text,
                            'password':digest.toString(),
                            'userid': user.uid,
                            'salt':salt
                          });
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                          );
                        }else{
                          print('please try later');
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
  @override
  //void initState() {
    //super.initState();
  //}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff96D5EB),
          leading: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Icon(
              Icons.view_headline,
              color: Colors.white,
              size: 30,
            ),
          ),
          title: Text(
            'See',
            style: TextStyle(
              fontFamily: 'Lobster',
              fontSize: 40,
            ),
          ),
          actions: <Widget>[
            Icon(
              See.see,
              size: 60,
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
                    color: b1 ? Colors.white : Colors.white,
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
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        b1 = !b1;
                      });
                    },
                  ),
                  MaterialButton(
                    height: 150,
                    minWidth: 150,
                    color: b2 ? Colors.white : Colors.white,
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
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        b2 = !b2;
                      });
                    },
                  ),
                  MaterialButton(
                    height: 150,
                    minWidth: 150,
                    color: b3 ? Colors.white : Colors.white,
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
                          Icons.headset,
                          color: b3 ? Colors.red : Color(0xff96D5EB),
                          size: 40,
                        ),
                        Text(
                          "Audio",
                          style: TextStyle(
                            color: b3 ? Colors.red : Color(0xff96D5EB),
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        b3 = !b3;
                      });
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
                    color: b4 ? Colors.white : Colors.white,
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
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        b4 = !b4;
                      });
                    },
                  ),
                  MaterialButton(
                    height: 150,
                    minWidth: 150,
                    color: b5 ? Colors.white : Colors.white,
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
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        b5 = !b5;
                      });
                    },
                  ),
                  MaterialButton(
                    height: 150,
                    minWidth: 150,
                    color: b6 ? Colors.white : Colors.white,
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
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        b6 = !b6;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        drawer: NavBar(),
        floatingActionButton: Container(
          width: 120,
          height: 50,
          child: new FloatingActionButton.extended(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              label: Text(
                "Scan",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              icon: Icon(
                Icons.settings_overscan,
                size: 30,
              ),
              backgroundColor: new Color(0xff96D5EB),
              onPressed: () {
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff96D5EB),
          leading: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Icon(
              Icons.view_headline,
              color: Colors.white,
              size: 30,
            ),
          ),
          title: Text(
            'See',
            style: TextStyle(
              fontFamily: 'Lobster',
              fontSize: 40,
            ),
          ),
          actions: <Widget>[
            Icon(
              See.see,
              size: 60,
            ),
          ],
        ),
        drawer: NavBar(),
        body: SingleChildScrollView(
          child: Center(
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
                      fontFamily: "RubikItalic",
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding: new EdgeInsets.all(20.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(
                            color: Color(0xff96D5EB),
                            width: 2,
                          )),
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          const ListTile(
                            leading: Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xff96D5EB),
                            ),
                            title: Text('Username',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  color: Color(0xff96D5EB),
                                )),
                            subtitle: Text('email@abx.com',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Color(0xff96D5EB),
                                )),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.end,
                            children: <Widget>[
                              MaterialButton(
                                child: Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {/* ... */},
                                color: Color(0xff96D5EB),
                              ),
                              MaterialButton(
                                color: Color(0xff96D5EB),
                                child: Text(
                                  'Remove',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {/* ... */},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  MaterialButton(
                    height: 40,
                    minWidth: 50,
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide(
                          width: 0,
                          color: Color(0xff96D5EB),
                        )),
                    color: Color(0xff96D5EB),
                    child: Text(
                      '+ Add Friend',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: Colors.white,
                                  )),
                              scrollable: true,
                              title: Text('Add Friend',style: TextStyle(fontSize: 30),textAlign: TextAlign.center,),
                              content: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Form(
                                  child: Column(
                                    children: <Widget>[
                                      TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                          icon: Icon(Icons.person),
                                        ),
                                      ),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          icon: Icon(Icons.lock ),
                                        ),
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
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {Navigator.pop(context);},
                                  ),
                                ),
                              ],
                            );
                          });
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

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff96D5EB),
          leading: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Icon(
              Icons.view_headline,
              color: Colors.white,
              size: 30,
            ),
          ),
          title: Text(
            'See',
            style: TextStyle(
              fontFamily: 'Lobster',
              fontSize: 40,
            ),
          ),
          actions: <Widget>[
            Icon(
              See.see,
              size: 60,
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
                      fontFamily: "RubikItalic",
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: SizedBox(
                  width: 160,
                  child: MaterialButton(
                    height: 45,
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => Profile()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Edit Profile",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                          ),
                        ),
                         Icon(Icons.edit,size: 20,color: Colors.red,)
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      side: BorderSide(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Account",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              buildAccountOptionRow(
                  context, "Linked Devices", "Remove", "Device"),
              buildAccountOptionRow(context, "Contacts", "Remove", "Contact"),
              buildDeactivateAccountOptionRow(context, "Deactivate Account"),
              SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "General",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              buildAccountOptionRow(context, "Language", "Set", "Language"),
              buildPrivacyAndSecurityOptionRow(
                context,
                "Privacy and Security",
              ),
              SizedBox(
                height: 50,
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
                        Text(option + " 1"),
                        MaterialButton(
                          onPressed: () {},
                          child: Text(
                            label,
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(option + " 2"),
                        MaterialButton(
                          onPressed: () {},
                          child: Text(
                            label,
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      ],
                    ),
                    MaterialButton(
                      onPressed: () {},
                      child: Text("+ Add",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
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

  GestureDetector buildPrivacyAndSecurityOptionRow(
    BuildContext context,
    String title,
  ) {
    return GestureDetector(
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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        color: Colors.red,
                        child: Text(
                          "Deactivate Account",
                          style: TextStyle(color: Colors.white),
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
  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xff96D5EB),
        leading: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Icon(
            Icons.view_headline,
            color: Colors.white,
            size: 30,
          ),
        ),
        title: Text(
          'See',
          style: TextStyle(
            fontFamily: 'Lobster',
            fontSize: 40,
          ),
        ),
        actions: <Widget>[
          Icon(
            See.see,
            size: 60,
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
                  "Edit Profile",
                  style: TextStyle(
                    fontFamily: "RubikItalic",
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
                              image: AssetImage("assets/images/user.jpg"),)),
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
                            color: Colors.grey,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 25,
              ),
              buildTextField("Full Name", "example", false),
              buildTextField("E-mail", "abc@gmail.com", false),
              buildTextField("Password", "********", true),
              buildTextField("Location", "Ismalia, Egypt", false),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MaterialButton(
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Color(0xff96D5EB),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) => Settings()));},
                    child: Text("CANCEL",
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.black)),
                  ),
                  MaterialButton(
                    height: 40,
                    onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) => Settings()));},
                    color: Color(0xff96D5EB),
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      "SAVE",
                      style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 2.2,
                          color: Colors.white),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
    );
  }

  Widget buildTextField(
      String labelText, String placeholder, bool isPasswordTextField) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        obscureText: isPasswordTextField ? showPassword : false,
        decoration: InputDecoration(
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
              fontSize: 25,
              color: Colors.black,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            )),
      ),
    );
  }
}

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff96D5EB),
          leading: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Icon(
              Icons.view_headline,
              color: Colors.white,
              size: 30,
            ),
          ),
          title: Text(
            'See',
            style: TextStyle(
              fontFamily: 'Lobster',
              fontSize: 40,
            ),
          ),
          actions: <Widget>[
            Icon(
              See.see,
              size: 60,
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
                "Home Location",
                style: TextStyle(
                  fontFamily: "RubikItalic",
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text("Ismalia,Egypt"),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutDevice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff96D5EB),
          leading: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Icon(
              Icons.view_headline,
              color: Colors.white,
              size: 30,
            ),
          ),
          title: Text(
            'See',
            style: TextStyle(
              fontFamily: 'Lobster',
              fontSize: 40,
            ),
          ),
          actions: <Widget>[
            Icon(
              See.see,
              size: 60,
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
                  fontFamily: "RubikItalic",
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text("qwertyuuiopasdfghjkkfjjfffffffffffffffffjfffffffffff"),
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
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff96D5EB),
          leading: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Icon(
              Icons.view_headline,
              color: Colors.white,
              size: 30,
            ),
          ),
          title: Text(
            'See',
            style: TextStyle(
              fontFamily: 'Lobster',
              fontSize: 40,
            ),
          ),
          actions: <Widget>[
            Icon(
              See.see,
              size: 60,
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
                  fontFamily: "RubikItalic",
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text("qwertyuuiopasdfghjkkfjjfffffffffffffffffjfffffffffff"),
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
  List barcodes=["none"];
  final player = AudioCache();


  @override
  void initState() {
    super.initState();
  }

  Future<void> startBarcodeScanStream() async {
    barcodes.clear();
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)
        .listen((barcode) { print(barcode);
    player.play('audios/audio.wav');
    barcodes.add(barcode);
    _scanBarcode=barcode;
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
      _scanBarcode= barcodeScanRes;
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
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Color(0xff96D5EB),
              title: const Text(
                'Barcode scan',
                style: TextStyle(
                  fontFamily: "RubikItalic",
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.keyboard_backspace),
                color: Colors.white,
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
                              color: Colors.white,
                              fontSize: 25,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        MaterialButton(
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
                              color: Colors.white,
                              fontSize: 25,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        MaterialButton(
                          height: 50,
                            minWidth: 150,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            color: Colors.red,
                            child: Text(
                              'Scan stream results',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          onPressed: () { showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title:  Text('Scan Stream Results'),
                              content: InkWell(child: Text('$barcodes\n',style: TextStyle(fontSize: 20,color: Colors.red,decoration: TextDecoration.underline,),),
                                  onTap:() {launchURL(barcodes);}),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );}
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text('Scan result:',
                          style: TextStyle(fontSize: 25),textAlign: TextAlign.left,),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(child: Text('$_scanBarcode\n',style: TextStyle(fontSize: 30,color: Colors.red,decoration: TextDecoration.underline,),),
                        onTap:() {launchURL(_scanBarcode);}),


                      ]));
            })));
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
