import 'dart:async';
import 'dart:developer';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geo_firestore_flutter/geo_firestore_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hmapp/donate.dart';
import 'package:hmapp/food%20copy%202.dart';
import 'package:hmapp/home.dart';
import 'package:hmapp/notifications_receiver.dart';
import 'package:hmapp/search.dart';
import 'package:hmapp/sidebar.dart';
import 'package:permission_handler/permission_handler.dart';

import 'food copy.dart';
import 'giver.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

TextStyle style1 = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
const highlightColor = Color(0xFF214847);
const backgroundColor = Color(0xFFe3dbc8);
const style2 = ButtonStyle(
  backgroundColor: MaterialStatePropertyAll<Color>(highlightColor),
);

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 64, // Set this height
              title: Text("Notifications"),
              backgroundColor: highlightColor,
              bottom: const TabBar(tabs: [
                Tab(child: Text("Giver")),
                Tab(
                  child: Text("Receiver"),
                )
              ]),
            ),
            resizeToAvoidBottomInset: false,
            backgroundColor: backgroundColor,
            body: TabBarView(
              children: [GiverNotifications(), ReceiverNotifications()],
            )));
  }
}

class GiverNotifications extends StatefulWidget {
  @override
  _GiverNotificationsState createState() => _GiverNotificationsState();
}

class _GiverNotificationsState extends State<GiverNotifications> {
  Future<List<DocumentSnapshot>> getData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("donations")
        .where("owner_id", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where("complete", isEqualTo: false)
        .get();
    List<DocumentSnapshot> docs = [];
    snapshot.docs.forEach((element) {
      Map data = element.data() as Map;
      if (data['requestedBy'] != null) docs.add(element);
    });
    return docs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData(),
        builder: (BuildContext context,
            AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Map data = snapshot.data![index].data() as Map;
                  return GiverNotification(
                      notification_doc: snapshot.data![index]);
                },
              );
            } else {
              return Center(
                child: Text("You have no giver notifications."),
              );
            }
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

class GiverNotification extends StatefulWidget {
  final DocumentSnapshot notification_doc;
  GiverNotification({required this.notification_doc});
  @override
  _GiverNotificationState createState() => _GiverNotificationState();
}

class _GiverNotificationState extends State<GiverNotification> {
  String? url;
  DocumentSnapshot? requester_doc;
  Map<String, dynamic>? requester_data;
  String? fName, lName;
  Future<String> getImageDownloadURL() async {
    return await FirebaseStorage.instance
        .ref(widget.notification_doc.id)
        .getDownloadURL();
  }

  Future<DocumentSnapshot> getReceiverData(DocumentSnapshot doc) async {
    Map doc_data = doc.data() as Map;
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(doc_data['requestedBy'])
        .get();
  }

  @override
  void initState() {
    getImageDownloadURL().then((value) {
      setState(() {
        url = value;
      });
    });
    getReceiverData(widget.notification_doc).then((value) {
      Map<String, dynamic> data = value.data() as Map<String, dynamic>;
      setState(() {
        requester_doc = value;
        requester_data = data;
        fName = data['fName'];
        lName = data['lName'];
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Container(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              if (url != null && requester_data != null) ...[
                Expanded(
                    child: Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(fName! + " " + lName!),
                          Expanded(child: SizedBox.shrink()),
                          Text((widget.notification_doc.data()
                                  as dynamic)['confirmed']
                              ? (widget.notification_doc.data()
                                      as dynamic)['complete']
                                  ? "Completed"
                                  : "Waiting for Pickup"
                              : "Pending Request")
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Expanded(
                          child: Row(
                        children: [
                          Image.network(
                            url!,
                            height: 200,
                            width: 100,
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Food Details",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text((widget.notification_doc.data()
                                  as dynamic)['name']),
                              Text((widget.notification_doc.data()
                                          as dynamic)['portions']
                                      .toString() +
                                  " Portion(s)"),
                              Text((widget.notification_doc.data()
                                  as dynamic)['type']),
                              Text("Expires on " +
                                  DateTime.fromMillisecondsSinceEpoch(
                                          ((widget.notification_doc.data()
                                                      as dynamic)['expiration']
                                                  as Timestamp)
                                              .millisecondsSinceEpoch)
                                      .toString()
                                      .split(' ')[0]),
                            ],
                          ),
                        ],
                      )),
                      SizedBox(
                        height: 16,
                      ),
                      if (!(widget.notification_doc.data()
                          as dynamic)['complete'])
                        Row(
                          children: [
                            Expanded(
                                child: ElevatedButton(
                              child: Text("More Details"),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GiverRequestPopUp(
                                            url: url!,
                                            fName: fName!,
                                            lName: lName!,
                                            request_doc:
                                                widget.notification_doc,
                                            requester_doc: requester_doc!)));
                              },
                            ))
                          ],
                        )
                    ],
                  ),
                ))
              ] else ...[
                SizedBox.shrink()
              ]
            ],
          ),
        ),
        decoration: BoxDecoration(color: Colors.white),
      ),
    );
  }
}

class GiverRequestPopUp extends StatefulWidget {
  final DocumentSnapshot requester_doc, request_doc;
  final String fName, lName, url;
  GiverRequestPopUp(
      {required this.fName,
      required this.lName,
      required this.requester_doc,
      required this.request_doc,
      required this.url});
  @override
  _GiverRequestPopUpState createState() => _GiverRequestPopUpState();
}

class _GiverRequestPopUpState extends State<GiverRequestPopUp> {
  Stream<DocumentSnapshot>? _documentStream;
  bool confirmed = false;
  @override
  void initState() {
    confirmed = (widget.request_doc.data() as Map)['confirmed'];
    super.initState();

    // Subscribe to the Firestore document
    _documentStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.requester_doc.id)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF214847),
        title: Text("${widget.fName}'s Request"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (!confirmed)
              Align(
                alignment: Alignment.center,
                child: Text(
                  "${widget.fName} wants to pick up your food!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              )
            else
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Waiting for ${widget.fName} to pick up your food",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            SizedBox(
              height: 16,
            ),
            StreamBuilder<DocumentSnapshot>(
                stream: _documentStream,
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  }
                  if (!snapshot.hasData) {
                    return Text('Document does not exist');
                  }
                  final Map data = snapshot.data!.data() as Map;
                  return Row(
                    children: [
                      Expanded(
                          child: GMapFollower(
                        location: data['l'],
                        fName: widget.fName,
                        requester_id: widget.requester_doc.id,
                      ))
                    ],
                  );
                }),
            SizedBox(
              height: 16,
            ),
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 64,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.fName + " " + widget.lName,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text((widget.requester_doc.data() as Map)['phone']),
                      Text((widget.requester_doc.data() as Map)['address'])
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            if (!confirmed)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Image.network(widget.url),
                    SizedBox(
                      width: 16,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Food Details",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text((widget.request_doc.data() as Map)['name']),
                        Text((widget.request_doc.data() as Map)['portions']
                                .toString() +
                            " Portion(s)"),
                        Text((widget.request_doc.data() as Map)['type']),
                        Text((widget.request_doc.data() as Map)['note'])
                      ],
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 16,
            ),
            TextButton(
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      enableDrag: false,
                      context: context,
                      builder: (BuildContext context) {
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: MessagesBottomSheet(
                            doc_id: widget.request_doc.id,
                            fName: widget.fName,
                          ),
                        );
                      });
                },
                child: Row(
                  children: [
                    Expanded(child: SizedBox.shrink()),
                    Icon(Icons.message),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Message Receiver",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    Expanded(child: SizedBox.shrink()),
                  ],
                )),
            SizedBox(
              height: 16,
            ),
            if (!confirmed)
              ElevatedButton(
                  onPressed: () {
                    widget.request_doc.reference
                        .update({"confirmed": true}).then((value) {
                      setState(() {
                        confirmed = true;
                      });
                    });
                  },
                  child: Row(
                    children: [
                      Expanded(child: SizedBox.shrink()),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Confirm Request",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      ),
                      Expanded(child: SizedBox.shrink())
                    ],
                  )),
          ],
        ),
      ),
    );
  }
}

class GMapFollower extends StatefulWidget {
  final dynamic? location;
  final String fName;
  final String requester_id;

  const GMapFollower(
      {Key? key,
      this.location,
      required this.fName,
      required this.requester_id})
      : super(key: key);

  @override
  _GMapFollowerState createState() => _GMapFollowerState();
}

class _GMapFollowerState extends State<GMapFollower> {
  LatLng? requester_location;
  Set<Marker> _markers = {};
  LatLng? location;
  Timer? timer;
  @override
  void initState() {
    requestLocationPermission(FirebaseAuth.instance.currentUser!.uid)
        .then((value) {
      setState(() {
        location = value;
      });
    });
    if (widget.location != null) {
      timer =
          Timer.periodic(Duration(seconds: 5), (Timer t) => checkLocation());
      setState(() {
        _markers.clear();
        _markers.add(Marker(
            markerId: MarkerId(widget.requester_id),
            position: LatLng(widget.location[0], widget.location[1])));
        requester_location = LatLng(widget.location[0], widget.location[1]);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkLocation() async {
    var doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.requester_id)
        .get();
    var data = (doc.data() as Map);
    setState(() {
      _markers.clear();
      _markers.add(Marker(
          markerId: MarkerId(widget.requester_id),
          position: LatLng(data['l'][0], data['l'][1])));
      requester_location = LatLng(data['l'][0], data['l'][1]);
    });
    log("Called");
  }

  Future<LatLng?> requestLocationPermission(String uid) async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition();
      LatLng latlng = LatLng(position.latitude, position.longitude);
      GeoFirestore geo =
          GeoFirestore(FirebaseFirestore.instance.collection("users"));
      await geo.setLocation(
          uid, GeoPoint(position.latitude, position.longitude));
      return latlng;
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return HomeScreen();
      }));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "This page requires location access to function properly. Please adjust your permissions in the settings of your device.")));
      if (status.isPermanentlyDenied) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "This page requires location access to function properly. Please adjust your permissions in the settings of your device.")));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "This page requires location access to function properly. Please adjust your permissions in the settings of your device.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (requester_location == null) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            "No location history is available for ${widget.fName} at the moment. We will automatically update this page when their location becomes available.",
          ),
        ),
      );
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: GoogleMap(
          markers: _markers,
          zoomGesturesEnabled: true, //enable Zoom in, out on map
          minMaxZoomPreference: MinMaxZoomPreference(12, 15),
          initialCameraPosition: CameraPosition(
              target: requester_location != null
                  ? requester_location!
                  : LatLng(0, 0))),
    );
  }
}

class MessagesBottomSheet extends StatefulWidget {
  final String doc_id, fName;
  MessagesBottomSheet({required this.doc_id, required this.fName});
  @override
  _MessagesBottomSheetState createState() => _MessagesBottomSheetState();
}

class _MessagesBottomSheetState extends State<MessagesBottomSheet> {
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 480,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You and ${widget.fName}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("donations")
                  .doc(widget.doc_id)
                  .collection('messages')
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final message = messages[index].data() as Map;
                    return Row(
                      children: [
                        if (message['author'] ==
                            FirebaseAuth.instance.currentUser?.uid)
                          Expanded(child: SizedBox.shrink()),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          color: message['author'] !=
                                  FirebaseAuth.instance.currentUser?.uid
                              ? Colors.white
                              : Color(0xFF214847),
                          child: Container(
                            constraints:
                                BoxConstraints(minWidth: 100, maxWidth: 300),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(message['message'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: message['author'] ==
                                              FirebaseAuth
                                                  .instance.currentUser?.uid
                                          ? Colors.white
                                          : Colors.black)),
                            ),
                          ),
                        ),
                        if (message['author'] !=
                            FirebaseAuth.instance.currentUser?.uid)
                          Expanded(child: SizedBox.shrink()),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            onFieldSubmitted: (value) {
              FirebaseFirestore.instance
                  .collection("donations")
                  .doc(widget.doc_id)
                  .collection('messages')
                  .add({
                "message": value,
                "author": FirebaseAuth.instance.currentUser?.uid,
                "timestamp": Timestamp.now()
              }).then((value) {
                _messageController.clear();
              });
            },
            textInputAction: TextInputAction.go,
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'Send a message to ${widget.fName}',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
