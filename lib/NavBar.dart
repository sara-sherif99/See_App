import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation/icons.dart';
import 'package:graduation/see.dart';
import 'package:graduation/main.dart'as main;
import 'package:shared_preferences/shared_preferences.dart';
class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              margin: EdgeInsets.only(left: 2,),
              decoration: BoxDecoration(
            ),
              accountName: Text('Username',style: TextStyle(fontSize: 20,color: Colors.black,fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,),),
              accountEmail: Text('email@abc.com',style: TextStyle(fontSize: 18,color: Colors.grey,),),
              currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage("assets/images/user.jpg" ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home,size: 25,color: Colors.black,),
              title: Text('HomeScreen',style: TextStyle(fontSize: 18,color: Colors.black),),
              onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => main.Home()));},
            ),
            ListTile(
              leading: Icon(Icons.person,size: 25,color: Colors.black,),
              title: Text('Friends',style: TextStyle(fontSize: 18,color: Colors.black),),
              onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => main.Friends()));},
            ),
            ListTile(
              leading: Icon(Icons.location_on,size: 25,color: Colors.black,),
              title: Text('Home Location',style: TextStyle(fontSize: 18,color: Colors.black),),
              onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => main.Location()));},
            ),
            Divider(thickness: 1,indent: 15,endIndent: 15,),
            ListTile(
              leading: Icon(MyFlutterApp.glasses,size: 28,color: Colors.black,),
              title: Text('About Device',style: TextStyle(fontSize: 18,color: Colors.black),),
              onTap: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => main.AboutDevice()));
              },
            ),
            ListTile(
              leading: Icon(See.see,size: 31,color: Colors.black,),
              title: Text('About Us',style: TextStyle(fontSize: 18,color: Colors.black),),
              onTap: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => main.AboutUs()));
              },
            ),
            Divider(thickness: 1,indent: 15,endIndent: 15,),
            ListTile(
              title: Text('Settings',style: TextStyle(fontSize: 18,color: Colors.black),),
              leading: Icon(Icons.settings,size: 25,color: Colors.black,),
              onTap: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => main.Settings()));
              },
            ),
            ListTile(
              title: Text('Log Out',style: TextStyle(fontSize: 18,color: Colors.black),),
              leading: Icon(Icons.exit_to_app,size: 25,color: Colors.black,),
              onTap: () async{
                FirebaseAuth.instance.signOut();
                Navigator.push(context,MaterialPageRoute(builder: (context) => main.FirstScreen()));
                final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                sharedPreferences.remove("email");
                },
            ),
            SizedBox(height: 10,)

          ],
        ),
      ),
    );
  }
}