import 'package:extended/extended.dart';
import 'package:fe/screens/forum/forum.mixin.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class JobViewScreen extends StatefulWidget {
  const JobViewScreen({required this.arguments, Key? key}) : super(key: key);
  static final String routeName = '/jobView';

  final Map arguments;

  @override
  State<JobViewScreen> createState() => _JobViewScreenState();
}

class _JobViewScreenState extends State<JobViewScreen>
    with FirestoreMixin, ForumMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job View'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            JobEditForm(
              onError: error,
              onCreated: (id) => alert('Job opening created!', '$id'),
              onUpdated: (id) => alert('Job opening updated!', '$id'),
              job: widget.arguments['job'],
            ),
            space2xl,
          ],
        ),
      )),
    );
  }
}
