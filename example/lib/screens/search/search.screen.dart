import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostListScreenV2 extends StatefulWidget {
  PostListScreenV2({required this.arguments, Key? key}) : super(key: key);

  static const String routeName = '/search';
  final Map arguments;

  @override
  _PostListScreenV2State createState() => _PostListScreenV2State();
}

class _PostListScreenV2State extends State<PostListScreenV2> {
  final searchService = SearchService.instance;

  final searchEditController = TextEditingController();

  final scrollController = ScrollController();

  bool loading = false;

  bool get atBottom {
    return scrollController.offset > (scrollController.position.maxScrollExtent - 300);
  }

  @override
  void initState() {
    super.initState();

    searchService.uid = widget.arguments['uid'] ?? '';
    searchService.index = widget.arguments['index'] ?? 'posts-and-comments';
    searchService.category = widget.arguments['category'] ?? '';
    searchService.searchKey = widget.arguments['searchKey'] ?? '';
    searchEditController.text = searchService.searchKey;

    searchService.limit = 10;
    search();

    scrollController.addListener(() {
      if (atBottom) {
        search();
      }
    });
  }

  @override
  void dispose() {
    searchService.resetFilters();
    searchService.resetListAndPagination(limit: 4);
    scrollController.dispose();
    super.dispose();
  }

  search() async {
    if (loading) return;
    if (mounted) setState(() => loading = true);
    try {
      await searchService.search();
    } catch (e) {
      error(e);
    }
    if (mounted) setState(() => loading = false);
  }

  searchUserPosts(String _uid) {
    if (searchService.uid == _uid) return;
    searchService.uid = _uid;
    resetAndSearch();
  }

  searchCategoryPosts(String _category) {
    if (searchService.category == _category) return;
    searchService.category = _category;
    resetAndSearch();
  }

  searchKeyword(String _keyword) {
    searchService.searchKey = _keyword;
    resetAndSearch();
  }

  searchIndex(String index) {
    searchService.index = index;
    resetAndSearch();
  }

  resetAndSearch() {
    searchService.resetListAndPagination(limit: 4);
    search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Screen'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Current Index: ${searchService.index}'),
            Text('Current Search Params'),
            SizedBox(height: 8),
            Text('  UID: ${searchService.uid}'),
            Text('  Category: ${searchService.category}'),
            Text('  Search Key: ${searchService.searchKey}'),
            Divider(),
            Wrap(
              children: [
                ElevatedButton(
                  onPressed: () => searchIndex('posts-and-comments'),
                  child: Text('Post and Comments'),
                ),
                SizedBox(width: 10),
                ElevatedButton(onPressed: () => searchIndex('posts'), child: Text('Posts')),
                SizedBox(width: 10),
                ElevatedButton(onPressed: () => searchIndex('comments'), child: Text('Comments')),
              ],
            ),
            Wrap(
              children: [
                ElevatedButton(onPressed: () => searchUserPosts(''), child: Text('All Users')),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => searchUserPosts('user_aaa'),
                  child: Text('User A'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => searchUserPosts('user_bbb'),
                  child: Text('User B'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => searchUserPosts('user_ccc'),
                  child: Text('User C'),
                ),
              ],
            ),
            if (searchService.index != 'comments')
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () => searchCategoryPosts(''),
                    child: Text('All Category'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => searchCategoryPosts('update-test'),
                    child: Text('Update Test'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => searchCategoryPosts('qna'),
                    child: Text('QnA'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => searchCategoryPosts('discussion'),
                    child: Text('Discussion'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => searchCategoryPosts('job'),
                    child: Text('Job'),
                  ),
                ],
              ),
            TextField(
              onChanged: searchKeyword,
              decoration: InputDecoration(hintText: 'Search ...'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                separatorBuilder: (c, i) => Divider(),
                itemCount: searchService.resultList.length,
                controller: scrollController,
                itemBuilder: (c, i) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text("ID: ${searchService.resultList[i].toString()}"),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (searchService.resultList.isEmpty && !loading)
              Center(child: Text('NO POSTS FOUND.')),
            if (loading) Center(child: CircularProgressIndicator())
          ],
        ),
      ),
    );
  }
}
