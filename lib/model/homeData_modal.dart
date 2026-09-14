// To parse this JSON data, do
//
//     final homeBanner = homeBannerFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

HomeBanner homeBannerFromJson(String str) => HomeBanner.fromJson(json.decode(str));

String homeBannerToJson(HomeBanner data) => json.encode(data.toJson());

class HomeBanner {
  String responseCode;
  String result;
  String responseMsg;
  List<Banner> banner;
  String isBlock;
  String tax;
  String currency;
  List<Carlist> cartypelist;
  List<Carlist> carbrandlist;
  List<FeatureCar> featureCar;
  List<RecommendCar> recommendCar;
  String showAddCar;

  HomeBanner({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.banner,
    required this.isBlock,
    required this.tax,
    required this.currency,
    required this.cartypelist,
    required this.carbrandlist,
    required this.featureCar,
    required this.recommendCar,
    required this.showAddCar,
  });

  factory HomeBanner.fromJson(Map<String, dynamic> json) => HomeBanner(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    banner: List<Banner>.from(json["banner"].map((x) => Banner.fromJson(x))),
    isBlock: json["is_block"],
    tax: json["tax"] ?? "7.5",
    currency: "₦",
    cartypelist: List<Carlist>.from(json["cartypelist"].map((x) => Carlist.fromJson(x))),
    carbrandlist: List<Carlist>.from(json["carbrandlist"].map((x) => Carlist.fromJson(x))),
    featureCar: List<FeatureCar>.from(json["FeatureCar"].map((x) => FeatureCar.fromJson(x))),
    recommendCar: List<RecommendCar>.from(json["Recommend_car"].map((x) => RecommendCar.fromJson(x))),
    showAddCar: json["show_add_car"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "banner": List<dynamic>.from(banner.map((x) => x.toJson())),
    "is_block": isBlock,
    "tax": tax,
    "currency": currency,
    "cartypelist": List<dynamic>.from(cartypelist.map((x) => x.toJson())),
    "carbrandlist": List<dynamic>.from(carbrandlist.map((x) => x.toJson())),
    "FeatureCar": List<dynamic>.from(featureCar.map((x) => x.toJson())),
    "Recommend_car": List<dynamic>.from(recommendCar.map((x) => x.toJson())),
    "show_add_car": showAddCar,
  };
}

class Banner {
  String id;
  String img;

  Banner({
    required this.id,
    required this.img,
  });

  factory Banner.fromJson(Map<String, dynamic> json) => Banner(
    id: json["id"],
    img: json["img"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "img": img,
  };
}

class Carlist {
  String id;
  String title;
  String img;

  Carlist({
    required this.id,
    required this.title,
    required this.img,
  });

  factory Carlist.fromJson(Map<String, dynamic> json) => Carlist(
    id: json["id"],
    title: json["title"],
    img: json["img"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "img": img,
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
  String carRentPrice;
  String priceType;
  String engineHp;
  String fuelType;
  String carTypeTitle;
  String carDistance;

  FeatureCar({
    required this.id,
    required this.carTitle,
    required this.carImg,
    required this.carRating,
    required this.carNumber,
    required this.totalSeat,
    required this.carGear,
    required this.carRentPrice,
    required this.priceType,
    required this.engineHp,
    required this.fuelType,
    required this.carTypeTitle,
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
    carRentPrice: json["car_rent_price"],
    priceType: json["price_type"],
    engineHp: json["engine_hp"],
    fuelType: json["fuel_type"],
    carTypeTitle: json["car_type_title"],
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
    "car_rent_price": carRentPrice,
    "price_type": priceType,
    "engine_hp": engineHp,
    "fuel_type": fuelType,
    "car_type_title": carTypeTitle,
    "car_distance": carDistance,
  };
}

class RecommendCar {
  String id;
  String carTitle;
  List<String> carImg;
  String carRating;
  String carNumber;
  String totalSeat;
  String carGear;
  String carRentPrice;
  String priceType;
  String engineHp;
  String fuelType;
  String carTypeTitle;
  String carDistance;

  RecommendCar({
    required this.id,
    required this.carTitle,
    required this.carImg,
    required this.carRating,
    required this.carNumber,
    required this.totalSeat,
    required this.carGear,
    required this.carRentPrice,
    required this.priceType,
    required this.engineHp,
    required this.fuelType,
    required this.carTypeTitle,
    required this.carDistance,
  });

  factory RecommendCar.fromJson(Map<String, dynamic> json) => RecommendCar(
    id: json["id"],
    carTitle: json["car_title"],
    carImg: List<String>.from(json["car_img"].map((x) => x)),
    carRating: json["car_rating"],
    carNumber: json["car_number"],
    totalSeat: json["total_seat"],
    carGear: json["car_gear"],
    carRentPrice: json["car_rent_price"],
    priceType: json["price_type"],
    engineHp: json["engine_hp"],
    fuelType: json["fuel_type"],
    carTypeTitle: json["car_type_title"],
    carDistance: json["car_distance"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "car_title": carTitle,
    "car_img": List<dynamic>.from(carImg.map((x) => x)),
    "car_rating": carRating,
    "car_number": carNumber,
    "total_seat": totalSeat,
    "car_gear": carGear,
    "car_rent_price": carRentPrice,
    "price_type": priceType,
    "engine_hp": engineHp,
    "fuel_type": fuelType,
    "car_type_title": carTypeTitle,
    "car_distance": carDistance,
  };
}

HomeBanner getDefaultHomeBanner() {
  return HomeBanner(
    responseCode: "200",
    result: "true",
    responseMsg: "Loaded successfully",
    currency: "₦",
    tax: "7.5",
    isBlock: "0",
    showAddCar: "1",
    banner: [
      Banner(
        id: "1",
        img: "assets/featurecar1.png",
      ),
      Banner(
        id: "2",
        img: "assets/featurecar2.png",
      ),
      Banner(
        id: "3",
        img: "assets/Image.png",
      ),
    ],
    cartypelist: [
      Carlist(id: "1", title: "SUV", img: "assets/jeep.png"),
      Carlist(id: "2", title: "Sedan", img: "assets/car1.png"),
      Carlist(id: "3", title: "Luxury", img: "assets/modelcar.png"),
      Carlist(id: "4", title: "Sports", img: "assets/audiCar.png"),
    ],
    carbrandlist: [
      Carlist(id: "1", title: "Toyota", img: "assets/car2.png"),
      Carlist(id: "2", title: "Mercedes", img: "assets/car3.png"),
      Carlist(id: "3", title: "Audi", img: "assets/Audi.png"),
      Carlist(id: "4", title: "Jeep", img: "assets/jeep.png"),
    ],
    featureCar: [
      FeatureCar(
        id: "1",
        carTitle: "Toyota Land Cruiser Prado TXL",
        carImg: "assets/jeep.png",
        carRating: "4.9",
        carNumber: "LAG-782-AA",
        totalSeat: "7",
        carGear: "Automatic",
        carRentPrice: "65,000",
        priceType: "0", // 0 = day, 1 = hr
        engineHp: "300",
        fuelType: "Petrol",
        carTypeTitle: "SUV",
        carDistance: "2.5 km",
      ),
      FeatureCar(
        id: "2",
        carTitle: "Mercedes-Benz G-Wagon G63",
        carImg: "assets/car2.png",
        carRating: "5.0",
        carNumber: "ABJ-101-XX",
        totalSeat: "5",
        carGear: "Automatic",
        carRentPrice: "250,000",
        priceType: "0",
        engineHp: "577",
        fuelType: "Petrol",
        carTypeTitle: "Luxury SUV",
        carDistance: "1.2 km",
      ),
      FeatureCar(
        id: "3",
        carTitle: "Lexus RX350 Luxury AWD",
        carImg: "assets/car1.png",
        carRating: "4.8",
        carNumber: "KNG-340-BC",
        totalSeat: "5",
        carGear: "Automatic",
        carRentPrice: "85,000",
        priceType: "0",
        engineHp: "295",
        fuelType: "Petrol",
        carTypeTitle: "SUV",
        carDistance: "3.8 km",
      ),
      FeatureCar(
        id: "4",
        carTitle: "Range Rover Velar R-Dynamic",
        carImg: "assets/car3.png",
        carRating: "4.9",
        carNumber: "IBD-552-ZA",
        totalSeat: "5",
        carGear: "Automatic",
        carRentPrice: "130,000",
        priceType: "0",
        engineHp: "340",
        fuelType: "Petrol",
        carTypeTitle: "Luxury SUV",
        carDistance: "4.1 km",
      ),
      FeatureCar(
        id: "5",
        carTitle: "Audi RS e-tron GT",
        carImg: "assets/audiCar.png",
        carRating: "4.9",
        carNumber: "LAG-119-EE",
        totalSeat: "5",
        carGear: "Automatic",
        carRentPrice: "180,000",
        priceType: "0",
        engineHp: "637",
        fuelType: "Electric",
        carTypeTitle: "Sports",
        carDistance: "1.5 km",
      ),
      FeatureCar(
        id: "6",
        carTitle: "Audi Sportback Quattro",
        carImg: "assets/Imageaudi.png",
        carRating: "4.7",
        carNumber: "ABJ-504-GT",
        totalSeat: "5",
        carGear: "Automatic",
        carRentPrice: "95,000",
        priceType: "0",
        engineHp: "335",
        fuelType: "Petrol",
        carTypeTitle: "Sedan",
        carDistance: "3.2 km",
      ),
    ],
    recommendCar: [
      RecommendCar(
        id: "7",
        carTitle: "Mercedes-Benz C300 4Matic",
        carImg: [
          "assets/car3.png",
          "assets/car1.png"
        ],
        carRating: "4.8",
        carNumber: "LAG-221-FG",
        totalSeat: "5",
        carGear: "Automatic",
        carRentPrice: "55,000",
        priceType: "0",
        engineHp: "255",
        fuelType: "Petrol",
        carTypeTitle: "Sedan",
        carDistance: "1.8 km",
      ),
      RecommendCar(
        id: "8",
        carTitle: "Toyota Camry XSE V6",
        carImg: [
          "assets/car2.png",
          "assets/modelcar.png"
        ],
        carRating: "4.7",
        carNumber: "ABJ-889-BB",
        totalSeat: "5",
        carGear: "Automatic",
        carRentPrice: "45,000",
        priceType: "0",
        engineHp: "301",
        fuelType: "Petrol",
        carTypeTitle: "Sedan",
        carDistance: "3.0 km",
      ),
      RecommendCar(
        id: "9",
        carTitle: "BMW 530i M-Sport",
        carImg: [
          "assets/audiCar.png",
          "assets/audi1.png"
        ],
        carRating: "4.9",
        carNumber: "LAG-904-KL",
        totalSeat: "5",
        carGear: "Automatic",
        carRentPrice: "75,000",
        priceType: "0",
        engineHp: "248",
        fuelType: "Petrol",
        carTypeTitle: "Sedan",
        carDistance: "2.1 km",
      ),
      RecommendCar(
        id: "10",
        carTitle: "Range Rover Sport HSE",
        carImg: [
          "assets/Imageaudi.png",
          "assets/jeep.png"
        ],
        carRating: "4.9",
        carNumber: "IBD-802-RV",
        totalSeat: "7",
        carGear: "Automatic",
        carRentPrice: "140,000",
        priceType: "0",
        engineHp: "395",
        fuelType: "Petrol",
        carTypeTitle: "Luxury SUV",
        carDistance: "2.8 km",
      ),
    ],
  );
}

