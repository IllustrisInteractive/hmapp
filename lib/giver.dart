import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:hmapp/donate.dart';
import 'package:hmapp/home.dart';
import 'package:hmapp/search.dart';
import 'package:hmapp/sidebar.dart';

class Request extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> foodData;
  final DocumentSnapshot<Object?> ownerData;
  final bool? readOnly;
  final bool? receiver;
  Request(
      {super.key,
      required this.foodData,
      required this.ownerData,
      this.receiver,
      this.readOnly});
  @override
  _RequestState createState() => _RequestState();
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

class _RequestState extends State<Request> {
  bool finished = false;
  String? url;
  @override
  Widget build(BuildContext context) {
    Future<String> getImageFromStorage() async {
      var storageRef = FirebaseStorage.instance.ref(widget.foodData.id);
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
      if (widget.receiver != null) ...[
        Text(
          "Thank you! Enjoy your food.",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
          textAlign: TextAlign.center,
        )
      ] else ...[
        Text(
          "Thank you for sharing!",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
          textAlign: TextAlign.center,
        )
      ],
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
                  .update({"confirmed": true}).then((value) =>
                      Navigator.pushReplacementNamed(context, '/history'));
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: highlightColor,
        toolbarHeight: 64, // Set this height
        title: Text("Receive"),
      ),
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
                                          'Details: ${widget.foodData['note'] ?? 'None'}'),
                                      SizedBox(height: 8),
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
                            height: 8,
                          ),
                          if (widget.receiver == null) ...[
                            Align(
                              child: Text("Requester Information",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              alignment: Alignment.centerLeft,
                            )
                          ] else if (widget.receiver == true) ...[
                            Align(
                              child: Text("Giver Information",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              alignment: Alignment.centerLeft,
                            )
                          ],
                          SizedBox(
                            height: 8,
                          ),
                          Align(
                            child: Row(
                              children: [
                                Text(
                                  'Name:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                    '${widget.ownerData['fName']} ${widget.ownerData['lName']}',
                                    style: TextStyle(fontSize: 18))
                              ],
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          Align(
                            child: Row(
                              children: [
                                Text(
                                  'Contact Details:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text('${widget.ownerData['phone']}',
                                    style: TextStyle(fontSize: 18))
                              ],
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          Align(
                            child: Row(
                              children: [
                                Text(
                                  'Address:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text('${widget.ownerData['address']}',
                                    style: TextStyle(fontSize: 18))
                              ],
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          Expanded(child: SizedBox()),
                          if (widget.readOnly == null) ...[
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
                                            "Confirm",
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
                          ]
                        ]));
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
