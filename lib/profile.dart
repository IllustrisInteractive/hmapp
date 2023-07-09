import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geo_firestore_flutter/geo_firestore_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'home.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _f_nameController = TextEditingController();
  final TextEditingController _l_nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  String _f_name = "";
  String _l_name = '';
  String _phone = '';
  String _address = '';
  String? profileURL;
  bool ready = false;
  DateTime? _date;
  LocationMetadata? location;
  PickedFile? pickedProfilePicture;

  @override
  void dispose() {
    _f_nameController.dispose();
    _l_nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    FirebaseStorage.instance
        .ref()
        .child(FirebaseAuth.instance.currentUser!.uid)
        .getDownloadURL()
        .then((value) {
      setState(() {
        profileURL = value;
      });
    });
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      var data = value.data() as Map;
      setState(() {
        _f_name = data['fName'];
        _f_nameController.text = data['fName'];
        _l_name = data['lName'];
        _l_nameController.text = data['lName'];
        _phone = data['phone'];
        _phoneController.text = data['phone'];
        _address = data['address'];
        _addressController.text = data['address'];
        _date = DateTime.fromMillisecondsSinceEpoch(
            (data['dateOfBirth'] as Timestamp).millisecondsSinceEpoch);
        ready = true;
      });
    });
    super.initState();
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

  Future<LocationMetadata> _showPinLocationModal(BuildContext context) async {
    GeoFirestore geo =
        GeoFirestore(FirebaseFirestore.instance.collection("users"));
    var registeredLocation = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    var userLocation = LatLng((registeredLocation.data() as Map)['l'][0],
        (registeredLocation.data() as Map)['l'][1]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: ListView(
              children: ready
                  ? [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            Expanded(
                              child: pickedProfilePicture != null
                                  ? GestureDetector(
                                      onTap: () async {
                                        PickedFile? picked = await ImagePicker
                                            .platform
                                            .pickImage(
                                                source: ImageSource.gallery);
                                        setState(() {
                                          pickedProfilePicture = picked;
                                        });
                                      },
                                      child: Container(
                                        clipBehavior: Clip.hardEdge,
                                        child: Image.file(
                                          File(pickedProfilePicture!.path),
                                          height: 128,
                                          width: 128,
                                          fit: BoxFit.cover,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF214847),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        PickedFile? picked = await ImagePicker
                                            .platform
                                            .pickImage(
                                                source: ImageSource.gallery);
                                        setState(() {
                                          pickedProfilePicture = picked;
                                        });
                                      },
                                      child: Container(
                                        clipBehavior: Clip.hardEdge,
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: profileURL != null
                                              ? Image.network(
                                                  profileURL!,
                                                  height: 128,
                                                  width: 128,
                                                  fit: BoxFit.cover,
                                                )
                                              : Icon(
                                                  Icons.person,
                                                  size: 96,
                                                  color: Colors.white,
                                                ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF214847),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                            )
                          ],
                        ),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox.shrink(),
                              ),
                            ],
                          )),
                      Text(
                        'First Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        controller: _f_nameController,
                        onChanged: (value) {
                          setState(() {
                            _f_name = value;
                          });
                        },
                        validator: (value) {
                          // Validate phone number regex
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Last Name",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        controller: _l_nameController,
                        onChanged: (value) {
                          setState(() {
                            _l_name = value;
                          });
                        },
                        validator: (value) {
                          // Validate phone number regex
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Phone Number',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _phoneController,
                        onChanged: (value) {
                          setState(() {
                            _phone = value;
                          });
                        },
                        validator: (value) {
                          // Validate phone number regex
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          } else if (!RegExp(r'^\d{11}$').hasMatch(value)) {
                            return 'Please enter a valid 11-digit phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Address',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Birthday',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: _date ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          ).then((value) {
                            if (value != null) {
                              setState(() {
                                _date = value;
                              });
                            }
                          });
                        },
                        child: Text(_date == null ? 'Select a date' : '$_date'),
                      ),
                      SizedBox(height: 120),
                      Row(
                        children: [
                          Expanded(
                              child: ChangePasswordButton(
                                  email: FirebaseAuth
                                      .instance.currentUser!.email!))
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate() &&
                                  location != null) {
                                GeoFirestore geo = GeoFirestore(
                                    FirebaseFirestore.instance
                                        .collection("users"));
                                geo.setLocation(
                                    FirebaseAuth.instance.currentUser!.uid,
                                    GeoPoint(location!.location.latitude,
                                        location!.location.longitude));
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(FirebaseAuth.instance.currentUser?.uid)
                                    .update({
                                  "fName": _f_name,
                                  "lName": _l_name,
                                  "phone": _phone,
                                  "address": location!.address,
                                  "dateOfBirth": _date,
                                }).then(
                                  (value) {
                                    Navigator.pushReplacementNamed(
                                        context, "/login");
                                  },
                                );
                              } else if (_formKey.currentState!.validate()) {
                                if (pickedProfilePicture != null) {
                                  var ref = FirebaseStorage.instance.ref();
                                  await ref
                                      .child(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .putFile(
                                          File(pickedProfilePicture!.path));
                                }
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(FirebaseAuth.instance.currentUser?.uid)
                                    .update({
                                  "fName": _f_name,
                                  "lName": _l_name,
                                  "phone": _phone,
                                  "dateOfBirth": _date,
                                }).then(
                                  (value) {
                                    Navigator.pushReplacementNamed(
                                        context, "/login");
                                  },
                                );
                              }
                            },
                            child: Text('Save Changes'),
                          ))
                        ],
                      ),
                    ]
                  : [
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    ],
            )),
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

class ChangePasswordButton extends StatelessWidget {
  final String email;

  ChangePasswordButton({required this.email});

  void _showChangePasswordModal(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ChangePasswordModal(email: email),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _showChangePasswordModal(context);
      },
      child: Text('Change Password'),
    );
  }
}

class ChangePasswordModal extends StatefulWidget {
  final String email;

  ChangePasswordModal({required this.email});

  @override
  _ChangePasswordModalState createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<ChangePasswordModal> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isPasswordValid(String password) {
    final passwordRegExp = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  Future<void> _reauthenticateUser(String oldPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
            email: widget.email, password: oldPassword);
        await user.reauthenticateWithCredential(credential);
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to reauthenticate. Please check your old password.';
      });
      return;
    }
  }

  void _changePassword() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (!_isPasswordValid(newPassword)) {
      setState(() {
        _errorMessage =
            'Password must be at least 8 characters long and contain one uppercase letter, one lowercase letter, one number, and one special character';
      });
      return;
    }

    try {
      await _reauthenticateUser(oldPassword);

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        Navigator.of(context).pop(); // Close the modal bottom sheet
        // Show a success message or perform other actions
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while changing password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _oldPasswordController,
              decoration: InputDecoration(
                labelText: 'Old Password',
              ),
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your old password';
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
              ),
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a new password';
                }
                if (!_isPasswordValid(value)) {
                  return 'Password must be at least 8 characters long and contain one uppercase letter, one lowercase letter, one number, and one special character';
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
              ),
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please confirm the new password';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _changePassword();
                }
              },
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
