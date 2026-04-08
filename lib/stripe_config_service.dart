import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StripeConfigService {
  static Future<void> initStripe() async {
    // GetMaterialApp is not running yet; read saved language instead of Get.locale.
    final prefs = await SharedPreferences.getInstance();
    final String langCode = prefs.getString('language') ?? 'en';
    final String _url =
        "https://cgmember.com/api/stripe/get-keys?lang=$langCode";
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch Stripe keys");
    }

    final data = jsonDecode(response.body);

    if (data['status'] != 200 || data['publish_key'] == null) {
      throw Exception("Invalid Stripe key response");
    }

    // ✅ ONLY publishable key
    Stripe.publishableKey = data['publish_key'];

    // Required for iOS
    await Stripe.instance.applySettings();
  }
}
