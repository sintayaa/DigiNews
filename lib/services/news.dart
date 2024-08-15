import 'dart:convert';

import 'package:diginews/models/article_model.dart';
import 'package:http/http.dart' as http;

class News {
  List<ArticleModel> news = [];

  Future<void> getNews() async {
    String url = "https://the-lazy-media-api.vercel.app/api/tech?page=1";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        news = jsonData
            .where((element) =>
                element["thumb"] != null && element['desc'] != null)
            .map((element) => ArticleModel(
                  title: element["title"],
                  thumb: element["thumb"],
                  author: element["author"],
                  tag: element["tag"],
                  time: element["time"],
                  desc: element["desc"],
                  key: element["key"],
                ))
            .toList();
      } else {
        print('Failed to load news with status code: ${response.statusCode}');
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Error occurred: $e');
    }
  }

  Future<void> searchNews(String query) async {
    try {
      final response = await http.get(Uri.parse(
          'https://the-lazy-media-api.vercel.app/api/search?search=$query'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        news = data
            .where((element) =>
                element["thumb"] != null && element['desc'] != null)
            .map((json) => ArticleModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to search news');
      }
    } catch (e) {
      print('Search failed: $e');
      throw Exception('Search failed: $e');
    }
  }
}
