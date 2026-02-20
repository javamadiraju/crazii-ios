import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class DeviceIdService {
  static final DeviceIdService _instance = DeviceIdService._internal();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  factory DeviceIdService() {
    return _instance;
  }

  DeviceIdService._internal();

  static const String _deviceIdKey = 'stored_device_id';
  static const String _deviceSpecsKey = 'device_specs';

  /// Generate a unique device ID based on device specifications
  /// The ID is consistent for the same device
  Future<String> getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // ✅ Check if device ID already exists in storage
      final String? storedDeviceId = prefs.getString(_deviceIdKey);
      if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
        print("✅ Device ID found in storage: $storedDeviceId");
        return storedDeviceId;
      }

      // ✅ Generate new device ID based on device specifications
      final String deviceId = await _generateDeviceId();
      
      // ✅ Store it for future use
      await prefs.setString(_deviceIdKey, deviceId);
      print("✅ New Device ID generated and stored: $deviceId");
      
      return deviceId;
    } catch (e) {
      print("❌ Error getting device ID: $e");
      rethrow;
    }
  }

  /// Generate device ID from device specifications
  Future<String> _generateDeviceId() async {
    try {
      final Map<String, dynamic> deviceSpecs = await _getDeviceSpecifications();
      
      // Store device specs
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_deviceSpecsKey, jsonEncode(deviceSpecs));
      
      // Create a unique string from device specs
      final String specsString = _formatDeviceSpecs(deviceSpecs);
      print("📱 Device Specifications: $specsString");
      
      // ✅ Generate SHA-256 hash for device ID
      final String deviceId = sha256.convert(utf8.encode(specsString)).toString();
      print("📱 Device id is: $deviceId");
      return deviceId;
    } catch (e) {
      print("❌ Error generating device ID: $e");
      rethrow;
    }
  }

  /// Get detailed device specifications
  Future<Map<String, dynamic>> _getDeviceSpecifications() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return await _getAndroidSpecs();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        return await _getIOSSpecs();
      } else {
        return {'platform': 'unknown'};
      }
    } catch (e) {
      print("❌ Error getting device specifications: $e");
      rethrow;
    }
  }

  /// Get Android device specifications
  Future<Map<String, dynamic>> _getAndroidSpecs() async {
    try {
      final AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
      
      return {
        'platform': 'android',
        'device': androidInfo.device,
        'manufacturer': androidInfo.manufacturer,
        'model': androidInfo.model,
        'board': androidInfo.board,
        'fingerprint': androidInfo.fingerprint,
        'hardware': androidInfo.hardware,
        'androidId': androidInfo.id, // ✅ Unique Android device ID
        'version_release': androidInfo.version.release,
        'version_codename': androidInfo.version.codename,
        'version_sdkInt': androidInfo.version.sdkInt,
      };
    } catch (e) {
      print("❌ Error getting Android specs: $e");
      rethrow;
    }
  }

  /// Get iOS device specifications
  Future<Map<String, dynamic>> _getIOSSpecs() async {
    try {
      final IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
      
      return {
        'platform': 'ios',
        'model': iosInfo.model,
        'systemName': iosInfo.systemName,
        'systemVersion': iosInfo.systemVersion,
        'utsname_machine': iosInfo.utsname.machine,
        'utsname_sysname': iosInfo.utsname.sysname,
        'utsname_release': iosInfo.utsname.release,
        'identifierForVendor': iosInfo.identifierForVendor, // ✅ Unique iOS device ID
      };
    } catch (e) {
      print("❌ Error getting iOS specs: $e");
      rethrow;
    }
  }

  /// Format device specs into a readable string
  String _formatDeviceSpecs(Map<String, dynamic> specs) {
    final StringBuffer buffer = StringBuffer();
    specs.forEach((key, value) {
      buffer.write('$key:$value|');
    });
    return buffer.toString();
  }

  /// Get stored device specifications (for debugging/validation)
  Future<Map<String, dynamic>?> getStoredDeviceSpecs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? specsJson = prefs.getString(_deviceSpecsKey);
      if (specsJson != null) {
        return jsonDecode(specsJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("❌ Error retrieving stored device specs: $e");
      return null;
    }
  }

  /// Clear stored device ID (use only for testing)
  Future<void> clearStoredDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceIdKey);
      await prefs.remove(_deviceSpecsKey);
      print("✅ Stored device ID cleared");
    } catch (e) {
      print("❌ Error clearing device ID: $e");
    }
  }
}
