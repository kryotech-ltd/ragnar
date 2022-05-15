import 'package:firebase_database/firebase_database.dart';
import './../../fireflutter.dart';

/// UserSettingsModel
///
///
class UserSettingsModel with DatabaseMixin {
  UserSettingsModel({
    required this.topics,
    required this.data,
    required this.password,
  });

  Map<String, dynamic> topics;
  Map<String, dynamic> data;
  final String password;
  factory UserSettingsModel.fromJson(dynamic data) {
    return UserSettingsModel(
      topics: Map<String, dynamic>.from(data['topic'] ?? {}),
      data: Map<String, dynamic>.from(data),
      password: data['password'] ?? '',
    );
  }

  topicsFolder(String type) {
    return topics[type];
  }

  getTopicsFolderValue(String type, String topic) {
    return topics[type]?[topic];
  }

  factory UserSettingsModel.empty() {
    return UserSettingsModel(topics: {}, data: {}, password: '');
  }

  /// Create user-setting document for the first time with time and password.
  Future<UserSettingsModel> create() async {
    await userSettingsDoc.set({
      'timestamp': ServerValue.timestamp,
      'password': getRandomString(),
    });
    return this.get();
  }

  /// Generate new password for the user.
  ///
  /// Note, this should be called only if the user has no password, yet.
  Future<void> generatePassword() {
    return userSettingsDoc.update({
      'password': getRandomString(),
    });
  }

  Future<UserSettingsModel> get() async {
    final snapshot = await userSettingsDoc.get();
    if (snapshot.exists) {
      return UserSettingsModel.fromJson(snapshot.value);
    } else {
      return UserSettingsModel.empty();
    }
  }

  /// Update user setting
  ///
  /// ! For topic subscription, the app must use the cloud function.
  Future<void> update(Json settings) async {
    ///
    final snapshot = await userSettingsDoc.get();
    if (snapshot.exists) {
      return userSettingsDoc.update(settings);
    } else {
      return userSettingsDoc.set(settings);
    }
  }

  /// Returns the value of the key
  value(String key) {
    return data[key];
  }
}
