import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shops_app/models/not_authenticated_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  String? _userID;
  DateTime? _expiryDate;
  Timer? _authTimer;

  bool get isAuthenticated {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }

    return null;
  }

  String? get userID => _userID;

  Future<void> _authenticate(String email, String password, Uri url) async {
    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {"email": email, "password": password, "returnSecureToken": true},
        ),
      );
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData["error"] != null) {
        throw NotAuthenticatedException(responseData["error"]["message"]);
      }

      _token = responseData["idToken"];
      _userID = responseData["localId"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData["expiresIn"],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        "token": _token,
        "userID": _userID,
        "expiryDate": _expiryDate?.toIso8601String(),
      });
      prefs.setString("userData", userData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signUp(String email, String password) {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCVcVXA5Yzy0V-g7Clq54rNYw-KR_OtfSc");
    return _authenticate(email, password, url);
  }

  Future<void> signIn(String email, String password) {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCVcVXA5Yzy0V-g7Clq54rNYw-KR_OtfSc");
    return _authenticate(email, password, url);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("userData")) {
      return false;
    }

    final data = prefs.getString("userData");
    if (data == null) {
      return false;
    }
    final userData = jsonDecode(data) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(userData["expiryDate"]);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = userData["token"];
    _userID = userData["userID"];
    _expiryDate = expiryDate;
    _autoLogout();
    notifyListeners();
    return true;
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    final timeToExpire = _expiryDate?.difference(DateTime.now()).inSeconds ?? 0;
    _authTimer = Timer(Duration(seconds: timeToExpire), logout);
  }

  Future<void> logout() async {
    _token = null;
    _userID = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
