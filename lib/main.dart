import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graduation/NavBar.dart';
//import 'package:graduation/icons.dart';
import 'package:graduation/see.dart';

void main() => runApp(
      MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => FirstScreen(),
          '/second': (context) => Home(),
          '/login': (context) => LogIn(),
          '/sign': (context) => Sign(),
        },
      ),
    );

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              //colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop),
              image: AssetImage("assets/images/background.jpg"),
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
                  Navigator.push(context,MaterialPageRoute(builder: (context) => LogIn()));
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
                  Navigator.push(context,MaterialPageRoute(builder: (context) => Sign()));
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
  bool firstValue = false;
  bool secondValue = false;
  @override
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
              Navigator.push(context,MaterialPageRoute(builder: (context) => FirstScreen()));
            },
            iconSize: 30,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                Container(
                  height: 60,
                  child: Icon(
                    See.see,
                    size: 80,
                    color: Color(0xff4F7F8F),
                  ),
                ),
                Text(
                  'See',
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: 'Lobster',
                    color: Color(0xff4F7F8F),
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                Container(
                  height: 50,
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: TextField(
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
                  height: 40,
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: TextField(
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
                    SizedBox(width: 12,),
                  Checkbox(
                    checkColor: Colors.greenAccent,
                    value: this.firstValue,
                    onChanged: (bool value) {
                      setState(() {
                        this.firstValue = value;
                      });
                    },
                  ),
                  Text("Keep me logged in",style: TextStyle(fontSize: 17,color: Colors.grey),),
                ],
                ),
                SizedBox(height: 10,),
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
                    'LOG IN',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                 Navigator.push(context,MaterialPageRoute(builder: (context) => Home()));
                },
                ),
              ],
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
  int val = -1;
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "SIGN UP",
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
                  Navigator.push(context,MaterialPageRoute(builder: (context) => FirstScreen()));
                },
                iconSize: 30,
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
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
                      child: TextField(
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
                      child: TextField(
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
                    const SizedBox(height: 12.0),
                    Container(
                      height: 50,
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: TextField(
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
                              title: Text("Blind",style: TextStyle(fontSize: 20,color: Colors.grey),),
                              leading: Radio(
                                value: 1,
                                groupValue: val,
                                onChanged: (value) {
                                  setState(() {
                                    val = value;
                                  });
                                },
                                activeColor:  Color(0xff96D5EB),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: Text("Friend",style: TextStyle(fontSize: 20,color: Colors.grey),),
                              leading: Radio(
                                value: 2,
                                groupValue: val,
                                onChanged: (value) {
                                  setState(() {
                                    val = value;
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
                      minWidth: 50,
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
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
                      onPressed: () {
                        Navigator.push(context,MaterialPageRoute(builder: (context) => Home()));
                      },
                    ),
                  ],
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff96D5EB),
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child:
            Icon(
              Icons.settings,
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
                    color: b1 ? Colors.red : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(
                          color: b1 ? Colors.white : Color(0xff96D5EB),
                          width: 2,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.power_settings_new,
                          color: b1 ? Colors.white : Color(0xff96D5EB),
                          size: 40,
                        ),
                        Text(
                          "Power",
                          style: TextStyle(
                            color: b1 ? Colors.white : Color(0xff96D5EB),
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    onPressed: (){
                      setState(() {
                        b1 = !b1;
                      });
                    },
                  ),
                  MaterialButton(
                    height: 150,
                    minWidth: 150,
                    color: b2 ? Colors.red : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(
                          color: b2 ? Colors.white : Color(0xff96D5EB),
                          width: 2,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.search,
                          color: b2 ? Colors.white : Color(0xff96D5EB),
                          size: 40,
                        ),
                        Text(
                          "Search",
                          style: TextStyle(
                            color: b2 ? Colors.white : Color(0xff96D5EB),
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    onPressed: (){
                      setState(() {
                        b2 = !b2;
                      });
                    },
                  ),
                  MaterialButton(
                    height: 150,
                    minWidth: 150,
                    color: b3 ? Colors.red : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(
                          color: b3 ? Colors.white : Color(0xff96D5EB),
                          width: 2,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.headset,
                          color: b3 ? Colors.white : Color(0xff96D5EB),
                          size: 40,
                        ),
                        Text(
                          "Audio",
                          style: TextStyle(
                            color: b3 ? Colors.white : Color(0xff96D5EB),
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    onPressed: (){
                      setState(() {
                        b3 =!b3;
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
                    color: b4 ? Colors.red : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(
                          color: b4 ? Colors.white : Color(0xff96D5EB),
                          width: 2,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.location_on,
                          color: b4 ? Colors.white : Color(0xff96D5EB),
                          size: 40,
                        ),
                        Text(
                          "Location",
                          style: TextStyle(
                            color: b4 ? Colors.white : Color(0xff96D5EB),
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    onPressed: (){
                      setState(() {
                        b4 = !b4;
                      });
                    },
                  ),
                  MaterialButton(
                    height: 150,
                    minWidth: 150,
                    color: b5 ? Colors.red : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(
                          color: b5 ? Colors.white : Color(0xff96D5EB),
                          width: 2,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.home,
                          color: b5 ? Colors.white : Color(0xff96D5EB),
                          size: 40,
                        ),
                        Text(
                          "Go Home",
                          style: TextStyle(
                            color: b5 ? Colors.white : Color(0xff96D5EB),
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    onPressed: (){
                      setState(() {
                        b5 = !b5;
                      });
                    },
                  ),
                  MaterialButton(
                    height: 150,
                    minWidth: 150,
                    color: b6 ? Colors.red : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(
                          color: b6 ? Colors.white : Color(0xff96D5EB),
                          width: 2,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.call,
                          color: b6 ? Colors.white : Color(0xff96D5EB),
                          size: 40,
                        ),
                        Text(
                          "Call",
                          style: TextStyle(
                            color: b6 ? Colors.white : Color(0xff96D5EB),
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    onPressed: (){
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
        drawer:  NavBar(),
      ),
    );
  }
}

//class SideDrawer extends StatelessWidget {
  //@override
  //Widget build(BuildContext context) {
    //return
  //}
//}