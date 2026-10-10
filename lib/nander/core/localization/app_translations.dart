import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'languages/en_us.dart';
import 'languages/nl_nl.dart';

class AppTranslations extends Translations {
  static const Locale englishLocale = Locale('en', 'US');
  static const Locale dutchLocale = Locale('nl', 'NL');

  static const Locale fallbackLocale = englishLocale;

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'nl_NL': nlNL,
      };
}
