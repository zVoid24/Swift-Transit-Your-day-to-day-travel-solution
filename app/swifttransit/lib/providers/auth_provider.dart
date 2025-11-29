import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;

  final fullName = TextEditingController();
  final email = TextEditingController();
  final nid = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();

  bool agreed = false;

  void toggleAgreement(bool? value) {
    agreed = value ?? false;
    notifyListeners();
  }

  Future<bool> login(String mobile, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', data['jwt']);
        await prefs.setString('user', jsonEncode(data['user']));

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': fullName.text,
          'mobile': phone.text,
          'nid': nid.text,
          'email': email.text,
          'password': password.text,
          'is_student': false, // Default for now
          'balance': 200.0, // Default balance
        }),
      );

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool isSignupValid() {
    return fullName.text.isNotEmpty &&
        email.text.isNotEmpty &&
        nid.text.isNotEmpty &&
        phone.text.isNotEmpty &&
        password.text.length >= 6 &&
        agreed == true;
  }
}
