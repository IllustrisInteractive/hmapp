import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geo_firestore_flutter/geo_firestore_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:getwidget/getwidget.dart';
import 'package:hmapp/donate.dart';
import 'package:hmapp/food.dart';
import 'package:hmapp/sidebar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Search(),
    );
  }
}

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

TextStyle style1 = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
const highlightColor = Color(0xFF214847);
const backgroundColor = Color(0xFFe3dbc8);
const style2 = ButtonStyle(
  backgroundColor: MaterialStatePropertyAll<Color>(highlightColor),
);

class _SearchState extends State<Search> {
  Future<List<DocumentSnapshot>> getData() async {
    var query = await FirebaseFirestore.instance
        .collection("donations")
        .where("requestedBy", isNull: true)
        .orderBy("timestamp", descending: false)
        .get();
    return query.docs;
  }

  @override
  void initState() {
    super.initState();
  }

  Future<String?> getURL(String id) async {
    try {
      return await FirebaseStorage.instance.ref(id).getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: highlightColor,
          toolbarHeight: 64, // Set this height
          title: Text("Receive"),
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: backgroundColor,
        body: Padding(
          padding: EdgeInsets.all(48),
          child: FutureBuilder<List<DocumentSnapshot>>(
              future: getData(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null) {
                    var docs = snapshot.data;
                    if (docs!.isEmpty) {
                      return Center(
                        child: Text(
                            "No available donations listed at the moment."),
                      );
                    }
                    return ListView(
                      children: docs.map((doc) {
                        Map<String, dynamic> data =
                            doc.data() as Map<String, dynamic>;
                        Timestamp time = doc["expiration"];
                        DateTime expirationDate =
                            DateTime.fromMicrosecondsSinceEpoch(
                                time.microsecondsSinceEpoch);
                        if (data['owner_id'] !=
                            FirebaseAuth.instance.currentUser?.uid) {
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Food(foodData: doc)));
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      FutureBuilder(
                                          future: getURL(doc.id),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              if (snapshot.data! != null) {
                                                return Image.network(
                                                  snapshot.data?.toString() ??
                                                      "",
                                                  height: 96,
                                                  width: 96,
                                                );
                                              }
                                            }
                                            return CircularProgressIndicator();
                                          }),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Food Details",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                              "Name: ${data['name'] ?? 'None'}"),
                                          Text("Type of food: ${data['type']}"),
                                          Text(
                                              "Portions: ${data['portions'].toString()}"),
                                          Text(
                                              "Expiration: ${expirationDate.month}/${expirationDate.day}/${expirationDate.year}")
                                        ],
                                      ))
                                    ],
                                  ),
                                ),
                              ));
                        } else
                          return SizedBox.shrink();
                      }).toList(),
                    );
                    return Text("Has data");
                  } else
                    return Text(
                        "No listed donations available as of the moment.");
                } else {
                  return Center(
                    child: Column(children: [
                      CircularProgressIndicator(),
                      Text("Loading data...")
                    ]),
                  );
                }
              }),
        ));
  }
}

/*GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Food()));
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.image,
                  size: 64,
                ),
                SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Details:"),
                    SizedBox(height: 8),
                    Text("Type of food:"),
                    Text("Expiration:")
                  ],
                )
              ],
            ),
          ),
        ));*/