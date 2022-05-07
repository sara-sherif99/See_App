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
       backgroundColor: main.theme?Colors.white:Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              margin: EdgeInsets.only(left: 2,),
              decoration: BoxDecoration(

            ),
              accountName: Text(main.un,style: TextStyle(fontSize: 20,fontFamily: "RedHatBold",color: main.theme?Colors.black:Colors.white,fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,),),
              accountEmail: Text(main.finalEmail,style: TextStyle(fontSize: 18,color: Colors.grey,fontFamily: "RedHatRegular"),),
              currentAccountPicture: CircleAvatar(
                  backgroundImage: (main.pp=="")?AssetImage("assets/images/user.jpg"):NetworkImage(main.pp),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home,size: 25,color: main.theme?Colors.black:Colors.white,),
              title: Text('Home Screen',style: TextStyle(fontSize: 18,color: main.theme?Colors.black:Colors.white,fontFamily: "RedHatMedium"),),
              onLongPress: ()async{
                if(main.accountType=='Blind'){
                  await main.tts.setSpeechRate(0.5);
                  await main.tts.speak("home screen");
                }
              },
              onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => (main.accountType == "Blind")? main.Home(): main.HomeF()));},
            ),
            ListTile(
              leading: Icon(Icons.people,size: 25,color: main.theme?Colors.black:Colors.white,),
              title: Text('Friends',style: TextStyle(fontSize: 18,color: main.theme?Colors.black:Colors.white,fontFamily: "RedHatMedium"),),
              onLongPress: ()async{
                if(main.accountType=='Blind'){
                  await main.tts.setSpeechRate(0.5);
                  await main.tts.speak("friends");
                }
              },
              onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => main.Friends()));},
            ),
            ListTile(
              leading: Icon(Icons.person,size: 25,color: main.theme?Colors.black:Colors.white,),
              title: Text('Personal Info',style: TextStyle(fontSize: 18,color:main.theme?Colors.black:Colors.white,fontFamily: "RedHatMedium"),),
              onLongPress: ()async{
                if(main.accountType=='Blind'){
                  await main.tts.setSpeechRate(0.5);
                  await main.tts.speak("personal info");
                }
              },
              onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => main.userInfo()));},
            ),
            ListTile(
              leading: Icon(Icons.location_on,size: 25,color: main.theme?Colors.black:Colors.white,),
              title: Text((main.accountType == "Blind")? 'Home Location':'Tracking',style: TextStyle(fontSize: 18,color: main.theme?Colors.black:Colors.white,fontFamily: "RedHatMedium"),),
              onLongPress: ()async{
                if(main.accountType=='Blind'){
                  await main.tts.setSpeechRate(0.5);
                  await main.tts.speak("home location");
                }
              },
              onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => (main.accountType == "Blind")?main.getLocation(): main.Mapt()));},
            ),
            Divider(thickness: 1,indent: 15,endIndent: 15,),
            ListTile(
              leading: Icon(MyFlutterApp.glasses,size: 28,color: main.theme?Colors.black:Colors.white,),
              title: Text('About Device',style: TextStyle(fontSize: 18,color: main.theme?Colors.black:Colors.white,fontFamily: "RedHatMedium"),),
              onLongPress: ()async{
                if(main.accountType=='Blind'){
                  await main.tts.setSpeechRate(0.5);
                  await main.tts.speak("about device");
                }
              },
              onTap: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => main.AboutDevice()));
              },
            ),
            ListTile(
              leading: Icon(See.see,size: 31,color: main.theme?Colors.black:Colors.white,),
              title: Text('About Us',style: TextStyle(fontSize: 18,color: main.theme?Colors.black:Colors.white,fontFamily: "RedHatMedium"),),
              onLongPress: ()async{
                if(main.accountType=='Blind'){
                  await main.tts.setSpeechRate(0.5);
                  await main.tts.speak("about us");
                }
              },
              onTap: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => main.AboutUs()));
              },
            ),
            Divider(thickness: 1,indent: 15,endIndent: 15,),
            ListTile(
              title: Text('Settings',style: TextStyle(fontSize: 18,color: main.theme?Colors.black:Colors.white,fontFamily: "RedHatMedium"),),
              leading: Icon(Icons.settings,size: 25,color: main.theme?Colors.black:Colors.white,),
              onLongPress: ()async{
                if(main.accountType=='Blind'){
                  await main.tts.setSpeechRate(0.5);
                  await main.tts.speak("settings");
                }
              },
              onTap: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => main.Settings()));
              },
            ),
            ListTile(
              title: Text('Log Out',style: TextStyle(fontSize: 18,color: main.theme?Colors.black:Colors.white,fontFamily: "RedHatMedium"),),
              leading: Icon(Icons.exit_to_app,size: 25,color: main.theme?Colors.black:Colors.white,),
              onLongPress: ()async{
                if(main.accountType=='Blind'){
                  await main.tts.setSpeechRate(0.5);
                  await main.tts.speak("logout");
                }
              },
              onTap: () async{
                FirebaseAuth.instance.signOut();
                Navigator.push(context,MaterialPageRoute(builder: (context) => main.FirstScreen()));
                final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                sharedPreferences.remove("email");
                main.accountType="";
                main.cancelListen();
                },
            ),
            SizedBox(height: 10,)

          ],
        ),
      ),
    );
  }
}