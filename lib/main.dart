import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nander/nander/routes/app_route.dart';
import 'package:nander/nander/routes/route_name.dart';
import 'package:nander/nander/core/local_storage/user_info.dart';
import 'package:nander/nander/core/localization/app_translations.dart';
import 'package:nander/nander/core/localization/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  final isAuthenticated = await UserInfo.isLoggedIn();
  String? role;
  if (isAuthenticated) {
    role = await UserInfo.getUserRole();
  }
  final initialLocale = await LocalizationService.getInitialLocale();

  runApp(MyApp(
    isAuthenticated: isAuthenticated,
    role: role,
    initialLocale: initialLocale,
  ));
}

class MyApp extends StatefulWidget {
  final bool isAuthenticated;
  final String? role;
  final Locale initialLocale;
  const MyApp({
    super.key,
    this.isAuthenticated = false,
    this.role,
    this.initialLocale = AppTranslations.englishLocale,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String get initialRoute {
    if (!widget.isAuthenticated) return RouteName.wellcome1;
    return widget.role == 'CLUB_ADMIN' ? RouteName.main1 : RouteName.main;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          locale: widget.initialLocale,
          fallbackLocale: AppTranslations.fallbackLocale,
          initialRoute: initialRoute,
          getPages: AppRoute.pages,
          theme: ThemeData(
            brightness: Brightness.dark,
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
            ),
          ),
        );
      },
    );
  }
}
