import 'dart:convert';
import 'dart:ui';
import 'package:carlinknew/screen/gerneral_support/Applanguage_screen.dart';
import 'package:carlinknew/screen/login_flow/splash_screen.dart';
import 'package:carlinknew/utils/Dark_lightmode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:carlinknew/helpar/get_di.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';
import 'Localmodal_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  await GetStorage.init();
  if (!kIsWeb) {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("54e824a7-5665-4c1c-94fe-f1490539960f");
    OneSignal.Notifications.requestPermission(true);
  }
  final prefs = await SharedPreferences.getInstance();
  try {
    String? bData = prefs.getString('bannerData');
    if (bData == null) {
      prefs.setString('bannerData', '{"tax":"7.5","currency":"₦"}');
    } else {
      var decoded = jsonDecode(bData);
      if (decoded is Map) {
        decoded['currency'] = '₦';
        prefs.setString('bannerData', jsonEncode(decoded));
      }
    }
  } catch (_) {
    prefs.setString('bannerData', '{"tax":"7.5","currency":"₦"}');
  }
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences _prefs;
  const MyApp({super.key, required SharedPreferences prefs}): _prefs = prefs;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ColorNotifire()),
        ChangeNotifierProvider(create: (context) => LocaleModel(_prefs)),
      ],
      child: Consumer<LocaleModel>  (
        builder: (context, localeModel, child) {
          return GetMaterialApp(
            title: 'Fleet Rentals',
            debugShowCheckedModeBanner: false,
            translations: LocalString(),
            locale: localeModel.locale,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            theme: ThemeData(
              useMaterial3: false,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              dividerColor: Colors.transparent,
              fontFamily: "urbani_regular",
              primaryColor: const Color(0xff1347FF),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: const Color(0xff194BFB),
              ),
            ),
            builder: (context, child) {
              return child ?? const SizedBox();
            },
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}



