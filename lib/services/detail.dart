import 'dart:convert';

import 'package:diginews/models/detail_model.dart';
import 'package:http/http.dart' as http;

class NewsService {
  final String baseUrl;

  NewsService({required this.baseUrl});

  Future<NewsDetail> fetchNewsDetail(String key) async {
    final response = await http.get(
        Uri.parse('https://the-lazy-media-api.vercel.app/api/detail/$key'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return NewsDetail.fromJson(json['results']);
    } else {
      throw Exception('Failed to load news detail');
    }
  }
}
