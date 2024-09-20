import 'dart:ui';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart' show rootBundle;

class AuthForm extends StatefulWidget {
  const AuthForm(
      this.submitFn,
      this.isLoading,
      );

  final bool isLoading;
  final void Function(
      String email,
      String password,
      String userName,
      String phoneNo,
      BuildContext ctx,
      ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  var _phoneNo = '';
  var _age = '';
  var _checked = false;

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (!_checked) {
      Fluttertoast.showToast(
        msg: "Please accept terms and conditions.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
      return; // Stop further execution if terms are not accepted
    }

    if (isValid) {
      _formKey.currentState!.save();
      // Set _age based on a mechanism (e.g., a dropdown or radio buttons)
      // For demonstration, setting it statically
      _age = '0-10'; // This should be dynamic based on user selection

      try {
        widget.submitFn(
          _userEmail.trim(),
          _userPassword.trim(),
          _userName.trim(),
          _phoneNo.trim(),
          context,
        );
      } catch (error) {
        Fluttertoast.showToast(
          msg: "Submission failed: $error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0,
        );
      }
    }
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/legal.txt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: MediaQuery.of(context).padding,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/backdrop.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
              Positioned(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              Center(
                child: Card(
                  color: Colors.transparent,
                  margin: const EdgeInsets.all(20),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Center(
                              child: Image.asset(
                                'assets/logo.png',
                                height: 100,
                                width: 125,
                                fit: BoxFit.fill,
                              ),
                            ),
                            const Center(
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextFormField(
                              enabled: !widget.isLoading,
                              key: const ValueKey('email'),
                              validator: (value) {
                                if (!EmailValidator.validate(value!)) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email address',
                              ),
                              onSaved: (value) {
                                _userEmail = value!;
                              },
                            ),
                            TextFormField(
                              enabled: !widget.isLoading,
                              key: const ValueKey('username'),
                              validator: (value) {
                                if (value!.isEmpty || value.length < 4) {
                                  return 'Please enter at least 4 characters';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Username',
                              ),
                              onSaved: (value) {
                                _userName = value!;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              enabled: !widget.isLoading,
                              key: const ValueKey('password'),
                              validator: (value) {
                                if (value!.isEmpty || value.length < 7) {
                                  return 'Password must be at least 7 characters long.';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              onSaved: (value) {
                                _userPassword = value!;
                              },
                            ),
                            TextFormField(
                              enabled: !widget.isLoading,
                              key: const ValueKey('phoneno'),
                              validator: (value) {
                                if (value!.isEmpty || value.length < 10) {
                                  return 'Invalid Phone No.';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                              ),
                              keyboardType: TextInputType.number,
                              onSaved: (value) {
                                _phoneNo = value!;
                              },
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Checkbox(
                                  value: _checked,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _checked = newValue!;
                                    });
                                  },
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Show terms and conditions
                                    loadAsset().then((terms) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Terms and Conditions'),
                                            content: SingleChildScrollView(
                                              child: Text(terms),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text('Close'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    });
                                  },
                                  child: Text(
                                    'Please accept the terms and conditions.',
                                    style: TextStyle(
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (widget.isLoading)
                              const CircularProgressIndicator(),
                            if (!widget.isLoading)
                              Container(
                                width: MediaQuery.of(context).size.width * 0.58,
                                height: MediaQuery.of(context).size.height * 0.07,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                  ),
                                  onPressed: _trySubmit,
                                  child: const Text(
                                    'SIGNUP',
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
