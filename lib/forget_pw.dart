import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgetPasswordPage extends StatefulWidget {
  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String _errorMessage = '';
  bool _isEmailSent = false;
  Color highlightColor = Color(0xFF214847);
  Color backgroundColor = Color(0xFFe3dbc8);

  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      _errorMessage = '';
      _isEmailSent = false;
    });

    if (_formKey.currentState!.validate()) {
      try {
        await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
        setState(() {
          _isEmailSent = true;
        });
      } catch (error) {
        setState(() {
          _errorMessage = error.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool validateEmail(String email) {
    // Regular expression pattern for validating email addresses
    final RegExp emailRegex = RegExp(
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');

    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: highlightColor,
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter your email address to reset your password. We will then send a password reset link to this email. Afterwards, feel free to try and log in again. If any issues arise, such as not receiving an email, please contact support:',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (validateEmail(value) == false) {
                    return 'Please provide your email in the proper format';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    labelText: 'Email (Ex. example@example.com)',
                    labelStyle: TextStyle(color: highlightColor),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: highlightColor),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: highlightColor),
                    )),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: _sendPasswordResetEmail,
                          child: Text('Send Reset Email'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                highlightColor, // Set the background color here
                          )))
                ],
              ),
              SizedBox(height: 16.0),
              if (_isEmailSent)
                Text(
                  'A password reset email has been sent to ${_emailController.text}. If you are having trouble finding the email, check your spam folder.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (_errorMessage.isNotEmpty)
                Text(
                  "The email you entered does not seem to belong to an active user account. If you are certain that this email address was used to register an active account, please contact support.",
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
