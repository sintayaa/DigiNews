import 'dart:convert';

import 'package:diginews/models/show_category.dart';
import 'package:http/http.dart' as http;

class ShowCategoryNews {
  List<ShowCategoryModel> categories = [];

  Future<void> getCategoriesNews(String category) async {
    String url = "https://the-lazy-media-api.vercel.app/api/tech/$category?";

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        jsonData.forEach((element) {
          if (element["thumb"] != null && element['desc'] != null) {
            ShowCategoryModel categoryModel = ShowCategoryModel(
              title: element["title"],
              thumb: element["thumb"],
              author: element["author"],
              tag: element["tag"],
              time: element["time"],
              desc: element["desc"],
              key: element["key"],
            );
            categories.add(categoryModel);
          }
        });
      } else {
        print('Failed to load news with status code: ${response.statusCode}');
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }
}
