import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_authentication/crazii_signup.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_home.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';

import 'authapi.dart';
import 'crazii_forgot_password.dart';

class CraziiAppSignIn extends StatefulWidget {
  const CraziiAppSignIn({Key? key}) : super(key: key);

  @override
  _CraziiAppSignInState createState() => _CraziiAppSignInState();
}

class _CraziiAppSignInState extends State<CraziiAppSignIn> {
  String? _errorMessage;
  bool _isLoading = false;
  bool _showPassword = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService apiService = ApiService();
  final AuthService authService = AuthService();

  List<String> _languages = [];
  String? _selectedLang;

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
    _fetchLanguages();
  }

  Future<void> _fetchLanguages() async {
    try {
      final langCode = Get.locale?.languageCode ?? 'en';
      final response = await http.get(Uri.parse('https://cgmember.com/api/get-lang?lang=$langCode'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == 200 && data['data'] is List) {
          setState(() {
            _languages = List<String>.from(data['data']);
            _selectedLang = _languages.first;
          });
        }
      }
    } catch (_) {}
  }

  void _changeLanguage(String langCode) {
    Get.updateLocale(
      langCode == 'zh'
          ? const Locale('zh', 'CN')
          : langCode == 'vi'
              ? const Locale('vi', 'VN')
              : const Locale('en', 'US'),
    );
    setState(() => _selectedLang = langCode);
  }

  Future<void> _saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    // User stays logged in permanently
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (isLoggedIn) {
      String email = prefs.getString('email') ?? '';
      String password = prefs.getString('password') ?? '';
      
      if (email.isNotEmpty && password.isNotEmpty) {
        setState(() {
          _emailController.text = email;
          _passwordController.text = password;
        });
        // Auto-sign in user
        _signIn();
      }
    }
  }

  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    // Mark user as logged out (clear persistent login)
    await prefs.setBool('isLoggedIn', false);
  }

  Future<void> _signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      return setState(() => _errorMessage = "signin_error_empty".tr);
    }
    if (!EmailValidator.validate(email)) {
      return setState(() => _errorMessage = "signin_error_invalid_email".tr);
    }

    setState(() => _isLoading = true);

    try {
      var response = await apiService.signIn(email, password);
      if (response != null) {
        // ✅ ALWAYS save credentials and mark user as permanently logged in
        await _saveCredentials(email, password);
        setState(() => _errorMessage = null);
        Get.off(() => const CraziiHome());
      }
    } catch (e) {
      String displayError = "Something went wrong.";
      
      // ✅ CHECK IF IT'S AN API EXCEPTION WITH RESPONSE DATA
      if (e is ApiException && e.responseData != null) {
        // Extract error field from API response
        displayError = e.responseData!['error'] ?? e.message;
      } else {
        // Fallback to exception message
        displayError = e.toString();
      }
      
      setState(() => _errorMessage = displayError);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light Theme
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Language Dropdown
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLang,
                      icon: const Icon(Icons.language, color: Colors.black),
                      dropdownColor: Colors.white,
                      items: _languages
                          .map((lang) => DropdownMenuItem(
                                value: lang,
                                child: Text(lang.toUpperCase(),
                                    style: const TextStyle(color: Colors.black)),
                              ))
                          .toList(),
                      onChanged: (value) => _changeLanguage(value!),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 60),
              Image.asset(FreeBankingAppPngimage.crazii, width: 110),
              const SizedBox(height: 12),

              Text("login_title".tr,
                  style: const TextStyle(
                      color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),

              const SizedBox(height: 35),

              _label("email".tr),
              _inputField(_emailController, "enter_email".tr),

              const SizedBox(height: 18),

              _label("password".tr),
              _passwordField(_passwordController, "enter_password".tr),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.to(() => const CraziiForgotPassword()),
                  child: Text("forgot_password".tr,
                      style: const TextStyle(
                          color: Color(0xFFB38F3F),
                          decoration: TextDecoration.underline)),
                ),
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14)),
                ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB38F3F),
                  minimumSize: const Size(240, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("sign_in".tr,
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),

              const SizedBox(height: 25),

              GestureDetector(
                onTap: () {
                  _clearCredentials();
                  Get.to(() => const CraziiSignup());
                },
                child: Text("sign_up".tr,
                    style: const TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                        fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Helper Widgets ----------

  Widget _label(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
      );

  Widget _inputField(TextEditingController ctrl, String hint,
      {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade500),
        ),
      ),
    );
  }

  Widget _passwordField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      obscureText: !_showPassword,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade500),
        ),
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _showPassword = !_showPassword),
          child: Icon(
            _showPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
