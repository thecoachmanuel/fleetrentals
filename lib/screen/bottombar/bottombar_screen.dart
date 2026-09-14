// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, avoid_print, prefer_typing_uninitialized_variables, unused_import
import 'dart:async';
import 'dart:convert';
import 'package:carlinknew/screen/bottombar/carinfo_screeen.dart';
import 'package:carlinknew/screen/bottombar/favorite_screen.dart';
import 'package:carlinknew/screen/bottombar/home_screen.dart';
import 'package:carlinknew/screen/bottombar/profile_screen.dart';
import 'package:carlinknew/utils/Colors.dart';
import 'package:carlinknew/utils/Dark_lightmode.dart';
import 'package:carlinknew/utils/config.dart';
import 'package:http/http.dart' as http;
import 'package:carlinknew/utils/fontfameli_model.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../controller/location_controller.dart';
import '../../model/homeData_modal.dart';
import '../../utils/App_content.dart';
import '../login_flow/onbording_screen.dart';
import '../desktop/desktop_layout.dart';
import 'explore_screen.dart';

class BottomBarScreen extends StatefulWidget {
  final String? userType;
  const BottomBarScreen({super.key, this.userType});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int currentIndex = 0;
  List<Widget> myChilders = [
    HomeScreen(),
    ExploreScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  late ColorNotifire notifire;
  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  LocationController lController = Get.put(LocationController());
  locationSave() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    lName = _prefs.getString('location') ?? "Victoria Island, Lagos";
  }

  final DateRangePickerController _controller = DateRangePickerController();
  TextEditingController locationController = TextEditingController();

  HomeBanner banner = getDefaultHomeBanner();
  bool load = false;
  Future homeBanner(uid, dId) async {
    Map body = {
      "uid": uid ?? "1",
      "lats": (lat ?? 0.0).toString(),
      "longs": (long ?? 0.0).toString(),
      "cityid": dId ?? 0,
    };
    try {
      var response = await http.post(
        Uri.parse(Config.baseUrl + Config.homeData),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        SharedPreferences shared = await SharedPreferences.getInstance();
        shared.setString('lats', (lat ?? 0.0).toString());
        shared.setString('longs', (long ?? 0.0).toString());
        if (mounted) {
          setState(() {
            banner = homeBannerFromJson(response.body);
            load = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint("bottombar homeBanner error: $e");
    }
    if (mounted) {
      setState(() {
        banner = getDefaultHomeBanner();
        load = false;
      });
    }
  }

  bool? isLogin;

  var loId;
  var loName;
  var id;

  setLocal() async {
    SharedPreferences lName = await SharedPreferences.getInstance();
    String? userStr = lName.getString('UserLogin');
    if (userStr != null) {
      try {
        id = jsonDecode(userStr);
      } catch (e) {
        id = {"id": "1"};
      }
    } else {
      id = {"id": "1"};
    }
    loName = lName.getString('locationName');
    loId = lName.getString('lId');
    homeBanner(id['id'], loId);
  }

  @override
  void initState() {
    getdarkmodepreviousstate();
    setLocal();
    final DateTime today = DateTime.now();
    _controller.selectedRange =
        PickerDateRange(today, today.add(Duration(days: 3)));
    lController.dController = DateRangePickerController();
    getDataFromLocal().then((value) {
      if (isLogin == true) {
        lController.cityList().then((value) {
          set();
        });
      }
    });
    super.initState();
  }

  Future<void> _refresh()async {
    Future.delayed(const Duration(seconds: 1),() {
      setState(() {
        homeBanner(id['id'],loId);
      });
    },);
  }
  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return DesktopLayout(banner: banner);
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          color: onbordingBlue,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: notifire.getbgcolor,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: load ? SizedBox() : banner.showAddCar == "0" ? SizedBox() : FloatingActionButton(
              heroTag: null,
              elevation: 0,
              backgroundColor: onbordingBlue,
                onPressed: () {
                  Get.to(CarInfoScreen());
                },
              child: Icon(Icons.add,size: 30),
            ),
            bottomNavigationBar:  BottomNavigationBar(
              backgroundColor: notifire.getbgcolor,
              type: BottomNavigationBarType.fixed,
              unselectedItemColor: greyScale1,
              elevation: 0,
              selectedLabelStyle: const TextStyle(fontFamily: FontFamily.europaBold, fontSize: 12),
              fixedColor: onbordingBlue,
              unselectedLabelStyle: const TextStyle(fontFamily: FontFamily.europaWoff),
              currentIndex: currentIndex,
              landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                  icon: Image.asset("assets/homeBold.png", color: greyScale1, height: MediaQuery.of(context).size.height / 35),
                  activeIcon: Image.asset("assets/homeBold.png", color: onbordingBlue, height: MediaQuery.of(context).size.height / 35),
                  label: 'Home'.tr,
                ),
                BottomNavigationBarItem(
                  icon: Image.asset("assets/location-pin.png", height: MediaQuery.of(context).size.height / 35),
                  activeIcon: Image.asset("assets/location-pin.png", color: onbordingBlue, height: MediaQuery.of(context).size.height / 35),
                  label: 'Explore'.tr,
                ),
                BottomNavigationBarItem(
                  icon: Image.asset("assets/fevoriteBold.png", color: greyScale1, height: MediaQuery.of(context).size.height / 35),
                  activeIcon: Image.asset("assets/fevoriteBold.png", color: onbordingBlue, height: MediaQuery.of(context).size.height / 35),
                  label: 'Favorites'.tr,
                ),
                BottomNavigationBarItem(
                  icon: Image.asset("assets/profileBold.png", color: greyScale1, height: MediaQuery.of(context).size.height / 35),
                  activeIcon: Image.asset("assets/profileBold.png", color: onbordingBlue, height: MediaQuery.of(context).size.height / 35),
                  label: 'Profile'.tr,
                ),
              ],
              onTap: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
            ),
            body: myChilders[currentIndex],
          ),
        );
      },
    );
  }

  Future getDataFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        isLogin = prefs.getBool("bottomsheet") ?? false;
      });
    }
  }

  Future set() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("bottomsheet", false);
  }
}