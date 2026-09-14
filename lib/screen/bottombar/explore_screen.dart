// ignore_for_file: non_constant_identifier_names, empty_catches, prefer_typing_uninitialized_variables, unused_import
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:carlinknew/controller/home_controller.dart';
import 'package:carlinknew/model/explore_modal.dart';
import 'package:carlinknew/utils/common_ematy.dart';
import 'package:carlinknew/utils/common.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:carlinknew/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/App_content.dart';
import '../../utils/Colors.dart';
import '../../utils/Custom_widget.dart';
import '../../utils/Dark_lightmode.dart';
import '../../utils/fontfameli_model.dart';
import '../detailcar/cardetails_screen.dart';
import '../login_flow/onbording_screen.dart';

final List<FeatureCar> defaultNigerianCars = [
  FeatureCar(
    id: "1",
    carTitle: "Toyota Land Cruiser Prado TXL",
    carImg: "assets/jeep.png",
    carRating: "4.9",
    carNumber: "LAG-782-AA",
    totalSeat: "7",
    carGear: "0",
    pickLat: "6.4281",
    pickLng: "3.4219",
    engineHp: "300",
    fuelType: "0",
    pickAddress: "Victoria Island Hub, Lagos, Nigeria",
    carDistance: "1.2 km",
  ),
  FeatureCar(
    id: "2",
    carTitle: "Mercedes-Benz G63 AMG Edition",
    carImg: "assets/featurecar1.png",
    carRating: "5.0",
    carNumber: "ABJ-001-VIP",
    totalSeat: "5",
    carGear: "0",
    pickLat: "6.4474",
    pickLng: "3.4849",
    engineHp: "577",
    fuelType: "0",
    pickAddress: "Admiralty Way, Lekki Phase 1, Lagos",
    carDistance: "3.5 km",
  ),
  FeatureCar(
    id: "3",
    carTitle: "Range Rover Autobiography LWB",
    carImg: "assets/car1.png",
    carRating: "4.8",
    carNumber: "LAG-404-RR",
    totalSeat: "5",
    carGear: "0",
    pickLat: "6.4549",
    pickLng: "3.4357",
    engineHp: "523",
    fuelType: "0",
    pickAddress: "Bourdillon Road, Ikoyi, Lagos",
    carDistance: "2.1 km",
  ),
  FeatureCar(
    id: "4",
    carTitle: "Rolls-Royce Ghost Black Badge",
    carImg: "assets/car2.png",
    carRating: "5.0",
    carNumber: "ABJ-777-EX",
    totalSeat: "4",
    carGear: "0",
    pickLat: "9.0579",
    pickLng: "7.4951",
    engineHp: "563",
    fuelType: "0",
    pickAddress: "Central Business District, Abuja",
    carDistance: "4.8 km",
  ),
];

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  ExploreController exploreController = Get.find();
  late ColorNotifire notifire;
  GoogleMapController? mapController;
  final PageController pageController = PageController(viewportFraction: 0.88);
  Set<Marker> markers = {};
  ExploreModal? exploreModal;
  bool loading = true;
  int Index = 0;
  String address = "Victoria Island, Lagos, Nigeria";
  var currencies;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getCurrentLatAndLong();
    getvalidate();
    exploreController.shimmer();
  }

  Future explore(uid, lat, lng, cityId) async {
    Map body = {
      "uid": uid,
      "lats": lat,
      "longs": lng,
      "cityid": cityId ?? 0,
    };
    try {
      var response = await http.post(
        Uri.parse(Config.baseUrl + Config.explore),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        var parsed = exploreModalFromJson(response.body);
        if (parsed.featureCar.isNotEmpty) {
          if (mounted) {
            setState(() {
              exploreModal = parsed;
              loading = false;
            });
          }
          _updateAllMarkers(parsed.featureCar);
          return;
        }
      }
    } catch (e) {
      debugPrint("explore api error/timeout: $e");
    }

    if (mounted) {
      setState(() {
        exploreModal = ExploreModal(
          responseCode: "200",
          result: "true",
          responseMsg: "Success",
          featureCar: defaultNigerianCars,
        );
        loading = false;
      });
      _updateAllMarkers(defaultNigerianCars);
    }
  }

  Future<void> _updateAllMarkers(List<FeatureCar> cars) async {
    Set<Marker> newMarkers = {};
    BitmapDescriptor pinIcon;
    try {
      final Uint8List markIcon = await getImages(Appcontent.mapPin, 70);
      pinIcon = BitmapDescriptor.fromBytes(markIcon);
    } catch (e) {
      pinIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }

    for (int i = 0; i < cars.length; i++) {
      double lat = double.tryParse(cars[i].pickLat) ?? (6.4281 + (i * 0.015));
      double lng = double.tryParse(cars[i].pickLng) ?? (3.4219 + (i * 0.015));
      newMarkers.add(Marker(
        markerId: MarkerId("marker_$i"),
        position: LatLng(lat, lng),
        icon: pinIcon,
        infoWindow: InfoWindow(
          title: cars[i].carTitle,
          snippet: cars[i].pickAddress,
        ),
        onTap: () {
          setState(() {
            Index = i;
          });
          if (pageController.hasClients) {
            pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
      ));
    }
    if (mounted) {
      setState(() {
        markers = newMarkers;
      });
    }
  }

  Future getvalidate() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id;
    try {
      id = jsonDecode(sharedPreferences.getString('UserLogin') ?? '{"id":"1"}');
    } catch (e) {
      id = {"id": "1"};
    }
    var lId = sharedPreferences.getString('lId') ?? "0";
    try {
      currencies = jsonDecode(sharedPreferences.getString('bannerData') ?? '{"tax":"7.5","currency":"₦"}');
      if (currencies is Map) currencies['currency'] = '₦';
    } catch (e) {
      currencies = {"tax": "7.5", "currency": "₦"};
    }
    explore(id['id'], "6.4281", "3.4219", lId);
  }

  Future getvalidate1({required String latitude, required String longitude}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id;
    try {
      id = jsonDecode(sharedPreferences.getString('UserLogin') ?? '{"id":"1"}');
    } catch (e) {
      id = {"id": "1"};
    }
    var lId = sharedPreferences.getString('lId') ?? "0";
    explore(id['id'], latitude, longitude, lId);
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  getCurrentLatAndLong() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        var currentLocation = await locateUser().timeout(const Duration(seconds: 3));
        getvalidate1(latitude: currentLocation.latitude.toString(), longitude: currentLocation.longitude.toString());
      }
    } catch (e) {
      debugPrint("explore location skipped/denied: $e");
    }

    if (!kIsWeb) {
      try {
        var currentLocation = await locateUser();
        await placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude).then((List<Placemark> placeMarks) {
          if (placeMarks.isNotEmpty) {
            address = '${placeMarks.first.name!.isNotEmpty ? '${placeMarks.first.name!}, ' : ''}${placeMarks.first.locality!.isNotEmpty ? '${placeMarks.first.locality!}, ' : ''}${placeMarks.first.administrativeArea!.isNotEmpty ? placeMarks.first.administrativeArea : ''}';
          }
        });
      } catch (e) {}
    } else {
      address = "Victoria Island, Lagos, Nigeria";
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    List<FeatureCar> cars = (exploreModal != null && exploreModal!.featureCar.isNotEmpty)
        ? exploreModal!.featureCar
        : defaultNigerianCars;
    int safeIndex = Index.clamp(0, cars.length - 1);
    double initialLat = double.tryParse(cars[safeIndex].pickLat) ?? 6.4281;
    double initialLng = double.tryParse(cars[safeIndex].pickLng) ?? 3.4219;

    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        centerTitle: true,
        title: Text('Explore'.tr, style: TextStyle(fontSize: 18, color: notifire.getwhiteblackcolor, fontFamily: FontFamily.europaBold)),
      ),
      body: loading
          ? loader()
          : GetBuilder<ExploreController>(
              builder: (ctrl) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GoogleMap(
                      markers: markers,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(initialLat, initialLng),
                        zoom: 13,
                      ),
                      mapType: MapType.normal,
                      padding: const EdgeInsets.only(bottom: 185),
                      myLocationEnabled: false,
                      zoomGesturesEnabled: true,
                      tiltGesturesEnabled: true,
                      zoomControlsEnabled: true,
                      onMapCreated: (controller) {
                        mapController = controller;
                        _updateAllMarkers(cars);
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 12,
                      child: SizedBox(
                        height: 168,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ScrollConfiguration(
                              behavior: const MaterialScrollBehavior().copyWith(
                                dragDevices: {
                                  PointerDeviceKind.mouse,
                                  PointerDeviceKind.touch,
                                  PointerDeviceKind.trackpad,
                                  PointerDeviceKind.stylus,
                                },
                              ),
                              child: PageView.builder(
                                controller: pageController,
                                itemCount: cars.length,
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                onPageChanged: (value) {
                                  setState(() {
                                    Index = value;
                                  });
                                  double targetLat = double.tryParse(cars[value].pickLat) ?? initialLat;
                                  double targetLng = double.tryParse(cars[value].pickLng) ?? initialLng;
                                  try {
                                    mapController?.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: LatLng(targetLat, targetLng),
                                          zoom: 14,
                                        ),
                                      ),
                                    );
                                  } catch (e) {}
                                },
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Get.to(CarDetailsScreen(id: cars[index].id, currency: currencies != null ? currencies['currency'] ?? '₦' : '₦'));
                                    },
                                    child: Container(
                                      height: 160,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: notifire.getblackwhitecolor,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.18),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: SizedBox(
                                                  height: 85,
                                                  width: 130,
                                                  child: _buildCarThumb(cars[index].carImg),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      cars[index].carTitle,
                                                      style: TextStyle(fontFamily: FontFamily.europaBold, fontSize: 14, color: notifire.getwhiteblackcolor),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Image.asset(Appcontent.star1, height: 14),
                                                        const SizedBox(width: 4),
                                                        Text(cars[index].carRating, style: TextStyle(fontFamily: FontFamily.europaWoff, color: greyScale1, fontSize: 12)),
                                                        const SizedBox(width: 8),
                                                        Text("•  ${cars[index].carDistance}", style: TextStyle(fontFamily: FontFamily.europaWoff, color: notifire.getgreycolor, fontSize: 11)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(cars[index].carNumber, style: TextStyle(fontFamily: FontFamily.europaBold, fontSize: 13, color: onbordingBlue)),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      cars[index].pickAddress,
                                                      style: TextStyle(fontFamily: FontFamily.europaWoff, color: notifire.getgreycolor, fontSize: 11),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Divider(color: greyScale.withOpacity(0.3), height: 1),
                                          const SizedBox(height: 6),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              physics: const NeverScrollableScrollPhysics(),
                                              child: Row(
                                                children: [
                                                  carTool(image: Appcontent.engine, number: cars[index].engineHp, text: 'hp'.tr),
                                                  const SizedBox(width: 10),
                                                  carTool(image: Appcontent.gearbox, title: cars[index].carGear == '0' ? 'Automatic'.tr : 'Manual'.tr),
                                                  const SizedBox(width: 10),
                                                  carTool(image: Appcontent.petrol, title: '${cars[index].fuelType == '0' ? "Petrol".tr : cars[index].fuelType == '1' ? "Diesel".tr : cars[index].fuelType == '2' ? 'Electric'.tr : cars[index].fuelType == '3' ? 'CNG'.tr : 'Petrol & CNG'.tr} '),
                                                  const SizedBox(width: 10),
                                                  carTool(image: Appcontent.seat, number: cars[index].totalSeat, text: 'Seats'.tr),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (Index > 0)
                              Positioned(
                                left: 6,
                                child: InkWell(
                                  onTap: () {
                                    pageController.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Container(
                                    height: 34,
                                    width: 34,
                                    decoration: BoxDecoration(
                                      color: notifire.getblackwhitecolor.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: notifire.getwhiteblackcolor),
                                  ),
                                ),
                              ),
                            if (Index < cars.length - 1)
                              Positioned(
                                right: 6,
                                child: InkWell(
                                  onTap: () {
                                    pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Container(
                                    height: 34,
                                    width: 34,
                                    decoration: BoxDecoration(
                                      color: notifire.getblackwhitecolor.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.arrow_forward_ios_rounded, size: 15, color: notifire.getwhiteblackcolor),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget carTool({required String image, String? title, String? number, String? text}) {
    return Row(
      children: [
        const SizedBox(width: 4),
        Image.asset(image, height: 18, width: 18, color: notifire.getwhiteblackcolor),
        const SizedBox(width: 4),
        Text(title ?? '', style: TextStyle(fontFamily: FontFamily.europaWoff, color: notifire.getwhiteblackcolor, fontSize: 12)),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: number, style: TextStyle(fontFamily: FontFamily.europaWoff, color: notifire.getwhiteblackcolor, fontSize: 12)),
              const WidgetSpan(child: SizedBox(width: 3)),
              TextSpan(text: text, style: TextStyle(fontFamily: FontFamily.europaWoff, color: notifire.getwhiteblackcolor, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCarThumb(String rawImg) {
    String img = rawImg.split(r'$;').first;
    if (img.startsWith('assets/')) {
      return Image.asset(img, fit: BoxFit.cover);
    }
    String fullUrl = img.startsWith('http')
        ? img
        : Config.imgUrl + (img.startsWith('/') ? img.substring(1) : img);
    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset('assets/jeep.png', fit: BoxFit.cover),
    );
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }
}
