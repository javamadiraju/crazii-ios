import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_home.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_authentication/crazii_signin.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _rememberMe = false;

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );

    _initializeSplash();
  }

  Future<void> _initializeSplash() async {
    await _loadUserCredentials();
    await _controller.forward(); // Wait for animation
    _navigateNext();
  }

  Future<void> _loadUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // ✅ CHECK IF USER WAS PREVIOUSLY LOGGED IN (PERSISTENT LOGIN)
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (isLoggedIn) {
      // User was logged in before - skip login page
      _rememberMe = true;
      print("✅ User previously logged in - skipping login page");
      return;
    }
    
    // ✅ Otherwise check for auto-login via remember me
    final String? userJson = prefs.getString('user');

    if (userJson != null) {
      try {
        bool? result = await apiService.refreshToken();
        if (result == true) {
          _rememberMe = true;
        } else {
          print('Token refresh failed.');
        }
      } catch (e) {
        print('Error parsing userJson or signing in: $e');
      }
    } else {
      print('No user JSON found in shared preferences');
    }
  }

  void _navigateNext() {
    if (_rememberMe) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CraziiHome()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CraziiAppSignIn()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Center(
            child: Opacity(
              opacity: _animation.value,
              child: Image.asset(
                'assets/splash.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          );
        },
      ),
    );
  }
}
