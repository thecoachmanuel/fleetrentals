// ignore_for_file: empty_catches, prefer_typing_uninitialized_variables
import 'dart:convert';
import 'package:carlinknew/model/brandCar_modal.dart';
import 'package:carlinknew/utils/common_ematy.dart';
import 'package:carlinknew/utils/common.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/Dark_lightmode.dart';
import '../../utils/config.dart';
import '../../utils/fontfameli_model.dart';
import 'cardetails_screen.dart';

class BrandWiseScreen extends StatefulWidget {
  final String brandId;
  final String brandCar;
  const BrandWiseScreen({super.key, required this.brandId, required this.brandCar});

  @override
  State<BrandWiseScreen> createState() => _BrandWiseScreenState();
}

class _BrandWiseScreenState extends State<BrandWiseScreen> {
  late String finalId;
  bool isLoading = true;
  BrandModal? bCar;
  Future brandCar(lats, longs, uid, cityId) async {
    Map body = {
      "brand_id": widget.brandId,
      "lats": lats ?? 0.0,
      "longs": longs ?? 0.0,
      "uid": uid,
      "cityid": cityId ?? 0,
    };
    print("FFFFFF--->${body}");
    try{
      var response = await http.post(
        Uri.parse(Config.baseUrl+Config.brandWise),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 4));
      if(response.statusCode == 200){
        setState(() {
          bCar = brandModalFromJson(response.body);
          isLoading = false;
        });
        var data = jsonDecode(response.body.toString());
        return data;
      }
    }catch(e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  var currencies;
  Future getvalidate() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id;
    try {
      id = jsonDecode(sharedPreferences.getString('UserLogin') ?? '{"id":"1"}');
    } catch (e) {
      id = {"id": "1"};
    }
    var lat = sharedPreferences.getString('lats') ?? "0.0";
    var long = sharedPreferences.getString('longs') ?? "0.0";
    var dId = sharedPreferences.getString('lId');
    try {
      currencies = jsonDecode(sharedPreferences.getString('bannerData') ?? '{"tax":"7.5","currency":"₦"}');
      if (currencies is Map) currencies['currency'] = '₦';
    } catch (e) {
      currencies = {"tax": "7.5", "currency": "₦"};
    }
    brandCar(lat, long, id['id'], dId);
  }

  @override
  void initState() {
    getvalidate();
    super.initState();
  }

  late ColorNotifire notifire;
  int inDex = 0;
  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        iconTheme: IconThemeData(color: notifire.getwhiteblackcolor),
        elevation: 0,
        centerTitle: true,
        title: Text(widget.brandCar, style: TextStyle(fontFamily: FontFamily.europaBold, fontSize: 15, color: notifire.getwhiteblackcolor,),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: isLoading ? loader() : Column(
          children: [
            Expanded(
              child: bCar!.featureCar.isNotEmpty ? ListView.builder(
                itemCount: bCar?.featureCar.length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  inDex = index;
                  return InkWell(
                    onTap: () {
                      Get.to(CarDetailsScreen(id: bCar!.featureCar[index].id, currency: (currencies != null && currencies['currency'] != null) ? currencies['currency'] : '₦'));
                    },
                    child: Container(
                      height: 250,
                      width: Get.size.width,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        // border: Border.all(color: const Color(0xffF9F9F9)),
                        borderRadius: BorderRadius.circular(20),
                        color: notifire.getBottom,
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              height: 204,
                              width: Get.width,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: bCar!.featureCar[index].carImg.startsWith('assets/')
                                        ? Image.asset(bCar!.featureCar[index].carImg, fit: BoxFit.cover)
                                        : Image.network(
                                            Config.imgUrl + (bCar!.featureCar[index].carImg.startsWith('/') ? bCar!.featureCar[index].carImg.substring(1) : bCar!.featureCar[index].carImg),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Image.asset('assets/car1.png', fit: BoxFit.cover),
                                          ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: const [0.6, 0.8, 1.5],
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.9),
                                          Colors.black.withOpacity(0.9),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    right: 10,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        blurTitle(title: bCar!.featureCar[index].carTitle, context: context),
                                        blurRating(rating: bCar!.featureCar[index].carRating, color: Colors.white, context: context),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    left: 20,
                                    right: 20,
                                    bottom: 10,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(bCar!.featureCar[index].carNumber, style: const TextStyle(fontFamily: FontFamily.europaBold, color: Colors.white)),
                                        Text('₦${bCar!.featureCar[index].carRentPrice} /${bCar!.featureCar[index].priceType  == '1' ? "hr".tr : "days".tr}', style: const TextStyle(fontFamily: FontFamily.europaBold, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              carTool(image: 'assets/engine.png', title: '${bCar!.featureCar[index].engineHp} ${'hp'.tr}'),
                              carTool(image: 'assets/manual-gearbox.png', title: bCar!.featureCar[index].carGear == '0' ? 'Automatic'.tr : 'Manual'.tr),
                              carTool(image: 'assets/petrol.png',title: bCar!.featureCar[index].fuelType == '0' ? 'Petrol'.tr : bCar!.featureCar[index].fuelType == '1' ? 'Diesel'.tr : bCar!.featureCar[index].fuelType == '2' ? 'Electric'.tr : bCar!.featureCar[index].fuelType == '3' ? 'CNG'.tr : 'Petrol & CNG'.tr),
                              carTool(image: 'assets/seat.png', title: '${bCar!.featureCar[index].totalSeat} ${'Seats'.tr}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ) : ematyCar(title: 'Brand Car'.tr,colors: notifire.getwhiteblackcolor),
            ),
          ],
        ),
      ),
    );
  }
  Widget carTool({required String image, required String title}){
    return Row(
      children: [
        Image.asset(image, height: 20, width: 20, color: notifire.getwhiteblackcolor),
        const SizedBox(width: 4),
        Text(title, style:  TextStyle(fontFamily: FontFamily.europaWoff, color: notifire.getwhiteblackcolor, fontSize: 13)),
      ],
    );
  }
}
