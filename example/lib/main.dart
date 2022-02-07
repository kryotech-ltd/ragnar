// import 'package:fe/screens/chat/chat.room.screen.dart';
// import 'dart:async';

import 'dart:async';

import 'package:extended/extended.dart';
import 'package:fe/screens/admin/admin.screen.dart';
import 'package:fe/screens/admin/category.screen.dart';
import 'package:fe/screens/admin/report.screen.dart';
import 'package:fe/screens/forum/forum.list.screen.dart';
import 'package:fe/screens/forum/post.form.screen.dart';
import 'package:fe/service/app.controller.dart';
import 'package:fe/service/global.keys.dart';
import 'package:fe/service/route.names.dart';
import 'package:fe/screens/chat/chat.room.screen.dart';
import 'package:fe/screens/chat/chat.rooms.blocked.screen.dart';
import 'package:fe/screens/chat/chat.rooms.screen.dart';
import 'package:fe/screens/email_verification/email_verification.screen.dart';
import 'package:fe/screens/friend_map/friend_map.screen.dart';
import 'package:fe/screens/help/help.screen.dart';
import 'package:fe/screens/home/home.screen.dart';
import 'package:fe/screens/phone_sign_in/phone_sign_in.screen.dart';
import 'package:fe/screens/phone_sign_in/sms_code.screen.dart';
import 'package:fe/screens/phone_sign_in_ui/phone_sign_in_ui.screen.dart';
import 'package:fe/screens/phone_sign_in_ui/sms_code_ui.screen.dart';
import 'package:fe/screens/profile/profile.screen.dart';
import 'package:fe/screens/reminder/reminder.edit.screen.dart';
import 'package:fe/widgets/sign_in.widget.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MainApp(
    initialLink: await DynamicLinkService.instance.initialLink,
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({required this.initialLink, Key? key}) : super(key: key);
  final PendingDynamicLinkData? initialLink;
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final AppController _appController = AppController();
  @override
  void initState() {
    super.initState();
    Get.put(_appController);

    /// Instantiate UserService & see debug print message
    if (UserService.instance.user.isAdmin) {
      print('The user is admin...');
    }

    PresenceService.instance.activate(
      onError: (e) => debugPrint('--> Presence error: $e'),
    );

    // Timer(const Duration(milliseconds: 200), () => Get.toNamed('/email-verify'));
    // Timer(const Duration(milliseconds: 200), AppController.of.openCategory);
    // Timer(const Duration(milliseconds: 200),
    //     () => AppController.of.openForumList(category: 'qna'));

    // Open qna & open first post
    Timer(const Duration(milliseconds: 100), () async {
      AppController.of.openForumList(category: 'qna');

      /// wait
      await Future.delayed(Duration(milliseconds: 200));
    });

    /// Dynamic links for terminated app.
    if (widget.initialLink != null) {
      final Uri deepLink = widget.initialLink!.link;
      // Example of using the dynamic link to push the user to a different screen

      /// If you do alert too early, it may not appear on screen.
      WidgetsBinding.instance?.addPostFrameCallback((dr) {
        alert('Terminated app',
            'Got dynamic link event. deepLink.path; ${deepLink.path},  ${deepLink.queryParametersAll}');
        // Get.toNamed(deepLink.path, arguments: deepLink.queryParameters);
      });
    }

    ///
    DynamicLinkService.instance.listen((Uri? deepLink) {
      alert('Background 2',
          'Dyanmic Link Event on background(or foreground). deepLink.path; ${deepLink?.path}, ${deepLink?.queryParametersAll}');
    });

    /// Listen to FriendMap
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        /// Re-init for listening the login user (when account changed)
        InformService.instance.init(callback: (data) {
          if (data['type'] == 'FriendMap') {
            /// If it's a freind map request, then open friend map screen.
            Get.toNamed('/friend-map', arguments: {
              'latitude': data['latitude'],
              'longitude': data['longitude'],
            });
          }
        });
      } else {
        InformService.instance.dispose();
      }
    });

    /// Listen to reminder
    ///
    /// Delay 3 seconds. This is just to display the reminder dialog 3 seconds
    /// after the app boots. No big deal here.
    Timer(const Duration(seconds: 3), () {
      /// Listen to the reminder update event.
      ReminderService.instance.init(onReminder: (reminder) {
        /// Display the reminder using default dialog UI. You may copy the code
        /// and customize by yourself.
        ReminderService.instance.display(
          context: navigatorKey.currentContext!,
          data: reminder,
          onLinkPressed: (page, arguments) {
            Get.toNamed(page, arguments: arguments);
          },
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    PresenceService.instance.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: RouteNames.home,
      getPages: [
        GetPage(name: RouteNames.home, page: () => const HomeScreen()),
        GetPage(
          name: '/sign-in',
          page: () => const SignInWidget(),
        ),
        GetPage(name: '/phone-sign-in', page: () => const PhoneSignInScreen()),
        GetPage(name: '/sms-code', page: () => const SmsCodeScreen()),
        GetPage(name: '/phone-sign-in-ui', page: () => const PhoneSignInUIScreen()),
        GetPage(name: '/sms-code-ui', page: () => const SmsCodeUIScreen()),
        GetPage(name: '/help', page: () => const HelpScreen()),
        GetPage(
          name: RouteNames.profile,
          page: () => ProfileScreen(
            key: profileScreenKey,
          ),
        ),
        GetPage(name: RouteNames.forumList, page: () => ForumListScreen()),
        GetPage(name: RouteNames.postForm, page: () => PostFormScreen()),
        GetPage(name: RouteNames.admin, page: () => AdminScreen()),
        GetPage(name: RouteNames.category, page: () => CategoryScreen()),
        GetPage(name: '/chat-room-screen', page: () => const ChatRoomScreen()),
        GetPage(
          name: '/chat-rooms-screen',
          page: () => const ChatRoomsScreen(),
        ),
        GetPage(
          name: '/chat-rooms-blocked-screen',
          page: () => const ChatRoomsBlockedScreen(),
        ),
        GetPage(name: '/friend-map', page: () => const FriendMapScreen()),
        GetPage(name: '/reminder-edit', page: () => ReminderEditScreen()),
        GetPage(name: RouteNames.report, page: () => ReportScreen()),
        GetPage(name: '/email-verify', page: () => const EmailVerificationScreen())
      ],
    );
  }
}
