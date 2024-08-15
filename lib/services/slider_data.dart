import 'dart:convert';

import 'package:diginews/models/slider_model.dart';
import 'package:http/http.dart' as http;

class Sliders {
  List<sliderModel> sliders = [];

  Future<void> getSlider() async {
    String url = "https://the-lazy-media-api.vercel.app/api/tech/news?page=1";

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        jsonData.forEach((element) {
          if (element["thumb"] != null && element['desc'] != null) {
            sliderModel slidermodel = sliderModel(
              title: element["title"],
              thumb: element["thumb"],
              author: element["author"],
              tag: element["tag"],
              time: element["time"],
              desc: element["desc"],
              key: element["key"],
            );
            sliders.add(slidermodel);
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
