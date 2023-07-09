import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geo_firestore_flutter/geo_firestore_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:getwidget/getwidget.dart';
import 'package:hmapp/sidebar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'signup.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Donate(),
    );
  }
}

class Donate extends StatefulWidget {
  @override
  _DonateState createState() => _DonateState();
}

TextStyle style1 = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

class _DonateState extends State<Donate> {
  File? file;
  bool finished = false;
  DateTime? expiration;
  String? foodType;
  String? note;
  String? name;
  num portions = 1;

  Future<Position> getLocation() async {
    if (await Permission.location.request().isGranted) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else {
      return Future.error("Location permission not granted");
    }
  }

  List<DropdownMenuItem> items = [
    DropdownMenuItem(child: Text("Drinks")),
    DropdownMenuItem(
      child: Text("Carbs"),
      value: "Carbs",
    ),
    DropdownMenuItem(
      child: Text("Fruits and Vegetables"),
      value: "Fruits and Vegetables",
    ),
    DropdownMenuItem(
      child: Text("Dairy"),
      value: "Dairy",
    ),
    DropdownMenuItem(
      child: Text("Meat/fish/eggs"),
      value: "Meat/fish/eggs",
    ),
    DropdownMenuItem(
      child: Text("Fats"),
      value: "Fats",
    ),
    DropdownMenuItem(
      child: Text("High sugar foods"),
      value: "High sugar foods",
    ),
    DropdownMenuItem(
      child: Text("Canned Goods"),
      value: "Canned Goods",
    ),
    DropdownMenuItem(
      child: Text("Packed Meals"),
      value: "Packed Meals",
    )
  ];
  @override
  Widget build(BuildContext context) {
    Widget form = ListView(children: [
      if (file == null) ...[
        Container(
          height: 96,
          child: ElevatedButton(
              onPressed: () async {
                XFile? fileSelected = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    maxHeight: 1200,
                    maxWidth: 1200);
                if (fileSelected != null) {
                  setState(() {
                    file = File(fileSelected.path);
                  });
                }
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(highlightColor)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera,
                    size: 32,
                  ),
                  Text(
                    "Take a picture of the food",
                    style: style1,
                  )
                ],
              )),
        ),
      ] else ...[
        Image.file(file!, fit: BoxFit.cover)
      ],
      Form(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24),
          const Text(
            "Fill up the details",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          const Text(
            "Food Name",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please add a label to your food";
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                name = value;
              });
            },
          ),
          SizedBox(height: 24),
          const Text(
            "Type of food",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButton(
              items: items,
              value: foodType,
              onChanged: (value) {
                setState(() {
                  foodType = value;
                });
              }),
          const SizedBox(height: 24),
          Text("Portions",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    if (portions <= 9)
                      setState(() {
                        portions++;
                      });
                  },
                  child: Icon(Icons.add)),
              Expanded(child: SizedBox.shrink()),
              Text(portions.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
              Expanded(child: SizedBox.shrink()),
              ElevatedButton(
                  onPressed: () {
                    if (portions >= 2)
                      setState(() {
                        portions--;
                      });
                  },
                  child: Icon(Icons.remove))
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Expiration",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (expiration == null)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Color(0xFF214847)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Select Date of Expiration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2025));

                      if (picked != null && picked != expiration) {
                        setState(() {
                          expiration = picked;
                        });
                      }
                    },
                  ),
                )
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Color(0xFF214847)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        expiration.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2025));

                      if (picked != null && picked != expiration) {
                        setState(() {
                          expiration = picked;
                        });
                      }
                    },
                  ),
                )
              ],
            ),
          const SizedBox(height: 24),
          const Text(
            "Note",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "(Specify ingredients used to avoid possible allergic reactions)",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextFormField(
            onChanged: (value) {
              setState(() {
                note = value;
              });
            },
          ),
          const SizedBox(height: 24),
          const Text(
            "Disclaimer",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            "By clicking the submit button below, you hereby confirm to donate food through the HMApp. By agreeing, you acknowledge and understand that the creator of the application will not be liable for any possible health-related harm that may happen. This is because there are several factors that are beyond the control of the creator of the application. Please be aware that some recipients have food allergies and that the item you are giving them may contain or come into contact with common allergic reactions. Even though the developers take precautions to reduce potential dangers and safely process foods that may contain allergens, we ask that you be aware of the possibility of cross-contamination.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(
            height: 8,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                onPressed: () {
                  String errorMsg = "";

                  if (expiration == null) {
                    errorMsg += "Please add an expiration date. ";
                  }

                  if (file == null) {
                    errorMsg += "Please add an image of your donation. ";
                  }

                  if (note == null) {
                    errorMsg += "Please add a note. ";
                  }

                  if (errorMsg == "") {
                    FirebaseFirestore.instance.collection("donations").add({
                      "note": note,
                      "portions": portions,
                      "name": name,
                      "type": foodType ?? "Drinks",
                      "expiration": expiration,
                      "owner_id": FirebaseAuth.instance.currentUser?.uid,
                      "requestedBy": null,
                      "confirmed": false,
                      "complete": false,
                      "timestamp": DateTime.now()
                    }).then((value) async {
                      final geo = GeoFirestore(
                          FirebaseFirestore.instance.collection("donations"));
                      final position = await getLocation();
                      final latitude = position.latitude;
                      final longitude = position.longitude;
                      await geo.setLocation(
                          value.id, GeoPoint(latitude, longitude));
                      FirebaseStorage.instance
                          .ref(value.id)
                          .putFile(file!)
                          .then((value) {
                        setState(() {
                          finished = true;
                        });
                      });
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text("You are missing some details: " + errorMsg)));
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(highlightColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ))
            ],
          )
        ],
      )),
    ]);
    Widget ty = Column(children: [
      Icon(
        Icons.check,
        size: 64,
      ),
      Text(
        "Thank you for sharing! Your donation is now posted.",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
        textAlign: TextAlign.center,
      ),
      Expanded(child: SizedBox()),
      Text(
        "You will receive a notification once someone wants to receive your food.",
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
              Navigator.pushReplacementNamed(context, "/login");
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
          toolbarHeight: 64, // Set this height
          title: Text("Donate"),
          backgroundColor: highlightColor,
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: backgroundColor,
        body:
            Padding(padding: EdgeInsets.all(36), child: finished ? ty : form));
  }
}
