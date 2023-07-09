import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:hmapp/donate.dart';
import 'package:hmapp/email_verify.dart';
import 'package:hmapp/search.dart';
import 'package:hmapp/sidebar.dart';
import 'package:permission_handler/permission_handler.dart';

import 'account_data.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

TextStyle style1 = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
const highlightColor = Color(0xFF214847);
const backgroundColor = Color(0xFFe3dbc8);
const style2 = ButtonStyle(
  backgroundColor: MaterialStatePropertyAll<Color>(highlightColor),
);

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: highlightColor,
          toolbarHeight: 64, // Set this height
          flexibleSpace: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  height: 64,
                )
              ],
            ),
          ),
        ),
        drawer: Sidebar(),
        resizeToAvoidBottomInset: false,
        backgroundColor: backgroundColor,
        body: Padding(
          padding: EdgeInsets.all(36),
          child: Column(
            children: [
              if (DateTime.now().hour >= 7 && DateTime.now().hour <= 19) ...[
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      height: 128,
                      child: ElevatedButton(
                          style: style2,
                          onPressed: (() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Donate()));
                          }),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite,
                                  size: 36,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Donate Food",
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          )),
                    )),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      height: 128,
                      child: ElevatedButton(
                          style: style2,
                          onPressed: (() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Search()));
                          }),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 36,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Search for donation",
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          )),
                    ))
                  ],
                )
              ] else ...[
                Text(
                  "We'll be right back",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Expanded(child: SizedBox.shrink()),
                Text(
                    "Donating and Requesting Food in Haiki Mono is available from 7AM to 7PM everyday only. Please come back and refresh this app at a later time."),
                Expanded(child: SizedBox.shrink())
              ]
            ],
          ),
        ));
  }
}
