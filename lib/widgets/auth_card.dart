import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shops_app/models/not_authenticated_exception.dart';
import 'package:shops_app/providers/auth_provider.dart';

enum AuthMode { SignUp, Login }

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final Map<String, String> _authData = {
    "email": "",
    "password": "",
  };
  final _passwordController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;

  var _isLoading = false;
  AnimationController? _controller;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeIn,
      ),
    );
    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeIn,
      ),
    );
  }

  FutureOr<Null> showAlertDialog(String message, {String? title}) {
    return showDialog<Null>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? "An Error Occured"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Okay"),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false)
            .signIn(_authData["email"]!, _authData["password"]!);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .signUp(_authData["email"]!, _authData["password"]!);
      }
    } on NotAuthenticatedException catch (e) {
      String message;
      switch (e.toString()) {
        case "EMAIL_EXISTS":
          message = "The Email exists already. Please Log in.";
          break;
        case "EMAIL_NOT_FOUND":
          message = "The Email is not found. Please Sign Up.";
          break;
        case "INVALID_PASSWORD":
          message = "The Password is incorrect. Please Try Again.";
          break;
        default:
          message = "Authentication Failed. Please Try Again Later.";
          break;
      }
      await showAlertDialog(message, title: "Authentication Failed");
    } catch (e) {
      print(e);
      var message = "Unable to Verify. Please Try Again Later.";
      await showAlertDialog(message);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
      _controller!.forward();
      return;
    }
    setState(() {
      _authMode = AuthMode.Login;
    });
    _controller!.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8,
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: 300,
        ),
        height: _authMode == AuthMode.SignUp ? 320 : 260,
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.SignUp ? 320 : 260,
        ),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Email",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (email) {
                    final emailPattern =
                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                    if (RegExp(emailPattern, caseSensitive: false)
                            .firstMatch(email ?? "") ==
                        null) {
                      return "Invalid Email Address";
                    }

                    return null;
                  },
                  onSaved: (email) {
                    _authData["email"] = email ?? "";
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Password",
                  ),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (password) {
                    if (password?.length == 0 || password!.length < 5) {
                      return "Invalid Password";
                    }

                    return null;
                  },
                  onSaved: (password) {
                    _authData["password"] = password ?? "";
                  },
                ),
                AnimatedContainer(
                  duration: Duration(
                    milliseconds: 300,
                  ),
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.Login ? 0 : 60,
                    maxHeight: _authMode == AuthMode.Login ? 0 : 120,
                  ),
                  child: FadeTransition(
                    opacity: _opacityAnimation!,
                    child: SlideTransition(
                      position: _slideAnimation!,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                        ),
                        enabled: _authMode == AuthMode.SignUp,
                        obscureText: true,
                        validator: _authMode == AuthMode.SignUp
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return "Password do not match";
                                }

                                return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      _authMode == AuthMode.SignUp ? "SIGN UP" : "LOGIN",
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                TextButton(
                  child: Text(
                    "${_authMode == AuthMode.SignUp ? 'LOGIN' : 'SIGN UP'} INSTEAD",
                  ),
                  onPressed: _switchAuthMode,
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
