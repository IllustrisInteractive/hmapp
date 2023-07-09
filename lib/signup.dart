import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geo_firestore_flutter/geo_firestore_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hmapp/splash.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'account_data.dart';
import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpDemo(),
    );
  }
}

class SignUpDemo extends StatefulWidget {
  @override
  _SignUpDemoState createState() => _SignUpDemoState();
}

class _SignUpDemoState extends State<SignUpDemo> {
  LocationMetadata? location;
  bool terms = false;
  final _formKey = GlobalKey<FormState>();
  DateTime? dateOfBirth;
  String fName = "",
      lName = "",
      email = "",
      password = "",
      phone = "",
      address = "";

  void _signUp() {
    if (fName.isEmpty ||
        lName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phone.isEmpty ||
        address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Missing details in form. Please double-check if all fields were filled."),
        ),
      );
      return;
    }

    if (!passwordIsValid(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Password must have at least 8 characters, one uppercase letter, one lowercase letter, and one special character."),
        ),
      );
      return;
    }

    if (!phoneNumberIsValid(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid phone number."),
        ),
      );
      return;
    }

    // Rest of the code for signing up the user and navigating to HomeScreen
    // ...
  }

  bool passwordIsValid(String value) {
    final passwordRegex = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*(),.?":{}|<>])',
    );
    return value.length >= 8 && passwordRegex.hasMatch(value);
  }

  bool phoneNumberIsValid(String value) {
    final phoneRegex = RegExp(
      r'^(?:\d{2}-\d{3}-\d{3}-\d{3}|\d{11})$',
    );
    return phoneRegex.hasMatch(value);
  }

  Future<LatLng?> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition();
      LatLng latlng = LatLng(position.latitude, position.longitude);
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

  Future<LocationMetadata> _showPinLocationModal(BuildContext context) async {
    var userLocation = location != null
        ? location!.location
        : await requestLocationPermission();
    final LatLng? selectedLocation;
    if (userLocation != null) {
      final LatLng? selectedLocation = await showModalBottomSheet<LatLng>(
        enableDrag: false,
        context: context,
        builder: (BuildContext context) {
          return PinLocationModal(
              locationOverride:
                  LatLng(userLocation!.latitude, userLocation.longitude));
        },
      );
      final String? address = await getAddressFromCoordinates(
          selectedLocation!.latitude, selectedLocation.longitude);

      return LocationMetadata(selectedLocation, address);
    } else {
      final LatLng? selectedLocation = await showModalBottomSheet<LatLng>(
        enableDrag: false,
        context: context,
        builder: (BuildContext context) {
          return PinLocationModal();
        },
      );

      final String? address = await getAddressFromCoordinates(
          selectedLocation!.latitude, selectedLocation.longitude);

      return LocationMetadata(selectedLocation, address);
    }
  }

  Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String address =
            "${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
        return address;
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFe3dbc8),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: ListView(
          children: <Widget>[
            const Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "First Name",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == "") {
                          return 'Please enter your first name';
                        }
                      },
                      onChanged: (value) {
                        setState(() {
                          fName = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Last Name",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == "") {
                          return 'Please enter your last name';
                        }
                      },
                      onChanged: (value) {
                        setState(() {
                          lName = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Date of Birth",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (dateOfBirth == null)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll<Color>(
                                        Color(0xFF214847)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'Select Date of Birth',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2005),
                                    firstDate: DateTime(1970),
                                    lastDate: DateTime(2005));

                                if (picked != null && picked != dateOfBirth) {
                                  setState(() {
                                    dateOfBirth = picked;
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
                                    MaterialStatePropertyAll<Color>(
                                        Color(0xFF214847)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  dateOfBirth.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2005),
                                    firstDate: DateTime(1970),
                                    lastDate: DateTime(2005));

                                if (picked != null && picked != dateOfBirth) {
                                  setState(() {
                                    dateOfBirth = picked;
                                  });
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    const SizedBox(height: 24),
                    const Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null) {
                          return 'Please enter an email.';
                        } else if (!EmailValidator.validate(value)) {
                          return 'Please enter your email in valid format.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        errorMaxLines: 6,
                      ),
                      validator: (value) {
                        if (value == "") {
                          return 'Please enter your password';
                        } else if (!passwordIsValid(value!)) {
                          return 'Password must have one uppercase and lowercase letter, a special char, and be 8 chars long.';
                        }
                      },
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Confirm Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        errorMaxLines: 6,
                      ),
                      validator: (value) {
                        if (value != password) {
                          return 'Password does not match.';
                        }
                      },
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Phone Number",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null) {
                          return 'Please enter your phone number';
                        } else if (!phoneNumberIsValid(value)) {
                          return 'Phone number entered is not valid.';
                        } else {
                          return null;
                        }
                      },
                      onChanged: (value) {
                        setState(() {
                          phone = value;
                        });
                      },
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Address",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () async {
                                  var location_metadata =
                                      await _showPinLocationModal(context);
                                  setState(() {
                                    location = location_metadata;
                                  });
                                },
                                child: Text((location != null &&
                                        location!.address != null)
                                    ? location!.address!
                                    : "Select an address")))
                      ],
                    )
                  ]),
            ),
            const SizedBox(height: 24),
            InkWell(
              child: Text("Read the Terms of Conditions and Privacy Policy",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: highlightColor)),
              onTap: () {
                launchUrl(Uri.parse("https://haikimonoapp.wixsite.com/hmapp"));
              },
            ),
            const SizedBox(
              height: 24,
            ),
            CheckboxListTile(
              value: terms,
              title: Text(
                "I hereby agree to the Terms and Conditions of Haiki Mono in accordance to its Privacy Policy.",
              ),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) {
                setState(() {
                  terms = value!;
                });
              },
            ),
            const SizedBox(height: 24),
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
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate() && terms) {
                        if (email != "" &&
                            password != "" &&
                            fName != "" &&
                            lName != "" &&
                            dateOfBirth != null &&
                            phone != "" &&
                            location != null) {
                          FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: email, password: password)
                              .then((value) => {
                                    FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(value.user?.uid)
                                        .set({
                                      'fName': fName,
                                      'lName': lName,
                                      'email': email,
                                      'dateOfBirth': dateOfBirth,
                                      'phone': phone,
                                      'address': location!.address
                                    }).whenComplete(() {
                                      GeoFirestore geo = GeoFirestore(
                                          FirebaseFirestore.instance
                                              .collection("users"));
                                      geo.setLocation(
                                          value.user!.uid,
                                          GeoPoint(location!.location.latitude,
                                              location!.location.longitude));
                                    })
                                  })
                              .then((value) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SplashScreen()));
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Missing details in form. Did you miss adding your date of birth?")));
                        }
                      } else if (!terms) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Please accept the Terms and Conditions to continue.")));
                      }
                    },
                  ),
                )
              ],
            ),
            SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}

class LocationMetadata {
  LatLng location;
  String? address;

  LocationMetadata(this.location, this.address);
}

class PinLocationModal extends StatefulWidget {
  final LatLng? locationOverride;
  const PinLocationModal({Key? key, this.locationOverride}) : super(key: key);
  @override
  _PinLocationModalState createState() => _PinLocationModalState();
}

class _PinLocationModalState extends State<PinLocationModal> {
  TextEditingController _controller = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;

  @override
  void initState() {
    if (widget.locationOverride != null) {
      setState(() {
        _selectedLocation = widget.locationOverride;
      });
    } else {
      setState(() {
        _selectedLocation = LatLng(14.4130, 120.9737);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Pin Location',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            TextFormField(
              onFieldSubmitted: (value) async {
                if (value.isNotEmpty) {
                  try {
                    List<Location> locations =
                        await locationFromAddress(value + ", Philippines");
                    if (locations.isNotEmpty) {
                      log([locations[0].latitude, locations[0].longitude]
                          .toString());
                      _mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(
                              target: LatLng(locations[0].latitude,
                                  locations[0].longitude),
                              zoom: 15)));
                      setState(() {
                        _selectedLocation = LatLng(
                            locations[0].latitude, locations[0].longitude);
                      });
                    }
                  } catch (e) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: Container(
                              height: 80,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Uh oh.",
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Expanded(child: SizedBox.shrink()),
                                      Text(e.toString())
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  }
                }
              },
              textInputAction: TextInputAction.go,
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search an address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Expanded(
              child: GoogleMap(
                  onMapCreated: (controller) {
                    setState(() {
                      _mapController = controller;
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation!,
                    zoom: 15.0,
                  ),
                  onCameraMove: (CameraPosition position) {
                    setState(() {
                      _selectedLocation = position.target;
                    });
                  },
                  markers: Set<Marker>.from([
                    Marker(
                      markerId: MarkerId('pin'),
                      position: _selectedLocation!,
                      draggable: true,
                      onDragEnd: (LatLng position) {
                        setState(() {
                          _selectedLocation = position;
                        });
                      },
                    ),
                  ])),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _selectedLocation);
              },
              child: Text('Pin Location'),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
