import 'dart:async';
import 'dart:io';
// import 'package:rxdart/subjects.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../fireflutter.dart';
// import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService with FirestoreMixin, DatabaseMixin {
  static MessagingService? _instance;
  static MessagingService get instance {
    _instance ??= MessagingService();
    return _instance!;
  }

  // final BehaviorSubject<bool> permissionGranted = BehaviorSubject.seeded(false);

  MessagingService() {
    // debugPrint('MessagingService::constructor');
  }

  Function(RemoteMessage)? onForegroundMessage;
  Function(RemoteMessage)? onMessageOpenedFromTermiated;
  Function(RemoteMessage)? onMessageOpenedFromBackground;
  Function? onNotificationPermissionDenied;
  Function? onNotificationPermissionNotDetermined;
  String token = '';
  String defaultTopic = 'defaultTopic';

  // StreamSubscription? sub;
  init({
    Future<void> Function(RemoteMessage)? onBackgroundMessage,
    Function(RemoteMessage)? onForegroundMessage,
    Function(RemoteMessage)? onMessageOpenedFromTermiated,
    Function(RemoteMessage)? onMessageOpenedFromBackground,
    Function? onNotificationPermissionDenied,
    Function? onNotificationPermissionNotDetermined,
  }) {
    if (onBackgroundMessage != null) {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    }

    this.onForegroundMessage = onForegroundMessage;
    this.onMessageOpenedFromTermiated = onMessageOpenedFromTermiated;
    this.onMessageOpenedFromBackground = onMessageOpenedFromBackground;
    this.onNotificationPermissionDenied = onNotificationPermissionDenied;
    this.onNotificationPermissionNotDetermined = onNotificationPermissionNotDetermined;
    _init();
  }

  /// Initialize Messaging
  _init() async {
    ///
    FirebaseAuth.instance.authStateChanges().listen((u) => _updateToken());

    /// Permission request for iOS only. For Android, the permission is granted by default.
    if (Platform.isIOS) {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // print('User granted permission: ${settings.authorizationStatus}');

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          break;
        case AuthorizationStatus.denied:
          if (onNotificationPermissionDenied != null) onNotificationPermissionDenied!();
          break;
        case AuthorizationStatus.notDetermined:
          if (onNotificationPermissionNotDetermined != null)
            onNotificationPermissionNotDetermined!();
          break;
        case AuthorizationStatus.provisional:
          break;
      }
    }

    // Get the token each time the application loads and save it to database.
    try {
      token = (await FirebaseMessaging.instance.getToken())!;
    } catch (e) {}

    /// Permission is granted hereby.
    // permissionGranted.add(true);

    // Handler, when app is on Foreground.
    if (onForegroundMessage != null) FirebaseMessaging.onMessage.listen(onForegroundMessage!);

    // Check if app is opened from terminated state and get message data.
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (onMessageOpenedFromTermiated != null) onMessageOpenedFromTermiated!(initialMessage);
    }

    // Check if the app is opened from the background state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (onMessageOpenedFromBackground != null) onMessageOpenedFromBackground!(message);
    });

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(_updateToken);

    _updateToken(token);
  }

  /// Create or update token info
  ///
  /// User may not signed in. That is why we cannot put this code in user model.
  /// must be called when user signIn or when tokenRefresh
  /// skip if user is not signIn. _updateToken() will registered the device to default topic
  _updateToken([String? token]) {
    if (token == null) token = this.token;
    if (token == '') return;

    subscribeToDefaultTopic();

    if (UserService.instance.notSignedIn) return;
    FunctionsApi.instance.request('updateToken', data: {'token': token}, addAuth: true);

    // sub?.cancel();
    // sub = UserService.instance.changes.listen((user) {
    //   print(user);
    //   if (user.registeredAt > 0) {
    //     FunctionsApi.instance.request('updateToken', data: {'token': token}, addAuth: true);
    //     sub.cancel();
    //   }
    // });
  }

  // subcribe to topic only when token is created or refresh
  subscribeToDefaultTopic() async {
    // subscribe device to default topic once.
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('isSubscribeToDefaultTopic') != this.token) {
      FirebaseMessaging.instance.subscribeToTopic(defaultTopic);
      prefs.setString('isSubscribeToDefaultTopic', this.token);
    }
  }

  /// Updates the subscriptions (subscribe or unsubscribe)
  Future<dynamic> updateSubscription(String topic, String type, bool subscribe) async {
    if (subscribe) {
      await UserSettingService.instance.subscribe(topic, type);
    } else {
      await UserSettingService.instance.unsubscribe(topic, type);
    }
  }

  Future<dynamic> enableAllNotification({String? group, String? type}) async {
    return FunctionsApi.instance
        .request('enableAllNotification', data: {'group': group, 'type': type}, addAuth: true);
  }

  Future<dynamic> disableAllNotification({String? group, String? type}) async {
    return FunctionsApi.instance
        .request('disableAllNotification', data: {'group': group, 'type': type}, addAuth: true);
  }

  toggleSubscription(String topic, String type) {
    return updateSubscription(
      topic,
      type,
      !UserSettingService.instance.hasSubscription(topic, type),
    );
  }

  subscribeTopic(String topic, String type) async {
    return FunctionsApi.instance
        .request('subscribeTopic', data: {'topic': topic, 'type': type}, addAuth: true);
  }

  unsubscribeTopic(String topic, String type) async {
    return FunctionsApi.instance
        .request('unsubscribeTopic', data: {'topic': topic, 'type': type}, addAuth: true);
  }

  topicOn(String topic, String type) async {
    return FunctionsApi.instance
        .request('topicOn', data: {'topic': topic, 'type': type}, addAuth: true);
  }

  topicOff(String topic, String type) async {
    return FunctionsApi.instance
        .request('topicOff', data: {'topic': topic, 'type': type}, addAuth: true);
  }

  toggleTopic(String topic, String type) async {
    return FunctionsApi.instance
        .request('toggleTopic', data: {topic: topic, type: type}, addAuth: true);
  }

  sendMessage({
    String? to,
    Map<String, String>? data,
    String? collapseKey,
    String? messageId,
    String? messageType,
    int? ttl,
  }) {
    return FirebaseMessaging.instance.sendMessage(
      to: to,
      data: data,
      collapseKey: collapseKey,
      messageId: messageId,
      messageType: messageType,
    );
  }
}
