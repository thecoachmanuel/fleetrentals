// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, no_leading_underscores_for_local_identifiers, unused_field

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/homeData_modal.dart';
import '../../utils/Colors.dart';
import '../../utils/Dark_lightmode.dart';
import '../../utils/fontfameli_model.dart';
import '../../utils/price_utils.dart';
import '../detailcar/cardetails_screen.dart';
import '../gerneral_support/faq_screen.dart';
import '../gerneral_support/wallet_screen.dart';
import '../mypurchases/mypurchases_screen.dart';
import '../bottombar/profile_screen.dart';
import '../login_flow/login_screen.dart';

String formatNaira(dynamic amount) => "₦${formatNairaRate(amount)}";

class DesktopLayout extends StatefulWidget {
  final HomeBanner? banner;
  final Function(int)? onTabChange;

  const DesktopLayout({
    super.key,
    this.banner,
    this.onTabChange,
  });

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  late ColorNotifire notifire;
  late HomeBanner banner;

  int _selectedNavIndex = 0; // 0: Home, 1: Explore/Cars, 2: Bookings, 3: Wallet, 4: Profile
  String _selectedCity = "Victoria Island, Lagos";
  String _selectedCategory = "All";
  String _searchQuery = "";
  bool _withChauffeur = false;

  String _pickupDate = "Tomorrow, 10:00 AM";
  String _returnDate = "In 3 Days, 10:00 AM";

  double _walletBalance = 75000.0;
  Map<String, dynamic> _userData = {
    "name": "Fleet Rentals VIP User",
    "email": "demo@fleetrentals.ng",
  };

  final List<String> _cities = [
    "Victoria Island, Lagos",
    "Ikoyi, Lagos",
    "Ikeja GRA, Lagos",
    "Maitama, Abuja",
    "Wuse 2, Abuja",
    "Port Harcourt GRA",
  ];

  final List<Map<String, dynamic>> _categories = [
    {"title": "All", "icon": Icons.directions_car_rounded},
    {"title": "SUV", "icon": Icons.electric_car_rounded},
    {"title": "Sedan", "icon": Icons.local_taxi_rounded},
    {"title": "Luxury", "icon": Icons.star_rounded},
    {"title": "Sports", "icon": Icons.speed_rounded},
  ];

  @override
  void initState() {
    super.initState();
    banner = widget.banner ?? getDefaultHomeBanner();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString("UserLogin");
    if (userStr != null) {
      try {
        _userData = jsonDecode(userStr);
      } catch (_) {}
    }
    _walletBalance = await getWalletBalance();
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant DesktopLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.banner != null) {
      banner = widget.banner!;
    }
  }

  List<FeatureCar> get _filteredCars {
    List<FeatureCar> list = List.from(banner.featureCar);
    if (_selectedCategory != "All") {
      list = list.where((c) {
        final type = (c.carTypeTitle ?? "").toLowerCase();
        final title = (c.carTitle ?? "").toLowerCase();
        final target = _selectedCategory.toLowerCase();
        return type.contains(target) || title.contains(target);
      }).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((c) {
        return (c.carTitle ?? "").toLowerCase().contains(q) ||
            (c.carTypeTitle ?? "").toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    final isDark = notifire.isDark;
    final bg = isDark ? const Color(0xff090c15) : const Color(0xfff8fafc);
    final surface = isDark ? const Color(0xff121726) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff0f172a);
    final mutedColor = isDark ? Colors.white60 : const Color(0xff64748b);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // 1. Desktop Top Navigation Bar (Fixed at top)
          _buildTopNavigationBar(surface, textColor, mutedColor, isDark),

          // 2. Main Scrollable Content Area
          Expanded(
            child: _selectedNavIndex == 0
                ? _buildHomeContent(bg, surface, textColor, mutedColor, isDark)
                : _selectedNavIndex == 1
                    ? _buildExploreCarsContent(bg, surface, textColor, mutedColor, isDark)
                    : _selectedNavIndex == 2
                        ? MyPurchasesScreen()
                        : _selectedNavIndex == 3
                            ? const My_Wallet()
                            : ProfileScreen(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TOP NAVIGATION BAR
  // ==========================================
  Widget _buildTopNavigationBar(Color surface, Color textColor, Color mutedColor, bool isDark) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo & Branding
          InkWell(
            onTap: () => setState(() => _selectedNavIndex = 0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff1347FF), Color(0xff3D5BF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1347FF).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.car_rental_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Fleet ",
                            style: TextStyle(
                              fontFamily: FontFamily.europaBold,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const TextSpan(
                            text: "Rentals",
                            style: TextStyle(
                              fontFamily: FontFamily.europaBold,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xff1347FF),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "Executive Nigeria Fleet",
                      style: TextStyle(
                        fontFamily: FontFamily.europaWoff,
                        fontSize: 10,
                        color: mutedColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 32),

          // Location Selector Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Color(0xff1347FF), size: 16),
                const SizedBox(width: 6),
                DropdownButton<String>(
                  value: _selectedCity,
                  underline: const SizedBox(),
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: mutedColor, size: 18),
                  dropdownColor: surface,
                  style: TextStyle(
                    fontFamily: FontFamily.europaBold,
                    fontSize: 13,
                    color: textColor,
                  ),
                  items: _cities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (newVal) {
                    if (newVal != null) {
                      setState(() => _selectedCity = newVal);
                    }
                  },
                ),
              ],
            ),
          ),

          const Spacer(),

          // Navigation Links
          _buildNavLink("Home", 0, textColor, mutedColor),
          _buildNavLink("All Fleets", 1, textColor, mutedColor),
          _buildNavLink("My Bookings", 2, textColor, mutedColor),
          _buildNavLink("Wallet", 3, textColor, mutedColor),

          const SizedBox(width: 24),

          // Wallet Quick Balance Pill
          InkWell(
            onTap: () => setState(() => _selectedNavIndex = 3),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xff1347FF).withOpacity(0.12),
                    const Color(0xff3D5BF6).withOpacity(0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xff1347FF).withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xff1347FF),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 12),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatNaira(_walletBalance),
                    style: const TextStyle(
                      fontFamily: FontFamily.europaBold,
                      fontSize: 13,
                      color: Color(0xff1347FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.add_circle_outline_rounded, color: Color(0xff1347FF), size: 14),
                ],
              ),
            ),
          ),

          const SizedBox(width: 18),

          // Dark / Light Theme Toggle
          IconButton(
            onPressed: () {
              notifire.setIsDark = !notifire.isDark;
            },
            tooltip: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: mutedColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          // User Profile Pill / Menu
          PopupMenuButton<String>(
            tooltip: "User Account",
            offset: const Offset(0, 50),
            color: surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (val) {
              if (val == "profile") {
                setState(() => _selectedNavIndex = 4);
              } else if (val == "bookings") {
                setState(() => _selectedNavIndex = 2);
              } else if (val == "wallet") {
                setState(() => _selectedNavIndex = 3);
              } else if (val == "logout") {
                Get.offAll(() => const LoginScreen());
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "profile",
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 18),
                    const SizedBox(width: 12),
                    Text("My Profile", style: TextStyle(fontFamily: FontFamily.europaWoff, color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "bookings",
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, size: 18),
                    const SizedBox(width: 12),
                    Text("My Bookings", style: TextStyle(fontFamily: FontFamily.europaWoff, color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "wallet",
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 18),
                    const SizedBox(width: 12),
                    Text("Wallet & Top-up", style: TextStyle(fontFamily: FontFamily.europaWoff, color: textColor)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: "logout",
                child: Row(
                  children: const [
                    Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                    SizedBox(width: 12),
                    Text("Logout", style: TextStyle(fontFamily: FontFamily.europaWoff, color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xfff1f5f9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xff1347FF),
                    child: Text(
                      (_userData['name']?.toString() ?? "F").substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _userData['name']?.toString() ?? "Fleet User",
                    style: TextStyle(
                      fontFamily: FontFamily.europaBold,
                      fontSize: 13,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded, color: mutedColor, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String title, int index, Color textColor, Color mutedColor) {
    final isSelected = _selectedNavIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        onTap: () => setState(() => _selectedNavIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: FontFamily.europaBold,
                  fontSize: 14,
                  color: isSelected ? const Color(0xff1347FF) : mutedColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: isSelected ? 24 : 0,
                decoration: BoxDecoration(
                  color: const Color(0xff1347FF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HOME TAB CONTENT (DESKTOP)
  // ==========================================
  Widget _buildHomeContent(Color bg, Color surface, Color textColor, Color mutedColor, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section with Floating Search Booking Bar
          _buildHeroSection(surface, textColor, mutedColor, isDark),

          const SizedBox(height: 50),

          // Categories & Filter Pills
          _buildCategoriesBar(surface, textColor, mutedColor, isDark),

          const SizedBox(height: 40),

          // Featured Fleets Grid
          _buildFleetsGridSection(surface, textColor, mutedColor, isDark),

          const SizedBox(height: 80),

          // Why Choose Fleet Rentals (Highlights)
          _buildWhyChooseUsSection(surface, textColor, mutedColor, isDark),

          const SizedBox(height: 80),

          // VIP Concierge & Airport Meet & Greet Banner
          _buildVipConciergeBanner(isDark),

          const SizedBox(height: 100),

          // Desktop Footer
          _buildFooter(surface, textColor, mutedColor, isDark),
        ],
      ),
    );
  }

  // ==========================================
  // HERO SECTION
  // ==========================================
  Widget _buildHeroSection(Color surface, Color textColor, Color mutedColor, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.4),
          radius: 1.2,
          colors: isDark
              ? [const Color(0xff16203a), const Color(0xff090c15)]
              : [const Color(0xffedf2ff), const Color(0xfff8fafc)],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              // VIP Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xff1347FF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xff1347FF).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.workspace_premium_rounded, color: Color(0xff1347FF), size: 16),
                    SizedBox(width: 8),
                    Text(
                      "NIGERIA'S PREMIER EXECUTIVE CAR & FLEET RENTALS",
                      style: TextStyle(
                        fontFamily: FontFamily.europaBold,
                        fontSize: 11,
                        color: Color(0xff1347FF),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Hero Headline
              Text(
                "Drive Your Ambition with\nFleet Rentals Nigeria",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FontFamily.europaBold,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  height: 1.15,
                  letterSpacing: -1.2,
                ),
              ),

              const SizedBox(height: 18),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  "Experience executive luxury, chauffeur-driven security, and transparent car rentals across Lagos, Abuja, and Port Harcourt with instant booking & live wallet checkout.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FontFamily.europaWoff,
                    fontSize: 16,
                    color: mutedColor,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Floating Interactive Booking / Search Bar
              _buildBookingSearchBar(surface, textColor, mutedColor, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // FLOATING SEARCH & BOOKING BAR
  // ==========================================
  Widget _buildBookingSearchBar(Color surface, Color textColor, Color mutedColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.5) : const Color(0xff1347FF).withOpacity(0.08),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 1. Pick-up City / Location
              Expanded(
                flex: 3,
                child: _buildSearchInputTile(
                  icon: Icons.location_on_rounded,
                  label: "PICK-UP CITY / LOCATION",
                  value: _selectedCity,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  isDark: isDark,
                  onTap: () {
                    _showCitySelectionDialog();
                  },
                ),
              ),

              _buildVerticalDivider(isDark),

              // 2. Pick-up Date & Time
              Expanded(
                flex: 3,
                child: _buildSearchInputTile(
                  icon: Icons.calendar_today_rounded,
                  label: "PICK-UP DATE & TIME",
                  value: _pickupDate,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  isDark: isDark,
                  onTap: () {
                    _selectDateTime(true);
                  },
                ),
              ),

              _buildVerticalDivider(isDark),

              // 3. Return Date & Time
              Expanded(
                flex: 3,
                child: _buildSearchInputTile(
                  icon: Icons.event_repeat_rounded,
                  label: "RETURN DATE & TIME",
                  value: _returnDate,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  isDark: isDark,
                  onTap: () {
                    _selectDateTime(false);
                  },
                ),
              ),

              _buildVerticalDivider(isDark),

              // 4. Chauffeur Toggle & Search Button
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Chauffeur Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_pin_rounded, color: const Color(0xff1347FF), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              "With Chauffeur",
                              style: TextStyle(
                                fontFamily: FontFamily.europaBold,
                                fontSize: 12,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _withChauffeur,
                          activeColor: const Color(0xff1347FF),
                          onChanged: (val) {
                            setState(() => _withChauffeur = val);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Search Button
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedNavIndex = 1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1347FF),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        shadowColor: const Color(0xff1347FF).withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.search_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Find Fleets",
                            style: TextStyle(
                              fontFamily: FontFamily.europaBold,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
    );
  }

  Widget _buildSearchInputTile({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    required Color mutedColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xffeff6ff),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xff1347FF), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: FontFamily.europaBold,
                      fontSize: 10,
                      color: mutedColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FontFamily.europaBold,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCitySelectionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: notifire.isDark ? const Color(0xff16203a) : Colors.white,
        title: const Text("Select Pick-up Location", style: TextStyle(fontFamily: FontFamily.europaBold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _cities.map((c) {
            return ListTile(
              leading: const Icon(Icons.location_on_rounded, color: Color(0xff1347FF)),
              title: Text(c, style: const TextStyle(fontFamily: FontFamily.europaWoff)),
              onTap: () {
                setState(() => _selectedCity = c);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _selectDateTime(bool isPickup) {
    final now = DateTime.now();
    showDatePicker(
      context: context,
      initialDate: now.add(Duration(days: isPickup ? 1 : 3)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        setState(() {
          final formatted = "${date.day}/${date.month}/${date.year} at 10:00 AM";
          if (isPickup) {
            _pickupDate = formatted;
          } else {
            _returnDate = formatted;
          }
        });
      }
    });
  }

  // ==========================================
  // CATEGORIES / VEHICLE TYPES FILTER BAR
  // ==========================================
  Widget _buildCategoriesBar(Color surface, Color textColor, Color mutedColor, bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Explore Fleets by Category",
                  style: TextStyle(
                    fontFamily: FontFamily.europaBold,
                    fontSize: 24,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Choose from our curated executive fleet of sedans, SUVs, and luxury exotics",
                  style: TextStyle(
                    fontFamily: FontFamily.europaWoff,
                    fontSize: 14,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Category Pills
            Wrap(
              spacing: 10,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat["title"];
                return InkWell(
                  onTap: () => setState(() => _selectedCategory = cat["title"]),
                  borderRadius: BorderRadius.circular(30),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xff1347FF)
                          : isDark
                              ? Colors.white.withOpacity(0.05)
                              : const Color(0xfff1f5f9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xff1347FF)
                            : isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.05),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xff1347FF).withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat["icon"] as IconData,
                          size: 16,
                          color: isSelected ? Colors.white : mutedColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat["title"] as String,
                          style: TextStyle(
                            fontFamily: FontFamily.europaBold,
                            fontSize: 13,
                            color: isSelected ? Colors.white : textColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FEATURED FLEETS GRID SECTION
  // ==========================================
  Widget _buildFleetsGridSection(Color surface, Color textColor, Color mutedColor, bool isDark) {
    final cars = _filteredCars;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Column(
          children: [
            if (cars.isEmpty)
              Padding(
                padding: const EdgeInsets.all(60),
                child: Column(
                  children: [
                    Icon(Icons.directions_car_outlined, size: 64, color: mutedColor),
                    const SizedBox(height: 16),
                    Text(
                      "No vehicles found in this category",
                      style: TextStyle(fontFamily: FontFamily.europaBold, fontSize: 18, color: textColor),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() => _selectedCategory = "All"),
                      child: const Text("View All Fleets", style: TextStyle(color: Color(0xff1347FF))),
                    ),
                  ],
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 1100 ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 28,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      return _DesktopCarCard(
                        car: cars[index],
                        isDark: isDark,
                        surface: surface,
                        textColor: textColor,
                        mutedColor: mutedColor,
                        withChauffeur: _withChauffeur,
                        onTap: () {
                          Get.to(() => CarDetailsScreen(id: cars[index].id, currency: "₦"));
                        },
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // EXPLORE CARS / FULL CATALOG TAB
  // ==========================================
  Widget _buildExploreCarsContent(Color bg, Color surface, Color textColor, Color mutedColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search & Header
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "All Executive Vehicles",
                        style: TextStyle(
                          fontFamily: FontFamily.europaBold,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Showing ${_filteredCars.length} luxury vehicles available across Nigeria",
                        style: TextStyle(fontFamily: FontFamily.europaWoff, fontSize: 14, color: mutedColor),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Search Bar Input
                  Container(
                    width: 340,
                    height: 48,
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
                      ),
                    ),
                    child: TextField(
                      style: TextStyle(fontFamily: FontFamily.europaWoff, fontSize: 14, color: textColor),
                      decoration: InputDecoration(
                        hintText: "Search by make, model, or category...",
                        hintStyle: TextStyle(fontFamily: FontFamily.europaWoff, fontSize: 13, color: mutedColor),
                        prefixIcon: Icon(Icons.search_rounded, color: mutedColor, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (val) {
                        setState(() => _searchQuery = val);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Categories Filter Bar
              _buildCategoriesBar(surface, textColor, mutedColor, isDark),

              const SizedBox(height: 36),

              // Fleets Grid
              _buildFleetsGridSection(surface, textColor, mutedColor, isDark),

              const SizedBox(height: 80),

              _buildFooter(surface, textColor, mutedColor, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WHY CHOOSE US (EXECUTIVE HIGHLIGHTS)
  // ==========================================
  Widget _buildWhyChooseUsSection(Color surface, Color textColor, Color mutedColor, bool isDark) {
    final features = [
      {
        "icon": Icons.verified_user_rounded,
        "title": "Comprehensive Insurance",
        "desc": "Every vehicle is fully insured with complete passenger and third-party protection.",
      },
      {
        "icon": Icons.military_tech_rounded,
        "title": "Verified Chauffeurs",
        "desc": "Polite, security-vetted professional drivers trained in VIP executive navigation.",
      },
      {
        "icon": Icons.flight_takeoff_rounded,
        "title": "Airport VIP Meet & Greet",
        "desc": "Seamless executive airport transfers at MMA Lagos, Abuja, and Port Harcourt.",
      },
      {
        "icon": Icons.bolt_rounded,
        "title": "Instant Naira Wallet Pay",
        "desc": "Frictionless bookings via Paystack cards, bank transfers, or instant in-app wallet.",
      },
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Column(
          children: [
            Text(
              "Why Choose Fleet Rentals",
              style: TextStyle(
                fontFamily: FontFamily.europaBold,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "The most trusted luxury vehicle provider for corporate executives, celebrities, and VIP travelers.",
              style: TextStyle(fontFamily: FontFamily.europaWoff, fontSize: 15, color: mutedColor),
            ),
            const SizedBox(height: 40),
            Row(
              children: features.map((f) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xff1347FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(f["icon"] as IconData, color: const Color(0xff1347FF), size: 28),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          f["title"] as String,
                          style: TextStyle(
                            fontFamily: FontFamily.europaBold,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          f["desc"] as String,
                          style: TextStyle(
                            fontFamily: FontFamily.europaWoff,
                            fontSize: 13,
                            color: mutedColor,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VIP CONCIERGE BANNER
  // ==========================================
  Widget _buildVipConciergeBanner(bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff1347FF), Color(0xff092288)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff1347FF).withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "NEED A CUSTOM FLEET OR LONG-TERM LEASE?",
                      style: TextStyle(
                        fontFamily: FontFamily.europaBold,
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "24/7 VIP Executive Concierge & Escort Services",
                      style: TextStyle(
                        fontFamily: FontFamily.europaBold,
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "From armored convoys to corporate monthly fleet leases across Nigeria, our dedicated concierge is ready to assist.",
                      style: TextStyle(
                        fontFamily: FontFamily.europaWoff,
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => const FaqScreen());
                },
                icon: const Icon(Icons.support_agent_rounded, color: Color(0xff1347FF)),
                label: const Text(
                  "Contact Concierge",
                  style: TextStyle(
                    fontFamily: FontFamily.europaBold,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1347FF),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // DESKTOP FOOTER
  // ==========================================
  Widget _buildFooter(Color surface, Color textColor, Color mutedColor, bool isDark) {
    return Container(
      width: double.infinity,
      color: surface,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 40, right: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Col 1: Brand & Bio
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xff1347FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.car_rental_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Fleet Rentals",
                              style: TextStyle(
                                fontFamily: FontFamily.europaBold,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Nigeria's leading premium fleet rental service. We deliver unmatched comfort, reliability, and security for executive business and leisure mobility.",
                          style: TextStyle(
                            fontFamily: FontFamily.europaWoff,
                            fontSize: 13,
                            color: mutedColor,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Col 2: Quick Links
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("QUICK LINKS", style: TextStyle(fontFamily: FontFamily.europaBold, fontSize: 12, color: textColor, letterSpacing: 1.1)),
                        const SizedBox(height: 16),
                        _footerLink("All Fleets", () => setState(() => _selectedNavIndex = 1), mutedColor),
                        _footerLink("My Bookings", () => setState(() => _selectedNavIndex = 2), mutedColor),
                        _footerLink("Wallet Balance", () => setState(() => _selectedNavIndex = 3), mutedColor),
                        _footerLink("FAQs & Support", () => Get.to(() => const FaqScreen()), mutedColor),
                      ],
                    ),
                  ),

                  // Col 3: Operating Cities
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("LOCATIONS", style: TextStyle(fontFamily: FontFamily.europaBold, fontSize: 12, color: textColor, letterSpacing: 1.1)),
                        const SizedBox(height: 16),
                        _footerText("Lagos (VI, Lekki, Ikeja)", mutedColor),
                        _footerText("Abuja (Maitama, Wuse)", mutedColor),
                        _footerText("Port Harcourt (GRA)", mutedColor),
                        _footerText("Kano & Ibadan", mutedColor),
                      ],
                    ),
                  ),

                  // Col 4: Contact & Concierge
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("CONCIERGE CONTACT", style: TextStyle(fontFamily: FontFamily.europaBold, fontSize: 12, color: textColor, letterSpacing: 1.1)),
                        const SizedBox(height: 16),
                        _footerText("Email: support@fleetrentals.ng", mutedColor),
                        _footerText("Phone: +234 801 234 5678", mutedColor),
                        _footerText("Executive Terminal, MMA, Ikeja, Lagos", mutedColor),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              Divider(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),

              const SizedBox(height: 20),

              // Copyright Bottom Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "© 2026 Fleet Rentals Nigeria Ltd. All rights reserved.",
                    style: TextStyle(fontFamily: FontFamily.europaWoff, fontSize: 12, color: mutedColor),
                  ),
                  Row(
                    children: [
                      Text("Privacy Policy", style: TextStyle(fontFamily: FontFamily.europaWoff, fontSize: 12, color: mutedColor)),
                      const SizedBox(width: 20),
                      Text("Terms & Conditions", style: TextStyle(fontFamily: FontFamily.europaWoff, fontSize: 12, color: mutedColor)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(String title, VoidCallback onTap, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: TextStyle(fontFamily: FontFamily.europaWoff, fontSize: 13, color: color),
        ),
      ),
    );
  }

  Widget _footerText(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(fontFamily: FontFamily.europaWoff, fontSize: 13, color: color),
      ),
    );
  }
}

// ==========================================================
// DESKTOP CAR CARD COMPONENT WITH HOVER EFFECT
// ==========================================================
class _DesktopCarCard extends StatefulWidget {
  final FeatureCar car;
  final bool isDark;
  final Color surface;
  final Color textColor;
  final Color mutedColor;
  final bool withChauffeur;
  final VoidCallback onTap;

  const _DesktopCarCard({
    required this.car,
    required this.isDark,
    required this.surface,
    required this.textColor,
    required this.mutedColor,
    required this.withChauffeur,
    required this.onTap,
  });

  @override
  State<_DesktopCarCard> createState() => _DesktopCarCardState();
}

class _DesktopCarCardState extends State<_DesktopCarCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final car = widget.car;
    final priceStr = car.carRentPrice ?? "65,000";
    final price = parseNairaAmount(priceStr);
    final displayPrice = widget.withChauffeur ? price + 25000 : price;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0, _isHovered ? -6 : 0),
        decoration: BoxDecoration(
          color: widget.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _isHovered
                ? const Color(0xff1347FF).withOpacity(0.5)
                : widget.isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0xff1347FF).withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: _isHovered ? 24 : 12,
              offset: Offset(0, _isHovered ? 12 : 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Vehicle Image & Badges
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: widget.isDark ? const Color(0xff161e31) : const Color(0xfff1f5f9),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                        child: car.carImg.isNotEmpty
                            ? Image.asset(
                                car.carImg,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => Center(
                                  child: Icon(Icons.directions_car_filled_rounded, size: 54, color: widget.mutedColor),
                                ),
                              )
                            : Center(
                                child: Icon(Icons.directions_car_filled_rounded, size: 54, color: widget.mutedColor),
                              ),
                      ),
                    ),

                    // Top Left: Rating Badge
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xffFFBB0D), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              car.carRating ?? "4.9",
                              style: const TextStyle(
                                fontFamily: FontFamily.europaBold,
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top Right: Status Badge
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xff1347FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Instant Booking",
                          style: TextStyle(
                            fontFamily: FontFamily.europaBold,
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Vehicle Details
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car.carTitle ?? "Executive Car",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: FontFamily.europaBold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 13, color: Color(0xff1347FF)),
                              const SizedBox(width: 4),
                              Text(
                                "Victoria Island, Lagos",
                                style: TextStyle(
                                  fontFamily: FontFamily.europaWoff,
                                  fontSize: 12,
                                  color: widget.mutedColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Specs Row (Seats, Gear, Fuel)
                      Row(
                        children: [
                          _buildSpecItem(Icons.people_outline_rounded, "${car.totalSeat ?? '5'} Seats"),
                          const SizedBox(width: 12),
                          _buildSpecItem(Icons.settings_outlined, car.carGear ?? "Auto"),
                          const SizedBox(width: 12),
                          _buildSpecItem(Icons.local_gas_station_outlined, car.fuelType ?? "Petrol"),
                        ],
                      ),

                      // Price & Action Button Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatNaira(displayPrice),
                                style: const TextStyle(
                                  fontFamily: FontFamily.europaBold,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xff1347FF),
                                ),
                              ),
                              Text(
                                car.priceType == "1" ? "per hour" : "per day",
                                style: TextStyle(
                                  fontFamily: FontFamily.europaWoff,
                                  fontSize: 11,
                                  color: widget.mutedColor,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xff1347FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  "Rent Now",
                                  style: TextStyle(
                                    fontFamily: FontFamily.europaBold,
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: widget.mutedColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontFamily: FontFamily.europaWoff,
            fontSize: 11,
            color: widget.mutedColor,
          ),
        ),
      ],
    );
  }
}
