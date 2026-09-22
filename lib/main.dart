import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nander/trainer/routes/app_route.dart';
import 'package:nander/trainer/routes/route_name.dart';
import 'package:nander/trainer/core/local_storage/user_info.dart'; // adjust to your actual path

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

  runApp(MyApp(isAuthenticated: isAuthenticated, role: role));
}

class MyApp extends StatefulWidget {
  final bool isAuthenticated;
  final String? role;
  const MyApp({super.key, this.isAuthenticated = false, this.role});

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