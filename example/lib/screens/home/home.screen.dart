import 'dart:async';

import 'package:extended/extended.dart';
import 'package:fe/service/app.controller.dart';
import 'package:fe/service/config.dart';
import 'package:fe/service/global.keys.dart';
import 'package:fe/widgets/test.user.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) ChatService.instance.countNewMessages();
    });
    // ChatService.instance.newMessages.listen((value) => debugPrint('new messages: $value'));
  }

  final nickname = TextEditingController();
  String uploadUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    User user = snapshot.data!;
                    return Column(
                      children: [
                        Text(
                          'You have logged in as ${user.email ?? user.phoneNumber}',
                        ),
                        Text('User Email: ${user.email}'),
                        MyDoc(
                          builder: (UserModel u) {
                            return Wrap(
                              children: [
                                Text('Profile name: ${u.nickname}'),
                                Text(', photo: ${u.photoUrl}'),
                              ],
                            );
                          },
                        ),
                        Text('UID: ${FirebaseAuth.instance.currentUser?.uid}'),
                        MyDoc(builder: (_user) {
                          if (_user.isAdmin)
                            return const Text(
                              'You are an admin',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            );
                          else
                            return SizedBox();
                        }),
                        Wrap(
                          children: [
                            const EmailButton(),
                            ElevatedButton(
                                onPressed: AppController.of.openProfile,
                                child: const Text('Profile')),
                            ElevatedButton(
                              onPressed: () => FirebaseAuth.instance.signOut(),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        )
                      ],
                    );
                  } else {
                    return Wrap(
                      children: [
                        ElevatedButton(
                          child: const Text('Sign-In'),
                          onPressed: () {
                            Get.toNamed('/sign-in');
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Phone Sign-In'),
                          onPressed: () {
                            Get.toNamed('/phone-sign-in');
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Phone Sign-In UI'),
                          onPressed: () {
                            Get.toNamed('/phone-sign-in-ui');
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
              const Divider(),
              const Text('Test users;'),
              Wrap(
                alignment: WrapAlignment.spaceAround,
                children: Config.testUsers.values
                    .map(
                      (v) => TestUser(
                        email: v['email']!,
                        name: v['name']!,
                        uid: v['uid']!,
                      ),
                    )
                    .toList(),
              ),
              Wrap(
                children: [
                  ElevatedButton(onPressed: () => Get.toNamed('/help'), child: const Text('Help')),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/chat-rooms-screen'),
                    child: const Text('Chat Room List'),
                  ),
                  TextButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('Chat'),
                        ChatBadge(),
                      ],
                    ),
                    onPressed: () {
                      Get.toNamed('/chat-rooms-screen');
                    },
                  ),
                  TextButton(
                      onPressed: () async {
                        for (int i = 0; i < 10; i++) {
                          setState(() {});
                          await Future.delayed(const Duration(milliseconds: 500));
                        }
                      },
                      child: const Text('setState() 10 times')),
                  const ElevatedButton(
                    onPressed: getFirestoreIndexLinks,
                    child: Text('Get firestore index links'),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/friend-map'),
                    child: const Text('Friend Map'),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/reminder-edit'),
                    child: const Text('Reminder Management Screen'),
                  ),
                ],
              ),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () => AppController.of.openForumList(category: 'qna'),
                    child: const Text('QnA'),
                  ),
                  // if (Platform.isAndroid)
                  //   ElevatedButton(
                  //     onPressed: () {
                  //       MessagingService.instance.sendMessage(
                  //         to: '/topics/post_qna',
                  //         data: {
                  //           "click_action": "FLUTTER_NOTIFICATION_CLICK",
                  //         },
                  //       );
                  //     },
                  //     child: const Text('Test QnA Notification'),
                  //   ),
                  ElevatedButton(
                    onPressed: () => AppController.of.openForumList(category: 'discussion'),
                    child: const Text('Discussion'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppController.of.openForumList(category: 'buyandsell'),
                    child: const Text('Buy & Sell'),
                  ),
                ],
              ),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        uploadUrl = await StorageService.instance.pickUpload(
                          source: ImageSource.gallery,
                          onProgress: print,
                        );
                        alert('Success', 'Image uploaded successfully');
                      } catch (e) {
                        debugPrint('Upload exception; $e');
                        error(e);
                      }
                    },
                    child: const Text('Upload Image'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await StorageService.instance
                            .ref(uploadUrl)
                            .updateMetadata(SettableMetadata(customMetadata: {
                              'updated': 'yes',
                            }));
                        alert('Success', 'Uploaded file updated');
                      } catch (e) {
                        debugPrint('Update exception; $e');
                        error(e);
                      }
                    },
                    child: const Text('Update Image'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await StorageService.instance.delete(uploadUrl);
                        alert('Success', 'Uploaded file deleted!');
                      } catch (e) {
                        debugPrint('Delete exception; $e');
                        error(e);
                      }
                    },
                    child: const Text('Delete Image'),
                  ),
                ],
              ),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: testOnUser,
                    child: const Text('User Test'),
                  ),
                  ElevatedButton(
                    onPressed: testOnReport,
                    child: const Text('Test on report'),
                  ),
                  ElevatedButton(
                    onPressed: testOnForum,
                    child: const Text('Test on forum'),
                  ),
                ],
              ),
              Divider(color: Colors.blue),
              AdminButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Test user profile page
  ///
  /// To use the screen state.
  /// - Add GlobalKey on the profile screen widget.
  ///   The state must be public and declared in global.keys.dart
  ///   And pass it to route declaration in main.dart
  testOnUser() async {
    // Get test service instance
    final ts = TestService.instance;

    // Sign out to test error
    await FirebaseAuth.instance.signOut();

    // openProfile() throws an error if user is not signed in.
    await waitUntil(() => UserService.instance.user.signedOut);
    await ts.expectFailure(AppController.of.openProfile(), "sign in before open profile screen.");

    /// user signed in
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: Config.testUsers['apple']!['email']!, password: '12345a');

    /// waitl until user sign-in completes
    await waitUntil(() => UserService.instance.user.signedIn);

    /// Open profile screen
    AppController.of.openProfile();

    /// wait
    await Future.delayed(Duration(milliseconds: 200));

    /// Update nickname using the profile screen state
    final nickname = DateTime.now().toString().split('.').last;

    /// Update nickname on screen immediately.
    profileScreenKey.currentState?.nickname.text = nickname;

    /// Update nickname on firestore
    profileScreenKey.currentState?.updateNickname(nickname);

    /// wait until nickname changes
    await waitUntil(() => UserService.instance.user.nickname == nickname);

    ///
    profileScreenKey.currentState?.setState(() {});
    ts.testSuccess('Test success on updating nickname');

    /// Update photoUrl using the profile screen state
    await Future.delayed(Duration(milliseconds: 200));
    final photoUrl = 'photo url: $nickname';
    profileScreenKey.currentState?.photoUrl.text = photoUrl;
    profileScreenKey.currentState?.updatePhotoUrl(photoUrl);
    await waitUntil(() => UserService.instance.user.photoUrl == photoUrl);
    profileScreenKey.currentState?.setState(() {});
    ts.testSuccess('Test success on updating photoUrl');

    await Future.delayed(Duration(milliseconds: 300));

    /// To go back to home, it must call `Get.back()`.
    /// If it calls `AppController.of.openHome();`,
    /// then `Duplicate GlobalKey detected in widget tree` error will happen
    Get.back();
  }

  testOnReport() async {
    // final ts = TestService.instance;
    // final rs = ReportService.instance;

    // ts.reset();
    // await ts.expectSuccess(rs.report(
    //   target: 'post',
    //   targetId: '111',
    //   reporterUid: 'aaa',
    //   reporterDisplayName: 'User A',
    //   reporteeUid: 'bbb',
    //   reporteeDisplayName: 'User B',
    // ));

    // await ts.expectFailure(rs.report(
    //   target: 'post',
    //   targetId: '111',
    //   reporterUid: 'aaa',
    //   reporterDisplayName: 'User A',
    //   reporteeUid: 'bbb',
    //   reporteeDisplayName: 'User B',
    // ));
  }

  testOnForum() async {
    // final tag = DateTime.now().toString().split('.').last;
    // PostService.instance.create(title: 'title-$tag', content: 'content-$tag');
  }
}

// class ReText extends StatelessWidget {
//   const ReText({
//     Key? key,
//     required this.i,
//     required this.until,
//   }) : super(key: key);

//   final int i;
//   final int until;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text('No, $i'),
//         if (i < until)
//           ReText(
//             i: i + 1,
//             until: until,
//           )
//       ],
//     );
//   }
// }

class AdminButton extends StatelessWidget {
  AdminButton({
    Key? key,
  }) : super(key: key);

  final count = {'count': 0};

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        int c = count['count']!;
        c = c + 1;
        count['count'] = c;
      },
      onLongPress: () {
        if (count['count']! > 3) {
          AppController.of.openAdmin();
        }
      },
      child: const Text('Admin Screen - 3 tap & long press'),
    );
  }
}

class EmailButton extends StatefulWidget {
  const EmailButton({
    Key? key,
  }) : super(key: key);

  @override
  State<EmailButton> createState() => _EmailButtonState();
}

class _EmailButtonState extends State<EmailButton> {
  bool verified = false;

  @override
  void initState() {
    super.initState();

    /// reload and check if verified
    FirebaseAuth.instance.currentUser!.reload().then((value) {
      setState(() {
        verified = FirebaseAuth.instance.currentUser!.emailVerified;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Get.toNamed('/email-verify'),
      child: Text(
        '${verified ? 'Update' : 'Verify'} Email',
      ),
    );
  }
}
