// To parse this JSON data, do
//
//     final exploreModal = exploreModalFromJson(jsonString);

import 'dart:convert';
import 'package:carlinknew/utils/price_utils.dart';

ExploreModal exploreModalFromJson(String str) => ExploreModal.fromJson(json.decode(str));

String exploreModalToJson(ExploreModal data) => json.encode(data.toJson());

class ExploreModal {
  String responseCode;
  String result;
  String responseMsg;
  List<FeatureCar> featureCar;

  ExploreModal({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.featureCar,
  });

  factory ExploreModal.fromJson(Map<String, dynamic> json) => ExploreModal(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    featureCar: List<FeatureCar>.from(json["FeatureCar"].map((x) => FeatureCar.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "FeatureCar": List<dynamic>.from(featureCar.map((x) => x.toJson())),
  };
}

class FeatureCar {
  String id;
  String carTitle;
  String carImg;
  String carRating;
  String carNumber;
  String totalSeat;
  String carGear;
  String pickLat;
  String pickLng;
  String engineHp;
  String fuelType;
  String pickAddress;
  String carDistance;

  FeatureCar({
    required this.id,
    required this.carTitle,
    required this.carImg,
    required this.carRating,
    required this.carNumber,
    required this.totalSeat,
    required this.carGear,
    required this.pickLat,
    required this.pickLng,
    required this.engineHp,
    required this.fuelType,
    required this.pickAddress,
    required this.carDistance,
  });

  factory FeatureCar.fromJson(Map<String, dynamic> json) => FeatureCar(
    id: json["id"],
    carTitle: json["car_title"],
    carImg: json["car_img"],
    carRating: json["car_rating"],
    carNumber: json["car_number"],
    totalSeat: json["total_seat"],
    carGear: json["car_gear"],
    pickLat: ensureNigerianLat(json["pick_lat"], id: json["id"]),
    pickLng: ensureNigerianLng(json["pick_lng"], id: json["id"]),
    engineHp: json["engine_hp"],
    fuelType: json["fuel_type"],
    pickAddress: ensureNigerianAddress(json["pick_address"], id: json["id"], title: json["car_title"]?.toString() ?? ''),
    carDistance: json["car_distance"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "car_title": carTitle,
    "car_img": carImg,
    "car_rating": carRating,
    "car_number": carNumber,
    "total_seat": totalSeat,
    "car_gear": carGear,
    "pick_lat": pickLat,
    "pick_lng": pickLng,
    "engine_hp": engineHp,
    "fuel_type": fuelType,
    "pick_address": pickAddress,
    "car_distance": carDistance,
  };
}

ExploreModal getDefaultExploreModal() {
  return ExploreModal(
    responseCode: "200",
    result: "true",
    responseMsg: "Loaded",
    featureCar: [
      FeatureCar(
        id: "1",
        carTitle: "Toyota Land Cruiser Prado TXL",
        carImg: "assets/jeep.png",
        carRating: "4.9",
        carNumber: "LAG-782-AA",
        totalSeat: "7",
        carGear: "1",
        pickLat: "6.4281",
        pickLng: "3.4219",
        engineHp: "300",
        fuelType: "0",
        pickAddress: "Victoria Island Hub, Lagos",
        carDistance: "1.2 km",
      ),
      FeatureCar(
        id: "2",
        carTitle: "Mercedes-Benz G-Wagon G63",
        carImg: "assets/car2.png",
        carRating: "5.0",
        carNumber: "ABJ-101-XX",
        totalSeat: "5",
        carGear: "1",
        pickLat: "9.0765",
        pickLng: "7.4983",
        engineHp: "577",
        fuelType: "0",
        pickAddress: "Maitama Diplomatic Zone, Abuja",
        carDistance: "2.1 km",
      ),
      FeatureCar(
        id: "3",
        carTitle: "Lexus RX350 Luxury AWD",
        carImg: "assets/car1.png",
        carRating: "4.8",
        carNumber: "KNG-340-BC",
        totalSeat: "5",
        carGear: "1",
        pickLat: "6.4474",
        pickLng: "3.4723",
        engineHp: "295",
        fuelType: "0",
        pickAddress: "Admiralty Way, Lekki Phase 1, Lagos",
        carDistance: "3.5 km",
      ),
      FeatureCar(
        id: "4",
        carTitle: "Range Rover Velar R-Dynamic",
        carImg: "assets/car3.png",
        carRating: "4.9",
        carNumber: "IBD-552-ZA",
        totalSeat: "5",
        carGear: "1",
        pickLat: "6.5954",
        pickLng: "3.3515",
        engineHp: "340",
        fuelType: "0",
        pickAddress: "Ikeja GRA Airport Terminal, Lagos",
        carDistance: "4.0 km",
      ),
      FeatureCar(
        id: "5",
        carTitle: "Audi RS e-tron GT",
        carImg: "assets/audiCar.png",
        carRating: "4.9",
        carNumber: "LAG-119-EE",
        totalSeat: "5",
        carGear: "1",
        pickLat: "6.4549",
        pickLng: "3.4356",
        engineHp: "637",
        fuelType: "2",
        pickAddress: "Banana Island, Ikoyi, Lagos",
        carDistance: "1.8 km",
      ),
      FeatureCar(
        id: "7",
        carTitle: "Mercedes-Benz C300 4Matic",
        carImg: "assets/car3.png",
        carRating: "4.8",
        carNumber: "LAG-221-FG",
        totalSeat: "5",
        carGear: "1",
        pickLat: "9.0579",
        pickLng: "7.4951",
        engineHp: "255",
        fuelType: "0",
        pickAddress: "Central Business District, Abuja",
        carDistance: "2.4 km",
      ),
      FeatureCar(
        id: "10",
        carTitle: "Range Rover Sport HSE",
        carImg: "assets/Imageaudi.png",
        carRating: "4.9",
        carNumber: "IBD-802-RV",
        totalSeat: "7",
        carGear: "1",
        pickLat: "4.8156",
        pickLng: "7.0498",
        engineHp: "395",
        fuelType: "0",
        pickAddress: "GRA Phase 2, Port Harcourt",
        carDistance: "2.8 km",
      ),
      FeatureCar(
        id: "8",
        carTitle: "Toyota Camry XSE V6",
        carImg: "assets/car2.png",
        carRating: "4.7",
        carNumber: "ABJ-889-BB",
        totalSeat: "5",
        carGear: "1",
        pickLat: "6.4312",
        pickLng: "3.4180",
        engineHp: "301",
        fuelType: "0",
        pickAddress: "Adeola Odeku, Victoria Island, Lagos",
        carDistance: "1.5 km",
      ),
    ],
  );
}
