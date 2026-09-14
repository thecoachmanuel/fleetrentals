// To parse this JSON data, do
//
//     final policyPage = policyPageFromJson(jsonString);

import 'dart:convert';

PolicyPage policyPageFromJson(String str) => PolicyPage.fromJson(json.decode(str));

String policyPageToJson(PolicyPage data) => json.encode(data.toJson());

class PolicyPage {
  List<Pagelist> pagelist;
  String responseCode;
  String result;
  String responseMsg;

  PolicyPage({
    required this.pagelist,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory PolicyPage.fromJson(Map<String, dynamic> json) => PolicyPage(
    pagelist: List<Pagelist>.from(json["pagelist"].map((x) => Pagelist.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "pagelist": List<dynamic>.from(pagelist.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Pagelist {
  String title;
  String description;

  Pagelist({
    required this.title,
    required this.description,
  });

  factory Pagelist.fromJson(Map<String, dynamic> json) => Pagelist(
    title: json["title"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
  };
}

PolicyPage getDefaultPolicyPage() {
  return PolicyPage(
    responseCode: "200",
    result: "true",
    responseMsg: "1",
    pagelist: [
      Pagelist(
        title: "Privacy Policy",
        description: "Fleet Rentals respects your privacy. We are committed to protecting your personal data in accordance with Nigerian data protection regulations.",
      ),
      Pagelist(
        title: "Terms & Conditions",
        description: "By using Fleet Rentals services, you agree to our standard car rental and driving terms and conditions.",
      ),
      Pagelist(
        title: "Help & Support",
        description: "For assistance, contact our 24/7 customer support team via email at support@fleetrentals.ng or phone at +234 801 234 5678.",
      ),
      Pagelist(
        title: "About Us",
        description: "Fleet Rentals is Nigeria's premier peer-to-peer and luxury car rental platform, connecting verified drivers with premium vehicles.",
      ),
    ],
  );
}
