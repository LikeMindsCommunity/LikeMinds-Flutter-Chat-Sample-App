import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppLocalPreference {
  SharedPreferences? _sharedPreferences;

  static AppLocalPreference? _instance;
  static AppLocalPreference get instance =>
      _instance ??= AppLocalPreference._();

  AppLocalPreference._();

  Future initialize() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  void storeUserDetails(String? username, String? userId) {
    if (username == null || userId == null) {
      return;
    }
    _sharedPreferences?.setString('username', username);
    _sharedPreferences?.setString('userId', userId);
  }

  void storeMemberState(bool isMember) {
    _sharedPreferences?.setBool('isMember', isMember);
  }

  bool? fetchMemberState() {
    return _sharedPreferences?.getBool('isMember');
  }

  String? fetchUsername() {
    return _sharedPreferences?.getString('username');
  }

  String? fetchUserId() {
    return _sharedPreferences?.getString('userId');
  }

  void storeBrandingData(Map<String, dynamic> brandingData) {
    String brandingString = brandingData.toString();
    _sharedPreferences?.setString('branding', brandingString);
  }

  Map<String, dynamic> fetchBrandingData() {
    final String? brandingString = _sharedPreferences?.getString('branding');
    if (brandingString == null) {
      return {};
    } else {
      Map<String, dynamic> brandingData =
          Map<String, dynamic>.from(jsonDecode(brandingString));
      return brandingData;
    }
  }
}
