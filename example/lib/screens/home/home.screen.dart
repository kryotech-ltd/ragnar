import 'package:example/screens/home/home.auth.dart';
import 'package:example/screens/home/home.menu.dart';
import 'package:example/widgets/layout/layout.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      isHome: true,
      title: const Text(
        'kosomi',
        style: TextStyle(color: Colors.blue),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
          color: Colors.black,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.mark_chat_unread_outlined),
          color: Colors.black,
        ),
      ],
      bottom: const HomeMenu(height: 28),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: HomeAuth(
          child: ListView.builder(
            itemCount: 100,
            itemBuilder: (c, i) {
              final child = Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(i.toString()),
              );

              return child;
            },
          ),
        ),
      ),
    );
  }
}
