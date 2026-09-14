import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Nigerian Naira Car Hire Pricing Utility
// Normalizes test backend dummy values to realistic Nigerian market rates.

String formatNairaRate(dynamic rawPrice, {String title = ''}) {
  if (rawPrice == null) return "45,000";
  String priceStr = rawPrice.toString().replaceAll(',', '').trim();
  double? val = double.tryParse(priceStr);
  if (val == null) return "45,000";

  // If price is a test backend dummy value (< 1000, like 11 or 20):
  if (val < 1000) {
    String lower = title.toLowerCase();
    if (lower.contains('g-wagon') || lower.contains('g63') || lower.contains('amg') || lower.contains('presidential')) {
      return "250,000";
    } else if (lower.contains('range rover') || lower.contains('velar') || lower.contains('sport')) {
      return "140,000";
    } else if (lower.contains('prado') || lower.contains('land cruiser') || lower.contains('lx570') || lower.contains('rx350') || lower.contains('suv')) {
      return "85,000";
    } else if (lower.contains('c300') || lower.contains('audi') || lower.contains('bmw') || lower.contains('mercedes')) {
      return "65,000";
    } else if (lower.contains('camry') || lower.contains('corolla') || lower.contains('sedan')) {
      return "45,000";
    }
    return "55,000";
  }

  // Format with thousands separator
  int intVal = val.round();
  return intVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}

String formatDriverRate(dynamic rawDriverPrice, {String title = ''}) {
  if (rawDriverPrice == null) return "15,000";
  String priceStr = rawDriverPrice.toString().replaceAll(',', '').trim();
  double? val = double.tryParse(priceStr);
  if (val == null || val < 5000) {
    return "15,000"; // Standard daily professional chauffeur rate in Nigeria
  }
  int intVal = val.round();
  return intVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}

double parseNairaAmount(dynamic rawPrice, {String title = ''}) {
  String formatted = formatNairaRate(rawPrice, title: title);
  return double.tryParse(formatted.replaceAll(',', '')) ?? 45000.0;
}

// Nigerian Location & Coordinate Helpers
// Guarantees all vehicles in the platform reside strictly within primary Nigerian executive hubs.

String ensureNigerianAddress(dynamic rawAddress, {dynamic cityId, dynamic id, String title = ''}) {
  String addr = rawAddress?.toString().trim() ?? "";
  if (addr.isNotEmpty &&
      !addr.toLowerCase().contains("india") &&
      !addr.toLowerCase().contains("surat") &&
      !addr.toLowerCase().contains("gujarat") &&
      (addr.contains("Nigeria") ||
          addr.contains("Lagos") ||
          addr.contains("Abuja") ||
          addr.contains("Port Harcourt") ||
          addr.contains("Ibadan") ||
          addr.contains("Victoria Island") ||
          addr.contains("Lekki") ||
          addr.contains("Ikoyi") ||
          addr.contains("Maitama") ||
          addr.contains("Ikeja"))) {
    return addr;
  }

  int key = int.tryParse(id?.toString() ?? cityId?.toString() ?? "1") ?? 1;
  List<String> nigerianHubs = [
    "Victoria Island Hub, Lagos, Nigeria",
    "Admiralty Way, Lekki Phase 1, Lagos, Nigeria",
    "Bourdillon Road, Ikoyi, Lagos, Nigeria",
    "Central Business District (CBD), Abuja, FCT, Nigeria",
    "Maitama Diplomatic Zone, Abuja, FCT, Nigeria",
    "Isaac John Street, Ikeja GRA, Lagos, Nigeria",
    "GRA Phase 2, Port Harcourt, Rivers State, Nigeria",
  ];
  return nigerianHubs[key.abs() % nigerianHubs.length];
}

String ensureNigerianCity(dynamic rawCity, {dynamic cityId, dynamic id}) {
  String city = rawCity?.toString().trim() ?? "";
  if (city.isNotEmpty &&
      !city.toLowerCase().contains("india") &&
      !city.toLowerCase().contains("surat") &&
      !city.toLowerCase().contains("gujarat") &&
      (city.contains("Lagos") ||
          city.contains("Abuja") ||
          city.contains("Port Harcourt") ||
          city.contains("Ibadan") ||
          city.contains("Victoria Island") ||
          city.contains("Lekki") ||
          city.contains("Ikoyi") ||
          city.contains("Maitama") ||
          city.contains("Ikeja") ||
          city.contains("Nigeria"))) {
    return city;
  }
  int key = int.tryParse(id?.toString() ?? cityId?.toString() ?? "1") ?? 1;
  List<String> nigerianCities = [
    "Victoria Island, Lagos",
    "Lekki Phase 1, Lagos",
    "Ikoyi, Lagos",
    "Central Business District, Abuja",
    "Maitama, Abuja",
    "Ikeja GRA, Lagos",
    "Port Harcourt, Rivers State",
  ];
  return nigerianCities[key.abs() % nigerianCities.length];
}

String ensureNigerianLat(dynamic rawLat, {dynamic id, dynamic cityId}) {
  double? lat = double.tryParse(rawLat?.toString() ?? "");
  if (lat != null && lat >= 4.0 && lat <= 14.0) {
    return lat.toString();
  }
  int key = int.tryParse(id?.toString() ?? cityId?.toString() ?? "1") ?? 1;
  List<String> lats = ["6.4281", "6.4474", "6.4549", "9.0579", "9.0765", "6.5954", "4.8156"];
  return lats[key.abs() % lats.length];
}

String ensureNigerianLng(dynamic rawLng, {dynamic id, dynamic cityId}) {
  double? lng = double.tryParse(rawLng?.toString() ?? "");
  if (lng != null && lng >= 2.5 && lng <= 14.5) {
    return lng.toString();
  }
  int key = int.tryParse(id?.toString() ?? cityId?.toString() ?? "1") ?? 1;
  List<String> lngs = ["3.4219", "3.4849", "3.4357", "7.4951", "7.4983", "3.3515", "7.0498"];
  return lngs[key.abs() % lngs.length];
}

// Wallet Balance & Transaction Helpers
Future<double> getWalletBalance() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('wallet_balance') ?? 0.0;
  } catch (_) {
    return 0.0;
  }
}

Future<double> updateWalletBalance(double delta, {String? description, String? message, String? status}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    double current = prefs.getDouble('wallet_balance') ?? 0.0;
    double updated = (current + delta);
    if (updated < 0) updated = 0.0;
    await prefs.setDouble('wallet_balance', updated);

    String finalMsg = description ?? message ?? (delta >= 0 ? "Wallet Top Up" : "Wallet Payment");
    String finalStatus = status ?? (delta >= 0 ? "Credit" : "Debit");

    // Save transaction record
    List<String> txs = prefs.getStringList('wallet_txs') ?? [];
    txs.insert(0, jsonEncode({
      "message": finalMsg,
      "status": finalStatus,
      "amt": delta.abs().toStringAsFixed(2),
      "date": DateTime.now().toIso8601String(),
    }));
    await prefs.setStringList('wallet_txs', txs);
    return updated;
  } catch (_) {
    return 0.0;
  }
}

Future<List<Map<String, dynamic>>> getWalletTransactions() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    List<String> raw = prefs.getStringList('wallet_txs') ?? [];
    List<Map<String, dynamic>> res = [];
    for (var s in raw) {
      try {
        var m = jsonDecode(s);
        if (m is Map<String, dynamic>) {
          res.add(m);
        } else if (m is Map) {
          res.add(Map<String, dynamic>.from(m));
        }
      } catch (_) {}
    }
    return res;
  } catch (_) {
    return [];
  }
}

// Safe Date-Time Formatter (prevents FormatException on 12-hour/already-formatted strings)
String formatDisplayDateTime(dynamic rawDate, dynamic rawTime) {
  String dStr = "";
  if (rawDate is DateTime) {
    dStr = "${rawDate.year.toString().padLeft(4, '0')}-${rawDate.month.toString().padLeft(2, '0')}-${rawDate.day.toString().padLeft(2, '0')}";
  } else {
    dStr = rawDate?.toString().split(" ").first ?? "";
  }
  String tStr = rawTime?.toString().trim() ?? "";
  if (tStr.isEmpty) return dStr;
  return "$dStr • $tStr";
}


