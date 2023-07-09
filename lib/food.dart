import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:hmapp/donate.dart';
import 'package:hmapp/home.dart';
import 'package:hmapp/search.dart';
import 'package:hmapp/sidebar.dart';

class Food extends StatefulWidget {
  final DocumentSnapshot<Object?> foodData;
  Food({super.key, required this.foodData});
  @override
  _FoodState createState() => _FoodState();
}

const highlightColor = Color(0xFF214847);
const backgroundColor = Color(0xFFe3dbc8);
TextStyle style1 = TextStyle(
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.bold,
    color: highlightColor);
const style2 = ButtonStyle(
  backgroundColor: MaterialStatePropertyAll<Color>(highlightColor),
);

class _FoodState extends State<Food> {
  bool finished = false;
  String? url;
  @override
  Widget build(BuildContext context) {
    Future<String> getImageFromStorage() async {
      var storageRef = FirebaseStorage.instance.ref(widget.foodData.id);
      return await storageRef.getDownloadURL();
    }

    Future<String> getImageFromStorageProfilePic() async {
      var storageRef = FirebaseStorage.instance
          .ref((widget.foodData.data() as Map)['owner_id']);
      return await storageRef.getDownloadURL();
    }

    ;
    Timestamp time = widget.foodData['expiration'];
    DateTime expirationDate =
        DateTime.fromMillisecondsSinceEpoch(time.millisecondsSinceEpoch);
    Widget ty = Column(children: [
      Icon(
        Icons.check,
        size: 64,
      ),
      Text(
        "Thank you! Enjoy your food.",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
        textAlign: TextAlign.center,
      ),
      Expanded(child: SizedBox()),
      Text(
        "The people who give you their food, give you their heart.\nCesar Chavez",
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      SizedBox(
        height: 12,
      ),
      Row(
        children: [
          Expanded(
              child: ElevatedButton(
            child: Text("Finish"),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("donations")
                  .doc(widget.foodData.id)
                  .update({
                "requestedBy": FirebaseAuth.instance.currentUser?.uid
              }).then((value) =>
                      Navigator.pushReplacementNamed(context, '/search'));
            },
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(highlightColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ))
        ],
      )
    ]);

    Future<DocumentSnapshot> getOwner(String id) async {
      return await FirebaseFirestore.instance.collection("users").doc(id).get();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: highlightColor,
        toolbarHeight: 64, // Set this height
        title: Text("Receive"),
      ),
      drawer: Sidebar(),
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      body: FutureBuilder(
          future: getImageFromStorage(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                  padding: EdgeInsets.all(36),
                  child: finished
                      ? ty
                      : Column(children: [
                          Container(
                            child: Image.network(
                              snapshot.data!,
                              height: 240,
                            ),
                            height: 240,
                            decoration: new BoxDecoration(
                                color: highlightColor,
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Name: ${widget.foodData['name'] ?? 'None'}'),
                                      Text(
                                          "Portions ${widget.foodData['portions']} Portion(s)"),
                                      Text(
                                          'Note: ${widget.foodData['note'] ?? 'None'}'),
                                      Text(
                                          "Type of food: ${widget.foodData['type']}"),
                                      Text(
                                          "Expiration: ${expirationDate.month}/${expirationDate.day}/${expirationDate.year}"),
                                    ],
                                  ))
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          FutureBuilder(
                              future: getOwner(widget.foodData['owner_id']),
                              builder: ((context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  var data = (snapshot.data!.data() as Map);
                                  return Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white,
                                    ),
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        FutureBuilder(
                                            future:
                                                getImageFromStorageProfilePic(),
                                            builder: ((context, snapshot) {
                                              if (snapshot.connectionState ==
                                                      ConnectionState.done &&
                                                  snapshot.hasData) {
                                                return Image.network(
                                                    snapshot.data!,
                                                    height: 96);
                                              }
                                              return CircularProgressIndicator();
                                            })),
                                        SizedBox(
                                          width: 16,
                                        ),
                                        Flexible(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              data['fName'] +
                                                  " " +
                                                  data['lName'],
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(data['phone']),
                                            Text(data['address'])
                                          ],
                                        ))
                                      ],
                                    ),
                                  );
                                }
                                return CircularProgressIndicator();
                              })),
                          Expanded(child: SizedBox.shrink()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        finished = !finished;
                                      });
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll<Color>(
                                                highlightColor)),
                                    child: const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8),
                                        child: Text(
                                          "Request",
                                          style: TextStyle(
                                              fontSize: 24,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                )
                              ],
                            ),
                          )
                        ]));
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
