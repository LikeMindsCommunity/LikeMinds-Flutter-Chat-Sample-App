import 'dart:convert';

import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLocalPreference {
  SharedPreferences? _sharedPreferences;

  static UserLocalPreference? _instance;
  static UserLocalPreference get instance =>
      _instance ??= UserLocalPreference._();

  UserLocalPreference._();

  Future initialize() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  void storeUserData(User user) {
    UserEntity userEntity = user.toEntity();
    Map<String, dynamic> userData = userEntity.toJson();
    String userString = jsonEncode(userData);
    _sharedPreferences!.setString('user', userString);
  }

  void storeCommunityData(Community community) {
    Map<String, dynamic> communityData = {
      "community_id": community.id,
      "community_name": community.name
    };
    String communityString = jsonEncode(communityData);
    _sharedPreferences!.setString('community', communityString);
  }

  Map<String, dynamic> fetchCommunityData() {
    Map<String, dynamic> communityData =
        jsonDecode(_sharedPreferences!.getString('community')!);
    return communityData;
  }

  User fetchUserData() {
    Map<String, dynamic> userData =
        jsonDecode(_sharedPreferences!.getString('user')!);
    return User.fromEntity(UserEntity.fromJson(userData));
  }

  void storeMemberState(bool isCm) {
    _sharedPreferences!.setBool('isCm', isCm);
  }

  bool fetchMemberState() {
    return _sharedPreferences!.getBool('isCm')!;
  }
}
