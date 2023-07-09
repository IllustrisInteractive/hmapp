import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hmapp/account_data.dart';

TextStyle style1 =
    TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white);
TextStyle style2 =
    TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white);
TextStyle style3 =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);

const highlightColor = Color(0xFF214847);
const backgroundColor = Color(0xFFe3dbc8);

createListTile(context, title) {
  return ListTile(
    title: Text(
      title,
      style: style3,
    ),
    onTap: () {
      if (title != "Log Out") {
        try {
          Navigator.pushNamed(
              context, "/${title.toString().toLowerCase().trim()}");
        } on FlutterError catch (_) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("This route has not yet been implemented.")));
        }
      } else {
        FirebaseAuth.instance.signOut().then((value) {
          Navigator.pushReplacementNamed(context, "/login");
        });
      }
    },
  );
}

class Sidebar extends StatelessWidget {
  UserData userData = UserData();
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          backgroundColor,
          highlightColor,
        ],
      )),
      child: ListView(
        children: [
          SizedBox(
            height: 16,
          ),
          Column(
            children: [
              userData.profilePicture != null
                  ? Container(
                      child: Image.network(
                        userData.profilePicture!,
                        height: 96,
                        width: 96,
                        fit: BoxFit.cover,
                      ),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Color(0xFF214847),
                        shape: BoxShape.circle,
                      ))
                  : Icon(
                      Icons.account_circle_rounded,
                      size: 96,
                      color: Colors.white,
                    ),
              SizedBox(
                height: 8,
              ),
              Text(
                "${userData.getFName()} ${userData.getLName()}",
                style: style1,
              ),
              Text(
                FirebaseAuth.instance.currentUser?.email ??
                    "No email available",
                style: style2,
              )
            ],
          ),
          SizedBox(
            height: 32,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              createListTile(context, "Profile"),
              createListTile(context, "Notifications"),
              createListTile(context, "History"),
              createListTile(context, "Help"),
              createListTile(context, "Log Out"),
            ],
          )
        ],
      ),
    ));
  }
}
