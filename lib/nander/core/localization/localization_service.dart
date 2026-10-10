import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../local_storage/user_info.dart';

class LocalizationService {
  static const String englishCode = 'en';
  static const String dutchCode = 'nl';

  static const Locale englishLocale = Locale('en', 'US');
  static const Locale dutchLocale = Locale('nl', 'NL');

  static final List<Locale> supportedLocales = [
    englishLocale,
    dutchLocale,
  ];

  static Locale get currentLocale {
    final code = Get.locale?.languageCode ?? englishCode;
    return code == dutchCode ? dutchLocale : englishLocale;
  }

  static bool get isDutch {
    return (Get.locale?.languageCode ?? englishCode) == dutchCode;
  }

  static String get currentLanguageName {
    return isDutch ? 'Nederlands' : 'English';
  }

  static Future<void> changeLanguage(String langCode) async {
    final locale = langCode == dutchCode ? dutchLocale : englishLocale;
    await UserInfo.setLanguage(langCode);
    await Get.updateLocale(locale);
  }

  static Future<Locale> getInitialLocale() async {
    final savedCode = await UserInfo.getLanguage();
    return savedCode == dutchCode ? dutchLocale : englishLocale;
  }
}
