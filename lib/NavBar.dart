import 'package:flutter/material.dart';
import 'package:graduation/icons.dart';
import 'package:graduation/see.dart';
import 'package:graduation/main.dart'as main;
class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
            color: Color(0xff96D5EB),
          ),
            accountName: Text('Username',style: TextStyle(fontSize: 20,),),
            accountEmail: Text('email@abc.com',style: TextStyle(fontSize: 18,),),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white70,
              backgroundImage: AssetImage("assets/images/background.jpg" ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home,size: 28,color: Colors.grey,),
            title: Text('HomeScreen',style: TextStyle(fontSize: 18,color: Colors.grey),),
            onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => main.Home()));},
          ),
          ListTile(
            leading: Icon(Icons.person,size: 28,color: Colors.grey,),
            title: Text('Friends',style: TextStyle(fontSize: 18,color: Colors.grey),),
            onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => main.Friends()));},
          ),
          ListTile(
            leading: Icon(Icons.location_on,size: 28,color: Colors.grey,),
            title: Text('Home Location',style: TextStyle(fontSize: 18,color: Colors.grey),),
            onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => main.Location()));},
          ),
          Divider(thickness: 1,indent: 15,endIndent: 15,),
          ListTile(
            leading: Icon(MyFlutterApp.glasses,size: 30,color: Colors.grey,),
            title: Text('About Device',style: TextStyle(fontSize: 18,color: Colors.grey),),
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => main.AboutDevice()));
            },
          ),
          ListTile(
            leading: Icon(See.see,size: 32,color: Colors.grey,),
            title: Text('About Us',style: TextStyle(fontSize: 18,color: Colors.grey),),
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => main.AboutUs()));
            },
          ),
          Divider(thickness: 1,indent: 15,endIndent: 15,),
          ListTile(
            title: Text('Account Settings',style: TextStyle(fontSize: 18,color: Colors.grey),),
            leading: Icon(Icons.settings,size: 28,color: Colors.grey,),
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => main.Settings()));
            },
          ),
          ListTile(
            title: Text('Log Out',style: TextStyle(fontSize: 18,color: Colors.grey),),
            leading: Icon(Icons.exit_to_app,size: 28,color: Colors.grey,),
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => main.FirstScreen()));
            },
          ),

        ],
      ),
    );
  }
}