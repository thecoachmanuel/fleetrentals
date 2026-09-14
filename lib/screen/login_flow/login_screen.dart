// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, empty_catches
import 'dart:convert';
import 'package:carlinknew/model/login_modal.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:carlinknew/controller/login_controller.dart';
import 'package:carlinknew/screen/bottombar/bottombar_screen.dart';
import 'package:carlinknew/screen/login_flow/resetpassword_screen.dart';
import 'package:carlinknew/screen/login_flow/signup_screen.dart';
import 'package:carlinknew/utils/Colors.dart';
import 'package:carlinknew/utils/Custom_widget.dart';
import 'package:carlinknew/utils/Dark_lightmode.dart';
import 'package:carlinknew/utils/fontfameli_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/App_content.dart';
import '../../utils/config.dart';
import '../bottombar/carinfo_screeen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginController loginController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isPhoneLogin = true;

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

  resetNew() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLogin', true);
    prefs.setBool('bottomsheet', false);
    prefs.setString('bannerData', jsonEncode({"tax": "7.5", "currency": "₦"}));
  }

  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String ccode = "+234";

  void fillDemoCredentials() {
    setState(() {
      if (isPhoneLogin) {
        mobileController.text = "08012345678";
      } else {
        emailController.text = "demo@fleetrentals.ng";
      }
      passwordController.text = "123456";
    });
    Fluttertoast.showToast(msg: "Demo credentials filled".tr);
  }

  LoginData? loginData;
  Future login(mobile, ccode, password, {String? email}) async {
    // Temporary / Demo login check
    String identifier = isPhoneLogin ? (mobile ?? '').toString().trim() : (email ?? '').toString().trim();
    if ((identifier == "08012345678" || identifier == "8012345678" || identifier == "demo@fleetrentals.ng" || identifier == "demo@fleetrentals.com" || identifier == "demo@carlink.ng" || identifier == "demo@carlink.com") &&
        (password == "123456" || password == "password123")) {
      Map<String, dynamic> demoData = {
        "ResponseCode": "200",
        "Result": "true",
        "ResponseMsg": "Login Successfully! (Fleet Rentals Demo)",
        "type": "USER",
        "UserLogin": {
          "id": "999",
          "name": "Fleet Rentals VIP User",
          "mobile": "08012345678",
          "password": password,
          "rdate": "2026-01-01 10:00:00",
          "status": "1",
          "ccode": "+234",
          "code": "NG",
          "refercode": "",
          "wallet": "75000",
          "email": "demo@fleetrentals.ng",
          "profile_pic": null
        }
      };
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('Usertype', 'USER');
      prefs.setString('UserLogin', jsonEncode(demoData["UserLogin"]));
      prefs.setString('bannerData', jsonEncode({"tax": "7.5", "currency": "₦"}));
      prefs.setBool('isLogin', true);
      prefs.setBool('bottomsheet', false);
      setState(() {
        loginData = LoginData.fromJson(demoData);
      });
      return demoData;
    }

    Map body = isPhoneLogin
        ? {
            'mobile': mobile,
            'ccode': ccode,
            'password': password,
          }
        : {
            'email': email,
            'password': password,
          };
    try {
      var response = await http.post(Uri.parse(Config.baseUrl + Config.login), body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var data = jsonDecode(response.body.toString());

      if (response.statusCode == 200) {
        if (data["Result"] == "true") {
          prefs.setString('Usertype', data["type"]);
          data["type"] == "USER" ? prefs.setString('UserLogin', jsonEncode(data["UserLogin"])) : prefs.setString('AdminLogin', jsonEncode(data["AdminLogin"]));
          prefs.setString('bannerData', jsonEncode({"tax": "7.5", "currency": "₦"}));
          prefs.setBool('isLogin', true);
          prefs.setBool('bottomsheet', false);
          setState(() {
            data["type"] == "USER" ? loginData = loginDataFromJson(response.body) : null;
          });
          return data;
        } else {
          return data;
        }
      } else {
        return data;
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: notifire.getbgcolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(6),
                    child: Image.asset(Appcontent.close, color: notifire.getwhiteblackcolor),
                  ),
                ),
                SizedBox(height: Get.size.height * 0.02),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sign in to carlink".tr,
                          style: TextStyle(
                            fontFamily: FontFamily.europaBold,
                            color: notifire.getwhiteblackcolor,
                            fontSize: 28,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Welcome back! Please enter your details.".tr,
                          style: TextStyle(
                            fontFamily: FontFamily.europaWoff,
                            fontSize: 15,
                            color: greyScale,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Phone / Email Toggle
                        Container(
                          height: 46,
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: notifire.getblackwhitecolor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isPhoneLogin = true;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isPhoneLogin ? onbordingBlue : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.phone_iphone_rounded,
                                          size: 18,
                                          color: isPhoneLogin ? WhiteColor : greyScale,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Phone Number".tr,
                                          style: TextStyle(
                                            fontFamily: FontFamily.europaBold,
                                            fontSize: 13,
                                            color: isPhoneLogin ? WhiteColor : notifire.getwhiteblackcolor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isPhoneLogin = false;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: !isPhoneLogin ? onbordingBlue : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.mail_outline_rounded,
                                          size: 18,
                                          color: !isPhoneLogin ? WhiteColor : greyScale,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Email Address".tr,
                                          style: TextStyle(
                                            fontFamily: FontFamily.europaBold,
                                            fontSize: 13,
                                            color: !isPhoneLogin ? WhiteColor : notifire.getwhiteblackcolor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Input Field (Phone or Email)
                        if (isPhoneLogin)
                          IntlPhoneField(
                            controller: mobileController,
                            decoration: InputDecoration(
                              counterText: "",
                              filled: true,
                              fillColor: notifire.getblackwhitecolor,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: 'Phone Number'.tr,
                              hintStyle: TextStyle(
                                color: greyColor,
                                fontSize: 14,
                                fontFamily: FontFamily.europaWoff,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: onbordingBlue),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: onbordingBlue),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            style: TextStyle(
                              color: notifire.getwhiteblackcolor,
                              fontFamily: FontFamily.europaBold,
                            ),
                            flagsButtonPadding: EdgeInsets.only(left: 7),
                            dropdownTextStyle: TextStyle(color: notifire.getwhiteblackcolor),
                            showCountryFlag: false,
                            dropdownIcon: Icon(Icons.phone_outlined, color: greyScale),
                            initialCountryCode: 'NG',
                            onCountryChanged: (value) {
                              setState(() {
                                ccode = value.dialCode;
                              });
                            },
                            onChanged: (number) {
                              setState(() {
                                ccode = number.countryCode;
                              });
                            },
                          )
                        else
                          textFormFild(
                            notifire,
                            controller: emailController,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Icon(Icons.mail_outline_rounded, color: greyColor, size: 24),
                            ),
                            labelText: "Email Address".tr,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email'.tr;
                              }
                              if (!GetUtils.isEmail(value)) {
                                return 'Please enter a valid email'.tr;
                              }
                              return null;
                            },
                          ),

                        SizedBox(height: 15),

                        // Password Field
                        GetBuilder<LoginController>(builder: (context) {
                          return textFormFild(
                            notifire,
                            controller: passwordController,
                            obscureText: loginController.showPassword,
                            suffixIcon: InkWell(
                              onTap: () {
                                loginController.showOfPassword();
                              },
                              child: !loginController.showPassword
                                  ? Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Image.asset("assets/eye.png", height: 25, width: 25, color: greyColor),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Image.asset("assets/eye-off.png", height: 25, width: 25, color: greyColor),
                                    ),
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset("assets/lock.png", height: 25, width: 25, color: greyColor),
                            ),
                            labelText: "Password".tr,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password'.tr;
                              }
                              return null;
                            },
                          );
                        }),

                        SizedBox(height: 10),

                        // Forgot Password
                        InkWell(
                          onTap: () {
                            Get.to(ResetPasswordScreen());
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Forgot password? '.tr,
                                  style: TextStyle(
                                    fontFamily: FontFamily.europaWoff,
                                    color: notifire.getwhiteblackcolor,
                                    fontSize: 15,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Reset it'.tr,
                                  style: TextStyle(
                                    fontFamily: FontFamily.europaBold,
                                    color: onbordingBlue,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 15),

                        // Temporary Demo Account Quick Banner
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: onbordingBlue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: onbordingBlue.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: onbordingBlue.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.key_rounded, color: onbordingBlue, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Demo Credentials".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.europaBold,
                                        fontSize: 13,
                                        color: onbordingBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isPhoneLogin ? "08012345678  •  PIN: 123456" : "demo@fleetrentals.ng  •  PIN: 123456",
                                      style: TextStyle(
                                        fontFamily: FontFamily.europaWoff,
                                        fontSize: 12,
                                        color: notifire.getwhiteblackcolor.withOpacity(0.75),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: fillDemoCredentials,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: onbordingBlue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Auto Fill".tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.europaBold,
                                      color: WhiteColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 15),

                        // Sign In Button
                        GestButton(
                          height: 50,
                          Width: Get.size.width,
                          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                          buttoncolor: onbordingBlue,
                          buttontext: "Sign In".tr,
                          style: TextStyle(color: WhiteColor, fontFamily: FontFamily.europaBold, fontSize: 15),
                          onclick: () {
                            bool hasIdentifier = isPhoneLogin
                                ? mobileController.text.isNotEmpty
                                : emailController.text.isNotEmpty;

                            if (hasIdentifier && passwordController.text.isNotEmpty) {
                              if (_formKey.currentState?.validate() ?? false) {
                                login(
                                  mobileController.text,
                                  ccode,
                                  passwordController.text,
                                  email: emailController.text,
                                ).then((value) async {
                                  if (value != null && value["ResponseCode"] == "200") {
                                    Fluttertoast.showToast(msg: value['ResponseMsg']);

                                    resetNew();
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    String user = pref.getString("Usertype") ?? "USER";

                                    if (!kIsWeb) {
                                      if (user == "ADMIN") {
                                        OneSignal.User.addTagWithKey("user_id", '0');
                                      } else {
                                        OneSignal.User.addTagWithKey("user_id", loginData?.userLogin.id);
                                      }
                                    }

                                    if (user == "ADMIN") {
                                      Get.offAll(CarInfoScreen());
                                    } else {
                                      Get.offAll(BottomBarScreen());
                                    }
                                  } else {
                                    Fluttertoast.showToast(msg: value != null ? value['ResponseMsg'] : 'Login Failed');
                                  }
                                });
                              }
                            } else {
                              Fluttertoast.showToast(
                                msg: isPhoneLogin ? 'Please enter your phone number and password'.tr : 'Please enter your email and password'.tr,
                              );
                            }
                          },
                        ),

                        SizedBox(height: 10),

                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don’t have an account?".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.europaWoff,
                                color: notifire.getwhiteblackcolor,
                                fontSize: 15,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.to(SignUpScreen());
                              },
                              child: Text(
                                "Sign Up".tr,
                                style: TextStyle(
                                  fontFamily: FontFamily.europaBold,
                                  color: onbordingBlue,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
