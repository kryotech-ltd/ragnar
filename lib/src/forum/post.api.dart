import 'package:dio/dio.dart';
import 'package:fireflutter/fireflutter.dart';

/// PostApi
///
/// It handles the restful api call from firebase cloud functions
class PostApi {
  static PostApi? _instance;
  static PostApi get instance {
    _instance ??= PostApi();
    return _instance!;
  }

  Future create({
    required String category,
    String? title,
    String? content,
    Map<String, dynamic> extra = const {},
  }) async {
    if (UserService.instance.notSignIn) throw ERROR_NOT_SIGN_IN;
    final dio = Dio();
    final data = {
      'title': title ?? '',
      'content': content ?? '',
      ...extra,
    };
    print('data; $data');
    try {
      var response = await dio.post(
        'http://www.goog0002le.com',
        data: data,
      );

      /// 여기서 부터, 챨스와 에이스의 일을 확인하고, 서버에 publish 를 한다. 그리고, 서버에 글 작성하는 테스트를 한다.
    } on DioError catch (e) {
      throw e.message;
    }
  }
}
