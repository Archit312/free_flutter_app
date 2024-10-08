import 'dart:ui';

import 'package:flutter/material.dart';
import '/auth/register.dart';

class AuthFormLogin extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const AuthFormLogin(
    this.submitFn,
    this.isLoading,
    this.signInWithGoogle,
    this.signInWithFacebook,
    this.forgotPass,
  );

  final bool isLoading;
  final void Function(
    String email,
    String password,
    String userName,
    BuildContext ctx,
  ) submitFn;
  final void Function(
    BuildContext ctx,
  ) signInWithGoogle;
  final void Function(
    BuildContext ctx,
  ) signInWithFacebook;
  final void Function(
    BuildContext ctx,
  ) forgotPass;

  @override
  _AuthFormLoginState createState() => _AuthFormLoginState();
}

class _AuthFormLoginState extends State<AuthFormLogin> {
  final _formKey = GlobalKey<FormState>();
  var _userEmail = '';
  final _userName = '';
  var _userPassword = '';

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(
          _userEmail.trim(), _userPassword.trim(), _userName.trim(), context);
    }
  }

  void _tryGoogleSignIn() {
    widget.signInWithGoogle(context);
  }

  void _tryForgotPassword() {
    widget.forgotPass(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: MediaQuery.of(context).padding,
        child: Stack(children: [
          Positioned.fill(
              child: Image.asset(
            'assets/backdrop.jpg',
            fit: BoxFit.cover,
          )),
          Positioned.fill(
              child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 5,
              sigmaY: 5,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          )),
          Center(
            child: Card(
              color: Colors.transparent,
              margin: const EdgeInsets.all(20),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
                          'Login',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        )),
                        TextFormField(
                          enabled: widget.isLoading ? false : true,
                          key: const ValueKey('email'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a valid email address/Phone No..';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email address/Phone No',
                            focusColor: Colors.white,
                            fillColor: Colors.white,
                            hoverColor: Colors.white,
                          ),
                          onSaved: (value) {
                            _userEmail = '$value';
                          },
                        ),
                        TextFormField(
                          enabled: widget.isLoading ? false : true,
                          key: const ValueKey('password'),
                          validator: (value) {
                            if (value!.isEmpty || value.length < 7) {
                              return 'Password must be at least 7 characters long.';
                            }
                            return null;
                          },
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          onSaved: (value) {
                            _userPassword = '$value';
                          },
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                              onPressed: _tryForgotPassword,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                        if (widget.isLoading) const CircularProgressIndicator(),
                        if (!widget.isLoading)
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: ElevatedButton(
                              //color: const Color.fromARGB(255, 0, 171, 227),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white),
                              onPressed: _trySubmit,
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        //const SizedBox(height: 5),
                        // const Center(child: Text("Or Login With")),
                        // const SizedBox(height: 2),
                        // Center(
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       IconButton(
                        //         iconSize: 12,
                        //         icon: Image.asset('assets/google.png'),
                        //         onPressed:
                        //             widget.isLoading ? null : _tryGoogleSignIn,
                        //       ),
                        //       // IconButton(
                        //       //   iconSize: 12,
                        //       //   icon: Image.asset('assets/facebook.jpg'),
                        //       //   onPressed:
                        //       //       widget.isLoading ? null : _tryFacebookSignIn,
                        //       // )
                        //     ],
                        //   ),
                        // ),
                        TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushNamed(Register.routeName),
                            child: const Text(
                              'Register Now',
                              style: TextStyle(color: Colors.white),
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
