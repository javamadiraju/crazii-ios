import 'package:get/get.dart';

/// Utility class for language/locale operations
class LanguageUtils {
  /// Get the current language code from locale
  /// Returns 'en', 'vi', or 'zh' based on current Get.locale
  static String getLanguageCode() {
    final locale = Get.locale;
    if (locale == null) return 'en';
    
    switch (locale.languageCode) {
      case 'vi':
        return 'vi';
      case 'zh':
        return 'zh';
      default:
        return 'en';
    }
  }

  /// Get the full locale string for API calls
  /// Returns 'en_US', 'vi_VN', or 'zh_CN'
  static String getLocaleString() {
    final locale = Get.locale;
    if (locale == null) return 'en_US';
    
    switch (locale.languageCode) {
      case 'vi':
        return 'vi_VN';
      case 'zh':
        return 'zh_CN';
      default:
        return 'en_US';
    }
  }
}
